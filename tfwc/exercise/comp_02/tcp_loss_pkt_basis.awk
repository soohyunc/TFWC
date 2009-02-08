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
	printf "" > "trace/tcp_loss.xg";
	print 0,0 >> "trace/tcp_loss.xg";
}


{
	if (($1 == "+" || $1 == "d") && $5 == "tcp") {
		if (lines < 400) {

			if ( $1 == "+")
				sent++;

			if ( $1 == "d")
				drop++;

			lines++;
		}

		else {
			rate = drop/sent;
			print $2, rate >> "trace/tcp_loss.xg"; 
	
			lines = sent = drop = 0;
		}
	}
}



END {

}

