BEGIN {
       printf "" > "tcp_cwnd.xg";
}
                                                                                
{
	print $2, $4 >> "tcp_cwnd.xg";

}

END {
    }

