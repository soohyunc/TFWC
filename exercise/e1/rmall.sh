#!/bin/sh
# $Id$

# Initialise the simulation set up
# This will delete ALL graphs and trace files!

$PWD/rmtrace.sh
$PWD/rmgraph.sh

# delete sim trace
if [ -s temp ]
then
	echo "rm -f temp" 
	rm -f temp
fi

# del sim parameters
if [ -s $PWD/trace/THIS ]
then
	echo "rm -f $PWD/trace/THIS"
	rm -f $PWD/trace/THIS
fi

# del all
for i in $( ls $PWD/temp.* ); do
	echo "deleting: $i"
	rm -f $i
done 2> /dev/null
