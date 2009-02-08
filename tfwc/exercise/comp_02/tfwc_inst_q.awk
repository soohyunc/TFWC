#-------------------------------------------/
# Instaneous Queue Size Calculation
#-------------------------------------------/
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# Computer Science Department
# University College London
#-------------------------------------------/
                                                                                
                                                                                
BEGIN {
       count = tcp_count = tf_count = time = 0;
       printf "" > "trace/q_size.xg";
       printf "" > "trace/tcp_q.xg";
       printf "" > "trace/tfwc_q.xg";
       print 0,0 >> "trace/q_size.xg";
       print 0,0 >> "trace/tcp_q.xg";
       print 0,0 >> "trace/tfwc_q.xg";
}
                                                                                
{

#-------------------------------------------/
#
#This is aggregated and combined TCP/TFRC Q size
#
#-------------------------------------------/

if ($1 == "+" && $5 == "TFWC") {
	tf_count++;
	print $2 , tf_count >> "trace/tfwc_q.xg";
}

if (($1 == "-" || $1 == "d") && $5 == "TFWC") {
	tf_count--;
	print $2 , tf_count >> "trace/tfwc_q.xg";
}

}

END {
}

