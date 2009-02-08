# $Id$

FROM=$1
TO=$2

# throughput
gnuplot -persist << EOF
	set terminal x11 

	set title "8 TFWC Throughput per Flow"
	set xlabel "Simulation Time (sec)"
	set ylabel "Throughput (Mb/s)"

	set xrange [$FROM:$TO]
	set yrange [0:1.4]

	plot "tfwc_thru_1.xg" with lines notitle, \
		"tfwc_thru_2.xg" with lines notitle, \
        "tfwc_thru_3.xg" with lines notitle, \
        "tfwc_thru_4.xg" with lines notitle, \
        "tfwc_thru_5.xg" with lines notitle, \
        "tfwc_thru_6.xg" with lines notitle, \
        "tfwc_thru_7.xg" with lines notitle, \
        "tfwc_thru_8.xg" with lines notitle
EOF

# loss rate seen by the equation
gnuplot -persist << EOF
    set terminal x11 

    set title "8 TFWC Loss Rate seen by TCP Eq. per Flow"
    set xlabel "Simulation Time (sec)"
    set ylabel "Loss rate seen by Eq."

    set xrange [$FROM:$TO]
    set yrange [0:.05]

    set pointsize .6
    plot "tfwc_loss_by_cal_1.xg" with lines notitle, \
        "tfwc_loss_by_cal_2.xg" with lines notitle, \
        "tfwc_loss_by_cal_3.xg" with lines notitle, \
        "tfwc_loss_by_cal_4.xg" with lines notitle, \
        "tfwc_loss_by_cal_5.xg" with lines notitle, \
        "tfwc_loss_by_cal_6.xg" with lines notitle, \
        "tfwc_loss_by_cal_7.xg" with lines notitle, \
        "tfwc_loss_by_cal_8.xg" with lines notitle
EOF

# average loss interval (tfrc/tfwc)
gnuplot -persist << EOF
	set terminal x11 

	set title "8 TFWC ALI per Flow"
	set xlabel "Simulation Time (sec)"
	set ylabel "Ave. Loss Interval"

	set xrange [$FROM:$TO]
	set yrange [0:350]

	plot "tfwc_avg_int_1.xg" with lines notitle, \
		"tfwc_avg_int_2.xg" with lines notitle, \
        "tfwc_avg_int_3.xg" with lines notitle, \
        "tfwc_avg_int_4.xg" with lines notitle, \
        "tfwc_avg_int_5.xg" with lines notitle, \
        "tfwc_avg_int_6.xg" with lines notitle, \
        "tfwc_avg_int_7.xg" with lines notitle, \
        "tfwc_avg_int_8.xg" with lines notitle
EOF

# cwnd 
gnuplot -persist << EOF
	set terminal x11 

    set title "8 TFWC Flows"
    set xlabel "Simulation Time (sec)"
    set ylabel "cwnd (packet)"

    set xrange [$FROM:$TO]
	set yrange [0:]

    plot "tfwc_cwnd_1.xg" with lines notitle, \
        "tfwc_cwnd_2.xg" with lines notitle, \
        "tfwc_cwnd_3.xg" with lines notitle, \
        "tfwc_cwnd_4.xg" with lines notitle, \
        "tfwc_cwnd_5.xg" with lines notitle, \
        "tfwc_cwnd_6.xg" with lines notitle, \
        "tfwc_cwnd_7.xg" with lines notitle, \
        "tfwc_cwnd_8.xg" with lines notitle
EOF

