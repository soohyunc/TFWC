#!/bin/sh
#
# Copyright(c) 2010 University College London
# All rights reserved.
#
# AUTHOR: Soo-Hyun Choi <s.choi@cs.ucl.ac.uk>
#		  UCL Computer Science Department
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

# print out usage
if [ $# -lt 1 ];
then
	echo "Usage:"
	echo "./plot.sh <tcp/tfrc/tfwc> <thru/loss/...> <fifo/red> \
<x-range from> <x-range to> <y-range from> <y-range to> <max no. of sources>"
	exit
fi
var=$PWD

# count the number of files that we're plotting
file_count=`find . -name "$1_$2_*.xg" -type f  -exec ls {} + | wc -l`
#file_list=`find . -name "$1_$2_*.xg" -type f  -exec ls {} +`
#for filename in $filelist ; do

# determine the number of flows to plot
if [ "$8" -gt 0 ]
	num_src=$8
else
	num_src=$file_count
fi 2> /dev/null

# for loop for plotting
for i in `seq 1 $num_src`
do
	if [ $i -eq "1" ];
	then
		gnuplot -persist << EOF
		set terminal postscript eps enhanced color
		set output "graph/$1_$2_$3.eps"
		set grid
		set size .85,.6
		set title "$1 $2"
		set xrange [$4:$5]
		set yrange [$6:$7]
		plot "trace/$1_$2_$i.xg" with lines title "$i"
		save "$1_$2_$3.env"
EOF
	else
		gnuplot -persist << EOF
		set terminal postscript eps enhanced color
		load "$1_$2_$3.env"
		set output "graph/$1_$2_$3.eps"
		set grid
		set size .85,.6
		set title "$1 $2"
		set xrange [$4:$5]
		set yrange [$6:$7]
		replot "trace/$1_$2_$i.xg" with lines title "$i"
		save "$1_$2_$3.env"
EOF
	fi
done > /dev/null 2>&1

rm -f $1_$2_$3.env
