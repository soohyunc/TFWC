BEGIN {
       printf "" > "./trace/tfwc_cwnd.xg";
}
                                                                                
{
	print $4, $3 >> "./trace/tfwc_cwnd.xg";

}

END {
    }

