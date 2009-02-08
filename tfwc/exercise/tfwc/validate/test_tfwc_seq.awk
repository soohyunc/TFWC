BEGIN {
	printf "" > "./trace/test_tfwc_seq.temp";
}

{
	if ($5 == "TFWC"){
		print >> "./trace/test_tfwc_seq.temp";
	}
}

END {
}
