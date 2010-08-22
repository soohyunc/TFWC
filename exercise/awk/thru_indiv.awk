# $Id$

BEGIN{
	time        = 0;
	last_bits   = 0;
	thru        = 0;
	option		= ARGV[1];
	ix			= ARGV[2];
	granul      = ARGV[3];
	cutoff      = ARGV[4];
    until       = ARGV[5];
}

{
	if ($1 == "r") {
		bits += $3 * 8;

		if (($2 - time) > granul) {
		# bits/sec
		time += granul;
		thru = (bits-last_bits)/granul;
		# convert to Mb/s
		thru /= 1000000;

		if ($2 > cutoff && $2 < until)
		print time,thru >> "trace/"option"_thru_"ix".xg";

		last_bits = bits;
		}

		while (($2 - time) > 2 * granul) {

		if ($2 > cutoff && $2 < until)
		print time,0 >> "trace/"option"_thru_"ix".xg";

		bits = 0;
		last_bits = 0;
		time += granul;
		} # end of while
	} #end of if ($1 == "r")
}

END{}
