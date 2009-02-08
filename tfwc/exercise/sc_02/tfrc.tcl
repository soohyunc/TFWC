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
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/sc/tfrc.tcl,v 1.2 2006/02/01 16:32:40 soohyunc Exp $
#

# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: S.Choi@cs.ucl.ac.uk

if {$argc <= 1} {
        #puts "This Tcl script is written for working under ns-2.28."
        #puts "This file takes upto 7 parameters for its input."
        #puts ""
        puts "Usage: ns tfrc.tcl \[a \| b \| c \| d \| e \| f \| g\| h \] > temp.tfrc"
        puts ""
        puts "  a: Number of TFRC sources"
        puts "  b: Bottleneck Queue Size"
        puts "  c: Total Simulation Time"
        puts "  d: Random Seed Number"
        puts "  e: Is Reverse TCP? \(y\/n\)"
        puts "  f: Queue Type \(DropTail\/RED\)"
        puts "  g: max_p for RED"
        puts "     \(Note: Type \'auto\' for automatic max_p approximation\)"
        puts "  h: q_weight for RED"
        puts "     \(Note: Type \'auto\' for automatic q_weight configuratioin\)"
        puts ""
        #puts "Example of Queue Type: type \"DropTail\" or \"RED\""
        #puts "Example of Reverse Traffic: type \"y\" or \"n\""
        #puts ""
        exit
}

if {$argc == 2} {
        set tfrc_src_num [lindex $argv 0]
        set q_len       [lindex $argv 1]
        set duration    150
        set seedno      5
        set isReverse   n
        set queue_type  DropTail
        set max_p       0.1
	set q_w		-1
}

if {$argc == 3} {
        set tfrc_src_num [lindex $argv 0]
        set q_len       [lindex $argv 1]
        set duration    [lindex $argv 2]
        set seedno      5
        set isReverse   n
        set queue_type  DropTail
        set max_p       0.1
	set q_w		-1
}

if {$argc == 4} {
        set tfrc_src_num [lindex $argv 0]
        set q_len       [lindex $argv 1]
        set duration    [lindex $argv 2]
        set seedno      [lindex $argv 3]
        set isReverse   n
        set queue_type  DropTail
        set max_p       0.1
	set q_w		-1
}

if {$argc == 5} {
        set tfrc_src_num [lindex $argv 0]
        set q_len       [lindex $argv 1]
        set duration    [lindex $argv 2]
        set seedno      [lindex $argv 3]
        set isReverse   [lindex $argv 4]
        set queue_type  DropTail
        set max_p       0.1
	set q_w		-1
}

if {$argc == 6} {
        set tfrc_src_num [lindex $argv 0]
        set q_len       [lindex $argv 1]
        set duration    [lindex $argv 2]
        set seedno      [lindex $argv 3]
        set isReverse   [lindex $argv 4]
        set queue_type  [lindex $argv 5]
        set max_p       0.1
	set q_w		-1
}

if {$argc == 7} {
        set tfrc_src_num [lindex $argv 0]
        set q_len       [lindex $argv 1]
        set duration    [lindex $argv 2]
        set seedno      [lindex $argv 3]
        set isReverse   [lindex $argv 4]
        set queue_type  [lindex $argv 5]
        set max_p       [lindex $argv 6]
	set q_w		-1
}

if {$argc == 8} {
        set tfrc_src_num [lindex $argv 0]
        set q_len       [lindex $argv 1]
        set duration    [lindex $argv 2]
        set seedno      [lindex $argv 3]
        set isReverse   [lindex $argv 4]
        set queue_type  [lindex $argv 5]
        set max_p       [lindex $argv 6]
	set q_w		[lindex $argv 7]
}

source common.tfrc.tcl

if {$isReverse == "y" || $isReverse =="Y"} {
        source reverse.tcp.tcl
}

if {$queue_type =="RED"} {
        $ns at $t_sim "finish_for_red"
}

if {$queue_type =="DropTail"} {
        $ns at $t_sim "finish_for_droptail"
}

$ns run

