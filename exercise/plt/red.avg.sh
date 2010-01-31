#!/bin/sh
#
# Copyright(c) 2005-2008 University College London
# All rights reserved.
#
# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: S.Choi@cs.ucl.ac.uk
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

if [ -f "$1/trace/tcp_red_avg.xg" ];
then
    echo ""
else
    echo "20 0" > "$1/trace/tcp_red_avg.xg"
fi

if [ -f "$1/trace/tfrc_red_avg.xg" ];
then
    echo ""
else
    echo "20 0" > "$1/trace/tfrc_red_avg.xg"
fi

if [ -f "$1/trace/tfwc_red_avg.xg" ];
then
    echo ""
else
    echo "20 0" > "$1/trace/tfwc_red_avg.xg"
fi

gnuplot -persist << EOF
set     terminal        png
set     output          "$1/graph/aggr_red_avg.png"
#set     pointsize       0.4
set     grid

set	yrange		[0:]

set     title           "RED Average Queue Dymanics"
set     xlabel          "time"
set     ylabel          "average queue size"

plot    "$1/trace/tcp_red_avg.xg" with lines, \
	"$1/trace/tfrc_red_avg.xg" with lines, \
	"$1/trace/tfwc_red_avg.xg" with lines

#replot
EOF
