BEGIN {
	printf "" > "test_tfwc_seq.temp";
}

{
	if ($5 == "TFWC"){
		print >> "test_tfwc_seq.temp";
	}
}

END {
}
