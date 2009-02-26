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
       count = time = 0;
       printf "" > "tf_q.rands";
       print 0,0 >> "tf_q.rands";
      }
                                                                                
{

#-------------------------------------------/
#
#This is aggregated TFRC Q size
#
#-------------------------------------------/

if ($1 == "+") {
	if ($5 == "tcpFriend") count++;
	if (($2 - time) > granul) {
	        time += granul;
		print time, count >> "tf_q.rands";
	}
}

if ($1 == "-" || $1 == "d") {
	if ($5 == "tcpFriend") count--;
	if (($2 - time) > granul) {
        	time += granul;
		print time, count >> "tf_q.rands";
        }
}

}

END {
    }
