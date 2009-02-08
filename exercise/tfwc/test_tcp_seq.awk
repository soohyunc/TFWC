BEGIN {
	printf "" > "test_tcp_seq.temp";
}

{
	if ($5 == "tcp" && $9 == "1.0" && $10 == "3.0"){
		print >> "test_tcp_seq.temp";
	}
}

END {
}
