#----------------------------------------------------/
# Loss Rate Calculation
# -- calculated by per packet based
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# Computer Science Department
# University College London
#----------------------------------------------------/


BEGIN {
	lines = sent = drop = 0;
	printf "" > "trace/tf_loss.xg";
	print 0,0 >> "trace/tf_loss.xg";
}


{
if (($1 == "+" || $1 == "d") && $5 == "TFWC") {
if (lines < 350) {

	if ( $1 == "+") {
		sent++;
	} 

	if ( $1 == "d") {
		drop++;
	}

	lines++;
}

else {
	rate = drop/sent;
	print $2, rate >> "trace/tf_loss.xg"; 
	
	lines = sent = drop = 0;
}
}
}



END {

}

