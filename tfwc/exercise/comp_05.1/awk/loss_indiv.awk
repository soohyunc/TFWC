# $Id $

BEGIN{
	time        = 0;
	last_bits   = 0;
	last_lbits  = 0;
	thru        = 0;
	option		= ARGV[1];
	ix			= ARGV[2];
	granul      = ARGV[3];
	cutoff      = ARGV[4];
}

{
	if ($1 == "d" || $1 == "r") {
		bits += $3 * 8;

		if ($1 == "d") {
			lbits = lbits + $3 * 8;
		}

		if (($2 - time) > granul) {
			time += granul;

			thru = ((bits-last_bits)/1000000)/granul;
			loss = ((lbits - last_lbits)/1000000)/granul;

			rate = loss/thru;

			if ($2 > cutoff)
				print time, rate >> "trace/"option"_loss_"ix".xg";

			last_bits = bits;
			last_lbits = lbits;
		}

		while (($2 - time) > 2 * granul) {
			bits = 0;
			lbits = 0;
			last_bits = 0;
			last_lbits = 0;
			time += granul;
		} # end of while
	} #end of if ($1 == "r")

}

END{}
