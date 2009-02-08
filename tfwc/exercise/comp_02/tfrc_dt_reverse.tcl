#
# Test on TFRC sending/receiving
# Usage: ns tfrc_dt_reverse.tcl [number of TFRC sources] [bottleneck queue size] [simulation time] [random seed number]
#
# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: s.choi@cs.ucl.ac.uk
#

if {$argc <= 1} {
	puts "Usage: ns tfrc_dt_reverse.tcl \[number of TFRC sources\] \[bottleneck queue size\] \[simulation time\] \[random seed number\] \> temp.tfrc"
	exit
}

if {$argc == 2} {
	set tfrc_src_num [lindex $argv 0]
	set q_len [lindex $argv 1]
	set duration	150
	set seedno	5
} 

if {$argc == 3} {
	set tfrc_src_num [lindex $argv 0]
	set q_len [lindex $argv 1]
	set duration [lindex $argv 2]
	set seedno	5
} 

if {$argc == 4} {
	set tfrc_src_num [lindex $argv 0]
	set q_len [lindex $argv 1]
	set duration [lindex $argv 2]
	set seedno [lindex $argv 3]
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
set node_num	$tfrc_src_num
set src_num	$node_num
set app_num	$src_num
set t_sim	$duration
set q_size	$q_len

#
# create source nodes
#
for {set i 1} {$i <= $src_num} {incr i} {
	set tfrc_node($i) [$ns node]
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
$RVftp set min_	1.0
$RVftp set max_	5.0
$RVftp use-rng $ftpRNG

#
# random variables for random access link delay
#
set RVdly [new RandomVariable/Uniform]
$RVdly set min_ 0.5
$RVdly set max_ 5.0
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
	$ns duplex-link $tfrc_node($i) $n(2) 50Mb $dly($i)ms DropTail
}

#
# create link between bottleneck node to the destination
#
$ns duplex-link $n(2) $n(3) 15Mb 20ms DropTail

#
# bottleneck queue setting
#
$ns queue-limit $n(2) $n(3) $q_size

#
# TFRC Agent
#
for {set i 1} {$i <= $src_num} {incr i} {
	set tfrc_src($i) [new Agent/TFRC]
	$ns attach-agent $tfrc_node($i) $tfrc_src($i)
}


#
# TFRC Sink
#
for {set i 1} {$i <= $src_num} {incr i} {
	set tfrc_sink($i) [new Agent/TFRCSink]
	$ns attach-agent $n(3) $tfrc_sink($i)
}

#
# connections
#
for {set i 1} {$i <= $src_num} {incr i} {
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
	$ftp($i) attach-agent $tfrc_src($i)
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
	$ns at $t_sim "$ns detach-agent $tfrc_node($i) $tfrc_src($i); $ns detach-agent $n(3) $tfrc_sink($i)"
}

####################################################
# REVERSE TCP SACK in oder to avoid Phase Effect ###
####################################################

set	reverse_app_num		$src_num

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
	$ns attach-agent $tfrc_node($i) $reverse_tcp_sink($i)
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
	$ns queue-limit $n(2) $tfrc_node($i)	2
}

#
# random start time for each FTP connection
#
for {set i 1} {$i <= $reverse_app_num} {incr i} {
	set startT($i) [expr [$RVftp value]]
}

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
############# END OF REVERSE TCP SACK ##############
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
        #exec xgraph -bg white -P -x time -y "rate (Mb/s)" -t "Aggregated Thruput (TFRCs)" trace/tfrc_thru.xg &
	exec gnuplot tfrc_dt_thru.plt &

	#
        # INSTANEOUS QUEUE SIZE PLOT
	#
        exec awk -f tfrc_q.awk trace/out.queue
        exec gnuplot tfrc_dt_q.plt &

	#
        # LOSS RATE PLOT
	#
        exec awk -f tfrc_loss.awk trace/out.queue
        exec gnuplot tfrc_dt_loss.plt &

	#
	# Avg Loss Interval
	#
	exec grep tfrc_avg_loss_int temp.tfrc > trace/tfrc_avg_int.tr
	exec awk -f tfrc_avg_int.awk trace/tfrc_avg_int.tr

	#exec xgraph -bg white -x time -y "avg_loss_interval" -t "Avg Loss Interval" trace/tfrc_avg_int_01.xg trace/tfrc_avg_int_02.xg trace/tfrc_avg_int_03.xg trace/tfrc_avg_int_04.xg &
	exec gnuplot tfrc_dt_ali.plt &

        exit 0
}

$ns run


