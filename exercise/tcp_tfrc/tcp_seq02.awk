#
# 
# Separate TCP Time Sequence Graphing
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# UCL Computer Science
# (May 05, 2004)
#

BEGIN {
	printf "" > "tcp_seq02.temp";
}


{
if ($5 == "tcp" && $9 == "1.1" && $10 == "3.1") {

	print >> "tcp_seq02.temp"; 

				  }
}


END {
}
