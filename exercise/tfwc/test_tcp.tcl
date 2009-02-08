# test on TFWC sending/receiving

# creat a simulator object
set ns [new Simulator]

# file openings
set output [open out.tr w]
$ns trace-all $output

set nam_out [open out.nam w]
$ns namtrace-all $nam_out

set tcp_cwnd [open tcp_cwnd.rands w]
set queue_out [open queue.tr w]

# topology definition
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n2 5Mb 2ms DropTail orient right-down
$ns duplex-link $n1 $n2 5Mb 2ms DropTail orient right-up
$ns duplex-link $n2 $n3 0.25Mb 10ms DropTail orient right

#Queue Setting
$ns queue-limit $n2 $n3 10

# set dummy UDP agent
set udp_dummy [new Agent/UDP]
$ns attach-agent $n0 $udp_dummy

# set TCP agent
set tcp [new Agent/TCP]
$ns attach-agent $n1 $tcp

# set TFWC Sink agent
set tcp_sink [new Agent/TCPSink]
$ns attach-agent $n3 $tcp_sink

# creat FTP from n1 to n3
set ftp [new Application/FTP]
$ftp attach-agent $tcp

$ns at 0.3 "$ftp start"
$ns connect $tcp $tcp_sink

$ns at 100.0 "$ns detach-agent $n1 $tcp; $ns detach-agent $n3 $tcp_sink"

$ns trace-queue $n2 $n3 $queue_out

# simulation process
$ns at 100.0 "finish"
proc finish {} {
		global ns output nam_out queue_out
		$ns flush-trace
		close $output
		close $nam_out
		close $queue_out

	#exec nam out.nam &

	exec perl ../../ns-2.26/bin/set_flow_id -s out.tr
	exec perl ../../ns-2.26/bin/getrc -s 2 -d 3 < out.tr > foo
	exec perl ../../ns-2.26/bin/raw2xg -s 0.01 -m 90 < foo > temp.rands

	exec xgraph -bb -tk -nl -m -x time -y packets -t "TCP Test" temp.rands &
	exec awk -f test_thru.awk queue.tr
	#exec xgraph -P -x time -y rate -t "TCP Test" test_thru.rands &

	exec grep now temp.tcp > tcp_cwnd.tr
	exec awk -f tcp_cwnd.awk tcp_cwnd.tr
	exec xgraph -m -x time -y cwnd -t "TCP CWND Dynamics" tcp_cwnd.rands &

	exit 0
}

# trace TCP cwnd
proc record_cwnd {} {
	global tcp_cwnd
	global tcp

	set ns [Simulator instance]
	set now [$ns now]
	set granul 1.0

	set cwin [$tcp set cwnd_]
	puts $tcp_cwnd "$now $cwin"

	$ns at [expr $now + $granul] "record_cwnd"
}

#$ns at 0.0 "record_cwnd"
$ns run
