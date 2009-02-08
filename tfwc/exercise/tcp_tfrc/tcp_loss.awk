#----------------------------------------------------/
# Loss Rate Calculation
# -- calculated by per packet based
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# Computer Science Department
# University College London
# (May 27, 2004)
#----------------------------------------------------/


BEGIN {
	lines = sent = drop = 0;
	printf "" > "tcp_loss.rands";
	print 0,0 >> "tcp_loss.rands";
}


{
if (($1 == "+" || $1 == "d") && $5 == "tcp") {
if (lines < 80) {

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
	print $2, rate >> "tcp_loss.rands"; 
	
	lines = sent = drop = 0;
}
}
}



END {

}

