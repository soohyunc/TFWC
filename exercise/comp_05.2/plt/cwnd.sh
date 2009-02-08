#
# Copyright(c) 2007 University College London
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
#    documentation and/or other materials provided with the distribution.
#
# 3. The name of the University must not be used to endorse or promote
#    products derived from this software without specific prior written
#    permission.
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
#
# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: S.Choi@cs.ucl.ac.uk

if [ $# -lt 1 ]
then
	echo "Usage: ./cwnd.sh <tcp/tfwc> <fifo/red> <file 1> <file 2> <file 3> <file 4>"
	exit
fi

gnuplot -persist << EOF
	set     terminal        png
	set     output          "graph/$1_$2_cwnd.png"
	set     grid

	set     title           "CWND ($1)"
	set     xlabel          "time"
	set     ylabel          "window size"

	plot    "$3" title '$1 1' with lines, \
			"$4" title '$1 2' with lines, \
			"$5" title '$1 3' with lines, \
			"$6" title '$1 4' with lines
EOF

gnuplot -persist << EOF
	set	terminal	postscript eps enhanced
    set	output		"graph/$1_$2_cwnd.eps"
    set	grid

    set	title		"CWND ($1)"
    set	xlabel		"time"
    set	ylabel		"window size"

    plot    "$3" title '$1 1' with lines, \
	        "$4" title '$1 2' with lines, \
    	    "$5" title '$1 3' with lines, \
        	"$6" title '$1 4' with lines
EOF
