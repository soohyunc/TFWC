BEGIN {
       printf "" > "tfwc_cwnd.rands";
}
                                                                                
{
	print $4, $3 >> "tfwc_cwnd.rands";

}

END {
    }

