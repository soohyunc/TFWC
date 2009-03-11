#
# Copyright(c) 2005-2009 University College London
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright 
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright 
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the
#    distribution.
#
# 3. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE
#
# $Id$

# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: S.Choi@cs.ucl.ac.uk

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
set tcp_node_num	$tcp_src_num
set tfrc_node_num	$tfrc_src_num
set tfwc_node_num	$tfwc_src_num
set tcp_app_num		$tcp_src_num
set tfrc_app_num	$tfrc_src_num
set tfwc_app_num	$tfwc_src_num
set min_dly			$accessMinDel
set max_dly			$accessMaxDel
set numeric_access_bandwidth		$accessBW
set numeric_bottleneck_bandwidth	$bottleneckBW
set numeric_bottleneck_delay		$bottleneckDel
set access_bandwidth		"$numeric_access_bandwidth\Mb"
set bottleneck_bandwidth	"$numeric_bottleneck_bandwidth\Mb"
set bottleneck_delay		"$numeric_bottleneck_delay\ms"
set node_num	[expr ($tcp_node_num + $tfrc_node_num + $tfwc_node_num)]
set src_num		[expr ($tcp_src_num + $tfrc_src_num + $tfwc_src_num)]
set app_num		[expr ($tcp_app_num + $tfrc_app_num + $tfwc_app_num)]
set t_sim       $duration
set q_size      $q_len
set queuetype   $queue_type
set maxth		[expr ($q_size / 2.0)]
set minth		[expr ($maxth / 3.0)]

set rtt_in_sec [expr (2 * ($bottleneckDel + ($min_dly + $max_dly) / 2.0)) \
		* 0.001]
set bottleneckBW_in_Bps [expr $bottleneckBW * 1000000]
set delbw_in_bits	[expr $rtt_in_sec * $bottleneckBW_in_Bps]
set delbw	[expr $delbw_in_bits / 8000]

set cutoff	20;	# cutoff time
set granul [expr 4 * $rtt_in_sec]; # gnuplot sampling granularity
puts ""
puts " Bandwidth-Delay Product		$delbw	packets"
puts " Approximated e2e delay (RTT)	$rtt_in_sec	(sec)"
puts ""

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
$RVftp set min_ 1.0
$RVftp set max_ 5.0
$RVftp use-rng $ftpRNG

#
# random variables for random access link delay
#
set RVdly [new RandomVariable/Uniform]
$RVdly set min_ $min_dly
$RVdly set max_ $max_dly
$RVdly use-rng $dlyRNG

#
# random delay for access link
#
for {set i 1} {$i <= $app_num} {incr i} {
	set dly($i) [expr [$RVdly value]]
	puts " dly($i)          $dly($i)"
}

#
# automaic max_p approximation for RED queue
#
if {$queuetype == "RED"} {
	if {$max_p == "auto"} {
		source max_p.tcl
		puts " max_p            $max_p"
		set max_p_inv   [expr (1.0/$max_p)]
		puts " max_p_inv        $max_p_inv"
	} else {
		puts " max_p            $max_p"
		set max_p_inv   [expr (1.0/$max_p)]
		puts " max_p_inv        $max_p_inv"
	}
}

#
# create bottleneck nodes
#
set n(2) [$ns node]
set n(3) [$ns node]

#
# create TCP, TFRC, and TFWC node
#
for {set i 1} {$i <= $tcp_node_num} {incr i} {
	set tcp_node($i) [$ns node]
	puts " creating...	tcp_node($i)"
}

for {set i 1} {$i <= $tfrc_node_num} {incr i} {
	set tfrc_node($i) [$ns node]
	puts " creating...	tfrc_node($i)"
}

for {set i 1} {$i <= $tfwc_node_num} {incr i} {
	set tfwc_node($i) [$ns node]
	puts " creating...	tfwc_node($i)"
}

#
# create TCP/Sack1, TFRC, and TFWC Agent
#
Agent/TCP/Sack1 set window_ 10000
for {set i 1} {$i <= $tcp_src_num} {incr i} {
	set tcp_src($i) [new Agent/TCP/Sack1]
	set tcpwin($i) [open trace/tcp_cwnd_$i.tr w]
	$tcp_src($i) attach $tcpwin($i)
	$tcp_src($i) trace cwnd_
	$ns attach-agent $tcp_node($i) $tcp_src($i)
}

Agent/TFRC set packetSize_ 1040 
Agent/TFRC set conservative_ 1
for {set i 1} {$i <= $tfrc_src_num} {incr i} {
        set tfrc_src($i) [new Agent/TFRC]
        $ns attach-agent $tfrc_node($i) $tfrc_src($i)
}

for {set i 1} {$i <= $tfwc_src_num} {incr i} {
        set tfwc_src($i) [new Agent/TFWC]
        $ns attach-agent $tfwc_node($i) $tfwc_src($i)
}

#
# create TCP/Sack1/Sink, TFRCSink, TFWCSink Agent
#
for {set i 1} {$i <= $tcp_src_num} {incr i} {
        set tcp_sink($i) [new Agent/TCPSink/Sack1]
        $ns attach-agent $n(3) $tcp_sink($i)
}

#Agent/TFRCSink set discount_ 0
for {set i 1} {$i <= $tfrc_src_num} {incr i} {
        set tfrc_sink($i) [new Agent/TFRCSink]
        $ns attach-agent $n(3) $tfrc_sink($i)
}

for {set i 1} {$i <= $tfwc_src_num} {incr i} {
        set tfwc_sink($i) [new Agent/TFWCSink]
        $ns attach-agent $n(3) $tfwc_sink($i)
}

#
# create connections
#
for {set i 1} {$i <= $tcp_src_num} {incr i} {
	$ns connect $tcp_src($i) $tcp_sink($i)
}

for {set i 1} {$i <= $tfrc_src_num} {incr i} {
	$ns connect $tfrc_src($i) $tfrc_sink($i)
}

for {set i 1} {$i <= $tfwc_src_num} {incr i} {
	$ns connect $tfwc_src($i) $tfwc_sink($i)
}

#
# create links between sources and bottleneck node
#
for {set i 1} {$i <= $tcp_src_num} {incr i} {
	$ns duplex-link $tcp_node($i) $n(2) $access_bandwidth $dly($i)ms DropTail
}

for {set i 1} {$i <= $tfrc_src_num} {incr i} {
	$ns duplex-link $tfrc_node($i) $n(2) $access_bandwidth $dly($i)ms DropTail
}

for {set i 1} {$i <= $tfwc_src_num} {incr i} {
	$ns duplex-link $tfwc_node($i) $n(2) $access_bandwidth $dly($i)ms DropTail
}

#
# create link between bottleneck node to the destination
#
$ns duplex-link $n(2) $n(3) $bottleneck_bandwidth $bottleneck_delay $queuetype
if {$queuetype =="RED"} {
	set redq [[$ns link $n(2) $n(3)] queue]
	set tchan_ [open trace/red_q.tr w]
	$redq set queue_in_bytes_ false
	$redq set bytes_        false
	$redq set drop_tail_    false
	$redq set drop_rand_    true
	$redq set cautious_     1
	$redq set linterm_      $max_p_inv
	$redq set thresh_       $minth
	$redq set maxthresh_    $maxth
	if {$q_w == "auto"} {
		$redq set q_weight_     -1
	} else {
		$redq set q_weight_     $q_w
	}
	$redq trace curq_
	$redq trace ave_
	$redq attach $tchan_
}

# frequence variables
if { $granul < 1 } {
	set granul	1; # if granul is too small, we use 1 sec granularity
}
set freq [expr $rtt_in_sec/4.0]

#
# bottleneck queue setting
#
$ns queue-limit $n(2) $n(3) $q_size

#
# random start time for each FTP connection
#
for {set i 1} {$i <= $app_num} {incr i} {
        set startT($i) [expr [$RVftp value]]
}

#
# create FTPs 
#
for {set i 1} {$i <= $tcp_app_num } {incr i} {
        set ftp($i) [new Application/FTP]
        $ftp($i) attach-agent $tcp_src($i)
}

for {set i [expr $tcp_app_num + 1]} {$i <= [expr $tcp_app_num + $tfrc_app_num]} {incr i} {
	set ftp($i) [new Application/FTP]
	$ftp($i) attach-agent $tfrc_src([expr $i - $tcp_app_num])
}

for {set i [expr $tcp_app_num + $tfrc_app_num + 1]} {$i <= $app_num} {incr i} {
	set ftp($i) [new Application/FTP]
	$ftp($i) attach-agent $tfwc_src([expr $i - $tcp_app_num - $tfrc_app_num])
}

#
# start FTP
#
for {set i 1} {$i <= $app_num} {incr i} {
	$ns at $startT($i) "$ftp($i) start"
	puts " startT($i)       $startT($i)"
}
puts ""
puts ""
#
# Make a queue trace
#
$ns trace-queue $n(2) $n(3) $queue_out

proc finish {} {
	global tcp_src_num tfrc_src_num tfwc_src_num
	global queuetype
	common_files

	# post processing for each type of sources
	if {$tcp_src_num > 0} {
		tcp_results
	}

	if {$tfrc_src_num > 0} {
		tfrc_results
	}

	if {$tfwc_src_num > 0} {
		tfwc_results
	}

	# plotting for each type of queue descipline
	if {$queuetype == "RED"} {
		red_plots
	} 

	if {$queuetype == "DropTail"} {
		fifo_plots
	}

	exit 0
}

proc common_files {} {
	global ns output queue_out
	$ns flush-trace
	close $output
	close $queue_out

	#exec perl ../../ns-2.28/bin/set_flow_id -s trace/out.tr
	#exec perl ../../ns-2.28/bin/getrc -s 2 -d 3 < trace/out.tr > trace/foo
	#exec perl ../../ns-2.28/bin/raw2xg -s 0.01 -m 90 < trace/foo > trace/all.xg
}

proc red_plots {} {
	global tcp_src_num tfrc_src_num tfwc_src_num app_num
	global cutoff rtt_in_sec

	# THROUGHPUT PLOT
	exec gnuplot plt/red.thru.plt 2> /dev/null

	# INSTANTANEOUS QUEUE SIZE PLOT
	exec gnuplot plt/red.q.plt 2> /dev/null

	# AVERAGE RED QUEUE SIZE PLOT
	exec gnuplot plt/red.avg.plt 2> /dev/null

	# LOSS RATE PLOT
	exec gnuplot plt/red.loss.plt 2> /dev/null

	if {$tcp_src_num > 0} {
	}
	if {$tfrc_src_num > 0} {
	}
	if {$tfwc_src_num > 0} {
	}
}

proc fifo_plots {} {
	global tcp_src_num tfrc_src_num tfwc_src_num app_num
	global cutoff rtt_in_sec

	# THROUGHPUT PLOT
	exec gnuplot plt/fifo.thru.plt 2> /dev/null 

	# INSTANTANEOUS QUEUE SIZE PLOT
	exec gnuplot plt/fifo.q.plt 2> /dev/null

	# LOSS RATE PLOT
	exec gnuplot plt/fifo.loss.plt 2> /dev/null

	if {$tcp_src_num > 0} {
	}
	if {$tfrc_src_num > 0} {
	}
	if {$tfwc_src_num > 0} {
	}
}

proc tcp_results {} {
	global queuetype tcp_src_num
	global cutoff t_sim src_num granul 
	global numeric_bottleneck_bandwidth
	global freq rtt_in_sec

	# THROUGHPUT
	exec awk -f awk/tcp_thru.awk cutoff=$cutoff trace/out.queue
	exec awk -f awk/total_avg_thru.awk cutoff=$cutoff \
		t_sim=$t_sim trace/out.queue

	exec ./add-on/indiv trace/out.queue tcp

	set ff [expr 2.0 * $rtt_in_sec]
	for {set i 1} {$i <= $tcp_src_num} {incr i} {
        exec awk -f awk/thru_indiv.awk option=tcp ix=$i granul=$granul \
            cutoff=$cutoff trace/tcp_indiv_$i.tr
		exec ./add-on/ewma tcp $i $freq $cutoff trace/tcp_indiv_$i.tr
		exec ./add-on/anti-alias tcp $i $ff $cutoff \
			trace/tcp_ewma_thru_$i.xg
	}

	# Average Throughput for CoV plot
	for {set i 1} {$i <= $tcp_src_num} {incr i} {
		exec ./add-on/average_i tcp $i trace/tcp_thru_$i.xg
	}

	# CoV per flow
	for {set i 1} {$i <= $tcp_src_num} {incr i} {
		exec ./add-on/cov tcp $i trace/tcp_thru_avg_$i.dat \
		trace/tcp_thru_$i.dat $numeric_bottleneck_bandwidth
		set cov($i) [exec cat trace/tcp_cov_$i.dat]
	}

	# Average CoV
	set totCoV 0
	for {set i 1} {$i <= $tcp_src_num} {incr i} {
		set totCoV [expr $totCoV + $cov($i)]
	}
	#set avgCoV [expr $totCoV / $tcp_src_num]
	#puts "average CoV	$avgCoV"
	exec ./add-on/avg_cov tcp $totCoV $tcp_src_num \
		$numeric_bottleneck_bandwidth

	# INSTANTANEOUS QUEUE SIZE (individual plot)
	exec awk -f awk/tcp_q.awk cutoff=$cutoff trace/out.queue
    for {set i 1} {$i <= $tcp_src_num} {incr i} {
        exec awk -f awk/q_indiv.awk option=tcp ix=$i granul=$granul \
            cutoff=$cutoff trace/tcp_indiv_$i.tr
    }

	# AVERAGE RED QUEUE SIZE (aggregated red queue plot)
	if {$queuetype == "RED"} {
		exec awk -f awk/q_red.awk option=tcp granul=$granul cutoff=$cutoff \
				trace/red_q.tr
	}

	# LOSS RATE
	exec awk -f awk/tcp_loss.awk cutoff=$cutoff trace/out.queue
	for {set i 1} {$i <= $tcp_src_num} {incr i} {
        exec awk -f awk/loss_indiv.awk option=tcp ix=$i granul=$granul \
            cutoff=$cutoff trace/tcp_indiv_$i.tr
	}

	# CWND
	for {set i 1} {$i <= $tcp_src_num} {incr i} {
		exec awk -f awk/tcp_cwnd.awk granul=$granul cutoff=$cutoff \
			trace/tcp_cwnd_$i.tr > trace/tcp_cwnd_$i.tmp

		# delete the last line of a file
		exec sed \$d trace/tcp_cwnd_$i.tmp > trace/tcp_cwnd_$i.xg
		exec rm trace/tcp_cwnd_$i.tmp 
	}
}

proc tfrc_results {} {
	global queuetype tfrc_src_num
	global cutoff t_sim src_num granul 
	global numeric_bottleneck_bandwidth
	global freq rtt_in_sec

	# THROUGHPUT
	exec awk -f awk/tfrc_thru.awk cutoff=$cutoff trace/out.queue
	exec awk -f awk/total_avg_thru.awk cutoff=$cutoff \
		t_sim=$t_sim trace/out.queue

	exec ./add-on/indiv trace/out.queue tcpFriend

	set ff [expr 2.0 * $rtt_in_sec]
	for {set i 1} {$i <= $tfrc_src_num} {incr i} {
        exec awk -f awk/thru_indiv.awk option=tfrc ix=$i granul=$granul \
            cutoff=$cutoff trace/tfrc_indiv_$i.tr
		exec ./add-on/ewma tfrc $i $freq $cutoff trace/tfrc_indiv_$i.tr
		exec ./add-on/anti-alias tfrc $i $ff $cutoff \
			trace/tfrc_ewma_thru_$i.xg
	}

	# Average Throughput for CoV plot
	for {set i 1} {$i <= $tfrc_src_num} {incr i} {
		exec ./add-on/average_i tfrc $i trace/tfrc_thru_$i.xg
	}

	# CoV per flow
	for {set i 1} {$i <= $tfrc_src_num} {incr i} {
		exec ./add-on/cov tfrc $i trace/tfrc_thru_avg_$i.dat \
		trace/tfrc_thru_$i.dat $numeric_bottleneck_bandwidth
		set cov($i) [exec cat trace/tfrc_cov_$i.dat]
	}

	# Average CoV
	set totCoV 0
	for {set i 1} {$i <= $tfrc_src_num} {incr i} {
		set totCoV [expr $totCoV + $cov($i)]
	}
	#set avgCoV [expr $totCoV / $tfrc_src_num]
	#puts "average CoV	$avgCoV"
	exec ./add-on/avg_cov tfrc $totCoV $tfrc_src_num \
		$numeric_bottleneck_bandwidth

	# INSTANTANEOUS QUEUE SIZE (individual plot)
	exec awk -f awk/tfrc_inst_q.awk cutoff=$cutoff trace/out.queue
    for {set i 1} {$i <= $tfrc_src_num} {incr i} {
        exec awk -f awk/q_indiv.awk option=tfrc ix=$i granul=$granul \
            cutoff=$cutoff trace/tfrc_indiv_$i.tr
    }

	# AVERAGE RED QUEUE SIZE (aggregated red queue plot)
	if {$queuetype == "RED"} {
        exec awk -f awk/q_red.awk option=tfrc granul=$granul cutoff=$cutoff \
                trace/red_q.tr
	}

	# LOSS RATE
	exec awk -f awk/tfrc_loss.awk cutoff=$cutoff trace/out.queue
	for {set i 1} {$i <= $tfrc_src_num} {incr i} {
        exec awk -f awk/loss_indiv.awk option=tfrc ix=$i granul=$granul \
            cutoff=$cutoff trace/tfrc_indiv_$i.tr
	}
	if {[catch {exec grep tfrcTx temp > \
			trace/tfrc_loss_by_equation.tr} errmsg]} {
		puts "Abruptly Terminated - $errmsg"
	} else {
		exec grep tfrcTx temp > trace/tfrc_loss_by_equation.tr
	}
    exec ./add-on/loss_by_eq trace/tfrc_loss_by_equation.tr tfrc
    exec ./add-on/thru_by_eq trace/tfrc_loss_by_equation.tr tfrc


	# Avg Loss Interval
	exec grep tfrc_avg_loss_int temp > trace/tfrc_avg_int.tr
	exec ./add-on/map trace/tfrc_avg_int.tr tfrc_avg_int
}

proc tfwc_results {} {
	global queuetype tfwc_src_num
	global cutoff t_sim src_num granul
	global numeric_bottleneck_bandwidth
	global freq rtt_in_sec

	# THROUGHPUT
	exec awk -f awk/tfwc_thru.awk cutoff=$cutoff trace/out.queue
	exec awk -f awk/total_avg_thru.awk cutoff=$cutoff \
		t_sim=$t_sim trace/out.queue

	exec ./add-on/indiv trace/out.queue TFWC
	set ff [expr 2.0 * $rtt_in_sec]
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
        exec awk -f awk/thru_indiv.awk option=tfwc ix=$i granul=$granul \
            cutoff=$cutoff trace/tfwc_indiv_$i.tr
		exec ./add-on/ewma tfwc $i $freq $cutoff trace/tfwc_indiv_$i.tr
		exec ./add-on/anti-alias tfwc $i $ff $cutoff \
			trace/tfwc_ewma_thru_$i.xg
	}

	# Average Throughput for CoV plot
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
		exec ./add-on/average_i tfwc $i trace/tfwc_thru_$i.xg
	}

	# CoV per flow
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
		exec ./add-on/cov tfwc $i trace/tfwc_thru_avg_$i.dat \
		trace/tfwc_thru_$i.dat $numeric_bottleneck_bandwidth
		set cov($i) [exec cat trace/tfwc_cov_$i.dat]
	}

	# Average CoV
	set totCoV 0
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
		set totCoV [expr $totCoV + $cov($i)]
	}
	#set avgCoV [expr $totCoV / $tfwc_src_num]
	#puts "average CoV	$avgCoV"
	exec ./add-on/avg_cov tfwc $totCoV $tfwc_src_num \
		$numeric_bottleneck_bandwidth

	# INSTANTANEOUS QUEUE SIZE (individual plot)
	exec awk -f awk/tfwc_inst_q.awk cutoff=$cutoff trace/out.queue
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
        exec awk -f awk/q_indiv.awk option=tfwc ix=$i granul=$granul \
            cutoff=$cutoff trace/tfwc_indiv_$i.tr
	}

	# AVERAGE RED QUEUE SIZE (aggregated red queue plot)
	if {$queuetype == "RED"} {
        exec awk -f awk/q_red.awk option=tfwc granul=$granul \
		cutoff=$cutoff trace/red_q.tr
	}

	# LOSS RATE
	exec awk -f awk/tfwc_loss.awk cutoff=$cutoff trace/out.queue
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
        exec awk -f awk/loss_indiv.awk option=tfwc ix=$i granul=$granul \
            cutoff=$cutoff trace/tfwc_indiv_$i.tr
	}
	if {[catch {exec grep tfwcTx temp > \
			trace/tfwc_by_equation.tr} errmsg]} {
		puts "Abruptly Terminated - $errmsg"
	} else {
		exec grep tfwcTx temp > trace/tfwc_by_equation.tmp
		exec sed \$d trace/tfwc_by_equation.tmp > \
			trace/tfwc_by_equation.tr
		exec rm trace/tfwc_by_equation.tmp
	}
	exec ./add-on/loss_by_eq trace/tfwc_by_equation.tr tfwc
	exec ./add-on/thru_by_eq trace/tfwc_by_equation.tr tfwc

	# Loss rate calculated by TCP equation (using ALI)
	exec grep loss_by_cal temp > trace/tfwc_loss_by_cal.tr
	exec ./add-on/map trace/tfwc_loss_by_cal.tr tfwc_loss_by_cal

	# CWND
	exec grep cwnd_ temp > trace/tfwc_cwnd.1
	exec sed \$d trace/tfwc_cwnd.1 > trace/tfwc_cwnd.tr
	exec rm trace/tfwc_cwnd.1
	exec ./add-on/map trace/tfwc_cwnd.tr tfwc_cwnd

	# Avg Loss Interval
	exec grep avg_interval_ temp > trace/tfwc_avg_int.1
	exec sed \$d trace/tfwc_avg_int.1 > trace/tfwc_avg_int.tr
	exec rm trace/tfwc_avg_int.1
	exec grep pkt_drop_in_avg_hist temp > trace/tfwc_loss_in_hist.tr
	exec ./add-on/map trace/tfwc_avg_int.tr tfwc_avg_int
	exec ./add-on/map trace/tfwc_loss_in_hist.tr tfwc_loss_in_hist

	# TFWC Smoother
	exec grep num_inf temp > trace/tfwc_smoothing.tr
	exec ./add-on/s_ratio trace/tfwc_smoothing.tr

	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
        exec awk -f awk/smoother_indiv.awk option=tfwc ix=$i granul=$granul \
            cutoff=$cutoff trace/tfwc_sr_$i.tr
	}

	# TIMEOUT
	exec grep TIMEOUT temp > trace/tfwc_timeout.tr
	exec ./add-on/timeout trace/tfwc_timeout.tr
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
		for {set j 1} {$j <= $tfwc_src_num} {incr j} {
			exec ./add-on/paste $j $tfwc_src_num $cutoff \
				trace/tfwc_to_$i.tr trace/tfwc_cwnd_$j.tr
		}
	}
	
	# Estimated Timeout
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
		exec ./add-on/estimated_t0 $i $cutoff \
			trace/tfwc_to_$i.tr trace/tfwc_thru_$i.xg
	}
}

# end of file
