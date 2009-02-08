#
# Test on TFWC sending/receiving
# Usage: ns tcp_tfwc_red_reverse.tcl [bottleneck queue size] [simulation time] [replication number]
#
# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: s.choi@cs.ucl.ac.uk
#

if {$argc < 1} {
	puts "Usage: ns tcp_tfwc_red_reverse.tcl \[bottleneck queue size\] \[simulation time\] \[replication number\]"
	exit
}

if {$argc == 1} {
	set q_len [lindex $argv 0]
	set duration	150
	set seedno	5
} 

if {$argc == 2} {
	set q_len [lindex $argv 0]
	set duration [lindex $argv 1]
	set seedno	5
} 

if {$argc == 3} {
	set q_len [lindex $argv 0]
	set duration [lindex $argv 1]
	set seedno [lindex $argv 2]
}

#
# create a simulator object
#
set ns [new Simulator]

#
# file openings
#
set output [open trace/out.tr w]
$ns trace-all $output

set queue_out [open trace/out.queue w]

#
# set simulation parameters
#
set node_num	4
set src_num	$node_num
set app_num	[expr 2*$src_num]
set t_sim	$duration
set q_size	$q_len

#
# create source nodes
#
for {set i 1} {$i <= $src_num} {incr i} {
	set tcp_node($i) [$ns node]
	set tfwc_node($i) [$ns node]
	puts " creating...	tcp_node($i)"
	puts " creating...	tfwc_node($i)"
}

#
# create bottleneck nodes
#
set n(2) [$ns node]
set n(3) [$ns node]

#
# create a random generator for FTP and Link Delay
#
set ftpRNG [new RNG]
set dlyRNG [new RNG]
for {set i 1} {$i < $seedno} {incr i} {
	$ftpRNG next-substream
	$dlyRNG next-substream
}

#
# random variables for beginning FTP connections
#
set RVftp [new RandomVariable/Uniform]
$RVftp set min_	0.5
$RVftp set max_	7.5
$RVftp use-rng $ftpRNG

#
# random variables for random access link delay
#
set RVdly [new RandomVariable/Uniform]
$RVdly set min_ 3.5
$RVdly set max_ 6.5
$RVdly use-rng $dlyRNG

#
# random delay for access link
#
for {set i 1} {$i <= $app_num} {incr i} {
	set dly($i) [expr [$RVdly value]]
	puts " dly($i)		$dly($i)"
}

#
# create links between sources and bottleneck node
#
for {set i 1} {$i <= $src_num} {incr i} {
	$ns duplex-link $tcp_node($i) $n(2) 50Mb $dly($i)ms DropTail
	$ns duplex-link $tfwc_node($i) $n(2) 50Mb $dly([expr $i + $src_num])ms DropTail
}

#
# create link between bottleneck node to the destination
#
$ns duplex-link $n(2) $n(3) 15Mb 20ms RED

#
# bottleneck queue setting
#
$ns queue-limit $n(2) $n(3) $q_size

#
# TCP/TFWC Agent
#
for {set i 1} {$i <= $src_num} {incr i} {
	set tcp_src($i) [new Agent/TCP/Sack1]
	$ns attach-agent $tcp_node($i) $tcp_src($i)
	$tcp_src($i) set window_ 10000
}
for {set i 1} {$i <= $src_num} {incr i} {
	set tfwc_src($i) [new Agent/TFWC]
	$ns attach-agent $tfwc_node($i) $tfwc_src($i)
}


#
# TCP/TFWC Sink
#
for {set i 1} {$i <= $src_num} {incr i} {
	set tcp_sink($i) [new Agent/TCPSink/Sack1]
	$ns attach-agent $n(3) $tcp_sink($i)
}
for {set i 1} {$i <= $src_num} {incr i} {
	set tfwc_sink($i) [new Agent/TFWCSink]
	$ns attach-agent $n(3) $tfwc_sink($i)
}

#
# connections
#
for {set i 1} {$i <= $src_num} {incr i} {
	$ns connect $tcp_src($i) $tcp_sink($i)
	$ns connect $tfwc_src($i) $tfwc_sink($i)
}

#
# random start time for each FTP connection
#
for {set i 1} {$i <= $app_num} {incr i} {
	set startT($i) [expr [$RVftp value]]
}

#
# create FTP from n(0)<-->n(3) and n(1)<-->n(3)
#
for {set i 1} {$i <= $app_num} {incr i} {
	set ftp($i) [new Application/FTP]

	if {$i <= [expr $app_num/2]} {
		$ftp($i) attach-agent $tcp_src($i)
	} else {
		$ftp($i) attach-agent $tfwc_src([expr $i - [expr $app_num/2]])
	}
}

#
# start FTP
#
for {set i 1} {$i <= $app_num} {incr i} {
	$ns at $startT($i) "$ftp($i) start"
	puts " startT($i)	$startT($i)"
}

#
# detach FTP agent
#
for {set i 1} {$i <= $src_num} {incr i} {
	$ns at $t_sim "$ns detach-agent $tcp_node($i) $tcp_src($i); $ns detach-agent $n(3) $tcp_sink($i)"
	$ns at $t_sim "$ns detach-agent $tfwc_node($i) $tfwc_src($i); $ns detach-agent $n(3) $tfwc_sink($i)"
}

####################################################
# REVERSE TCP SACK in oder to avoid Phase Effect
####################################################

set	reverse_app_num		$src_num
#set	reverse_app_num		1

#
# Backward TCP Agent
#
for {set i 1} {$i <= $reverse_app_num} {incr i} {
	set reverse_tcp_src($i)	[new Agent/TCP/Sack1]
	$ns attach-agent $n(3) $reverse_tcp_src($i)
}

#
# Backward TCP Sink Agent
#
for {set i 1} {$i <= $reverse_app_num} {incr i} {

	set reverse_tcp_sink($i) [new Agent/TCPSink/Sack1]

	if {$i <= [expr $app_num/2]} {
		$ns attach-agent $tcp_node($i) $reverse_tcp_sink($i)
	} else {
		$ns attach-agent $tfwc_node([expr $i - [expr $app_num/2]]) $reverse_tcp_sink($i)
	}
	
}

#
# connections
#
for {set i 1} {$i <= $reverse_app_num} {incr i} {
	$ns connect $reverse_tcp_src($i) $reverse_tcp_sink($i)
}

#
# Queue Size Setting
#
for {set i 1} {$i <= $src_num} {incr i} {
	$ns queue-limit $n(2) $tcp_node($i)	2
	$ns queue-limit $n(2) $tfwc_node($i)	2
}

#
# random start time for each FTP connection
#
#for {set i 1} {$i <= $reverse_app_num} {incr i} {
#	set startT($i) [expr [$RVftp value]]
#}

#
# create reverse FTPs
#
for {set i 1} {$i <= $reverse_app_num} {incr i} {
	set reverse_ftp($i) [new Application/FTP]
	$reverse_ftp($i) attach-agent $reverse_tcp_src($i)
}

#
# start FTP
#
for {set i 1} {$i <= $reverse_app_num} {incr i} {
	$ns at $startT($i) "$reverse_ftp($i) start"
}
####################################################

#
# Make a queue trace
#
$ns trace-queue $n(2) $n(3) $queue_out

#
# simulation process
#
$ns at $t_sim "finish"
proc finish {} {
                global ns output queue_out
                $ns flush-trace
                close $output
                close $queue_out

        exec perl ../../ns-2.28/bin/set_flow_id -s trace/out.tr
        exec perl ../../ns-2.28/bin/getrc -s 2 -d 3 < trace/out.tr > trace/foo
        exec perl ../../ns-2.28/bin/raw2xg -s 0.01 -m 90 < trace/foo > trace/all.xg

        #
	# THRUPUT PLOT
	#
        exec awk -f tfwc_thru.awk trace/out.queue
        exec awk -f tcp_thru.awk trace/out.queue
        exec xgraph -bg white -P -x time -y "rate (Mb/s)" -t "Aggregated Thruput (Sack & TFWC)" trace/tcp_thru.xg trace/tfwc_thru.xg &
        exec perl ../../../Chart-Graph-2/graph.pl -i "trace/tcp_thru.xg,trace/tfwc_thru.xg" -x "time" -y "rate (Mb/s)" -t "Aggregated Thruput (Sack & TFWC)" -o graph/aggr_thru_sack_tfwc_red_reverse.png -s lines &

	#
        # INSTANEOUS QUEUE SIZE PLOT
	#
        exec awk -f tfwc_q.awk trace/out.queue
        exec perl ../../../Chart-Graph-2/graph.pl -i "trace/tcp_q.xg,trace/tfwc_q.xg" -x time -y "Q size" -t "Aggregated Queue Size (Sack & TFWC)" -o graph/aggr_q_sack_tfwc_red_reverse.png -s lines &

	#
        # LOSS RATE PLOT
	#
        exec awk -f tcp_loss.awk trace/out.queue
        exec awk -f tfwc_loss.awk trace/out.queue
        exec perl ../../../Chart-Graph-2/graph.pl -i "trace/tcp_loss.xg,trace/tfwc_loss.xg" -x time -y "Loss Rate" -t "Aggregated Loss Rate (Sack & TFWC)" -o graph/aggr_loss_sack_tfwc_red_reverse.png -s lines &

	#
        # CWND
	#
        exec grep cwnd_ temp.tfwc > trace/tfwc_cwnd.tr
        exec awk -f tfwc_cwnd.awk trace/tfwc_cwnd.tr
        exec xgraph -bg white -x time -y cwnd -t "TFWC CWND Dynamics" trace/tfwc_cwnd_01.xg trace/tfwc_cwnd_02.xg trace/tfwc_cwnd_03.xg trace/tfwc_cwnd_04.xg &
        exec perl ../../../Chart-Graph-2/graph.pl -i "trace/tfwc_cwnd_01.xg,trace/tfwc_cwnd_02.xg,trace/tfwc_cwnd_03.xg,trace/tfwc_cwnd_04.xg" -x time -y cwnd -t "TFWC CWND Dynamics" -o graph/cwnd_red_reverse.png -s lines &

	#
	# Avg Loss Interval
	#
	exec grep avg_interval_ temp.tfwc > trace/tfwc_avg_int.tr
	exec awk -f tfwc_avg_int.awk trace/tfwc_avg_int.tr

	exec grep pkt_drop_in_avg_hist temp.tfwc > trace/tfwc_loss_in_hist.tr
	exec awk -f tfwc_loss_in_hist.awk trace/tfwc_loss_in_hist.tr

	exec xgraph -bg white -x time -y "avg_loss_interval" -t "Avg Loss Interval" trace/tfwc_avg_int_01.xg trace/tfwc_avg_int_02.xg trace/tfwc_avg_int_03.xg trace/tfwc_avg_int_04.xg &
	exec perl ../../../Chart-Graph-2/graph.pl -i "trace/tfwc_avg_int_01.xg,trace/tfwc_avg_int_02.xg,trace/tfwc_avg_int_03.xg,trace/tfwc_avg_int_04.xg" -x time -y "avg_loss_interval" -t "Avg Loss Interval" -o graph/avg_interval_red_reverse.png -s lines &
	exec perl ../../../Chart-Graph-2/graph.pl -i "trace/tfwc_loss_in_hist_01.xg,trace/tfwc_loss_in_hist_02.xg,trace/tfwc_loss_in_hist_03.xg,trace/tfwc_loss_in_hist_04.xg" -x time -y "packet loss in avg hist" -t "Packet Loss in Avg Loss Hist" -o graph/pkt_loss_in_hist_red_reverse.png -s points &

	exec gnuplot tfwc_red_avg_int_with_loss.plt &

        exit 0
}

#
# trace cwnd size
#
proc record_cwnd {} {
        global tfwc_cwnd

        set ns [Simulator instance]
        set now [$ns now]
        set granul 1.0

        set cwin [$tfwc set cwnd_]
        puts $tfwc_cwnd "$now cwin"
}

#$ns at 0.0 "record_cwnd"
$ns run


