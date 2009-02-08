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
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/sc/max_p.tcl,v 1.11 2006/02/20 15:37:43 soohyunc Exp $ 
#

# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: S.Choi@cs.ucl.ac.uk


#
# Compute delay-bandwidth product
#
set rtt1	[expr 2.0 * ($numeric_bottleneck_delay + $min_dly) * 0.001]
set rtt2	[expr 2.0 * ($numeric_bottleneck_delay + $max_dly) * 0.001]
set rtt		[expr ($rtt1 + $rtt2) / 2.0]
	puts " rtt		$rtt"
set t_dlyBW	[expr 1000000 * ($rtt * $numeric_bottleneck_bandwidth)]
set dlyBW	[expr ($t_dlyBW / 8000)]
	puts " dly x BW	$dlyBW in packets "

#
# Get estimated loss rate
#
for {set p 0.00001} {$p < 1.0} {set p [expr ($p + 0.00001)]} {

	set f_p 	{[expr sqrt((2.0/3.0) * $p)] + [expr 12.0 * $p * (1.0 + 32.0 * pow($p, 2.0)) * sqrt((3.0/8.0) * $p)]}

	set t_win 	[expr (1.0 / $f_p)]
	#puts "t_win	$t_win"

	if {$t_win < [expr ($dlyBW / $src_num)]} {
		break 
	}
}

#
# If the estimated 'p' is too small, we will round it up to 0.0001
#
if {$p < 0.0001} {
	set p	0.0001
} elseif {$p > 1.0} {
	set p	1.0
}
	puts " p		$p"

#
# Set estimated max_p
#
set max_p [expr (2.0 * $p)]

