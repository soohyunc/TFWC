#
# 
# Separate TCP Time Sequence Graphing
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# UCL Computer Science
# (May 05, 2004)
#

BEGIN {
	printf "" > "tf_seq01.temp";
}


{
if ($5 == "tcpFriend" && $9 == "1.4" && $10 == "3.4") {

	print >> "tf_seq01.temp"; 

				  }
}


END {
}
