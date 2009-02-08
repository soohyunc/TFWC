#Create scheduler
set ns [new Simulator]

$ns color 0 Red
$ns color 1 Blue
$ns color 2 Yellow

#Turn on tracing
set nf [open out.nam w]
$ns namtrace-all $nf

#create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#create links
$ns duplex-link $n0 $n1 5Mb 2ms DropTail
$ns duplex-link $n1 $n2 1.5Mb 10ms RED
$ns duplex-link $n2 $n3 5Mb 2ms DropTail
$ns queue-limit $n1 $n2 25
$ns queue-limit $n2 $n1 25

set redq [[$ns link $n1 $n2] queue]
$redq set setbit_ true

set dccp1 [new Agent/DCCP/TCPlike]
set dccp2 [new Agent/DCCP/TCPlike]
$dccp1 set fid_ 1
$dccp2 set fid_ 1
$ns attach-agent $n0 $dccp1
$ns attach-agent $n3 $dccp2

set ftp1 [new Application/FTP]
$ftp1 set packetSize_ 500
$ftp1 attach-agent $dccp1

set traffic [new Application/Traffic/Exponential]
$traffic set packetSize_ 500
$traffic set burst_time_ 0.4s
$traffic set idle_time_ 1s
$traffic set rate_ 1.4Mb
$traffic attach-agent $dccp2

$ns connect $dccp1 $dccp2

$ns at 0.1 "init"
$ns at 0.2 "$dccp2 listen"
$ns at 0.3 "$ftp1 start"
$ns at 1.5 "$traffic start"
$ns at 30.0 "$traffic stop"
$ns at 31.0 "$ftp1 stop"
$ns at 35.0 "finish"

proc init {} {
    global dccp1 dccp2

    $dccp1 set q_scheme_ 1
    $dccp1 set allow_mult_neg_ 1
    $dccp2 set q_scheme_ 1
    $dccp2 set allow_mult_neg_ 1

    $dccp1 reset
    $dccp2 reset
}

proc finish {} {
	global ns nf 
	$ns flush-trace
	close $nf
	puts "Running nam"
	exec nam out.nam &
	exit 0
}
$ns run

