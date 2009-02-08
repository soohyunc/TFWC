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
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/comp_03/awk/tfrc_avg_int.awk,v 1.4 2006/03/16 14:44:29 soohyunc Exp $ 
#

# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: S.Choi@cs.ucl.ac.uk


#
# Avg Loss Interval Dynamics
#

BEGIN {
	granul = 0.05;
	time = 0;
	cutoff	= 20;
	printf "" > "./trace/tfrc_avg_int_01.xg";
	printf "" > "./trace/tfrc_avg_int_02.xg";
	printf "" > "./trace/tfrc_avg_int_03.xg";
	printf "" > "./trace/tfrc_avg_int_04.xg";
	print cutoff,0 > "./trace/tfrc_avg_int_01.xg";
	print cutoff,0 > "./trace/tfrc_avg_int_02.xg";
	print cutoff,0 > "./trace/tfrc_avg_int_03.xg";
	print cutoff,0 > "./trace/tfrc_avg_int_04.xg";

	src_num = 4;
	for (i = 1; i <= src_num; i++)
		id[i] = 0;
}

{
	#
	# pre-condition
	#
	if (id[1] == 0 && id[2] == 0 && id[3] == 0 && id[4] == 0) {
		id[1] = $5;
	} else if (id[1] != $5 && (id[2] == 0 && id[3] == 0 && id[4] == 0)) {
		id[2] = $5;
	} else if ((id[1] != $5 && id[2] != $5) && (id[3] == 0 && id[4] == 0)) {
			id[3] = $5;
	} else if ((id[1] != $5 && id[2] != $5 && id[3] != $5) && id[4] == 0) {
		id[4] = $5;
	}

	#for (i = 1; i <= src_num; i++) {
	#	print id[i];
	#}
	#print "-----------";

	#
	# Avg Loss Interval No.1
	#
	if (id[1] == $5 && $4 > cutoff) {
		print $4, $3 >> "./trace/tfrc_avg_int_01.xg";
	} 

	#
	# Avg Loss Interval No.2
	#
	if (id[2] == $5 && $4 > cutoff) {
		print $4, $3 >> "./trace/tfrc_avg_int_02.xg";
	}
 
	#
	# Avg Loss Interval No.3
	#
	if (id[3] == $5 && $4 > cutoff) {
		print $4, $3 >> "./trace/tfrc_avg_int_03.xg";
	}
 
	#
	# Avg Loss Interval No.4
	#
	if (id[4] == $5 && $4 > cutoff) {
		print $4, $3 >> "./trace/tfrc_avg_int_04.xg";
	} 
}

END {
}

