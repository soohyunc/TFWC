# $Id$

BEGIN {
    time    = 0;
    option  = ARGV[1];
    granul  = ARGV[2];
    cutoff  = ARGV[3];
    until   = ARGV[4];
}

{
    if ($1 == "a") {
		if (($2 - time) > granul) {
		time += granul;

		if (($2 > cutoff) && ($2 < until))
		print time, $3 >> "trace/"option"_red_avg.xg";
		}
	}

	if ($1 == "Q") {
		if (($2 - time) > granul) {
		time += granul;

		if (($2 > cutoff) && ($2 < until))
		print time, $3 >> "trace/"option"_red_inst.xg";
		}
	}
}
END {
}
