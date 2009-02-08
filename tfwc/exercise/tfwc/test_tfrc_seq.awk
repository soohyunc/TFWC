BEGIN {
	printf "" > "test_tfrc_seq.temp";
}

{
	if ($5 == "tcpFriend" && $9 == "1.1" && $10 == "3.1"){
		print >> "test_tfrc_seq.temp";
	}
}

END {
}
