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
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/sc/awk/tfwc_loss_in_hist.awk,v 1.3 2006/02/02 15:29:24 soohyunc Exp $ 
#

# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: S.Choi@cs.ucl.ac.uk


#
# TFWC packet lost in Average Loss Interval
#

BEGIN {
	granul = 0.05;
	time = 0;
	cutoff	= 20;

	printf "" > "./trace/tfwc_loss_in_hist_01.xg";
	printf "" > "./trace/tfwc_loss_in_hist_02.xg";
	printf "" > "./trace/tfwc_loss_in_hist_03.xg";
	printf "" > "./trace/tfwc_loss_in_hist_04.xg";

	print 0,0 >> "./trace/tfwc_loss_in_hist_01.xg";	
	print 0,0 >> "./trace/tfwc_loss_in_hist_02.xg";	
	print 0,0 >> "./trace/tfwc_loss_in_hist_03.xg";	
	print 0,0 >> "./trace/tfwc_loss_in_hist_04.xg";	

	src_num = 4;
	for (i = 1; i <= src_num; i++)
		src_id[i] = 0;
}

{
	#
	# pre-condition
	#
	if (src_id[1] == 0 && src_id[2] == 0 && src_id[3] == 0 && src_id[4] == 0) {
		src_id[1] = $5;
	} else if (src_id[1] != $5 && (src_id[2] == 0 && src_id[3] == 0 && src_id[4] == 0)) {
		src_id[2] = $5;
	} else if ((src_id[1] != $5 && src_id[2] != $5) && (src_id[3] == 0 && src_id[4] == 0)) {
			src_id[3] = $5;
	} else if ((src_id[1] != $5 && src_id[2] != $5 && src_id[3] != $5) && src_id[4] == 0) {
		src_id[4] = $5;
	}

	#for (i = 1; i <= src_num; i++) {
	#	print src_id[i];
	#}
	#print "-----------";

	#
	# Avg Loss Interval No.1
	#
	if (src_id[1] == $5 && $4 > cutoff) {
		print $4, $3 >> "./trace/tfwc_loss_in_hist_01.xg";
	} 

	#
	# Avg Loss Interval No.2
	#
	if (src_id[2] == $5 && $4 > cutoff) {
		print $4, $3 >> "./trace/tfwc_loss_in_hist_02.xg";
	}
 
	#
	# Avg Loss Interval No.3
	#
	if (src_id[3] == $5 && $4 > cutoff) {
		print $4, $3 >> "./trace/tfwc_loss_in_hist_03.xg";
	}
 
	#
	# Avg Loss Interval No.4
	#
	if (src_id[4] == $5 && $4 > cutoff) {
		print $4, $3 >> "./trace/tfwc_loss_in_hist_04.xg";
	} 
}

END {
}

