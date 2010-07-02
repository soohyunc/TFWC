#!/bin/sh
# $Id$

# del sim environment
if [ -s $PWD/trace/SIMENV ]
then
	echo "rm -f $PWD/trace/SIMENV"
	rm -f $PWD/trace/SIMENV
fi

# delete all trace files
for i in $( ls $PWD/archives/ ); do
    echo "deleting: $i"
    rm -f $PWD/archives/$i
done

