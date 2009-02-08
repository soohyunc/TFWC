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
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/sc/common.tfwc.tcl,v 1.27 2006/02/23 03:36:39 soohyunc Exp $ 
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
set node_num    $tfwc_src_num
set src_num     $node_num
set app_num     $src_num
set t_sim       $duration
set q_size      $q_len
set queuetype	$queue_type

set access_bandwidth		50Mb
set bottleneck_bandwidth	15Mb
set bottleneck_delay		20ms
set numeric_bottleneck_bandwidth	15
set numeric_bottleneck_delay	20
set min_dly			0.5
set max_dly			5.0
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
# automaic max_p approximation
#
if {$max_p == "auto"} {
	source max_p.tcl
	puts " max_p		$max_p"
	set max_p_inv	[expr (1.0/$max_p)]
	puts " max_p_inv	$max_p_inv"
} else {
	puts " max_p		$max_p"
	set max_p_inv	[expr (1.0/$max_p)]
	puts " max_p_inv	$max_p_inv"

}

#
# create bottleneck nodes
#
set n(2) [$ns node]
set n(3) [$ns node]

#
# create source nodes
#
for {set i 1} {$i <= $src_num} {incr i} {
        set src_node($i) [$ns node]
        puts " creating...      src_node($i)"
}

#
# TFWC Agent
#
for {set i 1} {$i <= $src_num} {incr i} {
	set tfwc_src($i) [new Agent/TFWC]
	$ns attach-agent $src_node($i) $tfwc_src($i)
}

#
# TFWC Sink
#
for {set i 1} {$i <= $src_num} {incr i} {
        set tfwc_sink($i) [new Agent/TFWCSink]
        $ns attach-agent $n(3) $tfwc_sink($i)
}

#
# connections
#
for {set i 1} {$i <= $src_num} {incr i} {
        $ns connect $tfwc_src($i) $tfwc_sink($i)
}

#
# create links between sources and bottleneck node
#
for {set i 1} {$i <= $src_num} {incr i} {
        $ns duplex-link $src_node($i) $n(2) $access_bandwidth $dly($i)ms DropTail
}

#
# create link between bottleneck node to the destination
#
$ns duplex-link $n(2) $n(3) $bottleneck_bandwidth $bottleneck_delay $queuetype
set redq [[$ns link $n(2) $n(3)] queue]
$redq set queue_in_bytes_ false
$redq set bytes_	false
$redq set drop_tail_	false
$redq set drop_rand_	true
$redq set cautious_	1
$redq set linterm_	$max_p_inv
$redq set thresh_       $minth
$redq set maxthresh_    $maxth
if {$q_w == "auto"} {
	$redq set q_weight_	-1
} else {
	$redq set q_weight_	$q_w
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
# create FTP from n(0)<-->n(3) and n(1)<-->n(3)
#
for {set i 1} {$i <= $app_num} {incr i} {
        set ftp($i) [new Application/FTP]
        $ftp($i) attach-agent $tfwc_src($i)
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


proc finish_for_red {} {
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
        exec awk -f awk/tfwc_thru.awk trace/out.queue
        exec awk -f awk/tcp_thru.awk trace/out.queue
        #exec xgraph -bg white -P -x time -y "rate (Mb/s)" -t "Aggregated Thruput (TFWCs)" trace/tfwc_thru.xg &
        exec gnuplot plt/tfwc_red_thru.plt &

        #
        # INSTANTANEOUS QUEUE SIZE PLOT
        #
        exec awk -f awk/tfwc_inst_q.awk trace/out.queue

	#
	# AVERAGE RED QUEUE SIZE PLOT
	#
	exec grep avg_redq temp.tfwc > trace/tfwc_red_avg.tr
	exec awk -f awk/tfwc_red_avg.awk trace/tfwc_red_avg.tr
        exec gnuplot plt/tfwc_red_q.plt &
	exec gnuplot plt/tfwc_red_avg.plt &

        #
        # LOSS RATE PLOT
        #
        exec awk -f awk/tfwc_loss.awk trace/out.queue
        exec gnuplot plt/tfwc_red_loss.plt &

        #
        # CWND
        #
        exec grep cwnd_ temp.tfwc > trace/tfwc_cwnd.tr
        exec awk -f awk/tfwc_cwnd.awk trace/tfwc_cwnd.tr
        #exec xgraph -bg white -x time -y cwnd -t "TFWC CWND Dynamics" trace/tfwc_cwnd_01.xg trace/tfwc_cwnd_02.xg trace/tfwc_cwnd_03.xg trace/tfwc_cwnd_04.xg &
        exec gnuplot plt/tfwc_red_cwnd.plt &

        #
        # Avg Loss Interval
        #
        exec grep avg_interval_ temp.tfwc > trace/tfwc_avg_int.tr
        exec awk -f awk/tfwc_avg_int.awk trace/tfwc_avg_int.tr

        exec grep pkt_drop_in_avg_hist temp.tfwc > trace/tfwc_loss_in_hist.tr
        exec awk -f awk/tfwc_loss_in_hist.awk trace/tfwc_loss_in_hist.tr

        #exec xgraph -bg white -x time -y "avg_loss_interval" -t "Avg Loss Interval" trace/tfwc_avg_int_01.xg trace/tfwc_avg_int_02.xg trace/tfwc_avg_int_03.xg trace/tfwc_avg_int_04.xg &
        exec gnuplot plt/tfwc_red_ali.plt &

        exit 0
}

proc finish_for_droptail {} {
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
        exec awk -f awk/tfwc_thru.awk trace/out.queue
        exec awk -f awk/tcp_thru.awk trace/out.queue
        #exec xgraph -bg white -P -x time -y "rate (Mb/s)" -t "Aggregated Thruput (TFWCs)" trace/tfwc_thru.xg &
        exec gnuplot plt/tfwc_dt_thru.plt &

        #
        # INSTANTANEOUS QUEUE SIZE PLOT
        #
        exec awk -f awk/tfwc_inst_q.awk trace/out.queue
        exec gnuplot plt/tfwc_dt_q.plt &

        #
        # LOSS RATE PLOT
        #
        exec awk -f awk/tfwc_loss.awk trace/out.queue
        exec gnuplot plt/tfwc_dt_loss.plt &

        #
        # CWND
        #
        exec grep cwnd_ temp.tfwc > trace/tfwc_cwnd.tr
        exec awk -f awk/tfwc_cwnd.awk trace/tfwc_cwnd.tr
        #exec xgraph -bg white -x time -y cwnd -t "TFWC CWND Dynamics" trace/tfwc_cwnd_01.xg trace/tfwc_cwnd_02.xg trace/tfwc_cwnd_03.xg trace/tfwc_cwnd_04.xg &
        exec gnuplot plt/tfwc_dt_cwnd.plt &

        #
        # Avg Loss Interval
        #
        exec grep avg_interval_ temp.tfwc > trace/tfwc_avg_int.tr
        exec awk -f awk/tfwc_avg_int.awk trace/tfwc_avg_int.tr

        exec grep pkt_drop_in_avg_hist temp.tfwc > trace/tfwc_loss_in_hist.tr
        exec awk -f awk/tfwc_loss_in_hist.awk trace/tfwc_loss_in_hist.tr

        #exec xgraph -bg white -x time -y "avg_loss_interval" -t "Avg Loss Interval" trace/tfwc_avg_int_01.xg trace/tfwc_avg_int_02.xg trace/tfwc_avg_int_03.xg trace/tfwc_avg_int_04.xg &
        exec gnuplot plt/tfwc_dt_ali.plt &

        exit 0

}
