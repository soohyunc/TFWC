#
# Loss Rate Calculation
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
       last_lbits=0;
       loss = 0;
       printf "" > "tcp01_loss.rands";
}

{
if (($1 == "d" || $1 == "r") && $5 == "tcp" && $9 == "1.0" && $10 == "3.0") {
	bits = bits + $6*8;
	if ($1 =="d") {
		lbits=lbits + $6*8;
	}
	
	if (($2-time) > granul) {
		time = time + granul;

		thru = ((bits-last_bits)/1000000)/granul;
		loss = ((lbits-last_lbits)/1000000)/granul;

		rate = loss/thru;
		print time, rate >> "tcp01_loss.rands";

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

