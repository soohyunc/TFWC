#!/usr/local/bin/gnuplot
#
#
# Copyright(c) 2005-2008 University College London
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

set	terminal	png 
set	output		'graph/tfwc_fifo_ali.png'
#set	pointsize	0.4
set	grid

set	yrange		[0:]

set	title		"TFWC Avg Loss Interval"
set	xlabel		"time"
set	ylabel		"Avg Loss Interval"

plot	"trace/tfwc_avg_int_01.xg" title 'TFWC 1' with linespoints, \
		"trace/tfwc_avg_int_02.xg" title 'TFWC 2' with linespoints, \
		"trace/tfwc_avg_int_03.xg" title 'TFWC 3' with linespoints, \
		"trace/tfwc_avg_int_04.xg" title 'TFWC 4' with linespoints

#	"trace/tfwc_loss_in_hist_01.xg" with points, \
#	"trace/tfwc_loss_in_hist_02.xg" with points, \
#	"trace/tfwc_loss_in_hist_03.xg" with points, \
#	"trace/tfwc_loss_in_hist_04.xg" with points

#replot
#EOF
