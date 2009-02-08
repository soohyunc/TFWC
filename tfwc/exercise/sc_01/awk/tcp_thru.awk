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
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/sc/awk/tcp_thru.awk,v 1.5 2006/03/13 15:34:37 soohyunc Exp $ 
#

#
# Pattern findingg and Throughput calculation
# (Find an outgoing packet from the queue at a bottleneck node)
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# Computer Science Department
# University College London
                                                                                
                                                                                
BEGIN {
	granul = 0.5;
	bits = 0;
	last_bits = 0;
	time = 0;
	cutoff	= 20;

	printf "" > "trace/tcp_thru.xg";
	print cutoff,0 >> "trace/tcp_thru.xg";
}
                                                                                
{
	if ($1 == "r" && $5 == "tcp") {
      	        bits = bits + $6*8;
                                                                                
	        if (($2 - time) > granul) {
			time = time + granul;
			rate = ((bits-last_bits)/1000000)/granul;

			if ($2 > cutoff) {
				print time, rate >> "trace/tcp_thru.xg";
			}
			last_bits = bits;
		}

		while (($2 - time) > 2 * granul) {
			if ($2 > cutoff) {
				print time, 0 >> "trace/tcp_thru.xg";
			}
			bits = 0;
			last_bits = 0;
			time = time + granul;
		}
	}
}

END {
}

