#!/bin/sh
# $Id$

# delete all graphs
for i in $( ls $PWD/graph/ ); do
	echo "deleting: $i"
	rm -f $PWD/graph/$i
done
