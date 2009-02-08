#-------------------------------------------/
# Instaneous Queue Size Calculation
#-------------------------------------------/
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# Computer Science Department
# University College London
# (May 11, 2004)
#
#-------------------------------------------/
                                                                                
                                                                                
BEGIN {
       granul = 2.0;
       count = tcp_count = tf_count = time = 0;
       printf "" > "q_size.rands";
       printf "" > "tcp_q.rands";
       printf "" > "tf_q.rands";
       print 0,0 >> "q_size.rands";
       print 0,0 >> "tcp_q.rands";
       print 0,0 >> "tf_q.rands";
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
		print time , count >> "q_size.rands";
		print time , tcp_count >> "tcp_q.rands";
		print time , tf_count >> "tf_q.rands";
	}
}

if ($1 == "-" || $1 == "d") {
	count--;

	if ($5 == "tcp") tcp_count--;
	if ($5 == "tcpFriend") tf_count--;
	if (($2 - time) > granul) {
	        time += granul;
		print time , count >> "q_size.rands";
		print time , tcp_count >> "tcp_q.rands";
		print time , tf_count >> "tf_q.rands";
	}

}

}

END {
    }

