#!/bin/sh
# $Id$

#####################################################################
#                                                                   #
#                 largescale ns-2 simulation script                 #
#                                                                   #
#####################################################################

if [ $# -lt 1 ];
then
    echo "  <<< Large-scale TFWC Batch Simulation >>>"
    echo "Usage: ./largescale.01.sh [a|b|c|d|e|f|g|h|i|j]"
    echo "  a: '1' for TCP/TFRC, and '2' for TCP/TFWC"
    echo "  b: access link speed"
    echo "  c: minimum access link delay"
    echo "  d: maximum access link delay"
    echo "  e: initial bottleneck link speed"
    echo "  f: bottleneck link delay"
    echo "  g: total simulation time"
    echo "  h: random seed number"
    echo "  i: is reverse TCP traffic (y/n)?"
    echo "  j: type of queue (DropTail/RED)"
    exit
fi
#####################################################################
#                         takes input                               #
#####################################################################
sim=$1		# simulation type (TCP/TFRC or TCP/TFWC)
accessbw=$2	# access link bw
amindel=$3	# access link min delay
amaxdel=$4	# access link max delay
bw=$5		# bottleneck link bw
del=$6		# bottleneck link delay
runtime=$7	# total simulation time
rnd=$8		# random seed number
reverse=$9	# is reverse TCP flows?
toq=${10}	# type of queue

rtt=`echo "scale=4; 0.001 * (2 * ($del + ($amindel + $amaxdel)/2))" | bc -l`
e2edel=`echo "scale=4; 0.001 * ($del + ($amindel + $amaxdel)/2)" | bc -l`

echo "" > trace/SIMENV
echo "\t\t" `date` >> trace/SIMENV
echo "" >> trace/SIMENV
echo "Simulation Type:           $sim" >> trace/SIMENV
echo "Access Link Speed:         $accessbw" >> trace/SIMENV
echo "Min Access Link Delay:     $amindel" >> trace/SIMENV
echo "Max Access Link Delay:     $amaxdel" >> trace/SIMENV
echo "Bottleneck Link Speed:     $bw" >> trace/SIMENV
echo "Bottleneck Link Delay:     $del" >> trace/SIMENV
echo "Total Simulation Time:     $runtime" >> trace/SIMENV
echo "Random Seed Number:        $rnd" >> trace/SIMENV
echo "is reverse TCP traffic?    $reverse" >> trace/SIMENV
echo "Queue Type:                $toq" >> trace/SIMENV
echo "approximate one-way delay: $e2edel" >> trace/SIMENV
echo "approximate average RTT:   $rtt" >> trace/SIMENV
echo "" >> trace/SIMENV

#####################################################################
#                       additional variables                        #
#####################################################################

a1=0.2
a2=2.0
a3=5.0

TOOLS="`dirname $PWD`/tools"
NICE=`which nice`
NS2=`which ns`
CAT=`which cat`
CP=`which cp`
RM=`which rm`
AWK=`which gawk`

# use BSD awk if GNU awk doesn't exist in the system
if [ -z "$AWK" ]
then
	AWK=`which awk`
fi

# appropriate queue string
if [ $toq = 'DropTail' ]
then
	queue=fifo
elif [ $toq = 'RED' ]
then
	queue=red
fi

#####################################################################
#                                                                   #
#                            TCP/TFRC                               #
#                                                                   #
#####################################################################
if [ "$sim" -eq "1" ]
then
for i in 1 2 4 8 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100
do
  tcp=$i
  tfrc=$i
  tfwc=0
  src=$tcp
  echo ""
  echo $i
  echo ""

  # queue size is set to .5 * BDP
  factor=`echo ".5" | bc -l`
  # initial bottleneck bw
  bw=$5

  for i in `seq 1 20`
  do
	if [ $i -le "5" ]
	then
	  if [ $i -eq "1" ]
	  then
		bw=$bw
	  elif [ $i -ge "2" ] && [ $i -le "4" ]
	  then
		bw=`echo $bw \* $a2 | bc -l`
	  else
		bw=`echo $bw + $a1 | bc -l`
	  fi
	elif [ $i -ge "5" ] && [ $i -le "10" ]
	then
	  if [ $i -eq "6" ]
	  then
		bw=`echo $bw \* $a2 | bc -l`
	  else
		bw=`echo $bw + $a2 | bc -l`
	  fi
	elif [ $i -gt "10" ]
	then
	  bw=`echo $bw + $a3 | bc -l`
	fi

	# bottleneck bw should be always less than the half of access bw
	ibw=`$TOOLS/round $bw`
	accessbw2=`echo "scale=4; $accessbw/2" | bc -l`
	iaccessbw=`$TOOLS/round $accessbw2`
	if [ "$ibw" -ge "$iaccessbw" ]
	then
	  bw=$accessbw2
	  pbw=$iaccessbw

	  # don't need to run same simulation, so quit
	  if [ "$iaccessbw" -eq "$pbw" ]
	  then
	    break
	  fi
	fi

	# calculate bottleneck queue size
	qsize=`echo "$factor * $rtt * $bw * 10^6 / 8000" | bc -l`
	qsize=`$TOOLS/round $qsize`

	# queue size is always greater than 5 packets
	if [ $qsize -lt "5" ]
	then
	  qsize=5
	fi

	echo -n "ns main.tcl $tcp $tfrc $tfwc $accessbw $amindel $amaxdel $bw $del $qsize $runtime $rnd $reverse $toq > temp 2>&1"
	echo ""
	#$NICE $NS2 main.tcl $tcp $tfrc $tfwc $accessbw $amindel $amaxdel $bw $del $qsize $runtime $rnd $reverse $toq > temp 2>&1

	# CoV computation
	$CAT trace/tcp_avg_cov.xg >> trace/tcp_cov.xg
	$CAT trace/tfrc_avg_cov.xg >> trace/tfrc_cov.xg

	# archive throughput and fairness
	$CP graph/aggr_fifo_thru.png archives/bw${bw}_${queue}_${qsize}_thru_tcp_${tcp}_tfrc_${tfrc}_tfwc_${tfwc}.png
	$TOOLS/fairness tcp-tfrc $toq $bw $src trace/tcp_thru_tot.dat trace/tfrc_thru_tot.dat
	$CAT trace/tcp-tfrc_${queue}_fairness.xg >> trace/tcp-tfrc_${queue}x${factor}_fairness.xg
	$RM trace/tcp-tfrc_${queue}_fairness.xg

  done # for i in `seq 1 20`

  $CAT trace/tcp_cov.xg >> trace/tcp_${factor}_cov.xg
  $CAT trace/tfrc_cov.xg >> trace/tfrc_${factor}_cov.xg

  # make a line break for 3D plot for each of these cases
  if [ -f trace/tcp-tfrc_${queue}x${factor}_fairness.xg ]
  then
	$TOOLS/breakline trace/tcp-tfrc_${queue}x${factor}_fairness.xg
	$TOOLS/breakline trace/tcp_${factor}_cov.xg
	$TOOLS/breakline trace/tfrc_${factor}_cov.xg
  fi

done

#####################################################################
#                                                                   #
#                            TCP/TFWC                               #
#                                                                   #
#####################################################################
elif [ "$sim" -eq "2" ]
then
for i in 1 2 4 8 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100
do
  tcp=$i
  tfrc=0
  tfwc=$i
  src=$tcp
  echo ""
  echo $i
  echo ""

  # queue size is set to .5 * BDP
  factor=`echo ".5" | bc -l`
  # initial bottleneck bw
  bw=$5

  for i in `seq 1 20`
  do
    if [ $i -le "5" ]
    then
      if [ $i -eq "1" ]
      then
        bw=$bw
      elif [ $i -ge "2" ] && [ $i -le "4" ]
      then
        bw=`echo $bw \* $a2 | bc -l`
      else
        bw=`echo $bw + $a1 | bc -l`
      fi
    elif [ $i -ge "5" ] && [ $i -le "10" ]
    then
      if [ $i -eq "6" ]
      then
        bw=`echo $bw \* $a2 | bc -l`
      else
        bw=`echo $bw + $a2 | bc -l`
      fi
    elif [ $i -gt "10" ]
    then
      bw=`echo $bw + $a3 | bc -l`
    fi

    # bottleneck bw should be always less than the half of access bw
    ibw=`$TOOLS/round $bw`
    accessbw2=`echo "scale=4; $accessbw/2" | bc -l`
    iaccessbw=`$TOOLS/round $accessbw2`
    if [ "$ibw" -ge "$iaccessbw" ]
    then
      bw=$accessbw2
      pbw=$iaccessbw

      # don't need to run same simulation, so quit
      if [ "$iaccessbw" -eq "$pbw" ]
      then
        break
      fi
    fi
    echo "bw: $bw"

    # calculate bottleneck queue size
    qsize=`echo "$factor * $rtt * $bw * 10^6 / 8000" | bc -l`
    qsize=`$TOOLS/round $qsize`

    # queue size is always greater than 5 packets
    if [ $qsize -lt "5" ]
    then
      qsize=5
    fi

    echo -n "ns main.tcl $tcp $tfrc $tfwc $accessbw $amindel $amaxdel $bw $del $qsize $runtime $rnd $reverse $toq > temp 2>&1"
  done
  echo ""
done
fi
