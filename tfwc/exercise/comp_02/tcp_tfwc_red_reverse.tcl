#
# Test on TFWC sending/receiving
# Usage: ns tcp_tfwc_red_reverse.tcl [number of TCP/TFWC sources] [bottleneck queue size] [simulation time] [random seed number]
#
# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: s.choi@cs.ucl.ac.uk
#

if {$argc <= 1} {
	puts "Usage: ns tcp_tfwc_red_reverse.tcl \[number of TCP/TFWC sources\] \[bottleneck queue size\] \[simulation time\] \[random seed number\] \> temp.tfwc"
	exit
}

if {$argc == 2} {
	set src_num [lindex $argv 0]
	set q_len [lindex $argv 1]
	set duration	150
	set seedno	5
} 

if {$argc == 3} {
	set src_num [lindex $argv 0]
	set q_len [lindex $argv 1]
	set duration [lindex $argv 2]
	set seedno	5
} 

if {$argc == 4} {
	set src_num [lindex $argv 0]
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

#set queue_out [open trace/out.queue w]
#for {set i 1} {$i <= $src_num} {incr i} {
#	set tcp_cwnd($i) [open trace/tcp_cwin($i).tr w]
#}

#
# set simulation parameters
#
set node_num	$src_num
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
        $ns duplex-link $tfwc_node($i) $n(2) 50Mb $dly([expr $i + $src_num])ms DropTail
}

#
# create link between bottleneck node to the destination
#
$ns duplex-link $n(2) $n(3) 15Mb 20ms RED
set redq [[$ns link $n(2) $n(3)] queue]
$redq set bytes_ false
$redq set queue_in_bytes_ false
$redq set adaptive_ 1
 
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
	$ns attach-agent $tfwc_node($i) $reverse_tcp_sink($i)
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
	$ns queue-limit $n(2) $tfwc_node($i)	5
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
        exec awk -f tfwc_thru.awk trace/out.queue
        exec awk -f tcp_thru.awk trace/out.queue
        #exec xgraph -bg white -P -x time -y "rate (Mb/s)" -t "Aggregated Thruput (TFWCs)" trace/tfwc_thru.xg &
	exec gnuplot tcp_tfwc_red_thru.plt &

	#
        # INSTANEOUS QUEUE SIZE PLOT
	#
        exec awk -f tfwc_q.awk trace/out.queue
	#exec awk -f tcp_q.awk trace/out.queue
        exec gnuplot tcp_tfwc_red_q.plt &

	#
        # LOSS RATE PLOT
	#
        exec awk -f tfwc_loss.awk trace/out.queue
        exec gnuplot tfwc_red_loss.plt &

	#
        # CWND
	#
        exec grep cwnd_ temp.tfwc > trace/tfwc_cwnd.tr
        exec awk -f tfwc_cwnd.awk trace/tfwc_cwnd.tr
        #exec xgraph -bg white -x time -y cwnd -t "TFWC CWND Dynamics" trace/tfwc_cwnd_01.xg trace/tfwc_cwnd_02.xg trace/tfwc_cwnd_03.xg trace/tfwc_cwnd_04.xg &
        exec gnuplot tfwc_red_cwnd.plt &

	exec grep TCPWIN temp.tfwc > trace/tcp_cwnd.tr
	exec awk -f tcp_cwnd.awk trace/tcp_cwnd.tr
	exec gnuplot tcp_red_cwnd.plt &

	#
	# Avg Loss Interval
	#
	exec grep avg_interval_ temp.tfwc > trace/tfwc_avg_int.tr
	exec awk -f tfwc_avg_int.awk trace/tfwc_avg_int.tr

	exec grep pkt_drop_in_avg_hist temp.tfwc > trace/tfwc_loss_in_hist.tr
	exec awk -f tfwc_loss_in_hist.awk trace/tfwc_loss_in_hist.tr

	#exec xgraph -bg white -x time -y "avg_loss_interval" -t "Avg Loss Interval" trace/tfwc_avg_int_01.xg trace/tfwc_avg_int_02.xg trace/tfwc_avg_int_03.xg trace/tfwc_avg_int_04.xg &
	exec gnuplot tfwc_red_ali.plt &

        exit 0
}

#
# trace TCP cwnd size
#
proc tcp_cwnd {} {
	global src_num 
	for {set i 1} {$i <= $src_num} {incr i} {
		global tcp_cwnd($i)
		global tcp_src($i)
		puts "1"
	}

        set ns [Simulator instance]
        set now [$ns now]
        set granul 0.5 

	for {set i 1} {$i <= $src_num} {incr i} {
		set cwin($i) [$tcp_src($i) set cwnd_]
		puts $tcp_cwnd($i) "$now cwin($i)"
	}

	$ns at [expr $now+$granul] "tcp_cwnd"
}

#$ns at 0.0 "tcp_cwnd"
$ns run


