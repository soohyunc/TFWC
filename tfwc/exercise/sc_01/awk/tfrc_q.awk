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
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/sc/awk/tfrc_q.awk,v 1.4 2006/02/09 13:03:07 soohyunc Exp $ 
#

#-------------------------------------------/
# Instaneous Queue Size Calculation
#-------------------------------------------/
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# Computer Science Department
# University College London
#-------------------------------------------/
                                                                                
                                                                                
BEGIN {
	granul = 0.005;
	count = tcp_count = tf_count = time = 0;
	cutoff	= 20;

	printf "" > "trace/q_size.xg";
	printf "" > "trace/tcp_q.xg";
	printf "" > "trace/tfrc_q.xg";
}
                                                                                
{

#-------------------------------------------/
#
#This is aggregated and combined TCP/TFRC Q size
#
#-------------------------------------------/
if ($2 > cutoff) {

	if ($1 == "+") {
		count++;

		if ($5 == "tcp") tcp_count++;
		if ($5 == "tcpFriend") tf_count++;
		if (($2 - time) > granul) {
		        time += granul;
			print time , count >> "trace/q_size.xg";
			print time , tcp_count >> "trace/tcp_q.xg";
			print time , tf_count >> "trace/tfrc_q.xg";
		}
	}

	if ($1 == "-" || $1 == "d") {
		count--;

		if ($5 == "tcp") tcp_count--;
		if ($5 == "tcpFriend") tf_count--;
		if (($2 - time) > granul) {
		        time += granul;
			print time , count >> "trace/q_size.xg";
			print time , tcp_count >> "trace/tcp_q.xg";
			print time , tf_count >> "trace/tfrc_q.xg";
		}
	}
} # end of if ($2 > cutoff)
}

END {
}

