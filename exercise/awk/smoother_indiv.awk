# $Id$

BEGIN{
	time        = 0;
	ratio		= 0;
	option		= ARGV[1];
	ix			= ARGV[2];
	granul      = 2 * ARGV[3];
	cutoff      = ARGV[4];
    until       = ARGV[5];
}

{
	if (($1 - time) > granul) {
		time += granul;

		if (($1 > cutoff) && ($1 < until))
		print time,$2 >> "trace/"option"_sr_"ix".xg";
	}

	while (($1 - time) > 2 * granul) {

		if (($1 > cutoff) && ($1 < until))
		print time,0 >> "trace/"option"_sr_"ix".xg";
		time += granul;
	} # end of while
}

END{}
