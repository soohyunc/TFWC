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
set tcp [new Agent/TCP/Sack1]
$ns attach-agent $n1 $tcp

# set TFWC agent
set tfwc [new Agent/TFWC]
$ns attach-agent $n1 $tfwc

# set TCP Sink agent
set tcp_sink [new Agent/TCPSink/Sack1]
$ns attach-agent $n3 $tcp_sink

# set TFWC Sink agent
set tfwc_sink [new Agent/TFWCSink]
$ns attach-agent $n3 $tfwc_sink

# creat FTP from n1 to n3
set tcp_ftp [new Application/FTP]
set tfwc_ftp [new Application/FTP]
$tcp_ftp attach-agent $tcp
$tfwc_ftp attach-agent $tfwc

$ns at 0.3 "$tcp_ftp start"
$ns at 0.3 "$tfwc_ftp start"
$ns connect $tcp $tcp_sink
$ns connect $tfwc $tfwc_sink

$ns at 250.0 "$ns detach-agent $n1 $tcp; $ns detach-agent $n3 $tcp_sink"
$ns at 250.0 "$ns detach-agent $n1 $tfwc; $ns detach-agent $n3 $tfwc_sink"

$ns trace-queue $n2 $n3 $queue_out

# simulation process
$ns at 5000.0 "finish"
proc finish {} {
		global ns output nam_out queue_out
		$ns flush-trace
		close $output
		close $nam_out
		close $queue_out

	#exec nam out.nam &

	exec perl ../../ns-2.28/bin/set_flow_id -s out.tr
	exec perl ../../ns-2.28/bin/getrc -s 2 -d 3 < out.tr > foo

	exec awk -f test_tcp_seq.awk foo
	exec awk -f test_tfwc_seq.awk foo

	exec perl ../../ns-2.28/bin/raw2xg -s 0.01 -m 90 < test_tcp_seq.temp > test_tcp_seq.rands
	exec perl ../../ns-2.28/bin/raw2xg -s 0.01 -m 90 < test_tfwc_seq.temp > test_tfwc_seq.rands

	exec xgraph -bb -tk -nl -m -x time -y packets -t "SACK Test" test_tcp_seq.rands &
	exec xgraph -bb -tk -nl -m -x time -y packets -t "TFWC Test" test_tfwc_seq.rands &

	grep now temp0101 > tcp_cwnd.tr
	awk -f tcp_cwnd.awk tcp_cwnd.tr
	grep cwnd_ temp0101 > tfwc_cwnd.tr
	awk -f tfwc_cwnd.awk tfwc_cwnd.tr

	exec xgraph -m -x time -y cwnd -t "SACK/TFWC CWND Dynamics" tcp_cwnd.rands tfwc_cwnd.rands &
	exec perl ../../../Chart-Graph-2/graph.pl -i "tcp_cwnd.rands,tfwc_cwnd.rands" -x "time" -y "cwnd" -t "SACK/TFWC CWND Dynamics" -o ./graph/test_sack_cwnd_0101.png -s linespoints &

	exec awk -f test_tcp_thru.awk queue.tr
	exec awk -f test_tfwc_thru.awk queue.tr
	exec xgraph -P -x time -y rate -t "SACK/TFWC Test" test_tcp_thru.rands test_tfwc_thru.rands &
	exec perl ../../../Chart-Graph-2/graph.pl -i "test_tcp_thru.rands,test_tfwc_thru.rands" -x "time" -y "rate" -t "SACK/TFWC Thruput Test" -o ./graph/test_sack_thru_0101.png -s linespoints &

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
