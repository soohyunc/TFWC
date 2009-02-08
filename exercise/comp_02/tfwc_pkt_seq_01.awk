#
# 
# Separate TCP Time Sequence Graphing
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# UCL Computer Science
# (May 05, 2004)
#

BEGIN {
	printf "" > "trace/tfwc_pkt_seq_01.temp";
}


{
if ($5 == "TFWC") {

	print >> "trace/tfwc_pkt_seq_01.temp"; 

				  }
}


END {
}
