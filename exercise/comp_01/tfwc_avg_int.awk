#
# Avg Loss Interval Dynamics
#

BEGIN {
	granul = 0.05;
	time = 0;
	printf "" > "./trace/tfwc_avg_int_01.xg";
	printf "" > "./trace/tfwc_avg_int_02.xg";
	printf "" > "./trace/tfwc_avg_int_03.xg";
	printf "" > "./trace/tfwc_avg_int_04.xg";

	print 0,0 >> "./trace/tfwc_avg_int_01.xg";	
	print 0,0 >> "./trace/tfwc_avg_int_02.xg";	
	print 0,0 >> "./trace/tfwc_avg_int_03.xg";	
	print 0,0 >> "./trace/tfwc_avg_int_04.xg";	

	src_num = 4;
	for (i = 1; i <= src_num; i++)
		src_id[i] = 0;
}

{
	#
	# pre-condition
	#
	if (src_id[1] == 0 && src_id[2] == 0 && src_id[3] == 0 && src_id[4] == 0) {
		src_id[1] = $5;
	} else if (src_id[1] != $5 && (src_id[2] == 0 && src_id[3] == 0 && src_id[4] == 0)) {
		src_id[2] = $5;
	} else if ((src_id[1] != $5 && src_id[2] != $5) && (src_id[3] == 0 && src_id[4] == 0)) {
			src_id[3] = $5;
	} else if ((src_id[1] != $5 && src_id[2] != $5 && src_id[3] != $5) && src_id[4] == 0) {
		src_id[4] = $5;
	}

	#for (i = 1; i <= src_num; i++) {
	#	print src_id[i];
	#}
	#print "-----------";

	#
	# Avg Loss Interval No.1
	#
	if (src_id[1] == $5) {
			print $4, $3 >> "./trace/tfwc_avg_int_01.xg";
	} 

	#
	# Avg Loss Interval No.2
	#
	if (src_id[2] == $5) {
			print $4, $3 >> "./trace/tfwc_avg_int_02.xg";
	}
 
	#
	# Avg Loss Interval No.3
	#
	if (src_id[3] == $5) {
			print $4, $3 >> "./trace/tfwc_avg_int_03.xg";
	}
 
	#
	# Avg Loss Interval No.4
	#
	if (src_id[4] == $5) {
			print $4, $3 >> "./trace/tfwc_avg_int_04.xg";
	} 
}

END {
}

