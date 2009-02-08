#!/usr/local/bin/gnuplot
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
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/sc/plt/tfwc_red_q_wt.plt,v 1.2 2006/02/10 14:18:58 soohyunc Exp $ 
#

# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: S.Choi@cs.ucl.ac.uk

set     terminal        png
set     output          'graph/tfwc_red_q_wt.png'
set     pointsize       0.4
set     grid

set     title           "RED Queue Dynamics with \"q_weight\" variations (TFWCs)"
set     xlabel          "q_weight"
set     ylabel          "queue size variation in packets"

set	yrange		[0:100]

plot    "trace/tfwc_q_weight_inst.xg" with yerrorbars, \
        "trace/tfwc_q_weight_avg.xg" with yerrorbars

#replot
#EOF
