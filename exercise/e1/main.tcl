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
# THE POSSIBILITY OF SUCH DAMAGE.
#
# $Id$

if {$argc < 13} {
	#puts "This Tcl script is written for working under ns-2.28."
	#puts "This file takes up to 15 parameters for its input."
	#puts ""
	puts "Usage: "
	puts "ns main.tcl \[tcp\|tfrc\|tfwc\| a\| b\| c\| d\| e\| f\| g\| h\| i\| j\| k\| l\] > temp"
	puts ""
	puts "  tcp: Number of TCP sources"
	puts "  tfrc: Number of TFRC sources"
	puts "  tfwc: Number of TFWC sources"
	puts "  a: Access Link Speed in Mb/s"
	puts "  b: Access Link Delay \(Min\) in ms"
	puts "  c: Access Link Delay \(Max\) in ms"
	puts "  d: Bottleneck BW in Mb/s"
	puts "  e: Bottleneck Link Delay in ms"
	puts "  f: Bottleneck Queue Size"
	puts "  g: Total Simulation Time"
	puts "  h: Random Seed Number"
	puts "  i: Is Reverse TCP traffic? \(y\/n\)"
	puts "  j: Queue Type \(DropTail\/RED\)"
	puts "  k: max_p for RED"
	puts "     \(Note: Type \'auto\' for automatic max_p approximation\)"
	puts "  l: q_weight for RED"
	puts "     \(Note: Type \'auto\' for automatic q_weight configuratioin\)"
	puts ""
	exit
}

if {$argc == 13} {
	set tcp_src_num		[lindex $argv 0]
	set tfrc_src_num	[lindex $argv 1]
	set tfwc_src_num	[lindex $argv 2]
	set accessBW		[lindex $argv 3]
	set accessMinDel	[lindex $argv 4]
	set accessMaxDel	[lindex $argv 5]
	set bottleneckBW	[lindex $argv 6]
	set bottleneckDel	[lindex $argv 7]
	set q_len			[lindex $argv 8]
	set duration		[lindex $argv 9]
	set seedno			[lindex $argv 10]
	set isReverse		[lindex $argv 11]
	set queue_type		[lindex $argv 12]
	set max_p			auto
	set q_w				auto
}

if {$argc == 14} {
	set tcp_src_num		[lindex $argv 0]
	set tfrc_src_num	[lindex $argv 1]
	set tfwc_src_num	[lindex $argv 2]
	set accessBW		[lindex $argv 3]
	set accessMinDel	[lindex $argv 4]
	set accessMaxDel	[lindex $argv 5]
	set bottleneckBW	[lindex $argv 6]
	set bottleneckDel	[lindex $argv 7]
	set q_len			[lindex $argv 8]
	set duration		[lindex $argv 9]
	set seedno			[lindex $argv 10]
	set isReverse		[lindex $argv 11]
	set queue_type		[lindex $argv 12]
	set max_p			[lindex $argv 13]
	set q_w				auto
}

if {$argc == 15} {
	set tcp_src_num		[lindex $argv 0]
	set tfrc_src_num	[lindex $argv 1]
	set tfwc_src_num	[lindex $argv 2]
	set accessBW		[lindex $argv 3]
	set accessMinDel	[lindex $argv 4]
	set accessMaxDel	[lindex $argv 5]
	set bottleneckBW	[lindex $argv 6]
	set bottleneckDel	[lindex $argv 7]
	set q_len			[lindex $argv 8]
	set duration		[lindex $argv 9]
	set seedno			[lindex $argv 10]
	set isReverse		[lindex $argv 11]
	set queue_type		[lindex $argv 12]
	set max_p			[lindex $argv 13]
	set q_w				[lindex $argv 14]
}

puts ""
puts " ----------------------------------------------------------------------"
puts " ns main.tcl $tcp_src_num $tfrc_src_num $tfwc_src_num $accessBW\
	$accessMinDel $accessMaxDel $bottleneckBW $bottleneckDel\
	$q_len $duration $seedno $isReverse $queue_type > temp"
puts " ----------------------------------------------------------------------"

source common.tcl

if {$isReverse == "y" || $isReverse == "Y"} {
	source reverse.tcp.tcl
}

# final results and plots
$ns at $t_sim "finish"

# run ns simulatior
$ns run
