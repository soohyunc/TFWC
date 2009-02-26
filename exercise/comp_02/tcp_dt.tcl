#
# Test on TCP sending/receiving
# Usage: ns tcp_dt.tcl [number of TCP sources] [bottleneck queue size] [simulation time] [random seed number]
#
# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: s.choi@cs.ucl.ac.uk
#

if {$argc <= 1} {
	puts "Usage: ns tcp_dt.tcl \[number of TCP sources\] \[bottleneck queue size\] \[simulation time\] \[random seed number\] \> temp.tcp"
	exit
}

if {$argc == 2} {
	set tcp_src_num [lindex $argv 0]
	set q_len [lindex $argv 1]
	set duration	150
	set seedno	5
} 

if {$argc == 3} {
	set tcp_src_num [lindex $argv 0]
	set q_len [lindex $argv 1]
	set duration [lindex $argv 2]
	set seedno	5
} 

if {$argc == 4} {
	set tcp_src_num [lindex $argv 0]
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
set node_num	$tcp_src_num
set src_num	$node_num
set app_num	$src_num
set t_sim	$duration
set q_size	$q_len

#
# create source nodes
#
for {set i 1} {$i <= $src_num} {incr i} {
	set tcp_node($i) [$ns node]
	puts " creating...	tcp_node($i)"
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
	$ns duplex-link $tcp_node($i) $n(2) 50Mb $dly($i)ms DropTail
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
# TCP Agent
#
Agent/TCP set window_ 1000
for {set i 1} {$i <= $src_num} {incr i} {
	set tcp_src($i) [new Agent/TCP]
	#$tcp_src($i)	set	window_	1000
	#$tcp_src($i)	set	minrto_	0
	$ns attach-agent $tcp_node($i) $tcp_src($i)
}

#
# TCP Sink
#
for {set i 1} {$i <= $src_num} {incr i} {
	set tcp_sink($i) [new Agent/TCPSink]
	$ns attach-agent $n(3) $tcp_sink($i)
}

#
# connections
#
for {set i 1} {$i <= $src_num} {incr i} {
	$ns connect $tcp_src($i) $tcp_sink($i)
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
	$ftp($i) attach-agent $tcp_src($i)
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
}

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
        #exec awk -f tcp_thru.awk trace/out.queue
        #exec awk -f tcp_thru.awk trace/out.queue
        #exec xgraph -bg white -P -x time -y "rate (Mb/s)" -t "Aggregated Thruput (TCPs)" trace/tcp_thru.xg &
	#exec gnuplot tcp_thru.plt &

	#
        # INSTANEOUS QUEUE SIZE PLOT
	#
        #exec awk -f tfwc_q.awk trace/out.queue
        #exec gnuplot tcp_q.plt &

	#
        # LOSS RATE PLOT
	#
        #exec awk -f tcp_loss.awk trace/out.queue
        #exec gnuplot tcp_loss.plt &

	#
        # CWND
	#
        exec grep TCPWIN temp.tcp > trace/tcp_cwnd.tr
        exec awk -f tcp_cwnd.awk trace/tcp_cwnd.tr
        exec gnuplot tcp_dt_cwnd.plt &

        exit 0
}

#
# trace cwnd size
#
proc record_cwnd {} {
        global tcp_cwnd

        set ns [Simulator instance]
        set now [$ns now]
        set granul 1.0

        set cwin [$tcp set cwnd_]
        puts $tcp_cwnd "$now cwin"
}

#$ns at 0.0 "record_cwnd"
$ns run

