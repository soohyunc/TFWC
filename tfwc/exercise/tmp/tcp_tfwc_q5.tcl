# test on TFWC sending/receiving

# creat a simulator object
set ns [new Simulator]

# file openings
set output [open trace/out.tr w]
$ns trace-all $output

set queue_out [open trace/out.queue w]
#set tfwc_cwnd [open trace/cwnd.rands w]

# topology definition
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n2 5Mb 2ms DropTail orient right-down
$ns duplex-link $n1 $n2 5Mb 2ms DropTail orient right-up
$ns duplex-link $n2 $n3 1.5Mb 10ms DropTail orient right

#Queue Setting
$ns queue-limit $n2 $n3 5

# set dummy UDP agent
set udp_dummy [new Agent/UDP]
$ns attach-agent $n0 $udp_dummy

#----------------------------------------------------------/
# Create 4 TCP/Sack1 and 4 TFWC Agents
#----------------------------------------------------------/
set tcp01 [new Agent/TCP/Sack1]
set tcp02 [new Agent/TCP/Sack1]
set tcp03 [new Agent/TCP/Sack1]
set tcp04 [new Agent/TCP/Sack1]

set tfwc01 [new Agent/TFWC]
set tfwc02 [new Agent/TFWC]
set tfwc03 [new Agent/TFWC]
set tfwc04 [new Agent/TFWC]

$ns attach-agent $n1 $tcp01
$ns attach-agent $n1 $tcp02
$ns attach-agent $n1 $tcp03
$ns attach-agent $n1 $tcp04

$ns attach-agent $n1 $tfwc01
$ns attach-agent $n1 $tfwc02
$ns attach-agent $n1 $tfwc03
$ns attach-agent $n1 $tfwc04

#----------------------------------------------------------/
# Create a TCP/TFWC Sink Agent
#----------------------------------------------------------/
set tcp_sink01 [new Agent/TCPSink/Sack1]
set tcp_sink02 [new Agent/TCPSink/Sack1]
set tcp_sink03 [new Agent/TCPSink/Sack1]
set tcp_sink04 [new Agent/TCPSink/Sack1]

Agent/TCP/Sack1 set window_ 100
Agent/TCP set minrto_ 0

set tfwc_sink01 [new Agent/TFWCSink]
set tfwc_sink02 [new Agent/TFWCSink]
set tfwc_sink03 [new Agent/TFWCSink]
set tfwc_sink04 [new Agent/TFWCSink]

$ns attach-agent $n3 $tcp_sink01
$ns attach-agent $n3 $tcp_sink02
$ns attach-agent $n3 $tcp_sink03
$ns attach-agent $n3 $tcp_sink04

$ns attach-agent $n3 $tfwc_sink01
$ns attach-agent $n3 $tfwc_sink02
$ns attach-agent $n3 $tfwc_sink03
$ns attach-agent $n3 $tfwc_sink04

#----------------------------------------------------------/
# Create FTPs from n1 to n3
#----------------------------------------------------------/
set ftp01 [new Application/FTP]
set ftp02 [new Application/FTP]
set ftp03 [new Application/FTP]
set ftp04 [new Application/FTP]

set ftp05 [new Application/FTP]
set ftp06 [new Application/FTP]
set ftp07 [new Application/FTP]
set ftp08 [new Application/FTP]

$ftp01 attach-agent $tcp01
$ftp02 attach-agent $tcp02
$ftp03 attach-agent $tcp03
$ftp04 attach-agent $tcp04

$ftp05 attach-agent $tfwc01
$ftp06 attach-agent $tfwc02
$ftp07 attach-agent $tfwc03
$ftp08 attach-agent $tfwc04

$ns at 0.3 "$ftp01 start"
$ns at 0.3 "$ftp02 start"
$ns at 0.3 "$ftp03 start"
$ns at 0.3 "$ftp04 start"

$ns at 1.5 "$ftp05 start"
$ns at 1.5 "$ftp06 start"
$ns at 1.5 "$ftp07 start"
$ns at 1.5 "$ftp08 start"

$ns connect $tcp01 $tcp_sink01
$ns connect $tcp02 $tcp_sink02
$ns connect $tcp03 $tcp_sink03
$ns connect $tcp04 $tcp_sink04

$ns connect $tfwc01 $tfwc_sink01
$ns connect $tfwc02 $tfwc_sink02
$ns connect $tfwc03 $tfwc_sink03
$ns connect $tfwc04 $tfwc_sink04

$ns at 800.0 "$ns detach-agent $n1 $tcp01; $ns detach-agent $n3 $tcp_sink01"
$ns at 800.0 "$ns detach-agent $n1 $tcp02; $ns detach-agent $n3 $tcp_sink02"
$ns at 800.0 "$ns detach-agent $n1 $tcp03; $ns detach-agent $n3 $tcp_sink03"
$ns at 800.0 "$ns detach-agent $n1 $tcp04; $ns detach-agent $n3 $tcp_sink04"

$ns at 800.0 "$ns detach-agent $n1 $tfwc01; $ns detach-agent $n3 $tfwc_sink01"
$ns at 800.0 "$ns detach-agent $n1 $tfwc02; $ns detach-agent $n3 $tfwc_sink02"
$ns at 800.0 "$ns detach-agent $n1 $tfwc03; $ns detach-agent $n3 $tfwc_sink03"
$ns at 800.0 "$ns detach-agent $n1 $tfwc04; $ns detach-agent $n3 $tfwc_sink04"


# Make a queue trace
$ns trace-queue $n2 $n3 $queue_out

# simulation process
$ns at 800.0 "finish"
proc finish {} {
		global ns output queue_out
		$ns flush-trace
		close $output
		close $queue_out


	exec perl ../../ns-2.28/bin/set_flow_id -s trace/out.tr
	exec perl ../../ns-2.28/bin/getrc -s 2 -d 3 < trace/out.tr > trace/foo
	exec perl ../../ns-2.28/bin/raw2xg -s 0.01 -m 90 < trace/foo > trace/all.xg

	# THRUPUT PLOT
	exec awk -f tfwc_thru.awk trace/out.queue
	exec awk -f tcp_thru.awk trace/out.queue
	exec xgraph -P -x time -y "rate (Mb/s)" -t "Aggregated Thruput (4Sack & 4TFWC) Q=5" trace/tcp_thru.xg tfwc_thru.xg &
	exec perl ../../../Chart-Graph-2/graph.pl -i "trace/tcp_thru.xg,trace/tfwc_thru.xg" -x "time" -y "rate (Mb/s)" -t "Aggregated Thruput (4Sack & 4TFWC) Q=5" -o graph/aggr_thru_sack_tfwc_q5.png -s linespoints &

	# INSTANEOUS QUEUE SIZE PLOT
	exec awk -f q_size.awk trace/out.queue
	exec perl ../../../Chart-Graph-2/graph.pl -i "trace/tcp_q.xg,trace/tf_q.xg" -x time -y "Q size" -t "Aggregated Queue Size (4Sack & 4TFWC) Q=5" -o graph/aggr_q_sack_tfwc_q5.png -s linespoints &

        # LOSS RATE PLOT
        exec awk -f tcp_loss.awk trace/out.queue
        exec awk -f tf_loss.awk trace/out.queue
        exec perl ../../../Chart-Graph-2/graph.pl -i "trace/tcp_loss.xg,trace/tf_loss.xg" -x time -y "Loss Rate" -t "Aggregated 4Sack/4TFWC Loss Rate, Q=5" -o graph/aggr_loss_sack_tfwc_dq.png -s linespoints &


	exit 0
}

# trace cwnd size
proc record_cwnd {} {
	global tfwc_cwnd

	set ns [Simulator instance]
	set now [$ns now]
	set granul 1.0

	set cwin [$tfwc set cwnd_]
	puts $tfwc_cwnd "$now cwin]"
}

#$ns at 0.0 "record_cwnd"
$ns run
