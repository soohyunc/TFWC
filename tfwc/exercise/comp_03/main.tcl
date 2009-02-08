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
#    documentation and/or other materials provided with the
#    distribution.
# 3. All advertising materials mentioning features or use of this
# software
#    must display the following acknowledgement:
#      This product includes software developed by the Computer Systems
#      Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be
# used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS''
# AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE
# LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL
# DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT
# LIABILITY, OR TORT(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
# WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE. 
#
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/sc/tcp.tcl,v
# 1.4 2006/02/02 14:09:21 soohyunc Exp $
#

# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: S.Choi@cs.ucl.ac.uk

if {$argc < 8} {
        #puts "This Tcl script is written for working under ns-2.28."
        #puts "This file takes up to 10 parameters for its input."
        #puts ""
        puts "Usage: ns main.tcl \[ tcp\| tfrc\| tfwc\| a\| b\| c\| d\| e\| f\| g\] > temp"
        puts ""
        puts "  tcp: Number of TCP sources"
        puts "  tfrc: Number of TFRC sources"
        puts "  tfwc: Number of TFWC sources"
        puts "  a: Bottleneck Queue Size"
        puts "  b: Total Simulation Time"
        puts "  c: Random Seed Number"
        puts "  d: Is Reverse TCP? \(y\/n\)"
        puts "  e: Queue Type \(DropTail\/RED\)"
        puts "  f: max_p for RED"
        puts "     \(Note: Type \'auto\' for automatic max_p approximation\)"
        puts "  g: q_weight for RED"
        puts "     \(Note: Type \'auto\' for automatic q_weight configuratioin\)"
        puts ""
        #puts "Example of Queue Type: type \"DropTail\" or \"RED\""
        #puts "Example of Reverse Traffic: type \"y\" or \"n\""
        #puts ""
        exit
}

if {$argc == 8} {
        set tcp_src_num		[lindex $argv 0]
        set tfrc_src_num	[lindex $argv 1]
        set tfwc_src_num	[lindex $argv 2]
        set q_len		[lindex $argv 3]
        set duration		[lindex $argv 4]
        set seedno		[lindex $argv 5]
        set isReverse		[lindex $argv 6]
        set queue_type		[lindex $argv 7]
        set max_p		auto
        set q_w			auto
}

if {$argc == 9} {
        set tcp_src_num		[lindex $argv 0]
        set tfrc_src_num	[lindex $argv 1]
        set tfwc_src_num	[lindex $argv 2]
        set q_len		[lindex $argv 3]
        set duration		[lindex $argv 4]
        set seedno		[lindex $argv 5]
        set isReverse		[lindex $argv 6]
        set queue_type		[lindex $argv 7]
        set max_p		[lindex $argv 8]
        set q_w			auto
}

if {$argc == 10} {
        set tcp_src_num		[lindex $argv 0]
        set tfrc_src_num	[lindex $argv 1]
        set tfwc_src_num	[lindex $argv 2]
        set q_len		[lindex $argv 3]
        set duration		[lindex $argv 4]
        set seedno		[lindex $argv 5]
        set isReverse		[lindex $argv 6]
        set queue_type		[lindex $argv 7]
        set max_p		[lindex $argv 8]
        set q_w			[lindex $argv 9]
}

source common.tcl

if {$isReverse == "y" || $isReverse == "Y"} {
	source reverse.tcp.tcl
}

# final results and plots
$ns at $t_sim "finish"

# run ns simulatior
$ns run
