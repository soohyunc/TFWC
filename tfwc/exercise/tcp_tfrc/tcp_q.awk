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
       printf "" > "tcp_q.rands";
       print 0,0 >> "tcp_q.rands";
      }
                                                                                
{

#-------------------------------------------/
#
#This is aggregated TCP Q size
#
#-------------------------------------------/

if ($1 == "+") {
	if ($5 == "tcp")  count++;
	if (($2 - time) > granul) {
		time += granul;
		print time, count >> "tcp_q.rands";
	}
}

if ($1 == "-" || $1 == "d") {
	if ($5 == "tcp") count--; 
	if (($2 - time) > granul) {
		time += granul;
		print time, count >> "tcp_q.rands";
	}
}


}
END {
    }

