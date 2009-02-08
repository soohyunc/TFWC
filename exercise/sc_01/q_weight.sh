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
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/sc/q_weight.sh,v 1.15 2006/02/13 22:55:18 soohyunc Exp $ 
#

# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: S.Choi@cs.ucl.ac.uk

#
# Batch NS-2 Simulation Script for TFWC performance evaluation
# (Note: This simulation examines the effect of q_weight_ variation under RED)
#

# get the traffic type for this run
echo -n "Enter the traffic type for this run (TCP/TFRC/TFWC):	"
read SRC_TYPE
T_SRC=$SRC_TYPE

# get the number of TFWC sources
echo -n "Enter the number of $T_SRC sources:			"
read SRC
SOURCE=$SRC

# get the bottleneck Queue size
echo -n "Enter the RED queue length:				"
read QLEN
QUEUE=$QLEN

# get the simulation time
echo -n "Enter simulation time:					"
read T_SIM
TIME=$T_SIM

# get the random seed number for the simulation
echo -n "Enter the random seed number:				"
read RAND
RND=$RAND

# delete all trace file before get started?
echo -n "Delete all trace file before get started (y/n)? 	"
read isDelete
isDel=$isDelete
if [ $isDel == 'y' ] || [ $isDel == 'Y' ]
then
	./rmall.sh
fi

# is there any reverse trffic going on?
#echo -n "Do you want to put reverse traffice? (y/n)"
#read isBack
#isReverse=$isBack

#
# examine q_weight_ from 0 to 1
# (Note: it starts from 0 with 0.01 increment)
#

# initial q_weight_ value
QW=0
STEP=0.0001

#
# run batch simulatioin
#

#########################
#			#
#	T C P		#
#			#
#########################
if [ $T_SRC == 'TCP' ];
then
	for i in `seq 0 1900`;
	do
		echo ""
		echo -n "ns tcp.tcl $SOURCE $QUEUE $TIME $RND n RED auto $QW > temp.tcp";
		echo ""
		nice ns tcp.tcl $SOURCE $QUEUE $TIME $RND n RED auto $QW > temp.tcp

		# sort queue value (instantaneous queue)
		awk '{if ($1 > 20) print $2}' trace/tcp_q.xg > trace/tcp_q.tmp
		sort -g trace/tcp_q.tmp -o archives/tcp_sorted_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).tmp
		./add-on/minmax tcp inst $QW archives/tcp_sorted_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).tmp

		# sort queue value (red queue)
		awk '{if ($1 > 20) print $2}' trace/tcp_red_avg.xg > trace/tcp_red_avg.tmp
		sort -g trace/tcp_red_avg.tmp -o archives/tcp_sorted_avg_red_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).tmp
		./add-on/minmax tcp avg $QW archives/tcp_sorted_avg_red_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).tmp

		# archive graphs
		cp graph/aggr_q_tcp_red.png graph/tcp_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).png
		cp graph/aggr_thru_tcp_red.png graph/tcp_thru_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).png
		cp graph/aggr_loss_tcp_red.png graph/tcp_loss_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).png
		cp graph/tcp_red_cwnd.png graph/tcp_cwnd_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).png

		# archive trace files
		cp trace/tcp_q.xg archives/tcp_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tcp_red_avg.xg archives/tcp_red_avg_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tcp_thru.xg archives/tcp_thru_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tcp_loss.xg archives/tcp_loss_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg

		if [ $i -le 1000 ]; then
			QW=`echo $QW + $STEP | bc -l`
		else
			QW=`echo $QW + 10*$STEP | bc -l`
		fi
	done
	#gnuplot plt/tcp_red_q_wt.plt

#########################
#			#
#	T F R C		#
#			#
#########################
elif [ $T_SRC == 'TFRC' ];
then
	for i in `seq 0 1900`;
	do
		echo ""
		echo -n "ns tfrc.tcl $SOURCE $QUEUE $TIME $RND n RED auto $QW > temp.tfrc";
		echo ""
		nice ns tfrc.tcl $SOURCE $QUEUE $TIME $RND n RED auto $QW > temp.tfrc

		# sort queue value (instantaneous queue)
		awk '{if ($1 > 20) print $2}' trace/tfrc_q.xg > trace/tfrc_q.tmp
		sort -g trace/tfrc_q.tmp -o archives/tfrc_sorted_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).tmp
		./add-on/minmax tfrc inst $QW archives/tfrc_sorted_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).tmp

		# sort queue value (red queue)
		awk '{if ($1 > 20) print $2}' trace/tfrc_red_avg.xg > trace/tfrc_red_avg.tmp
		sort -g trace/tfrc_red_avg.tmp -o archives/tfrc_sorted_avg_red_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).tmp
		./add-on/minmax tfrc avg $QW archives/tfrc_sorted_avg_red_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).tmp

		# archive graphs
		cp graph/aggr_q_tfrc_red.png graph/tfrc_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).png
		cp graph/aggr_thru_tfrc_red.png graph/tfrc_thru_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).png
		cp graph/aggr_loss_tfrc_red.png graph/tfrc_loss_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).png
		cp graph/tfrc_red_ali.png graph/tfrc_red_ali_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).png

		# archive trace files
		cp trace/tfrc_q.xg archives/tfrc_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfrc_red_avg.xg archives/tfrc_red_avg_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfrc_thru.xg archives/tfrc_thru_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfrc_loss.xg archives/tfrc_loss_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfrc_avg_int_01.xg archives/tfrc_avg_int_01_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfrc_avg_int_02.xg archives/tfrc_avg_int_02_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfrc_avg_int_03.xg archives/tfrc_avg_int_03_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfrc_avg_int_04.xg archives/tfrc_avg_int_04_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg

		if [ $i -le 1000 ]; then
			QW=`echo $QW + $STEP | bc -l`
		else
			QW=`echo $QW + 10*$STEP | bc -l`
		fi
	done
	#gnuplot plt/tfrc_red_q_wt.plt

#########################
#			#
#	T F W C		#
#			#
#########################
elif [ $T_SRC == 'TFWC'  ];
then
	for i in `seq 0 1000`;
	do
		echo ""
		echo -n "ns tfwc.tcl $SOURCE $QUEUE $TIME $RND n RED auto $QW > temp.tfwc";
		echo ""
		nice ns tfwc.tcl $SOURCE $QUEUE $TIME $RND n RED auto $QW > temp.tfwc

		# sort queue value (instantaneous queue)
		awk '{if ($1 > 20) print $2}' trace/tfwc_q.xg > trace/tfwc_q.tmp
		sort -g trace/tfwc_q.tmp -o archives/tfwc_sorted_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).tmp
		./add-on/minmax tfwc inst $QW archives/tfwc_sorted_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).tmp

		# sort queue value (red queue)
		awk '{if ($1 > 20) print $2}' trace/tfwc_red_avg.xg > trace/tfwc_red_avg.tmp
		sort -g trace/tfwc_red_avg.tmp -o archives/tfwc_sorted_avg_red_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).tmp
		./add-on/minmax tfwc avg $QW archives/tfwc_sorted_avg_red_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).tmp

		# archive graphs
		cp graph/aggr_q_tfwc_red.png graph/tfwc_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).png
		cp graph/aggr_thru_tfwc_red.png graph/tfwc_thru_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).png
		cp graph/aggr_loss_tfwc_red.png graph/tfwc_loss_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).png
		cp graph/tfwc_red_ali.png graph/tfwc_red_ali_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).png
		cp graph/tfwc_red_cwnd.png graph/tfwc_red_cwnd_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).png

		# archive tracefiles
		cp trace/tfwc_q.xg archives/tfwc_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfwc_red_avg.xg archives/tfwc_red_avg_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfwc_thru.xg archives/tfwc_thru_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfwc_loss.xg archives/tfwc_loss_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfwc_cwnd_01.xg archives/tfwc_cwnd_01_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfwc_cwnd_02.xg archives/tfwc_cwnd_02_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfwc_cwnd_03.xg archives/tfwc_cwnd_03_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfwc_cwnd_04.xg archives/tfwc_cwnd_04_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfwc_avg_int_01.xg archives/tfwc_avg_int_01_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfwc_avg_int_02.xg archives/tfwc_avg_int_02_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfwc_avg_int_03.xg archives/tfwc_avg_int_03_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg
		cp trace/tfwc_avg_int_04.xg archives/tfwc_avg_int_04_q\($QUEUE\)_src\($SOURCE\)_wt\($QW\).xg

		if [ $i -le 1000 ]; then
			QW=`echo $QW + $STEP | bc -l`
		else
			QW=`echo $QW + 10*$STEP | bc -l`
		fi
	done
	#gnuplot plt/tfwc_red_q_wt.plt

fi
