# $Id$

# delete all trace files
for i in $( ls $PWD/archives/ ); do
	echo "deleting: $i"
	rm -f $PWD/archives/$i
done
