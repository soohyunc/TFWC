#
# Pattern findingg and Throughput calculation
# (Find an outgoing packet from the queue at a bottleneck node)
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# Computer Science Department
# University College London
# (Apr. 28, 2004)
#
                                                                                
                                                                                
BEGIN {
       granul = 0.5;
       bits = 0;
       last_bits = 0;
       printf "" > "tf_thru.rands";
       time = 0;
      }
                                                                                
{
	if ($1 == "r" && $5 == "tcpFriend") {
                bits = bits + $6*8;
                                                                                
        	if (($2 - time) > granul) {
                        time = time + granul;
                        rate = ((bits-last_bits)/1000000)/granul;
                        print time, rate >> "tf_thru.rands";
                                                                                
                        last_bits = bits;
		}
                                                                                
		while (($2 - time) > 2* granul) {
                	print time, 0 >> "tf_thru.rands";
	                bits = 0;
        	        last_bits = 0;
	                time = time + granul;
		}
	}
}
                                                                                
END {
}

