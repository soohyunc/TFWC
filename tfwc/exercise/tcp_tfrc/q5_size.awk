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
       count = 0;
       printf "" > "q_size.rands";
       time = 0;
      }
                                                                                
{

if ($1 == "+") {
	count = count + 1;

        if (count > 5) {
                count = 5;
        }

	if (($2 - time) > granul) {
	        time = time + granul;
		print time, count >> "q_size.rands";
	}
}

if ($1 == "-") {
        count = count - 1;

        if (count > 5) {
                count = 5;
        }
                                                                                       
       if (($2 - time) > granul) {
        	time = time + granul;
                print time, count >> "q_size.rands";
        }
}

}

END {
    }

