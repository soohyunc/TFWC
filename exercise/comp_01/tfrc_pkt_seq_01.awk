#
# 
# Separate TCP Time Sequence Graphing
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# UCL Computer Science
#

BEGIN {
	printf "" > "trace/tfrc_pkt_seq_01.temp";
}


{
if ($5 == "tcpFriend") {

	print >> "trace/tfrc_pkt_seq_01.temp"; 

				  }
}


END {
}
