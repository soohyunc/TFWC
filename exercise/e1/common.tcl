#
# Copyright(c) 2005-2009 University College London
# All rights reserved.
#
# AUTHOR: Soo-Hyun Choi <s.choi@cs.ucl.ac.uk>
# 		  UCL Computer Science Department
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


# create a simulator object
set ns [new Simulator]

# file openings
set output [open trace/out.tr w]
$ns trace-all $output

set queue_out [open trace/out.queue w]

# sim env
#set simenv [open trace/THIS w]

# hostname
set hn [info hostname]

# set pwd
set curr_dir [pwd]
puts ""
puts " $hn:$curr_dir"
puts $simenv ""
puts $simenv " $hn:$curr_dir"

# simulation parameters
#set tcl_precision	6
set tcp_node_num	$tcp_src_num
set tfrc_node_num	$tfrc_src_num
set tfwc_node_num	$tfwc_src_num
set tcp_app_num		$tcp_src_num
set tfrc_app_num	$tfrc_src_num
set tfwc_app_num	$tfwc_src_num
set min_dly			$accessMinDel
set max_dly			$accessMaxDel

set numeric_access_bandwidth \
	$accessBW
set numeric_bottleneck_bandwidth \
	$bottleneckBW
set numeric_bottleneck_delay \
	$bottleneckDel
set access_bandwidth \
	"$numeric_access_bandwidth\Mb"
set bottleneck_bandwidth \
	"$numeric_bottleneck_bandwidth\Mb"
set bottleneck_delay \
	"$numeric_bottleneck_delay\ms"
set node_num	\
	[expr ($tcp_node_num + $tfrc_node_num + $tfwc_node_num)]
set src_num		\
	[expr ($tcp_src_num + $tfrc_src_num + $tfwc_src_num)]
set app_num		\
	[expr ($tcp_app_num + $tfrc_app_num + $tfwc_app_num)]
set t_sim       $duration
set q_size      $q_len
set queuetype   $queue_type
set maxth		[expr ($q_size / 2.0)]
set minth		[expr ($maxth / 3.0)]

set rtt_in_msec \
	[expr (2.0 * ($bottleneckDel + ($min_dly + $max_dly)/2.0))]
set rtt_in_sec \
	[expr $rtt_in_msec * .001]
set bottleneckBW_in_Bps \
	[expr $bottleneckBW * 1000000]
set delbw_in_bits	\
	[expr $rtt_in_sec * $bottleneckBW_in_Bps]

set pkt_size	1000; # packet size is 1000 bytes
set delbw		[expr $delbw_in_bits / (8 * $pkt_size)]

# initial cutoff time
set cutoff	20

# gnuplot sampling granularity
set granul [expr $rtt_in_sec]

puts ""
puts " Bandwidth-Delay Product		$delbw	packets"
puts " Approximated e2e delay (RTT)	$rtt_in_sec	(sec)"
puts " Approximated e2e delay (RTT)	$rtt_in_msec (msec)"
puts ""
puts $simenv ""
puts $simenv " Bandwidth-Delay Product		$delbw	packets"
puts $simenv " Approximated e2e delay (RTT)	$rtt_in_sec	(sec)"
puts $simenv " Approximated e2e delay (RTT)	$rtt_in_msec (msec)"
puts $simenv ""


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
	puts $simenv " dly($i)          $dly($i)"
}

#
# automaic max_p approximation for RED queue
#
if {$queuetype == "RED"} {
	if {$max_p == "auto"} {
		source max_p.tcl
		puts " max_p            $max_p"
		puts $simenv " max_p            $max_p"
		set max_p_inv   [expr (1.0/$max_p)]
		puts " max_p_inv        $max_p_inv"
		puts $simenv " max_p_inv        $max_p_inv"
	} else {
		puts " max_p            $max_p"
		puts $simenv " max_p            $max_p"
		set max_p_inv   [expr (1.0/$max_p)]
		puts " max_p_inv        $max_p_inv"
		puts $simenv " max_p_inv        $max_p_inv"
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
	puts $simenv " creating...	tcp_node($i)"
}

for {set i 1} {$i <= $tfrc_node_num} {incr i} {
	set tfrc_node($i) [$ns node]
	puts " creating...	tfrc_node($i)"
	puts $simenv " creating...	tfrc_node($i)"
}

for {set i 1} {$i <= $tfwc_node_num} {incr i} {
	set tfwc_node($i) [$ns node]
	puts " creating...	tfwc_node($i)"
	puts $simenv " creating...	tfwc_node($i)"
}

#
# create TCP/Sack1, TFRC, and TFWC Agent
#
Agent/TCP/Sack1 set window_ 10000
Agent/TCP/Sack1 set packetSize_ 960
for {set i 1} {$i <= $tcp_src_num} {incr i} {
	set tcp_src($i) [new Agent/TCP/Sack1]
	set tcpwin($i) [open trace/tcp_cwnd_$i.tr w]
	$tcp_src($i) attach $tcpwin($i)
	$tcp_src($i) trace cwnd_
	$ns attach-agent $tcp_node($i) $tcp_src($i)
}

Agent/TFRC set packetSize_ 1000
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
	$ns duplex-link $tcp_node($i) $n(2) \
		$access_bandwidth $dly($i)ms DropTail
}

for {set i 1} {$i <= $tfrc_src_num} {incr i} {
	$ns duplex-link $tfrc_node($i) $n(2) \
		$access_bandwidth $dly($i)ms DropTail
}

for {set i 1} {$i <= $tfwc_src_num} {incr i} {
	$ns duplex-link $tfwc_node($i) $n(2) \
		$access_bandwidth $dly($i)ms DropTail
}

#
# create link between bottleneck node to the destination
#
$ns duplex-link $n(2) $n(3) \
	$bottleneck_bandwidth $bottleneck_delay $queuetype

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

for {set i [expr $tcp_app_num + 1]} \
	{$i <= [expr $tcp_app_num + $tfrc_app_num]} \
	{incr i} {
		set ftp($i) [new Application/FTP]
		$ftp($i) attach-agent \
		$tfrc_src([expr $i - $tcp_app_num])
}

for {set i [expr $tcp_app_num + $tfrc_app_num + 1]} \
	{$i <= $app_num} \
	{incr i} {
		set ftp($i) [new Application/FTP]
		$ftp($i) attach-agent \
		$tfwc_src([expr $i - $tcp_app_num - $tfrc_app_num])
}

#
# start FTP
#
for {set i 1} {$i <= $app_num} {incr i} {
	$ns at $startT($i) "$ftp($i) start"
	puts " startT($i)       $startT($i)"
	puts $simenv " startT($i)       $startT($i)"
}
puts ""
puts ""
puts $simenv ""
puts $simenv ""
#
# Make a queue trace
#
$ns trace-queue $n(2) $n(3) $queue_out

# close file descriptor
close $simenv

proc finish {} {
	global tcp_src_num tfrc_src_num tfwc_src_num
	global queuetype
	common_files

	# post processing for each type of sources
	if {$tcp_src_num > 0} {
		puts ""
		tcp_results
	}

	if {$tfrc_src_num > 0} {
		puts ""
		tfrc_results
	}

	if {$tfwc_src_num > 0} {
		puts ""
		tfwc_results
	}

	# plotting for each type of queue descipline
	if {$queuetype == "RED"} {
		puts ""
		red_plots
	} 

	if {$queuetype == "DropTail"} {
		puts ""
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
	global cutoff rtt_in_sec curr_dir t_sim

    # 30 secs from the half of the sim time
    set from [expr ($t_sim / 2.0)]
    set to   [expr ($from + 30)]

	# THROUGHPUT PLOT
	exec ../plt/red.thru.sh $curr_dir $from $to 2> /dev/null

	# INSTANTANEOUS QUEUE SIZE PLOT
	exec ../plt/red.q.sh $curr_dir $from $to 2> /dev/null

	# AVERAGE RED QUEUE SIZE PLOT
	exec ../plt/red.avg.sh $curr_dir $from $to 2> /dev/null

	# LOSS RATE PLOT
	exec ../plt/red.loss.sh $curr_dir $from $to 2> /dev/null

	if {$tcp_src_num > 0} {
		exec ../plt/plot.sh tcp thru red $from $to
		exec ../plt/plot.sh tcp ewma_thru red $from $to
		exec ../plt/plot.sh tcp ant_thru red $from $to
		exec ../plt/plot.sh tcp loss red $from $to
		exec ../plt/plot.sh tcp cwnd red $from $to
		exec ../plt/plot.sh tcp q red $from $to
	}
	if {$tfrc_src_num > 0} {
		exec ../plt/plot.sh tfrc thru red $from $to
		exec ../plt/plot.sh tfrc ewma_thru red $from $to
		exec ../plt/plot.sh tfrc ant_thru red $from $to
		exec ../plt/plot.sh tfrc loss red $from $to
		exec ../plt/plot.sh tfrc cwnd red $from $to
		exec ../plt/plot.sh tfrc q red $from $to
		exec ../plt/plot.sh tfrc avg_int red $from $to
	}
	if {$tfwc_src_num > 0} {
		exec ../plt/plot.sh tfwc thru red $from $to
		exec ../plt/plot.sh tfwc ewma_thru red $from $to
		exec ../plt/plot.sh tfwc ant_thru red $from $to
		exec ../plt/plot.sh tfwc loss red $from $to
		exec ../plt/plot.sh tfwc loss_by_cal red $from $to
		exec ../plt/plot.sh tfwc cwnd red $from $to
		exec ../plt/plot.sh tfwc q red $from $to
		exec ../plt/plot.sh tfwc sr red $from $to
		exec ../plt/plot.sh tfwc avg_int red $from $to
	}
}

proc fifo_plots {} {
	global tcp_src_num tfrc_src_num tfwc_src_num app_num
	global cutoff rtt_in_sec curr_dir t_sim 

    # 30 secs from the half of the sim time
    set from [expr ($t_sim / 2.0)]
    set to   [expr ($from + 30)]

	# THROUGHPUT PLOT
	exec ../plt/fifo.thru.sh $curr_dir $from $to 2> /dev/null

	# INSTANTANEOUS QUEUE SIZE PLOT
	exec ../plt/fifo.q.sh $curr_dir $from $to 2> /dev/null

	# LOSS RATE PLOT
	exec ../plt/fifo.loss.sh $curr_dir $from $to 2> /dev/null

	if {$tcp_src_num > 0} {
		exec ../plt/plot.sh tcp thru fifo $from $to
		exec ../plt/plot.sh tcp ewma_thru fifo $from $to
		exec ../plt/plot.sh tcp ant_thru fifo $from $to
		exec ../plt/plot.sh tcp loss fifo $from $to
		exec ../plt/plot.sh tcp cwnd fifo $from $to
		exec ../plt/plot.sh tcp q fifo $from $to
	}
	if {$tfrc_src_num > 0} {
		exec ../plt/plot.sh tfrc thru fifo $from $to
		exec ../plt/plot.sh tfrc ewma_thru fifo $from $to
		exec ../plt/plot.sh tfrc ant_thru fifo $from $to
		exec ../plt/plot.sh tfrc loss fifo $from $to
		exec ../plt/plot.sh tfrc cwnd fifo $from $to
		exec ../plt/plot.sh tfrc q fifo $from $to
		exec ../plt/plot.sh tfrc avg_int fifo $from $to
	}
	if {$tfwc_src_num > 0} {
		exec ../plt/plot.sh tfwc thru fifo $from $to
		exec ../plt/plot.sh tfwc ewma_thru fifo $from $to
		exec ../plt/plot.sh tfwc ant_thru fifo $from $to
		exec ../plt/plot.sh tfwc loss fifo $from $to
		exec ../plt/plot.sh tfwc loss_by_cal fifo $from $to
		exec ../plt/plot.sh tfwc cwnd fifo $from $to
		exec ../plt/plot.sh tfwc q fifo $from $to
		exec ../plt/plot.sh tfwc sr fifo $from $to
		exec ../plt/plot.sh tfwc avg_int fifo $from $to
	}
}

proc tcp_results {} {
	global queuetype tcp_src_num
	global cutoff t_sim src_num granul 
	global numeric_bottleneck_bandwidth
	global rtt_in_sec

    # 30 secs from the half of the sim time
    set from [expr ($t_sim / 2.0)]
    set to   [expr ($from + 30)]

	# THROUGHPUT
	exec awk -f ../awk/tcp_thru.awk \
				cutoff=$from \
                until=$to \
				trace/out.queue
	exec awk -f ../awk/total_avg_thru.awk \
				cutoff=$from \
				t_sim=$to \
				trace/out.queue

	#this will generate per flow trace files
	exec ../tools/indiv trace/out.queue tcp

	# capture inter-packet arrival time
	# (this is median value instead of arithmetic average)
	#for {set i 1} {$i <= $tcp_src_num} {incr i} {
	#	exec ../tools/ipa tcp ipa \
	#			$i \
	#			$from \
	#			trace/tcp_indiv_$i.tr
	#}

	# avoid unnecessary long floating point value
	set tcl_precision 6
	# set over-sampling frequency for EWMA
	if {$queuetype == "RED"} {
		if {$rtt_in_sec < 0.05} {
			set max_factor .25
		} elseif {$rtt_in_sec >= 0.05 && $rtt_in_sec < 0.1} {
			set max_factor .75
		} elseif {$rtt_in_sec >= 0.1 && $rtt_in_sec < 0.5} {
			set max_factor 1
		} else {
			set max_factor 4
		}
	} else {
		if {$rtt_in_sec < 0.05} {
			set max_factor .5
		} elseif {$rtt_in_sec >= 0.05 && $rtt_in_sec < 0.1} {
			set max_factor 1
		} elseif {$rtt_in_sec >= 0.1 && $rtt_in_sec < 0.5} {
			set max_factor 2
		} else {
			set max_factor 4
		}
	}

	set freq [expr $rtt_in_sec/$max_factor]
	if {$freq > 0.5} {
		set freq 0.5
	}
	set ff [expr 10 * $rtt_in_sec]
	if {$ff > 0.5} {
		set ff 0.5
	}
	set tcl_precision 16

#	for {set i 1} {$i <= $tcp_src_num} {incr i} {
#		set max_freq($i) [expr $rtt_in_sec/$max_factor]
#		
#		# inter-packet arrival (IPA) time per flow
#		set ipa($i) [exec cat trace/tcp_ipa_$i.dat]
#	
#		# the over-sampling frequency shouldn't go beyond IPA time
#		if {$ipa($i) > $max_freq($i)} {
#			set freq($i) $ipa($i)
#			set factor($i) [expr $rtt_in_sec/$freq($i)]
#		} else {
#			set freq($i) $max_freq($i)
#			set factor($i) $max_factor
#		}
#		puts " tcp ewma sampling freq($i): $freq($i)"
#		puts " tcp ewma sampling factor($i): $factor($i)"
#	}

	for {set i 1} {$i <= $tcp_src_num} {incr i} {
        exec awk -f ../awk/thru_indiv.awk \
					option=tcp \
					ix=$i \
					granul=$granul \
					cutoff=$from \
                    until=$to \
					trace/tcp_indiv_$i.tr
		exec ../tools/ewma tcp thru \
				$i \
				$freq \
				0.085 \
				$from \
                $to \
				trace/tcp_indiv_$i.tr
		exec ../tools/anti-alias tcp thru \
				$i \
				$ff \
				$from \
                $to \
				trace/tcp_ewma_thru_$i.xg
	}

	# Average Throughput for CoV plot
	for {set i 1} {$i <= $tcp_src_num} {incr i} {
		exec ../tools/average_i tcp \
				$i \
                $from \
                $to \
				trace/tcp_thru_$i.xg
	}

	# CoV per flow
	for {set i 1} {$i <= $tcp_src_num} {incr i} {
		exec ../tools/cov tcp \
				$i \
				trace/tcp_thru_avg_$i.dat \
				trace/tcp_thru_$i.dat \
				$numeric_bottleneck_bandwidth
		set cov($i) [exec cat trace/tcp_cov_$i.dat]
	}

	# Average CoV
	set totCoV 0
	for {set i 1} {$i <= $tcp_src_num} {incr i} {
		set totCoV [expr $totCoV + $cov($i)]
	}
	#set avgCoV [expr $totCoV / $tcp_src_num]
	#puts "average CoV	$avgCoV"
	exec ../tools/avg_cov tcp \
			$totCoV \
			$tcp_src_num \
			$numeric_bottleneck_bandwidth

	# INSTANTANEOUS QUEUE SIZE (individual plot)
	exec awk -f ../awk/tcp_q.awk cutoff=$from trace/out.queue
    for {set i 1} {$i <= $tcp_src_num} {incr i} {
        exec awk -f ../awk/q_indiv.awk \
					option=tcp \
					ix=$i \
					granul=$granul \
					cutoff=$from \
                    until=$to \
					trace/tcp_indiv_$i.tr
    }

	# AVERAGE RED QUEUE SIZE (aggregated red queue plot)
	if {$queuetype == "RED"} {
		exec awk -f ../awk/q_red.awk \
					option=tcp \
					granul=$granul \
					cutoff=$from \
                    until=$to \
					trace/red_q.tr
	}

	# LOSS RATE
	exec awk -f ../awk/tcp_loss.awk cutoff=$from trace/out.queue
	for {set i 1} {$i <= $tcp_src_num} {incr i} {
        exec awk -f ../awk/loss_indiv.awk \
					option=tcp \
					ix=$i \
					granul=$granul \
					cutoff=$from \
                    until=$to \
					trace/tcp_indiv_$i.tr
	}

	# CWND
	for {set i 1} {$i <= $tcp_src_num} {incr i} {
		exec awk -f ../awk/tcp_cwnd.awk \
					granul=$granul \
					cutoff=$from \
                    until=$to \
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
	global rtt_in_sec

    # 30 secs from the half of the sim time
    set from [expr ($t_sim / 2.0)]
    set to   [expr ($from + 30)]

	# THROUGHPUT
	exec awk -f ../awk/tfrc_thru.awk \
				cutoff=$from \
                until=$to \
				trace/out.queue
	exec awk -f ../awk/total_avg_thru.awk \
				cutoff=$from \
				t_sim=$to \
				trace/out.queue

	#this will generate per flow trace files
	exec ../tools/indiv trace/out.queue tcpFriend

	# capture inter-packet arrival time
	# (this is median value instead of arithmetic average)
	#for {set i 1} {$i <= $tfrc_src_num} {incr i} {
	#	exec ../tools/ipa tfrc ipa \
	#			$i \
	#			$from \
	#			trace/tfrc_indiv_$i.tr
	#}

	# avoid unnecessary long floating point value
	set tcl_precision 6
	# set over-sampling frequency for EWMA
	if {$queuetype == "RED"} {
		if {$rtt_in_sec < 0.05} {
			set max_factor .25
		} elseif {$rtt_in_sec >= 0.05 && $rtt_in_sec < 0.1} {
			set max_factor .75
		} elseif {$rtt_in_sec >= 0.1 && $rtt_in_sec < 0.5} {
			set max_factor 1
		} else {
			set max_factor 4
		}
	} else {
		if {$rtt_in_sec < 0.05} {
			set max_factor .5
		} elseif {$rtt_in_sec >= 0.05 && $rtt_in_sec < 0.1} {
			set max_factor 1
		} elseif {$rtt_in_sec >= 0.1 && $rtt_in_sec < 0.5} {
			set max_factor 2
		} else {
			set max_factor 4
		}
	}

	set freq [expr $rtt_in_sec/$max_factor]
	set ff [expr 6 * $rtt_in_sec]
	if {$ff > 0.5} {
		set ff 0.5
	}
	set tcl_precision 16

#	for {set i 1} {$i <= $tfrc_src_num} {incr i} {
#		set max_freq($i) [expr $rtt_in_sec/$max_factor]
#		
#		# inter-packet arrival (IPA) time per flow
#		set ipa($i) [exec cat trace/tfrc_ipa_$i.dat]
#	
#		# the over-sampling frequency shouldn't go beyond IPA time
#		if {$ipa($i) > $max_freq($i)} {
#			set freq($i) $ipa($i)
#			set factor($i) [expr $rtt_in_sec/$freq($i)]
#		} else {
#			set freq($i) $max_freq($i)
#			set factor($i) $max_factor
#		}
#		puts " tfrc ewma sampling freq($i): $freq($i)"
#		puts " tfrc ewma sampling factor($i): $factor($i)"
#	}

	for {set i 1} {$i <= $tfrc_src_num} {incr i} {
        exec awk -f ../awk/thru_indiv.awk \
					option=tfrc \
					ix=$i \
					granul=$granul \
					cutoff=$from \
                    until=$to \
					trace/tfrc_indiv_$i.tr
		exec ../tools/ewma tfrc thru \
				$i \
				$freq \
				0.085 \
				$from \
                $to \
				trace/tfrc_indiv_$i.tr
		exec ../tools/anti-alias tfrc thru \
				$i \
				$ff \
				$from \
                $to \
				trace/tfrc_ewma_thru_$i.xg
	}

	# Average Throughput for CoV plot
	for {set i 1} {$i <= $tfrc_src_num} {incr i} {
		exec ../tools/average_i tfrc \
				$i \
                $from \
                $to \
				trace/tfrc_ant_thru_$i.xg
	}

	# CoV per flow
	for {set i 1} {$i <= $tfrc_src_num} {incr i} {
		exec ../tools/cov tfrc \
				$i \
				trace/tfrc_thru_avg_$i.dat \
				trace/tfrc_thru_$i.dat \
				$numeric_bottleneck_bandwidth
		set cov($i) [exec cat trace/tfrc_cov_$i.dat]
	}

	# Average CoV
	set totCoV 0
	for {set i 1} {$i <= $tfrc_src_num} {incr i} {
		set totCoV [expr $totCoV + $cov($i)]
	}
	#set avgCoV [expr $totCoV / $tfrc_src_num]
	#puts "average CoV	$avgCoV"
	exec ../tools/avg_cov tfrc \
			$totCoV \
			$tfrc_src_num \
			$numeric_bottleneck_bandwidth

	# INSTANTANEOUS QUEUE SIZE (individual plot)
	exec awk -f ../awk/tfrc_inst_q.awk \
				cutoff=$from \
				trace/out.queue
    for {set i 1} {$i <= $tfrc_src_num} {incr i} {
        exec awk -f ../awk/q_indiv.awk \
					option=tfrc \
					ix=$i \
					granul=$granul \
					cutoff=$from \
                    until=$to \
					trace/tfrc_indiv_$i.tr
    }

	# AVERAGE RED QUEUE SIZE (aggregated red queue plot)
	if {$queuetype == "RED"} {
        exec awk -f ../awk/q_red.awk \
					option=tfrc \
					granul=$granul \
					cutoff=$from \
                    until=$to \
					trace/red_q.tr
	}

	# LOSS RATE
	exec awk -f ../awk/tfrc_loss.awk \
            cutoff=$from \
            until=$to \
            trace/out.queue
	for {set i 1} {$i <= $tfrc_src_num} {incr i} {
        exec awk -f ../awk/loss_indiv.awk \
					option=tfrc \
					ix=$i \
					granul=$granul \
					cutoff=$from \
                    until=$to \
					trace/tfrc_indiv_$i.tr
	}
	if {[catch {exec grep tfrcTx temp > \
			trace/tfrc_loss_by_equation.tr} errmsg]} {
		puts ""
		puts "ERROR: Abruptly Terminated - $errmsg"
		puts "......while doing exec grep tfrcTx temp"
	} else {
		exec grep tfrcTx temp > trace/tfrc_loss_by_equation.tr
	}
    exec ../tools/loss_by_eq trace/tfrc_loss_by_equation.tr tfrc
    exec ../tools/thru_by_eq trace/tfrc_loss_by_equation.tr tfrc


	# Avg Loss Interval
	exec grep tfrc_avg_loss_int temp > trace/tfrc_avg_int.tr
	exec ../tools/map trace/tfrc_avg_int.tr tfrc_avg_int
}

proc tfwc_results {} {
	global queuetype tfwc_src_num
	global cutoff t_sim src_num granul
	global numeric_bottleneck_bandwidth
	global rtt_in_sec

    # 30 secs from the half of the sim time
    set from [expr ($t_sim / 2.0)]
    set to   [expr ($from + 30)]

	# THROUGHPUT
	exec awk -f ../awk/tfwc_thru.awk \
				cutoff=$from \
                until=$to \
				trace/out.queue
	exec awk -f ../awk/total_avg_thru.awk \
				cutoff=$from \
				t_sim=$to \
				trace/out.queue

	#this will generate per flow trace files
	exec ../tools/indiv trace/out.queue TFWC

	# capture inter-packet arrival time
	# (this is median value instead of arithmetic average)
	#for {set i 1} {$i <= $tfwc_src_num} {incr i} {
	#	exec ../tools/ipa tfwc ipa \
	#			$i \
	#			$from \
	#			trace/tfwc_indiv_$i.tr
	#}

	# avoid unnecessary long floating point value
	set tcl_precision 6
	# set over-sampling frequency for EWMA
	if {$queuetype == "RED"} {
		if {$rtt_in_sec < 0.05} {
			set max_factor .25
		} elseif {$rtt_in_sec >= 0.05 && $rtt_in_sec < 0.1} {
			set max_factor .75
		} elseif {$rtt_in_sec >= 0.1 && $rtt_in_sec < 0.5} {
			set max_factor 1
		} else {
			set max_factor 4
		}
	} else {
		if {$rtt_in_sec < 0.05} {
			set max_factor .2
		} elseif {$rtt_in_sec >= 0.05 && $rtt_in_sec < 0.1} {
			set max_factor .4
		} elseif {$rtt_in_sec >= 0.1 && $rtt_in_sec < 0.5} {
			set max_factor .8
		} else {
			set max_factor 4
		}
	}

	set freq [expr $rtt_in_sec/$max_factor]
	if {$freq > 0.5 } {
		set freq 0.5
	}
	set ff [expr 10 * $rtt_in_sec]
	if {$ff > 0.5} {
		set ff 0.5
	}
	set tcl_precision 16

#	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
#		set max_freq($i) [expr $rtt_in_sec/$max_factor]
#		
#		# inter-packet arrival (IPA) time per flow
#		set ipa($i) [exec cat trace/tfwc_ipa_$i.dat]
#	
#		# the over-sampling frequency shouldn't go beyond IPA time
#		if {$ipa($i) > $max_freq($i)} {
#			set freq($i) $ipa($i)
#			set factor($i) [expr $rtt_in_sec/$freq($i)]
#		} else {
#			set freq($i) $max_freq($i)
#			set factor($i) $max_factor
#		}
#		puts " tfwc ewma sampling freq($i): $freq($i)"
#		puts " tfwc ewma sampling factor($i): $factor($i)"
#	}

	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
        exec awk -f ../awk/thru_indiv.awk \
					option=tfwc \
					ix=$i \
					granul=$granul \
					cutoff=$from \
                    until=$to \
					trace/tfwc_indiv_$i.tr
		exec ../tools/ewma tfwc thru \
				$i \
				$freq \
				0.085 \
				$from \
                $to \
				trace/tfwc_indiv_$i.tr
		exec ../tools/anti-alias tfwc thru \
				$i \
				$ff \
				$from \
                $to \
				trace/tfwc_ewma_thru_$i.xg
	}

	# Average Throughput for CoV plot
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
		exec ../tools/average_i tfwc \
				$i \
                $from \
                $to \
				trace/tfwc_ant_thru_$i.xg
	}

	# CoV per flow
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
		exec ../tools/cov tfwc \
				$i \
				trace/tfwc_thru_avg_$i.dat \
				trace/tfwc_thru_$i.dat \
				$numeric_bottleneck_bandwidth
		set cov($i) [exec cat trace/tfwc_cov_$i.dat]
	}

	# Average CoV
	set totCoV 0
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
		set totCoV [expr $totCoV + $cov($i)]
	}
	#set avgCoV [expr $totCoV / $tfwc_src_num]
	#puts "average CoV	$avgCoV"
	exec ../tools/avg_cov tfwc \
			$totCoV \
			$tfwc_src_num \
			$numeric_bottleneck_bandwidth

	# INSTANTANEOUS QUEUE SIZE (individual plot)
	exec awk -f ../awk/tfwc_inst_q.awk \
				cutoff=$from \
				trace/out.queue
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
        exec awk -f ../awk/q_indiv.awk \
					option=tfwc \
					ix=$i \
					granul=$granul \
					cutoff=$from \
                    until=$to \
					trace/tfwc_indiv_$i.tr
	}

	# AVERAGE RED QUEUE SIZE (aggregated red queue plot)
	if {$queuetype == "RED"} {
        exec awk -f ../awk/q_red.awk \
					option=tfwc \
					granul=$granul \
					cutoff=$from \
                    until=$to \
					trace/red_q.tr
	}

	# LOSS RATE
	exec awk -f ../awk/tfwc_loss.awk \
				cutoff=$from \
                until=$to \
				trace/out.queue
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
        exec awk -f ../awk/loss_indiv.awk \
					option=tfwc \
					ix=$i \
					granul=$granul \
					cutoff=$from \
                    until=$to \
					trace/tfwc_indiv_$i.tr
	}
	if {[catch {exec grep tfwcTx temp > \
			trace/tfwc_by_equation.tr} errmsg]} {
		puts ""
		puts "ERROR: Abruptly Terminated - $errmsg"
		puts "......while doing exec grep tfwcTx temp"
	} else {
		exec grep tfwcTx temp > trace/tfwc_by_equation.tmp
		exec sed \$d trace/tfwc_by_equation.tmp > \
			trace/tfwc_by_equation.tr
		exec rm trace/tfwc_by_equation.tmp
	}
	exec ../tools/loss_by_eq trace/tfwc_by_equation.tr tfwc
	exec ../tools/thru_by_eq trace/tfwc_by_equation.tr tfwc

	# Loss rate calculated by TCP equation (using ALI)
	exec grep loss_by_cal temp > trace/tfwc_loss_by_cal.tr
	exec ../tools/map trace/tfwc_loss_by_cal.tr tfwc_loss_by_cal

	# CWND
	exec grep cwnd_ temp > trace/tfwc_cwnd.1
	exec sed \$d trace/tfwc_cwnd.1 > trace/tfwc_cwnd.tr
	exec rm trace/tfwc_cwnd.1
	exec ../tools/map trace/tfwc_cwnd.tr tfwc_cwnd

	# Avg Loss Interval
	exec grep avg_interval_ temp > trace/tfwc_avg_int.1
	exec sed \$d trace/tfwc_avg_int.1 > trace/tfwc_avg_int.tr
	exec rm trace/tfwc_avg_int.1
	exec grep pkt_drop_in_avg_hist temp > trace/tfwc_loss_in_hist.tr
	exec ../tools/map trace/tfwc_avg_int.tr tfwc_avg_int
	exec ../tools/map trace/tfwc_loss_in_hist.tr tfwc_loss_in_hist

	# TFWC Smoother
	exec grep num_inf temp > trace/tfwc_smoothing.tr
	exec ../tools/s_ratio trace/tfwc_smoothing.tr

	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
        exec awk -f ../awk/smoother_indiv.awk \
					option=tfwc \
					ix=$i \
					granul=$granul \
					cutoff=$from \
                    until=$to \
					trace/tfwc_sr_$i.tr
	}

	# TIMEOUT
	if {[catch {exec grep TIMEOUT temp > \
			trace/tfwc_timeout.tr} errmsg]} {
		puts ""
		puts "ERROR: Abruptly Terminated - $errmsg"
		puts "......while doing exec grep TIMEOUT temp"
	} else {
		exec grep TIMEOUT temp > trace/tfwc_timeout.tr
		exec ../tools/timeout trace/tfwc_timeout.tr
		for {set i 1} {$i <= $tfwc_src_num} {incr i} {
			for {set j 1} {$j <= $tfwc_src_num} {incr j} {
				exec ../tools/paste \
				$j \
				$tfwc_src_num \
				$from \
				trace/tfwc_to_$i.tr \
				trace/tfwc_cwnd_$j.tr
			}
		}
	}
	# Estimated Timeout
	for {set i 1} {$i <= $tfwc_src_num} {incr i} {
		exec ../tools/estimated_t0 \
				$i \
				$from \
				trace/tfwc_to_$i.tr \
				trace/tfwc_thru_$i.xg
	}
}

# end of file
