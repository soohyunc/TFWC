#
# 
# Separate TCP Time Sequence Graphing
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# UCL Computer Science
# (May 05, 2004)
#

BEGIN {
	printf "" > "tcp_seq04.temp";
}


{
if ($5 == "tcp" && $9 == "1.3" && $10 == "3.3") {

	print >> "tcp_seq04.temp"; 

				  }
}


END {
}
