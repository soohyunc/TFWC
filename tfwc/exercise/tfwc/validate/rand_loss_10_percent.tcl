# test on TFWC sending/receiving

# creat a simulator object
set ns [new Simulator]

# file openings
set output [open ./trace/out.tr w]
$ns trace-all $output

set queue_out [open ./trace/queue.tr w]
#set tfwc_cwnd [open ./trace/cwnd.rands w]

# topology definition
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n2 2000Mb 0.5ms DropTail orient right-down
$ns duplex-link $n1 $n2 2000Mb 0.5ms DropTail orient right-up
$ns duplex-link $n2 $n3 100Mb 2ms DropTail orient right

#Queue Setting
$ns queue-limit $n2 $n3 1000

# set dummy UDP agent
set udp_dummy [new Agent/UDP]
$ns attach-agent $n0 $udp_dummy

# set TFWC agent
set tfwc [new Agent/TFWC]
$ns attach-agent $n1 $tfwc

# set TFWC Sink agent
set tfwc_sink [new Agent/TFWCSink]
$ns attach-agent $n3 $tfwc_sink

# creat FTP from n1 to n3
set ftp [new Application/FTP]
$ftp attach-agent $tfwc

$ns at 0.3 "$ftp start"
$ns connect $tfwc $tfwc_sink

$ns at 100.0 "$ns detach-agent $n1 $tfwc; $ns detach-agent $n3 $tfwc_sink"

$ns trace-queue $n2 $n3 $queue_out

# simulation process
$ns at 50.0 "finish"
proc finish {} {
	global ns output queue_out
	$ns flush-trace
	close $output
	close $queue_out


	exec perl ../../../ns-2.28/bin/set_flow_id -s ./trace/out.tr
	exec perl ../../../ns-2.28/bin/getrc -s 2 -d 3 < ./trace/out.tr > ./trace/foo
	exec perl ../../../ns-2.28/bin/raw2xg -s 0.01 -m 90 < ./trace/foo > ./trace/temp.xg

	#exec xgraph -bb -tk -nl -m -x time -y packets -t "TFWC Test" ./trace/temp.rands &
	#exec awk -f thru.awk ./trace/queue.tr
	#exec xgraph -P -x time -y rate -t "TFWC Test" ./trace/thru.rands &


        exec grep HISTORY temp.tfwc > ./trace/tfwc_random(0.10).HISTORY &
        exec grep avg_interval temp.tfwc > ./trace/tfwc_random(0.10).AvgInt &
        exec grep cwnd_ temp.tfwc > ./trace/tfwc_random(0.10).cwnd &


	exec grep cwnd_ temp.tfwc > ./trace/tfwc_cwnd.tr 
	exec awk -f tfwc_cwnd.awk ./trace/tfwc_cwnd.tr
	exec xgraph -m -x time -y cwnd -t "TFWC CWND Dynamics" ./trace/tfwc_cwnd.xg &
	exec perl ../../../../Chart-Graph-2/graph.pl -i "./trace/tfwc_cwnd.xg" -x "time" -y "cwnd" -t "TFWC CWND Dynamics w/ (10% random)" -o ./graph/tfwc_cwnd_10p_random.png -s linespoints &

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
