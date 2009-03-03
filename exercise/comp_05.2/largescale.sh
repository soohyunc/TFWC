#
# Copyright(c) 2005-2008 University College London
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

if [ $# -lt 1 ];
then
	echo "	<<< Large-scale TFWC Batch Simulation >>>"
	echo "Usage: ./largescale.01.sh [a|b|c|d|e|f|g|h|i|j]"
	echo "	a: '1' for TCP/TFRC, and '2' for TCP/TFWC"
	echo "	b: access link speed"
	echo "	c: minimum access link delay"
	echo "	d: maximum access link delay"
	echo "	e: initial bottleneck link speed"
	echo "	f: bottleneck link delay"
	echo "	g: total simulation time"
	echo "	h: random seed number"
	echo "	i: is reverse TCP traffic (y/n)?"
	echo "	j: type of queue (DropTail/RED)"

	exit
fi

## take values
#read $sim_type $access_link_speed $access_min_delay $access_max_delay $bottleneck_link_speed $bottleneck_delay $sim_time $rnd $type_of_queue


## save values for internal use
SIM_TYPE=$1		# simulation type (TCP/TFRC or TCP/TFWC)
accessBW=$2		# access link BW
accessMinDel=$3		# access link min delay
accessMaxDel=$4		# access link max delay
bw=$5			# bottleneck link BW
bottleneckDel=$6	# bottleneck link delay
TIME=$7			# total sim time
RND=$8			# randon seed number
isReverse=$9		# is reverse TCP traffie?
toq=${10}			# type of queue

#SIM_TYPE=$sim_type		# simulation type (TCP/TFRC or TCP/TFWC)
#accessBW=$access_link_speed	# access link BW
#accessMinDel=$access_min_delay	# access link min delay
#accessMaxDel=$access_max_delay	# access link max delay
#bw=$bottleneck_link_speed	# bottleneck link BW
#bottleneckDel=$bottleneck_delay	# bottleneck link delay
#TIME=$sim_time			# total sim time
#RND=$rnd			# randon seed number
#toq=$type_of_queue		# type of queue

rtt=`echo "0.001 * (2 * ($bottleneckDel + ($accessMinDel + $accessMaxDel) / 2))" | bc -l`
e2e_dly=`echo "0.001 * ($bottleneckDel + ($accessMinDel + $accessMaxDel) / 2)" | bc -l`

echo `date` > trace/SIMENV
echo "" >> trace/SIMENV
echo "Simulation Type:	$SIM_TYPE" >> trace/SIMENV
echo "Access Link Speed:	$accessBW" >> trace/SIMENV
echo "Min Access Link Delay:	$accessMinDel" >> trace/SIMENV
echo "Max Access Link Delay:	$accessMaxDel" >> trace/SIMENV
echo "Initial Bottleneck Link Speed:	$bw" >> trace/SIMENV
echo "Bottleneck Link Delay:	$bottleneckDel" >> trace/SIMENV
echo "Total Simulation Time:	$TIME" >> trace/SIMENV
echo "Random Seed Number:	$RND" >> trace/SIMENV
echo "is reverse TCP traffic?	$isReverse" >> trace/SIMENV
echo "Queue Type:		$toq" >> trace/SIMENV
echo "approximate one-way delay:	$e2e_dly" >> trace/SIMENV
echo "approximate average RTT:	$rtt" >> trace/SIMENV

#############################
## function for TFRC stats ##
#############################
tfrc_stats () {

if [ $toq == 'DropTail' ]
then
	# the points where TCP or TFRC is dominant
	awk '{ if($3 > 0.8) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfrc_fifo\(.5\)_fairness.xg >> trace/tcp-tfrc_fifo\(.5\)_tcp_dominant.xg
	awk '{ if($3 < 0.2) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfrc_fifo\(.5\)_fairness.xg >> trace/tcp-tfrc_fifo\(.5\)_friendly_dominant.xg
	awk '{ if($3 > 0.8) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfrc_fifo\(1.0\)_fairness.xg >> trace/tcp-tfrc_fifo\(1.0\)_tcp_dominant.xg
	awk '{ if($3 < 0.2) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfrc_fifo\(1.0\)_fairness.xg >> trace/tcp-tfrc_fifo\(1.0\)_friendly_dominant.xg
	awk '{ if($3 > 0.8) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfrc_fifo\(4.0\)_fairness.xg >> trace/tcp-tfrc_fifo\(4.0\)_tcp_dominant.xg
	awk '{ if($3 < 0.2) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfrc_fifo\(4.0\)_fairness.xg >> trace/tcp-tfrc_fifo\(4.0\)_friendly_dominant.xg

	# find some simple statistics
	total_fifo_count_1=`cat trace/tcp-tfrc_fifo\(.5\)_fairness.xg | wc -l` 2> /dev/null
	total_fifo_count_2=`cat trace/tcp-tfrc_fifo\(1.0\)_fairness.xg | wc -l` 2> /dev/null
	total_fifo_count_3=`cat trace/tcp-tfrc_fifo\(4.0\)_fairness.xg | wc -l` 2> /dev/null
	tcp_fifo_dominant_count_1=`awk '{ if($3 > 0.8) print $0}' trace/tcp-tfrc_fifo\(.5\)_fairness.xg | wc -l` 2> /dev/null
	tcp_fifo_dominant_count_2=`awk '{ if($3 > 0.8) print $0}' trace/tcp-tfrc_fifo\(1.0\)_fairness.xg | wc -l` 2> /dev/null
	tcp_fifo_dominant_count_3=`awk '{ if($3 > 0.8) print $0}' trace/tcp-tfrc_fifo\(4.0\)_fairness.xg | wc -l` 2> /dev/null

	friendly_fifo_dominant_count_1=`awk '{ if($3 < 0.2) print $0}' trace/tcp-tfrc_fifo\(.5\)_fairness.xg | wc -l` 2> /dev/null
	friendly_fifo_dominant_count_2=`awk '{ if($3 < 0.2) print $0}' trace/tcp-tfrc_fifo\(1.0\)_fairness.xg | wc -l` 2> /dev/null
	friendly_fifo_dominant_count_3=`awk '{ if($3 < 0.2) print $0}' trace/tcp-tfrc_fifo\(4.0\)_fairness.xg | wc -l` 2> /dev/null

	unfainess_indicator_fifo_1=`echo "($tcp_fifo_dominant_count_1 + $friendly_fifo_dominant_count_1) / $total_fifo_count_1" | bc -l` 2> /dev/null
	unfainess_indicator_fifo_2=`echo "($tcp_fifo_dominant_count_2 + $friendly_fifo_dominant_count_2) / $total_fifo_count_2" | bc -l` 2> /dev/null
	unfainess_indicator_fifo_3=`echo "($tcp_fifo_dominant_count_3 + $friendly_fifo_dominant_count_3) / $total_fifo_count_3" | bc -l` 2> /dev/null

	echo ".5	$unfairness_indicator_fifo_1" >> trace/unfairness_fifo.xg 
	echo "1.0	$unfairness_indicator_fifo_2" >> trace/unfairness_fifo.xg 
	echo "4.0	$unfairness_indicator_fifo_3" >> trace/unfairness_fifo.xg 

	echo ".5	`echo "$tcp_fifo_dominant_count_1 / $total_fifo_count_1" | bc -l`" >> trace/tcp_fifo_dominant.xg
	echo "1.0	`echo "$tcp_fifo_dominant_count_2 / $total_fifo_count_2" | bc -l`" >> trace/tcp_fifo_dominant.xg
	echo "4.0	`echo "$tcp_fifo_dominant_count_3 / $total_fifo_count_3" | bc -l`" >> trace/tcp_fifo_dominant.xg

	echo ".5	`echo "$friendly_fifo_dominant_count_1 / $total_fifo_count_1" | bc -l`" >> trace/friendly_fifo_dominant.xg
	echo "1.0	`echo "$friendly_fifo_dominant_count_2 / $total_fifo_count_2" | bc -l`" >> trace/friendly_fifo_dominant.xg
	echo "4.0	`echo "$friendly_fifo_dominant_count_3 / $total_fifo_count_3" | bc -l`" >> trace/friendly_fifo_dominant.xg
elif [ $toq == 'RED' ]
then
	# the points where TCP or TFRC is dominant
	awk '{ if($3 > 0.8) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfrc_red\(.5\)_fairness.xg >> trace/tcp-tfrc_red\(.5\)_tcp_dominant.xg
	awk '{ if($3 < 0.2) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfrc_red\(.5\)_fairness.xg >> trace/tcp-tfrc_red\(.5\)_friendly_dominant.xg
	awk '{ if($3 > 0.8) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfrc_red\(1.0\)_fairness.xg >> trace/tcp-tfrc_red\(1.0\)_tcp_dominant.xg
	awk '{ if($3 < 0.2) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfrc_red\(1.0\)_fairness.xg >> trace/tcp-tfrc_red\(1.0\)_friendly_dominant.xg
	awk '{ if($3 > 0.8) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfrc_red\(4.0\)_fairness.xg >> trace/tcp-tfrc_red\(4.0\)_tcp_dominant.xg
	awk '{ if($3 < 0.2) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfrc_red\(4.0\)_fairness.xg >> trace/tcp-tfrc_red\(4.0\)_friendly_dominant.xg

	# find some simple statistics
	total_red_count_1=`cat trace/tcp-tfrc_red\(.5\)_fairness.xg | wc -l` 2> /dev/null
	total_red_count_2=`cat trace/tcp-tfrc_red\(1.0\)_fairness.xg | wc -l` 2> /dev/null
	total_red_count_3=`cat trace/tcp-tfrc_red\(4.0\)_fairness.xg | wc -l` 2> /dev/null

	tcp_red_dominant_count_1=`awk '{ if($3 > 0.8) print $0}' trace/tcp-tfrc_red\(.5\)_fairness.xg | wc -l` 2> /dev/null
	tcp_red_dominant_count_2=`awk '{ if($3 > 0.8) print $0}' trace/tcp-tfrc_red\(1.0\)_fairness.xg | wc -l` 2> /dev/null
	tcp_red_dominant_count_3=`awk '{ if($3 > 0.8) print $0}' trace/tcp-tfrc_red\(4.0\)_fairness.xg | wc -l` 2> /dev/null

	friendly_red_dominant_count_1=`awk '{ if($3 < 0.2) print $0}' trace/tcp-tfrc_red\(.5\)_fairness.xg | wc -l` 2> /dev/null
	friendly_red_dominant_count_2=`awk '{ if($3 < 0.2) print $0}' trace/tcp-tfrc_red\(1.0\)_fairness.xg | wc -l` 2> /dev/null
	friendly_red_dominant_count_3=`awk '{ if($3 < 0.2) print $0}' trace/tcp-tfrc_red\(4.0\)_fairness.xg | wc -l` 2> /dev/null

	unfainess_indicator_red_1=`echo "($tcp_red_dominant_count_1 + $friendly_red_dominant_count_1) / $total_red_count_1" | bc -l` 2> /dev/null
	unfainess_indicator_red_2=`echo "($tcp_red_dominant_count_2 + $friendly_red_dominant_count_2) / $total_red_count_2" | bc -l` 2> /dev/null
	unfainess_indicator_red_3=`echo "($tcp_red_dominant_count_3 + $friendly_red_dominant_count_3) / $total_red_count_3" | bc -l` 2> /dev/null

	echo ".5	$unfairness_indicator_red_1" >> trace/unfairness_red.xg 
	echo "1.0	$unfairness_indicator_red_2" >> trace/unfairness_red.xg 
	echo "4.0	$unfairness_indicator_red_3" >> trace/unfairness_red.xg 

	echo ".5	`echo "$tcp_red_dominant_count_1 / $total_red_count_1" | bc -l`" >> trace/tcp_red_dominant.xg
	echo "1.0	`echo "$tcp_red_dominant_count_2 / $total_red_count_2" | bc -l`" >> trace/tcp_red_dominant.xg
	echo "4.0	`echo "$tcp_red_dominant_count_3 / $total_red_count_3" | bc -l`" >> trace/tcp_red_dominant.xg

	echo ".5	`echo "$friendly_red_dominant_count_1 / $total_red_count_1" | bc -l`" >> trace/friendly_red_dominant.xg
	echo "1.0	`echo "$friendly_red_dominant_count_2 / $total_red_count_2" | bc -l`" >> trace/friendly_red_dominant.xg
	echo "4.0	`echo "$friendly_red_dominant_count_3 / $total_red_count_3" | bc -l`" >> trace/friendly_red_dominant.xg
fi
}

#############################
## function for TFWC stats ##
#############################
tfwc_stats () {

if [ $toq == 'DropTail' ]
then
	# the points where TCP or TFWC is dominant
	awk '{ if($3 > 0.8) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfwc_fifo\(.5\)_fairness.xg >> trace/tcp-tfwc_fifo\(.5\)_tcp_dominant.xg
	awk '{ if($3 < 0.2) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfwc_fifo\(.5\)_fairness.xg >> trace/tcp-tfwc_fifo\(.5\)_friendly_dominant.xg
	awk '{ if($3 > 0.8) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfwc_fifo\(1.0\)_fairness.xg >> trace/tcp-tfwc_fifo\(1.0\)_tcp_dominant.xg
	awk '{ if($3 < 0.2) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfwc_fifo\(1.0\)_fairness.xg >> trace/tcp-tfwc_fifo\(1.0\)_friendly_dominant.xg
	awk '{ if($3 > 0.8) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfwc_fifo\(4.0\)_fairness.xg >> trace/tcp-tfwc_fifo\(4.0\)_tcp_dominant.xg
	awk '{ if($3 < 0.2) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfwc_fifo\(4.0\)_fairness.xg >> trace/tcp-tfwc_fifo\(4.0\)_friendly_dominant.xg

	# find some simple statistics
	total_fifo_count_1=`cat trace/tcp-tfwc_fifo\(.5\)_fairness.xg | wc -l` 2> /dev/null
	total_fifo_count_2=`cat trace/tcp-tfwc_fifo\(1.0\)_fairness.xg | wc -l` 2> /dev/null
	total_fifo_count_3=`cat trace/tcp-tfwc_fifo\(4.0\)_fairness.xg | wc -l` 2> /dev/null

	tcp_fifo_dominant_count_1=`awk '{ if($3 > 0.8) print $0}' trace/tcp-tfwc_fifo\(.5\)_fairness.xg | wc -l` 2> /dev/null
	tcp_fifo_dominant_count_2=`awk '{ if($3 > 0.8) print $0}' trace/tcp-tfwc_fifo\(1.0\)_fairness.xg | wc -l` 2> /dev/null
	tcp_fifo_dominant_count_3=`awk '{ if($3 > 0.8) print $0}' trace/tcp-tfwc_fifo\(4.0\)_fairness.xg | wc -l` 2> /dev/null

	friendly_fifo_dominant_count_1=`awk '{ if($3 < 0.2) print $0}' trace/tcp-tfwc_fifo\(.5\)_fairness.xg | wc -l` 2> /dev/null
	friendly_fifo_dominant_count_2=`awk '{ if($3 < 0.2) print $0}' trace/tcp-tfwc_fifo\(1.0\)_fairness.xg | wc -l` 2> /dev/null
	friendly_fifo_dominant_count_3=`awk '{ if($3 < 0.2) print $0}' trace/tcp-tfwc_fifo\(4.0\)_fairness.xg | wc -l` 2> /dev/null

	unfainess_indicator_fifo_1=`echo "($tcp_fifo_dominant_count_1 + $friendly_fifo_dominant_count_1) / $total_fifo_count_1" | bc -l` 2> /dev/null
	unfainess_indicator_fifo_2=`echo "($tcp_fifo_dominant_count_2 + $friendly_fifo_dominant_count_2) / $total_fifo_count_2" | bc -l` 2> /dev/null
	unfainess_indicator_fifo_3=`echo "($tcp_fifo_dominant_count_3 + $friendly_fifo_dominant_count_3) / $total_fifo_count_3" | bc -l` 2> /dev/null

	echo ".5	$unfairness_indicator_fifo_1" >> trace/unfairness_fifo.xg 
	echo "1.0	$unfairness_indicator_fifo_2" >> trace/unfairness_fifo.xg 
	echo "4.0	$unfairness_indicator_fifo_3" >> trace/unfairness_fifo.xg 

	echo ".5	`echo "$tcp_fifo_dominant_count_1 / $total_fifo_count_1" | bc -l`" >> trace/tcp_fifo_dominant.xg
	echo "1.0	`echo "$tcp_fifo_dominant_count_2 / $total_fifo_count_2" | bc -l`" >> trace/tcp_fifo_dominant.xg
	echo "4.0	`echo "$tcp_fifo_dominant_count_3 / $total_fifo_count_3" | bc -l`" >> trace/tcp_fifo_dominant.xg

	echo ".5	`echo "$friendly_fifo_dominant_count_1 / $total_fifo_count_1" | bc -l`" >> trace/friendly_fifo_dominant.xg
	echo "1.0	`echo "$friendly_fifo_dominant_count_2 / $total_fifo_count_2" | bc -l`" >> trace/friendly_fifo_dominant.xg
	echo "4.0	`echo "$friendly_fifo_dominant_count_3 / $total_fifo_count_3" | bc -l`" >> trace/friendly_fifo_dominant.xg
elif [ $toq == 'RED' ]
then
	# the points where TCP or TFWC is dominant
	awk '{ if($3 > 0.8) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfwc_red\(.5\)_fairness.xg >> trace/tcp-tfwc_red\(.5\)_tcp_dominant.xg
	awk '{ if($3 < 0.2) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfwc_red\(.5\)_fairness.xg >> trace/tcp-tfwc_red\(.5\)_friendly_dominant.xg
	awk '{ if($3 > 0.8) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfwc_red\(1.0\)_fairness.xg >> trace/tcp-tfwc_red\(1.0\)_tcp_dominant.xg
	awk '{ if($3 < 0.2) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfwc_red\(1.0\)_fairness.xg >> trace/tcp-tfwc_red\(1.0\)_friendly_dominant.xg
	awk '{ if($3 > 0.8) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfwc_red\(4.0\)_fairness.xg >> trace/tcp-tfwc_red\(4.0\)_tcp_dominant.xg
	awk '{ if($3 < 0.2) print $0; cur = $2; if (cur != prev) print ""; prev = $2}' trace/tcp-tfwc_red\(4.0\)_fairness.xg >> trace/tcp-tfwc_red\(4.0\)_friendly_dominant.xg

	# find some simple statistics
	total_red_count_1=`cat trace/tcp-tfwc_red\(.5\)_fairness.xg | wc -l` 2> /dev/null
	total_red_count_2=`cat trace/tcp-tfwc_red\(1.0\)_fairness.xg | wc -l` 2> /dev/null
	total_red_count_3=`cat trace/tcp-tfwc_red\(4.0\)_fairness.xg | wc -l` 2> /dev/null

	tcp_red_dominant_count_1=`awk '{ if($3 > 0.8) print $0}' trace/tcp-tfwc_red\(.5\)_fairness.xg | wc -l` 2> /dev/null
	tcp_red_dominant_count_2=`awk '{ if($3 > 0.8) print $0}' trace/tcp-tfwc_red\(1.0\)_fairness.xg | wc -l` 2> /dev/null
	tcp_red_dominant_count_3=`awk '{ if($3 > 0.8) print $0}' trace/tcp-tfwc_red\(4.0\)_fairness.xg | wc -l` 2> /dev/null

	friendly_red_dominant_count_1=`awk '{ if($3 < 0.2) print $0}' trace/tcp-tfwc_red\(.5\)_fairness.xg | wc -l` 2> /dev/null
	friendly_red_dominant_count_2=`awk '{ if($3 < 0.2) print $0}' trace/tcp-tfwc_red\(1.0\)_fairness.xg | wc -l` 2> /dev/null
	friendly_red_dominant_count_3=`awk '{ if($3 < 0.2) print $0}' trace/tcp-tfwc_red\(4.0\)_fairness.xg | wc -l` 2> /dev/null

	unfainess_indicator_red_1=`echo "($tcp_red_dominant_count_1 + $friendly_red_dominant_count_1) / $total_red_count_1" | bc -l` 2> /dev/null
	unfainess_indicator_red_2=`echo "($tcp_red_dominant_count_2 + $friendly_red_dominant_count_2) / $total_red_count_2" | bc -l` 2> /dev/null
	unfainess_indicator_red_3=`echo "($tcp_red_dominant_count_3 + $friendly_red_dominant_count_3) / $total_red_count_3" | bc -l` 2> /dev/null

	echo ".5	$unfairness_indicator_red_1" >> trace/unfairness_red.xg 
	echo "1.0	$unfairness_indicator_red_2" >> trace/unfairness_red.xg 
	echo "4.0	$unfairness_indicator_red_3" >> trace/unfairness_red.xg 

	echo ".5	`echo "$tcp_red_dominant_count_1 / $total_red_count_1" | bc -l`" >> trace/tcp_red_dominant.xg
	echo "1.0	`echo "$tcp_red_dominant_count_2 / $total_red_count_2" | bc -l`" >> trace/tcp_red_dominant.xg
	echo "4.0	`echo "$tcp_red_dominant_count_3 / $total_red_count_3" | bc -l`" >> trace/tcp_red_dominant.xg

	echo ".5	`echo "$friendly_red_dominant_count_1 / $total_red_count_1" | bc -l`" >> trace/friendly_red_dominant.xg
	echo "1.0	`echo "$friendly_red_dominant_count_2 / $total_red_count_2" | bc -l`" >> trace/friendly_red_dominant.xg
	echo "4.0	`echo "$friendly_red_dominant_count_3 / $total_red_count_3" | bc -l`" >> trace/friendly_red_dominant.xg
fi
}

##################################
##################################
##                              ##
##                              ##
## Main Batch Simulation Script ##
##                              ##
##                              ##
##################################
##################################
STEP1=0.2
STEP2=2.0
STEP3=5.0

##############
## TCP/TFRC ##
##############
if [ $SIM_TYPE == "1" ]
then

for i in 1 2 4 10 20 40 60 80 100
do

tcp=$i
tfrc=$i
tfwc=0
SRC=$tcp

# queue size is equal to .5 * delay x bandwidth
delbw=`echo ".5" | bc -l`
bw=$5	# initialize bottleneck b/w 
for i in `seq 1 20`
do
	# bottleneck bandwidth mainpulation
	if [ $i -le "5" ]
	then
		if [ $i -eq "1" ]
		then
			bw=$bw
		elif [ $i -ge "2" ] && [ $i -le "4" ]
		then
			bw=`echo $bw \* $STEP2 | bc -l`
		else
			bw=`echo $bw + $STEP1 | bc -l`
		fi
	elif [ $i -gt "5" ] && [ $i -le "10" ]
	then
		if [ $i -eq "6" ]
		then
			# this will make bw=(2.0) only
			bw=`echo $bw \* $STEP2 | bc -l`
		else
			# this will make bw=(4.0, 6.0, 8.0, 10.0)
			bw=`echo $bw + $STEP2  | bc -l`
		fi
	elif [ $i -gt "10" ]
	then
		# this will make bw=(10.0, 20.0, 30.0, 40.0, 50.0)
		bw=`echo $bw + $STEP3 | bc -l`
	fi

	# wrap up if bottleneck b/w is greater than access link b/w
	integer_bw=`add-on/round $bw`
	integer_accessBW=`add-on/round $accessBW`
	if [ $integer_bw -gt $integer_accessBW ]
	then
		bw=$accessBW
	fi

	# calculate bottleneck queue size
	qsize=`echo "$delbw * $rtt * $bw * 10^6 / 8000" | bc -l`
	qsize=`add-on/round $qsize`

	# if queue is less than 5, we set it 5
	if [ $qsize -lt 5 ]
	then
		qsize=5
	fi

	echo -n "ns main.tcl $tcp $tfrc $tfwc $accessBW $accessMinDel $accessMaxDel $bw $bottleneckDel $qsize $TIME $RND $isReverse $toq > temp"
	echo ""
	nice ns main.tcl $tcp $tfrc $tfwc $accessBW $accessMinDel $accessMaxDel $bw $bottleneckDel $qsize $TIME $RND $isReverse $toq > temp 2> /dev/null

	# CoV computation
	cat trace/tcp_avg_cov.xg >> trace/tcp_cov.xg
	cat trace/tfrc_avg_cov.xg >> trace/tfrc_cov.xg

	# archives throughput and fairness
	if [ $toq == 'DropTail' ]
	then
		cp graph/aggr_fifo_thru.png archives/BW\($bw\)_fifo\($qsize\)_thru_tcp\($tcp\)_tfrc\($tfrc\)_tfwc\($tfwc\).png
		./add-on/fairness tcp-tfrc $toq $bw $SRC trace/tcp_thru_tot.dat trace/tfrc_thru_tot.dat
		cat trace/tcp-tfrc_fifo_fairness.xg >> trace/tcp-tfrc_fifo\($delbw\)_fairness.xg
		rm trace/tcp-tfrc_fifo_fairness.xg
	elif [ $toq == 'RED' ]
	then
		cp graph/aggr_red_thru.png archives/BW\($bw\)_red\($qsize\)_thru_tcp\($tcp\)_tfrc\($tfrc\)_tfwc\($tfwc\).png
		./add-on/fairness tcp-tfrc $toq $bw $SRC trace/tcp_thru_tot.dat trace/tfrc_thru_tot.dat
		cat trace/tcp-tfrc_red_fairness.xg >> trace/tcp-tfrc_red\($delbw\)_fairness.xg
		rm trace/tcp-tfrc_red_fairness.xg
	fi
done 2> /dev/null # done for .5 * delay*bw

	cat trace/tcp_cov.xg >> trace/tcp_\($delbw\)_cov.xg
	cat trace/tfrc_cov.xg >> trace/tfrc_\($delbw\)_cov.xg

	# make a line break for 3-D plot for each of the case
	if [ -f trace/tcp-tfrc_fifo\($delbw\)_fairness.xg ]
	then
		./add-on/breakline trace/tcp-tfrc_fifo\($delbw\)_fairness.xg
		./add-on/breakline trace/tcp_\($delbw\)_cov.xg
		./add-on/breakline trace/tfrc_\($delbw\)_cov.xg
	elif [ -f trace/tcp-tfrc_red\($delbw\)_fairness.xg ]
	then
		./add-on/breakline trace/tcp-tfrc_red\($delbw\)_fairness.xg
		./add-on/breakline trace/tcp_\($delbw\)_cov.xg
		./add-on/breakline trace/tfrc_\($delbw\)_cov.xg
	fi
	echo ""

	rm trace/tcp_cov.xg
	rm trace/tfrc_cov.xg

# queue size is equal to delay x bandwidth
delbw=`echo "1.5" | bc -l`
bw=$5	# initialize bottleneck b/w 
for i in `seq 1 20`
do
	# bottleneck bandwidth mainpulation
	if [ $i -le "5" ]
	then
		if [ $i -eq "1" ]
		then
			bw=$bw
		elif [ $i -ge "2" ] && [ $i -le "4" ]
		then
			bw=`echo $bw \* $STEP2 | bc -l`
		else
			bw=`echo $bw + $STEP1 | bc -l`
		fi
	elif [ $i -gt "5" ] && [ $i -le "10" ]
	then
		if [ $i -eq "6" ]
		then
			# this will make bw=(2.0) only
			bw=`echo $bw \* $STEP2 | bc -l`
		else
			# this will make bw=(4.0, 6.0, 8.0, 10.0)
			bw=`echo $bw + $STEP2  | bc -l`
		fi
	elif [ $i -gt "10" ]
	then
		# this will make bw=(10.0, 20.0, 30.0, 40.0, 50.0)
		bw=`echo $bw + $STEP3 | bc -l`
	fi

	# wrap up if bottleneck b/w is greater than access link b/w
	integer_bw=`add-on/round $bw`
	integer_accessBW=`add-on/round $accessBW`
	if [ $integer_bw -gt $integer_accessBW ]
	then
		bw=$accessBW
	fi

	# calculate bottleneck queue size
	qsize=`echo "$delbw * $rtt * $bw * 10^6 / 8000" | bc -l`
	qsize=`add-on/round $qsize`

	# if queue is less than 5, we set it 5
	if [ $qsize -lt 5 ]
	then
		qsize=5
	fi

	echo -n "ns main.tcl $tcp $tfrc $tfwc $accessBW $accessMinDel $accessMaxDel $bw $bottleneckDel $qsize $TIME $RND $isReverse $toq > temp"
	echo ""
	nice ns main.tcl $tcp $tfrc $tfwc $accessBW $accessMinDel $accessMaxDel $bw $bottleneckDel $qsize $TIME $RND $isReverse $toq > temp 2> /dev/null

	# CoV computation
	cat trace/tcp_avg_cov.xg >> trace/tcp_cov.xg
	cat trace/tfrc_avg_cov.xg >> trace/tfrc_cov.xg

	if [ $toq == 'DropTail' ]
	then
		cp graph/aggr_fifo_thru.png archives/BW\($bw\)_fifo\($qsize\)_thru_tcp\($tcp\)_tfrc\($tfrc\)_tfwc\($tfwc\).png
		./add-on/fairness tcp-tfrc $toq $bw $SRC trace/tcp_thru_tot.dat trace/tfrc_thru_tot.dat
		cat trace/tcp-tfrc_fifo_fairness.xg >> trace/tcp-tfrc_fifo\($delbw\)_fairness.xg
		rm trace/tcp-tfrc_fifo_fairness.xg
	elif [ $toq == 'RED' ]
	then
		cp graph/aggr_red_thru.png archives/BW\($bw\)_red\($qsize\)_thru_tcp\($tcp\)_tfrc\($tfrc\)_tfwc\($tfwc\).png
		./add-on/fairness tcp-tfrc $toq $bw $SRC trace/tcp_thru_tot.dat trace/tfrc_thru_tot.dat
		cat trace/tcp-tfrc_red_fairness.xg >> trace/tcp-tfrc_red\($delbw\)_fairness.xg
		rm trace/tcp-tfrc_red_fairness.xg
	fi
done 2> /dev/null # done for delay*bw

	cat trace/tcp_cov.xg >> trace/tcp_\($delbw\)_cov.xg
	cat trace/tfrc_cov.xg >> trace/tfrc_\($delbw\)_cov.xg

	# make a line break for 3-D plot for each of the case
	if [ -f trace/tcp-tfrc_fifo\($delbw\)_fairness.xg ]
	then
		./add-on/breakline trace/tcp-tfrc_fifo\($delbw\)_fairness.xg
		./add-on/breakline trace/tcp_\($delbw\)_cov.xg
		./add-on/breakline trace/tfrc_\($delbw\)_cov.xg
	elif [ -f trace/tcp-tfrc_red\($delbw\)_fairness.xg ]
	then
		./add-on/breakline trace/tcp-tfrc_red\($delbw\)_fairness.xg
		./add-on/breakline trace/tcp_\($delbw\)_cov.xg
		./add-on/breakline trace/tfrc_\($delbw\)_cov.xg
	fi
	echo ""

	rm trace/tcp_cov.xg
	rm trace/tfrc_cov.xg

# queue size is equal to 4 * delay x bandwidth
delbw=`echo "4.0" | bc -l`
bw=$5	# initialize bottleneck b/w 
for i in `seq 1 20`
do
	# bottleneck bandwidth mainpulation
	if [ $i -le "5" ]
	then
		if [ $i -eq "1" ]
		then
			bw=$bw
		elif [ $i -ge "2" ] && [ $i -le "4" ]
		then
			bw=`echo $bw \* $STEP2 | bc -l`
		else
			bw=`echo $bw + $STEP1 | bc -l`
		fi
	elif [ $i -gt "5" ] && [ $i -le "10" ]
	then
		if [ $i -eq "6" ]
		then
			# this will make bw=(2.0) only
			bw=`echo $bw \* $STEP2 | bc -l`
		else
			# this will make bw=(4.0, 6.0, 8.0, 10.0)
			bw=`echo $bw + $STEP2  | bc -l`
		fi
	elif [ $i -gt "10" ]
	then
		# this will make bw=(10.0, 20.0, 30.0, 40.0, 50.0)
		bw=`echo $bw + $STEP3 | bc -l`
	fi

	# wrap up if bottleneck b/w is greater than access link b/w
	integer_bw=`add-on/round $bw`
	integer_accessBW=`add-on/round $accessBW`
	if [ $integer_bw -gt $integer_accessBW ]
	then
		bw=$accessBW
	fi

	# calculate bottleneck queue size
	qsize=`echo "$delbw * $rtt * $bw * 10^6 / 8000" | bc -l`
	qsize=`add-on/round $qsize`

	# if queue is less than 5, we set it 5
	if [ $qsize -lt 5 ]
	then
		qsize=5
	fi

	echo -n "ns main.tcl $tcp $tfrc $tfwc $accessBW $accessMinDel $accessMaxDel $bw $bottleneckDel $qsize $TIME $RND $isReverse $toq > temp"
	echo ""
	nice ns main.tcl $tcp $tfrc $tfwc $accessBW $accessMinDel $accessMaxDel $bw $bottleneckDel $qsize $TIME $RND $isReverse $toq > temp 2> /dev/null

	# CoV computation
	cat trace/tcp_avg_cov.xg >> trace/tcp_cov.xg 
	cat trace/tfrc_avg_cov.xg >> trace/tfrc_cov.xg

	if [ $toq == 'DropTail' ]
	then
		cp graph/aggr_fifo_thru.png archives/BW\($bw\)_fifo\($qsize\)_thru_tcp\($tcp\)_tfrc\($tfrc\)_tfwc\($tfwc\).png
		./add-on/fairness tcp-tfrc $toq $bw $SRC trace/tcp_thru_tot.dat trace/tfrc_thru_tot.dat
		cat trace/tcp-tfrc_fifo_fairness.xg >> trace/tcp-tfrc_fifo\($delbw\)_fairness.xg
		rm trace/tcp-tfrc_fifo_fairness.xg
	elif [ $toq == 'RED' ]
	then
		cp graph/aggr_red_thru.png archives/BW\($bw\)_red\($qsize\)_thru_tcp\($tcp\)_tfrc\($tfrc\)_tfwc\($tfwc\).png
		./add-on/fairness tcp-tfrc $toq $bw $SRC trace/tcp_thru_tot.dat trace/tfrc_thru_tot.dat
		cat trace/tcp-tfrc_red_fairness.xg >> trace/tcp-tfrc_red\($delbw\)_fairness.xg
		rm trace/tcp-tfrc_red_fairness.xg
	fi
done 2> /dev/null # done for 4 * delay*bw

	cat trace/tcp_cov.xg >> trace/tcp_\($delbw\)_cov.xg
	cat trace/tfrc_cov.xg >> trace/tfrc_\($delbw\)_cov.xg

	# make a line break for 3-D plot for each of the case
	if [ -f trace/tcp-tfrc_fifo\($delbw\)_fairness.xg ]
	then
		./add-on/breakline trace/tcp-tfrc_fifo\($delbw\)_fairness.xg
		./add-on/breakline trace/tcp_\($delbw\)_cov.xg
		./add-on/breakline trace/tfrc_\($delbw\)_cov.xg
	elif [ -f trace/tcp-tfrc_red\($delbw\)_fairness.xg ]
	then
		./add-on/breakline trace/tcp-tfrc_red\($delbw\)_fairness.xg
		./add-on/breakline trace/tcp_\($delbw\)_cov.xg
		./add-on/breakline trace/tfrc_\($delbw\)_cov.xg
	fi
	echo ""

	rm trace/tcp_cov.xg
	rm trace/tfrc_cov.xg

done 2> /dev/null ## done for TCP/TFRC

tfrc_stats
for i in .5 1.0 4.0
do
	plt/plotting.fairness.sh trace/tcp-tfrc\($i\)_fairness.xg trace/tcp-tfrc\($i\)_friendly_dominant.xg trace/tcp-tfrc\($i\)_tcp_dominant.xg
	cp graph/fairness.eps archives/tcp-tfrc_$toq\($i\)_fairness.eps 
done

##############
## TCP/TFWC ##
##############
elif [ $SIM_TYPE == "2" ]
then

for i in 1 2 4 10 20 40 60 80 100
do

tcp=$i
tfrc=0
tfwc=$i
SRC=$tcp

# queue size is equal to .5 * delay x bandwidth
delbw=`echo ".5" | bc -l`
bw=$5	# initialize bottleneck b/w 
for i in `seq 1 20`;
do
	# bottleneck bandwidth mainpulation
	if [ $i -le "5" ]
	then
		if [ $i -eq "1" ]
		then
			bw=$bw
		elif [ $i -ge "2" ] && [ $i -le "4" ]
		then
			bw=`echo $bw \* $STEP2 | bc -l`
		else
			bw=`echo $bw + $STEP1 | bc -l`
		fi
	elif [ $i -gt "5" ] && [ $i -le "10" ]
	then
		if [ $i -eq "6" ]
		then
			# this will make bw=(2.0) only
			bw=`echo $bw \* $STEP2 | bc -l`
		else
			# this will make bw=(4.0, 6.0, 8.0, 10.0)
			bw=`echo $bw + $STEP2  | bc -l`
		fi
	elif [ $i -gt "10" ]
	then
		# this will make bw=(10.0, 20.0, 30.0, 40.0, 50.0)
		bw=`echo $bw + $STEP3 | bc -l`
	fi

	# wrap up if bottleneck b/w is greater than access link b/w
	integer_bw=`add-on/round $bw`
	integer_accessBW=`add-on/round $accessBW`
	if [ $integer_bw -gt $integer_accessBW ]
	then
		bw=$accessBW
	fi

	# calculate bottleneck queue size
	qsize=`echo "$delbw * $rtt * $bw * 10^6 / 8000" | bc -l`
	qsize=`add-on/round $qsize`
		
	# if queue is less than 5, we set it 5
	if [ $qsize -lt 5 ]
	then
		qsize=5
	fi

	echo -n "ns main.tcl $tcp $tfrc $tfwc $accessBW $accessMinDel $accessMaxDel $bw $bottleneckDel $qsize $TIME $RND $isReverse $toq > temp"
	echo ""
	nice ns main.tcl $tcp $tfrc $tfwc $accessBW $accessMinDel $accessMaxDel $bw $bottleneckDel $qsize $TIME $RND $isReverse $toq > temp 2> /dev/null

	# CoV computation
	cat trace/tcp_avg_cov.xg >> trace/tcp_cov.xg
	cat trace/tfwc_avg_cov.xg >> trace/tfwc_cov.xg

	if [ $toq == 'DropTail' ]
	then
		cp graph/aggr_fifo_thru.png archives/BW\($bw\)_fifo\($qsize\)_thru_tcp\($tcp\)_tfrc\($tfrc\)_tfwc\($tfwc\).png
		./add-on/fairness tcp-tfwc $toq $bw $SRC trace/tcp_thru_tot.dat trace/tfwc_thru_tot.dat
		cat trace/tcp-tfwc_fifo_fairness.xg >> trace/tcp-tfwc_fifo\($delbw\)_fairness.xg
		rm trace/tcp-tfwc_fifo_fairness.xg
	elif [ $toq == 'RED' ]
	then
		cp graph/aggr_red_thru.png archives/BW\($bw\)_red\($qsize\)_thru_tcp\($tcp\)_tfrc\($tfrc\)_tfwc\($tfwc\).png
		./add-on/fairness tcp-tfwc $toq $bw $SRC trace/tcp_thru_tot.dat trace/tfwc_thru_tot.dat
		cat trace/tcp-tfwc_red_fairness.xg >> trace/tcp-tfwc_red\($delbw\)_fairness.xg
		rm trace/tcp-tfwc_red_fairness.xg
	fi
done 2> /dev/null # done for .5 * delay*bw

	cat trace/tcp_cov.xg >> trace/tcp_\($delbw\)_cov.xg
	cat trace/tfwc_cov.xg >> trace/tfwc_\($delbw\)_cov.xg

	# make a line break for 3-D plot for each of the case
	if [ -f trace/tcp-tfwc_fifo\($delbw\)_fairness.xg ]
	then
		./add-on/breakline trace/tcp-tfwc_fifo\($delbw\)_fairness.xg
		./add-on/breakline trace/tcp_\($delbw\)_cov.xg
		./add-on/breakline trace/tfwc_\($delbw\)_cov.xg
	elif [ -f trace/tcp-tfwc_red\($delbw\)_fairness.xg ]
	then
		./add-on/breakline trace/tcp-tfwc_red\($delbw\)_fairness.xg
		./add-on/breakline trace/tcp_\($delbw\)_cov.xg
		./add-on/breakline trace/tfwc_\($delbw\)_cov.xg
	fi
	echo ""

	rm trace/tcp_cov.xg
	rm trace/tfwc_cov.xg

# queue size is equal to 1.5 x delay x bandwidth
delbw=`echo "1.0" | bc -l`
bw=$5	# initialize bottleneck b/w 
for i in `seq 1 20`;
do
	# bottleneck bandwidth mainpulation
	if [ $i -le "5" ]
	then
		if [ $i -eq "1" ]
		then
			bw=$bw
		elif [ $i -ge "2" ] && [ $i -le "4" ]
		then
			bw=`echo $bw \* $STEP2 | bc -l`
		else
			bw=`echo $bw + $STEP1 | bc -l`
		fi
	elif [ $i -gt "5" ] && [ $i -le "10" ]
	then
		if [ $i -eq "6" ]
		then
			# this will make bw=(2.0) only
			bw=`echo $bw \* $STEP2 | bc -l`
		else
			# this will make bw=(4.0, 6.0, 8.0, 10.0)
			bw=`echo $bw + $STEP2  | bc -l`
		fi
	elif [ $i -gt "10" ]
	then
		# this will make bw=(10.0, 20.0, 30.0, 40.0, 50.0)
		bw=`echo $bw + $STEP3 | bc -l`
	fi

	# wrap up if bottleneck b/w is greater than access link b/w
	integer_bw=`add-on/round $bw`
	integer_accessBW=`add-on/round $accessBW`
	if [ $integer_bw -gt $integer_accessBW ]
	then
		bw=$accessBW
	fi

	# calculate bottleneck queue size
	qsize=`echo "$delbw * $rtt * $bw * 10^6 / 8000" | bc -l`
	qsize=`add-on/round $qsize`
		
	# if queue is less than 5, we set it 5
	if [ $qsize -lt 5 ]
	then
		qsize=5
	fi

	echo -n "ns main.tcl $tcp $tfrc $tfwc $accessBW $accessMinDel $accessMaxDel $bw $bottleneckDel $qsize $TIME $RND $isReverse $toq > temp"
	echo ""
	nice ns main.tcl $tcp $tfrc $tfwc $accessBW $accessMinDel $accessMaxDel $bw $bottleneckDel $qsize $TIME $RND $isReverse $toq > temp 2> /dev/null

	# CoV computation
	cat trace/tcp_avg_cov.xg >> trace/tcp_cov.xg
	cat trace/tfwc_avg_cov.xg >> trace/tfwc_cov.xg

	if [ $toq == 'DropTail' ]
	then
		cp graph/aggr_fifo_thru.png archives/BW\($bw\)_fifo\($qsize\)_thru_tcp\($tcp\)_tfrc\($tfrc\)_tfwc\($tfwc\).png
		./add-on/fairness tcp-tfwc $toq $bw $SRC trace/tcp_thru_tot.dat trace/tfwc_thru_tot.dat
		cat trace/tcp-tfwc_fifo_fairness.xg >> trace/tcp-tfwc_fifo\($delbw\)_fairness.xg
		rm trace/tcp-tfwc_fifo_fairness.xg
	elif [ $toq == 'RED' ]
	then
		cp graph/aggr_red_thru.png archives/BW\($bw\)_red\($qsize\)_thru_tcp\($tcp\)_tfrc\($tfrc\)_tfwc\($tfwc\).png
		./add-on/fairness tcp-tfwc $toq $bw $SRC trace/tcp_thru_tot.dat trace/tfwc_thru_tot.dat
		cat trace/tcp-tfwc_red_fairness.xg >> trace/tcp-tfwc_red\($delbw\)_fairness.xg
		rm trace/tcp-tfwc_red_fairness.xg
	fi
done 2> /dev/null # done for delay*bw

	cat trace/tcp_cov.xg >> trace/tcp_\($delbw\)_cov.xg
	cat trace/tfwc_cov.xg >> trace/tfwc_\($delbw\)_cov.xg

	# make a line break for 3-D plot for each of the case
	if [ -f trace/tcp-tfwc_fifo\($delbw\)_fairness.xg ]
	then
		./add-on/breakline trace/tcp-tfwc_fifo\($delbw\)_fairness.xg
		./add-on/breakline trace/tcp_\($delbw\)_cov.xg
		./add-on/breakline trace/tfwc_\($delbw\)_cov.xg
	elif [ -f trace/tcp-tfwc_red\($delbw\)_fairness.xg ]
	then
		./add-on/breakline trace/tcp-tfwc_red\($delbw\)_fairness.xg
		./add-on/breakline trace/tcp_\($delbw\)_cov.xg
		./add-on/breakline trace/tfwc_\($delbw\)_cov.xg
	fi
	echo ""

	rm trace/tcp_cov.xg
	rm trace/tfwc_cov.xg

# queue size is equal to 4 * delay x bandwidth
delbw=`echo "4.0" | bc -l`
bw=$5	# initialize bottleneck b/w
for i in `seq 1 20`;
do
	# bottleneck bandwidth mainpulation
	if [ $i -le "5" ]
	then
		if [ $i -eq "1" ]
		then
			bw=$bw
		elif [ $i -ge "2" ] && [ $i -le "4" ]
		then
			bw=`echo $bw \* $STEP2 | bc -l`
		else
			bw=`echo $bw + $STEP1 | bc -l`
		fi
	elif [ $i -gt "5" ] && [ $i -le "10" ]
	then
		if [ $i -eq "6" ]
		then
			# this will make bw=(2.0) only
			bw=`echo $bw \* $STEP2 | bc -l`
		else
			# this will make bw=(4.0, 6.0, 8.0, 10.0)
			bw=`echo $bw + $STEP2  | bc -l`
		fi
	elif [ $i -gt "10" ]
	then
		# this will make bw=(10.0, 20.0, 30.0, 40.0, 50.0)
		bw=`echo $bw + $STEP3 | bc -l`
	fi

	# wrap up if bottleneck b/w is greater than access link b/w
	integer_bw=`add-on/round $bw`
	integer_accessBW=`add-on/round $accessBW`
	if [ $integer_bw -gt $integer_accessBW ]
	then
		bw=$accessBW
	fi

	# calculate bottleneck queue size
	qsize=`echo "$delbw * $rtt * $bw * 10^6 / 8000" | bc -l`
	qsize=`add-on/round $qsize`
		
	# if queue is less than 5, we set it 5
	if [ $qsize -lt 5 ]
	then
		qsize=5
	fi

	echo -n "ns main.tcl $tcp $tfrc $tfwc $accessBW $accessMinDel $accessMaxDel $bw $bottleneckDel $qsize $TIME $RND $isReverse $toq > temp"
	echo ""
	nice ns main.tcl $tcp $tfrc $tfwc $accessBW $accessMinDel $accessMaxDel $bw $bottleneckDel $qsize $TIME $RND $isReverse $toq > temp 2> /dev/null

	# CoV computation
	cat trace/tcp_avg_cov.xg >> trace/tcp_cov.xg
	cat trace/tfwc_avg_cov.xg >> trace/tfwc_cov.xg

	if [ $toq == 'DropTail' ]
	then
		cp graph/aggr_fifo_thru.png archives/BW\($bw\)_fifo\($qsize\)_thru_tcp\($tcp\)_tfrc\($tfrc\)_tfwc\($tfwc\).png
		./add-on/fairness tcp-tfwc $toq $bw $SRC trace/tcp_thru_tot.dat trace/tfwc_thru_tot.dat
		cat trace/tcp-tfwc_fifo_fairness.xg >> trace/tcp-tfwc_fifo\($delbw\)_fairness.xg
		rm trace/tcp-tfwc_fifo_fairness.xg
	elif [ $toq == 'RED' ]
	then
		cp graph/aggr_red_thru.png archives/BW\($bw\)_red\($qsize\)_thru_tcp\($tcp\)_tfrc\($tfrc\)_tfwc\($tfwc\).png
		./add-on/fairness tcp-tfwc $toq $bw $SRC trace/tcp_thru_tot.dat trace/tfwc_thru_tot.dat
		cat trace/tcp-tfwc_red_fairness.xg >> trace/tcp-tfwc_red\($delbw\)_fairness.xg
		rm trace/tcp-tfwc_red_fairness.xg
	fi
done 2> /dev/null # done for 4 * delay*bw

	cat trace/tcp_cov.xg >> trace/tcp_\($delbw\)_cov.xg
	cat trace/tfwc_cov.xg >> trace/tfwc_\($delbw\)_cov.xg

	# make a line break for 3-D plot for each of the case
	if [ -f trace/tcp-tfwc_fifo\($delbw\)_fairness.xg ]
	then
		./add-on/breakline trace/tcp-tfwc_fifo\($delbw\)_fairness.xg
		./add-on/breakline trace/tcp_\($delbw\)_cov.xg
		./add-on/breakline trace/tfwc_\($delbw\)_cov.xg
	elif [ -f trace/tcp-tfwc_red\($delbw\)_fairness.xg ]
	then
		./add-on/breakline trace/tcp-tfwc_red\($delbw\)_fairness.xg
		./add-on/breakline trace/tcp_\($delbw\)_cov.xg
		./add-on/breakline trace/tfwc_\($delbw\)_cov.xg
	fi
	echo ""

	rm trace/tcp_cov.xg
	rm trace/tfwc_cov.xg
	
done 2> /dev/null ## done for TCP/TFWC

tfwc_stats
for i in .5 1.0 4.0
do
	plt/plotting.fairness.sh trace/tcp-tfwc\($i\)_fairness.xg trace/tcp-tfwc\($i\)_friendly_dominant.xg trace/tcp-tfwc\($i\)_tcp_dominant.xg
	cp graph/fairness.eps archives/tcp-tfwc_$toq\($i\)_fairness.eps 
done

fi ## end of SIM_TYPE
