#
# Copyright(c) 1991-1997 Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by the Computer Systems
#      Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/sc/common.tcp.tcl,v
# 1.6 2006/02/23 03:33:01 soohyunc Exp $ 
#

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
set numeric_bottleneck_bandwidth	$bottleneckBW
set tcp_app_num		$tcp_src_num
set tfrc_app_num	$tfrc_src_num
set tfwc_app_num	$tfwc_src_num
set node_num	[expr ($tcp_node_num + $tfrc_node_num + $tfwc_node_num)]
set src_num	[expr ($tcp_src_num + $tfrc_src_num + $tfwc_src_num)]
set app_num	[expr ($tcp_app_num + $tfrc_app_num + $tfwc_app_num)]
set t_sim       $duration
set q_size      $q_len
set queuetype   $queue_type

#set access_bandwidth            50Mb
#set bottleneck_bandwidth        15Mb
#set bottleneck_delay            20ms
#set numeric_bottleneck_bandwidth        15
#set numeric_bottleneck_delay    20
#set min_dly                     0.5
#set max_dly                     5.0

set access_bandwidth            5Mb
set bottleneck_bandwidth        "$numeric_bottleneck_bandwidth\Mb"
set bottleneck_delay            10ms
set numeric_bottleneck_delay    10
set min_dly                     0.5
set max_dly                     2.0
set maxth               [expr ($q_size / 2.0)]
set minth               [expr ($maxth / 3.0)]

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
$RVftp set max_ 10.0
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
}
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
	} else {
		fifo_plots
	}

	exit 0
}

proc common_files {} {
	global ns output queue_out
        $ns flush-trace
        close $output
        close $queue_out

	# making blank files for Gnuplot
	fake_gnuplot_files

        #exec perl ../../ns-2.28/bin/set_flow_id -s trace/out.tr
        #exec perl ../../ns-2.28/bin/getrc -s 2 -d 3 < trace/out.tr > trace/foo
        #exec perl ../../ns-2.28/bin/raw2xg -s 0.01 -m 90 < trace/foo > trace/all.xg
}

proc red_plots {} {
	global tcp_src_num tfrc_src_num tfwc_src_num

	# THROUGHPUT PLOT
	exec gnuplot plt/red.thru.plt

	# INSTANTANEOUS QUEUE SIZE PLOT
	exec gnuplot plt/red.q.plt

	# AVERAGE RED QUEUE SIZE PLOT
	exec gnuplot plt/red.avg.plt

	# LOSS RATE PLOT
	exec gnuplot plt/red.loss.plt 

	if {$tcp_src_num > 0} {
		exec gnuplot plt/tcp_red_cwnd.plt
	}
	if {$tfrc_src_num > 0} {
		exec gnuplot plt/tfrc_red_ali.plt
	}
	if {$tfwc_src_num > 0} {
		exec gnuplot plt/tfwc_red_cwnd.plt
	        exec gnuplot plt/tfwc_red_ali.plt &
	}
}

proc fifo_plots {} {
	global tcp_src_num tfrc_src_num tfwc_src_num

	# THROUGHPUT PLOT
	exec gnuplot plt/fifo.thru.plt &

	# INSTANTANEOUS QUEUE SIZE PLOT
	exec gnuplot plt/fifo.q.plt &

	# LOSS RATE PLOT
	exec gnuplot plt/fifo.loss.plt &

	if {$tcp_src_num > 0} {
		exec gnuplot plt/tcp_fifo_cwnd.plt &
	}
	if {$tfrc_src_num > 0} {
		exec gnuplot plt/tfrc_fifo_ali.plt &
	}
	if {$tfwc_src_num > 0} {
		exec gnuplot plt/tfwc_fifo_cwnd.plt &
	        exec gnuplot plt/tfwc_fifo_ali.plt &
	}
}

proc tcp_results {} {
	global queuetype tcp_src_num

        # THROUGHPUT
        exec awk -f awk/tcp_thru.awk trace/out.queue
        exec awk -f awk/tcp_thru_tot.awk trace/out.queue

        # INSTANTANEOUS QUEUE SIZE
        exec awk -f awk/tcp_q.awk trace/out.queue

        # AVERAGE RED QUEUE SIZE
	if {$queuetype == "RED"} {
	        exec grep avg_redq temp > trace/tcp_red_avg.tr
	        exec awk -f awk/tcp_red_avg.awk trace/tcp_red_avg.tr
	}

        # LOSS RATE
        exec awk -f awk/tcp_loss.awk trace/out.queue

        # CWND
	for {set i 1} {$i <= $tcp_src_num} {incr i} {
        	exec awk -f awk/tcp_cwnd.awk trace/tcp_cwnd_$i.tr > trace/tcp_cwnd_$i.xg 
	}
}

proc tfrc_results {} {
	global queuetype

        # THROUGHPUT
        exec awk -f awk/tfrc_thru.awk trace/out.queue
        exec awk -f awk/tfrc_thru_tot.awk trace/out.queue

        # INSTANTANEOUS QUEUE SIZE
        exec awk -f awk/tfrc_inst_q.awk trace/out.queue

        # AVERAGE RED QUEUE SIZE
	if {$queuetype == "RED"} {
	        exec grep avg_redq temp > trace/tfrc_red_avg.tr
	        exec awk -f awk/tfrc_red_avg.awk trace/tfrc_red_avg.tr
	}

        # LOSS RATE
        exec awk -f awk/tfrc_loss.awk trace/out.queue

        # Avg Loss Interval
        exec grep tfrc_avg_loss_int temp > trace/tfrc_avg_int.tr
        exec awk -f awk/tfrc_avg_int.awk trace/tfrc_avg_int.tr
}

proc tfwc_results {} {
	global queuetype

        # THROUGHPUT
        exec awk -f awk/tfwc_thru.awk trace/out.queue
        exec awk -f awk/tfwc_thru_tot.awk trace/out.queue

        # INSTANTANEOUS QUEUE SIZE
        exec awk -f awk/tfwc_inst_q.awk trace/out.queue

        # AVERAGE RED QUEUE SIZE
	if {$queuetype == "RED"} {
	        exec grep avg_redq temp > trace/tfwc_red_avg.tr
	        exec awk -f awk/tfwc_red_avg.awk trace/tfwc_red_avg.tr
	}

        # LOSS RATE
        exec awk -f awk/tfwc_loss.awk trace/out.queue

        # CWND
        exec grep cwnd_ temp > trace/tfwc_cwnd.tr
        exec awk -f awk/tfwc_cwnd.awk trace/tfwc_cwnd.tr

        # Avg Loss Interval
        exec grep avg_interval_ temp > trace/tfwc_avg_int.tr
        exec grep pkt_drop_in_avg_hist temp > trace/tfwc_loss_in_hist.tr
        exec awk -f awk/tfwc_avg_int.awk trace/tfwc_avg_int.tr
        exec awk -f awk/tfwc_loss_in_hist.awk trace/tfwc_loss_in_hist.tr
}

# Gnuplot fails to plot when it contains non-exisiting files. So we would like
# to generate blank files if it is not exisiting.
proc fake_gnuplot_files {} {
	global tcp_src_num tfrc_src_num tfwc_src_num
	global queuetype
	set cutoff	20

	# TCP plotting files
	for {set i 1} {$i <=4} {incr i} {
		exec echo "$cutoff 0" > trace/tcp_cwnd_$i.xg
	}

	exec echo "$cutoff 0" > trace/tcp_loss.xg
	exec echo "$cutoff 0" > trace/tcp_q.xg
	exec echo "$cutoff 0" > trace/tcp_thru.xg
	if {$queuetype == "RED"} {
		exec echo "$cutoff 0" >> trace/tcp_red_avg.xg
	}

	# TFRC plotting files
	exec echo "$cutoff 0" > trace/tfrc_avg_int_01.xg
	exec echo "$cutoff 0" > trace/tfrc_avg_int_02.xg
	exec echo "$cutoff 0" > trace/tfrc_avg_int_03.xg
	exec echo "$cutoff 0" > trace/tfrc_avg_int_04.xg

	exec echo "$cutoff 0" > trace/tfrc_loss.xg
	exec echo "$cutoff 0" > trace/tfrc_q.xg
	exec echo "$cutoff 0" > trace/tfrc_thru.xg
	if {$queuetype == "RED"} {
		exec echo "$cutoff 0" > trace/tfrc_red_avg.xg
	}

	# TFWC plotting files
	exec echo "$cutoff 0" > trace/tfwc_avg_int_01.xg
	exec echo "$cutoff 0" > trace/tfwc_avg_int_02.xg
	exec echo "$cutoff 0" > trace/tfwc_avg_int_03.xg
	exec echo "$cutoff 0" > trace/tfwc_avg_int_04.xg
	exec echo "$cutoff 0" > trace/tfwc_loss_in_hist_01.xg
	exec echo "$cutoff 0" > trace/tfwc_loss_in_hist_02.xg
	exec echo "$cutoff 0" > trace/tfwc_loss_in_hist_03.xg
	exec echo "$cutoff 0" > trace/tfwc_loss_in_hist_04.xg

	exec echo "$cutoff 0" > trace/tfwc_cwnd_01.xg
	exec echo "$cutoff 0" > trace/tfwc_cwnd_02.xg
	exec echo "$cutoff 0" > trace/tfwc_cwnd_03.xg
	exec echo "$cutoff 0" > trace/tfwc_cwnd_04.xg

	exec echo "$cutoff 0" > trace/tfwc_loss.xg
	exec echo "$cutoff 0" > trace/tfwc_q.xg
	exec echo "$cutoff 0" > trace/tfwc_thru.xg
	if {$queuetype == "RED"} {
		exec echo "$cutoff 0" > trace/tfwc_red_avg.xg
	}
}
