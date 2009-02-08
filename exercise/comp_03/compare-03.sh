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
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/comp_03/compare-03.sh,v 1.1 2006/04/05 22:05:16 soohyunc Exp $ 
#

# Author: Soo-Hyun Choi (UCL Computer Science)
# E-mail: S.Choi@cs.ucl.ac.uk

#
# Batch NS-2 Simulation Script for TFWC performance evaluation
#

echo -n "Do you want to delete all of the existing trace files before get started (y/n)? "
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

QUEUE=5
TIME=500
RND=7
STEP=5

echo -n "What type of queue do you like to test (DropTail/RED)? "
read Q_TYPE
QTYPE=$Q_TYPE

for i in 1 2 4
do

TCP=$i
TFRC=$i
TFWC=0

	for i in `seq 1 20`;
	do
	echo ""
	echo -n "ns main.tcl $TCP $TFRC $TFWC $QUEUE $TIME $RND y $QTYPE > temp"
	echo ""
	nice ns main.tcl $TCP $TFRC $TFWC $QUEUE $TIME $RND y $QTYPE > temp

		if [ $QTYPE == 'DropTail' ];
		then
			cp graph/aggr_fifo_thru.png archives/fifo\($QUEUE\)_thru_tcp\($TCP\)_tfrc\($TFRC\)_tfwc\($TFWC\).png
		elif [ $QTYPE == 'RED' ];
		then
			cp graph/aggr_red_thru.png archives/red\($QUEUE\)_thru_tcp\($TCP\)_tfrc\($TFRC\)_tfwc\($TFWC\).png
		fi

	QUEUE=`echo $QUEUE + $STEP | bc -l`
	done
QUEUE=5
done
