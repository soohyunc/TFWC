#
# 
# Separate TCP Time Sequence Graphing
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# UCL Computer Science
# (May 05, 2004)
#

BEGIN {
	printf "" > "tcp_seq03.temp";
}


{
if ($5 == "tcp" && $9 == "1.2" && $10 == "3.2") {

	print >> "tcp_seq03.temp"; 

				  }
}


END {
}
