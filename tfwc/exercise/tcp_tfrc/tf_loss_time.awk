#
# Loss Rate Calculation
# -- calculated by average time windonw scheme
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# Computer Science Department
# University College London
# (May 06, 2004)
#

BEGIN {
       granul = 2.0;
       time = 0;
       last_bits = 0;
       last_lbits = 0;
       loss = 0;
       printf "" > "tf_loss.rands";
}

{
if (($1 == "d" || $1 == "+") && $5 == "tcpFriend") {
	bits = bits + $6*8;
	if ($1 == "d") {
	lbits = lbits + $6*8;
	}

	if (($2-time) > granul) {
		time = time + granul;

		thru = ((bits-last_bits)/1000000)/granul;
		loss = ((lbits-last_lbits)/1000000)/granul;
		
		rate = loss/thru;
		print time, rate >> "tf_loss.rands";
		
		last_bits = bits;
		last_lbits = lbits;
	}

	while (($2-time) > 2*granul) {
		bits = 0;
		lbits = 0;
		last_bits = 0;
		last_lbits = 0;
		time = time + granul;
	}
}
}

END {
}

