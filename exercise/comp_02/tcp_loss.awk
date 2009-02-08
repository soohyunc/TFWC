#
# Loss Rate Calculation
#
# Soo-Hyun Choi (S.Choi@cs.ucl.ac.uk)
# Computer Science Department
# University College London
# (Oct. 12, 2005)
#

BEGIN {
	granul		= 1.0;
	time		= 0;
	last_bits	= 0;
	last_lbits	= 0;
	loss		= 0;
	printf "" > "trace/tcp_loss.xg";
}

{
	if (($1 == "d" || $1 == "r") && $5 == "tcp") {

		bits = bits + $6*8;
		
		if ($1 == "d") {
			lbits = lbits + $6*8;
		}

		if (($2 - time) > granul) {
			time = time + granul;

			thru = ((bits - last_bits)/1000000)/granul;
			loss = ((lbits - last_lbits)/1000000)/granul;

			rate = loss/thru;
			print time, rate >> "trace/tcp_loss.xg";

			last_bits	= bits;
			last_lbits	= lbits;
		}

		while (($2 - time) > 2*granul) {
			bits		= 0;
			lbits		= 0;
			last_bits	= 0;
			last_lbits	= 0;
			time		= time + granul;	
		}
	}
}

END {
}
