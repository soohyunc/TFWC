#Create scheduler
set ns [new Simulator]
set lr 0.01

source recvmon.tcl
source fsend.tcl

$ns color 0 Red
$ns color 1 Blue
$ns color 2 Yellow

#Turn on tracing
set nf [open out_tcpl_$lr.nam w]
$ns namtrace-all $nf

#create nodes
set n0 [$ns node]
set n1 [$ns node]

#create links
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns queue-limit $n0 $n1 25
$ns queue-limit $n1 $n0 25

set dccp1 [new Agent/DCCP/TCPlike]
set dccp2 [new Agent/DCCP/TCPlike]
$dccp1 set fid_ 1
$dccp2 set fid_ 1
$ns attach-agent $n0 $dccp1
$ns attach-agent $n1 $dccp2

set sender [new Application/FileSender]
$sender attach-agent $dccp1

set rm [new Application/ReceiveMonitor]
$rm openfile "flow_tcpl_$lr.txt"
$rm attach-agent $dccp2

$ns connect $dccp1 $dccp2

set em [new ErrorModel]
$em unit pkt
$em set rate_ 0
$em ranvar [new RandomVariable/Uniform]
$em drop-target [new Agent/Null]
$ns lossmodel $em $n0 $n1

$ns at 0.1 "init"
$ns at 0.11 "$rm start"
$ns at 0.11 "$sender start"
$ns at 0.2 "$dccp2 listen"
$ns at 0.3 "$sender sendfile 2000 1400"
$ns at 0.45 "$em set rate_ $lr"
$ns at 330.74 "$sender stop"
$ns at 334.0 "$rm stop"
$ns at 335.0 "finish"

proc init {} {
    global dccp1 dccp2
    $dccp1 set sb_size_ 5000
    $dccp2 set sb_size_ 5000
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


