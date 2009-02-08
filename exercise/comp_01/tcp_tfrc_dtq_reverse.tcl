#
# Test on TFRC sending/receiving
# Usage: ns tcp_tfrc_dtq_reverse.tcl [bottleneck queue size] [simulation time] [replication number]
#
# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: s.choi@cs.ucl.ac.uk
#

if {$argc < 1} {
	puts "Usage: ns tcp_tfrc_dtq_reverse.tcl \[bottleneck queue size\] \[simulation time\] \[replication number\]"
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
	set tfrc_node($i) [$ns node]
	puts " creating...	tcp_node($i)"
	puts " creating...	tfrc_node($i)"
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
	$ns duplex-link $tfrc_node($i) $n(2) 50Mb $dly([expr $i + $src_num])ms DropTail
}

#
# create link between bottleneck node to the destination
#
$ns duplex-link $n(2) $n(3) 15Mb 20ms DropTail orient right

#
# bottleneck queue setting
#
$ns queue-limit $n(2) $n(3) $q_size

#
# TCP/TFRC Agent
#
for {set i 1} {$i <= $src_num} {incr i} {
	set tcp_src($i) [new Agent/TCP/Sack1]
	$ns attach-agent $tcp_node($i) $tcp_src($i)
	$tcp_src($i) set window_ 10000
}
for {set i 1} {$i <= $src_num} {incr i} {
	set tfrc_src($i) [new Agent/TFRC]
	$ns attach-agent $tfrc_node($i) $tfrc_src($i)
}

#
# TCP/TFRC Sink
#
for {set i 1} {$i <= $src_num} {incr i} {
	set tcp_sink($i) [new Agent/TCPSink/Sack1]
	$ns attach-agent $n(3) $tcp_sink($i)
}
for {set i 1} {$i <= $src_num} {incr i} {
	set tfrc_sink($i) [new Agent/TFRCSink]
	$tfrc_sink($i) set discount 0
	$ns attach-agent $n(3) $tfrc_sink($i)
}

#
# connections
#
for {set i 1} {$i <= $src_num} {incr i} {
	$ns connect $tcp_src($i) $tcp_sink($i)
	$ns connect $tfrc_src($i) $tfrc_sink($i)
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
		$ftp($i) attach-agent $tfrc_src([expr $i - [expr $app_num/2]])
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
	$ns at $t_sim "$ns detach-agent $tfrc_node($i) $tfrc_src($i); $ns detach-agent $n(3) $tfrc_sink($i)"
}

####################################################
# REVERSE TCP SACK in oder to avoid Phase Effect
####################################################
set reverse_tcp_01 [new Agent/TCP/Sack1]
set reverse_tcp_sink_01 [new Agent/TCPSink/Sack1]

$ns attach-agent $n(3) $reverse_tcp_01
$ns attach-agent $tcp_node(1) $reverse_tcp_sink_01
$ns queue-limit $n(2) $tcp_node(1) 2

set reverse_ftp_01 [new Application/FTP]
$reverse_ftp_01 attach-agent $reverse_tcp_01

$ns at 3.0 "$reverse_ftp_01 start"
$ns connect $reverse_tcp_01 $reverse_tcp_sink_01
$ns at 1000.0 "$ns detach-agent $tcp_node(1) $reverse_tcp_sink_01; $ns detach-agent $n(3) $reverse_tcp_01"
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
        exec awk -f tfrc_thru.awk trace/out.queue
        exec awk -f tcp_thru.awk trace/out.queue
        exec xgraph -bg white -P -x time -y "rate (Mb/s)" -t "Aggregated Thruput (Sack & TFRC)" trace/tcp_thru.xg trace/tfrc_thru.xg &
        exec perl ../../../Chart-Graph-2/graph.pl -i "trace/tcp_thru.xg,trace/tfrc_thru.xg" -x "time" -y "rate (Mb/s)" -t "Aggregated Thruput (Sack & TFRC)" -o graph/aggr_thru_sack_tfrc_dq_reverse.png -s lines &

	#
        # INSTANEOUS QUEUE SIZE PLOT
	#
        exec awk -f tfrc_q.awk trace/out.queue
        exec perl ../../../Chart-Graph-2/graph.pl -i "trace/tcp_q.xg,trace/tfrc_q.xg" -x time -y "Q size" -t "Aggregated Queue Size (Sack & TFRC)" -o graph/aggr_q_sack_tfrc_dq_reverse.png -s lines &

	#
        # LOSS RATE PLOT
	#
        exec awk -f tcp_loss.awk trace/out.queue
        exec awk -f tfrc_loss.awk trace/out.queue
        exec perl ../../../Chart-Graph-2/graph.pl -i "trace/tcp_loss.xg,trace/tfrc_loss.xg" -x time -y "Loss Rate" -t "Aggregated Loss Rate (Sack & TFRC)" -o graph/aggr_loss_sack_tfrc_dq_reverse.png -s lines &

	#
        # CWND
	#
        #exec grep cwnd_ temp.tfrc > trace/tfrc_cwnd.tr
        #exec awk -f tfrc_cwnd.awk trace/tfrc_cwnd.tr
        #exec xgraph -bg white -m -x time -y cwnd -t "TFRC CWND Dynamics" trace/tfrc_cwnd.xg &
        #exec perl ../../../Chart-Graph-2/graph.pl -i "trace/tfrc_cwnd.xg" -x time -y cwnd -t "TFRC CWND Dynamics" -o graph/cwnd_dq_reverse.png -s lines &

        exit 0
}

#
# trace cwnd size
#
proc record_cwnd {} {
        global tfrc_cwnd

        set ns [Simulator instance]
        set now [$ns now]
        set granul 1.0

        set cwin [$tfrc set cwnd_]
        puts $tfrc_cwnd "$now cwin"
}

#$ns at 0.0 "record_cwnd"
$ns run


