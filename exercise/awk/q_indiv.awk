# $Id$

BEGIN {
	time	= 0;
	count	= 0;
	option	= ARGV[1];
	ix		= ARGV[2];
	granul	= ARGV[3];
	cutoff	= ARGV[4];
	until	= ARGV[5];
}

{
	if ($1 == "+") {
		count++;
		if (($2 - time) > granul) {
		time += granul;

		if (($2 > cutoff) && ($2 < until))
		print time , count >> "trace/"option"_q_"ix".xg";
		}
	} 
	
	if ($1 == "-" || $1 == "d") {
		count--;
		if (($2 - time) > granul) {
		time += granul;

		if (($2 > cutoff) && ($2 < until))
		print time , count >> "trace/"option"_q_"ix".xg";
		}
	}
}

END {}
