#
# cwnd Dynamics
#
# $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/exercise/comp_02/tcp_cwnd.awk,v 1.3 2006/01/18 23:51:07 soohyunc Exp $

BEGIN {
	granul = 0.05;
	time = 0;
	printf "" > "./trace/tcp_cwnd_01.xg";
	printf "" > "./trace/tcp_cwnd_02.xg";
	printf "" > "./trace/tcp_cwnd_03.xg";
	printf "" > "./trace/tcp_cwnd_04.xg";

	print 0,0 >> "./trace/tcp_cwnd_01.xg";	
	print 0,0 >> "./trace/tcp_cwnd_02.xg";	
	print 0,0 >> "./trace/tcp_cwnd_03.xg";	
	print 0,0 >> "./trace/tcp_cwnd_04.xg";	

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

	#
	# CWND No.1
	#
	if (src_id[1] == $5 && $4 > 10) {
			print $4, $3 >> "./trace/tcp_cwnd_01.xg";
	} 

	#
	# CWND No.2
	#
	if (src_id[2] == $5 && $4 > 10) {
			print $4, $3 >> "./trace/tcp_cwnd_02.xg";
	}
 
	#
	# CWND No.3
	#
	if (src_id[3] == $5 && $4 > 10) {
			print $4, $3 >> "./trace/tcp_cwnd_03.xg";
	}
 
	#
	# CWND No.4
	#
	if (src_id[4] == $5 && $4 > 10) {
			print $4, $3 >> "./trace/tcp_cwnd_04.xg";
	} 
}

END {
}

