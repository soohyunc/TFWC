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

#create links
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns queue-limit $n0 $n1 25
$ns queue-limit $n1 $n0 25

set dccp1 [new Agent/DCCP/TFRC]
set dccp2 [new Agent/DCCP/TFRC]
$dccp1 set fid_ 1
$dccp2 set fid_ 1
$ns attach-agent $n0 $dccp1
$ns attach-agent $n1 $dccp2

set ftp1 [new Application/FTP]
$ftp1 set packetSize_ 500
$dccp1 set packetSize_ 500
$ftp1 attach-agent $dccp1

$ns connect $dccp1 $dccp2

# Add agent traces and variable trace
$dccp1 set trace_all_oneline_ false
$dccp2 set trace_all_oneline_ false

set tf1 [open "sender.txt" w]
$dccp1 attach $tf1
set tf2 [open "recevier.txt" w]
$dccp2 attach $tf2
$dccp1 add-agent-trace dccp1
$dccp2 add-agent-trace dccp2
$dccp1 trace s_p_
$dccp2 trace r_p_

set em [new ErrorModel]
$em unit pkt
$em set rate_ 0.0
$em ranvar [new RandomVariable/Uniform]
$em drop-target [new Agent/Null]
$ns lossmodel $em $n0 $n1

$ns at 0.2 "$dccp2 listen"
$ns at 0.3 "$ftp1 start"
$ns at 0.5 "$em set rate_ 0.05"
$ns at 360.74 "$ftp1 stop"
$ns at 364.0 "finish"

proc finish {} {
	global ns nf tf1 tf2
	$ns flush-trace
        close $tf1
        close $tf2
	close $nf
	puts "Running nam"
	exec nam out.nam &
	exit 0
}
$ns run

