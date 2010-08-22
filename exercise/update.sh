#!/bin/sh
# $Id$

for i in $(find $PWD -type d | grep -v .svn | grep -v graph | grep -v archives |
    grep -v docs | grep -v trace | grep -v plt | grep -v awk  | grep -v tools);
do 
    cd $i 
    svn update 
	cd `dirname $PWD`
done


