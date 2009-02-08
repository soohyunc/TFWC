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
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/comp_04/fairness.sh,v 1.17 2006/06/09 14:09:35 soohyunc Exp $ 
#

# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: S.Choi@cs.ucl.ac.uk

#
# Batch NS-2 Simulation Script for TFWC performance evaluation
#

echo -n "Do you want to delete all of the existing trace files before starting (y/n)? "
read isDelete
isDel=$isDelete
if [ $isDel == 'y' ] || [ $isDel =='Y' ]
then
	./rmall.sh
fi

clear

for i in `seq 0 20`;
do
	echo ""
done

echo "starting TCP/TFRC/TFWC simulations..."

TIME=200
RND=55
STEP=0.25

echo "What would you like to have for the traffic sources? "
echo -n "	1. TCP/TFRC, 2. TCP/TFWC"
echo -n "	   (1 or 2)? "
read sim_type
SIM_TYPE=$sim_type

#echo -n "What would you like to have the bottleneck bandwidth in (Mb/s)? "
#read bottleneck
#BW=$bottleneck

echo -n "What type of queue do you like to test (DropTail/RED)? "
read Q_TYPE
QTYPE=$Q_TYPE


###########################
###	TCP/TFRC	###
###########################
if [ $SIM_TYPE == "1"  ];
then

for i in 1 2 4 6 8 10 12 14 16 18 20
do

TCP=$i
TFRC=$i
TFWC=0
bw=.5
SRC=$TCP

	for i in `seq 1 50`;
	do

		# calculate bottleneck queue size
		QUEUE=`echo "0.022 * $bw * 10^6 / 8000" | bc -l`
		QUEUE=`add-on/round $QUEUE`

		if [ $QUEUE -lt 5 ];
		then
			QUEUE=5
		fi

		echo ""
		echo -n "ns main.tcl $TCP $TFRC $TFWC $bw $QUEUE $TIME $RND y $QTYPE > temp"
		echo ""
		nice ns main.tcl $TCP $TFRC $TFWC $bw $QUEUE $TIME $RND n $QTYPE > temp 2> /dev/null

		if [ $QTYPE == 'DropTail' ];
		then
			cp graph/aggr_fifo_thru.png archives/BW\($bw\)_fifo\($QUEUE\)_thru_tcp\($TCP\)_tfrc\($TFRC\)_tfwc\($TFWC\).png
		elif [ $QTYPE == 'RED' ];
		then
			cp graph/aggr_red_thru.png archives/BW\($bw\)_red\($QUEUE\)_thru_tcp\($TCP\)_tfrc\($TFRC\)_tfwc\($TFWC\).png
		fi

		./add-on/fairness tcp-tfrc $QTYPE $bw $SRC trace/tcp_thru_tot.dat trace/tfrc_thru_tot.dat
		bw=`echo $bw + $STEP | bc -l`
	done

	if [ $QTYPE == 'DropTail' ];
	then
		./add-on/breakline trace/tcp-tfrc_fifo_fairness.xg
	elif [ $QTYPE == 'RED' ];
	then
		./add-on/breakline trace/tcp-tfrc_red_fairness.xg
	fi
done

###########################
###	TCP/TFWC	###
###########################
elif [ $SIM_TYPE == "2" ];
then

for i in 1 2 4 6 8 10 12 14 16 18 20
do

TCP=$i
TFRC=0
TFWC=$i
bw=.5
SRC=$TCP

	for i in `seq 1 50`;
	do

		# calculate bottleneck queue size
		QUEUE=`echo "0.022 * $bw * 10^6 / 8000" | bc -l`
		QUEUE=`add-on/round $QUEUE`

		if [ $QUEUE -lt 5 ];
		then
			QUEUE=5
		fi

		echo ""
		echo -n "ns main.tcl $TCP $TFRC $TFWC $bw $QUEUE $TIME $RND n $QTYPE > temp"
		echo ""
		nice ns main.tcl $TCP $TFRC $TFWC $bw $QUEUE $TIME $RND y $QTYPE > temp 2> /dev/null

		if [ $QTYPE == 'DropTail' ];
		then
			cp graph/aggr_fifo_thru.png archives/BW\($bw\)_fifo\($QUEUE\)_thru_tcp\($TCP\)_tfrc\($TFRC\)_tfwc\($TFWC\).png
		elif [ $QTYPE == 'RED' ];
		then
			cp graph/aggr_red_thru.png archives/BW\($bw\)_red\($QUEUE\)_thru_tcp\($TCP\)_tfrc\($TFRC\)_tfwc\($TFWC\).png
		fi

		./add-on/fairness tcp-tfwc $QTYPE $bw $SRC trace/tcp_thru_tot.dat trace/tfwc_thru_tot.dat
		bw=`echo $bw + $STEP | bc -l`
	done

	if [ $QTYPE == 'DropTail' ];
	then
		./add-on/breakline trace/tcp-tfwc_fifo_fairness.xg
	elif [ $QTYPE == 'RED' ];
	then
		./add-on/breakline trace/tcp-tfwc_red_fairness.xg
	fi
done
fi
