#!/bin/bash
# $Id$

# Initialise the simulation set up
# This will delete ALL graphs and trace files!

./rmtrace.sh
./rmgraph.sh
rm -f temp

for i in $( ls $PWD/temp.* ); do
	echo "deleting: $i"
	rm -f $i
done 2> /dev/null
