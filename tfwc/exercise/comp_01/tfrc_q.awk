#-------------------------------------------/
# Instaneous Queue Size Calculation
#-------------------------------------------/
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# Computer Science Department
# University College London
#-------------------------------------------/
                                                                                
                                                                                
BEGIN {
       granul = 2.0;
       count = tcp_count = tf_count = time = 0;
       printf "" > "trace/q_size.xg";
       printf "" > "trace/tcp_q.xg";
       printf "" > "trace/tfrc_q.xg";
       print 0,0 >> "trace/q_size.xg";
       print 0,0 >> "trace/tcp_q.xg";
       print 0,0 >> "trace/tfrc_q.xg";
      }
                                                                                
{

#-------------------------------------------/
#
#This is aggregated and combined TCP/TFRC Q size
#
#-------------------------------------------/

if ($1 == "+") {
	count++;

	if ($5 == "tcp") tcp_count++;
	if ($5 == "tcpFriend") tf_count++;
	if (($2 - time) > granul) {
	        time += granul;
		print time , count >> "trace/q_size.xg";
		print time , tcp_count >> "trace/tcp_q.xg";
		print time , tf_count >> "trace/tfrc_q.xg";
	}
}

if ($1 == "-" || $1 == "d") {
	count--;

	if ($5 == "tcp") tcp_count--;
	if ($5 == "tcpFriend") tf_count--;
	if (($2 - time) > granul) {
	        time += granul;
		print time , count >> "trace/q_size.xg";
		print time , tcp_count >> "trace/tcp_q.xg";
		print time , tf_count >> "trace/tfrc_q.xg";
	}

}

}

END {
    }

