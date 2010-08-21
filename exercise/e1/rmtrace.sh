#!/bin/sh
# $Id$

# delete all trace files
for i in $( ls $PWD/trace/*.xg ); do
	echo "deleting: $i"
	rm -f $i
done 2> /dev/null

for i in $( ls $PWD/trace/*.tr ); do
	echo "deleting: $i"
	rm -f $i
done 2> /dev/null

for i in $( ls $PWD/trace/*.queue ); do
	echo "deleting: $i"
	rm -f $i
done 2> /dev/null

for i in $( ls $PWD/trace/*.dat ); do
	echo "deleting: $i"
	rm -f $i
done 2> /dev/null

for i in $( ls $PWD/trace/*.eps ); do
	echo "deleting: $i"
	rm -f $i
done 2> /dev/null

delenv=$PWD/trace/SIMENV
if [ -s $delenv ];
then
echo "deleting: $delenv"
rm -f $delenv
fi
