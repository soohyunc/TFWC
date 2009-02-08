# $Id$

FROM=$1
TO=$2

# throughput
gnuplot -persist << EOF
	set terminal x11

	set title "8 TFRC Throughput per Flow"
	set xlabel "Simulation Time (sec)"
	set ylabel "Throughput (Mb/s)"

	set xrange [$FROM:$TO]
	set yrange [0:1.4]

	plot "tfrc_thru_1.xg" with lines notitle, \
		"tfrc_thru_2.xg" with lines notitle, \
        "tfrc_thru_3.xg" with lines notitle, \
        "tfrc_thru_4.xg" with lines notitle, \
        "tfrc_thru_5.xg" with lines notitle, \
        "tfrc_thru_6.xg" with lines notitle, \
        "tfrc_thru_7.xg" with lines notitle, \
        "tfrc_thru_8.xg" with lines notitle
EOF

# loss rate seen by the equation
gnuplot -persist << EOF
	set terminal x11

	set title "8 TFRC Loss Rate seen by TCP Eq. per Flow"
	set xlabel "Simulation Time (sec)"
	set ylabel "Loss rate seen by Eq."

	set xrange [$FROM:$TO]
	set yrange [0:.05]

	set pointsize .6
	plot "tfrc_loss_by_eq_1.xg" with lines notitle, \
		"tfrc_loss_by_eq_2.xg" with lines notitle, \
        "tfrc_loss_by_eq_3.xg" with lines notitle, \
        "tfrc_loss_by_eq_4.xg" with lines notitle, \
        "tfrc_loss_by_eq_5.xg" with lines notitle, \
        "tfrc_loss_by_eq_6.xg" with lines notitle, \
        "tfrc_loss_by_eq_7.xg" with lines notitle, \
        "tfrc_loss_by_eq_8.xg" with lines notitle
EOF

# average loss interval
gnuplot -persist << EOF
	set terminal x11

	set title "8 TFRC ALI per Flow"
	set xlabel "Simulation Time (sec)"
	set ylabel "Ave. Loss Interval"

	set xrange [$FROM:$TO]
	set yrange [0:300]

	plot "tfrc_avg_int_1.xg" with lines notitle, \
		"tfrc_avg_int_2.xg" with lines notitle, \
        "tfrc_avg_int_3.xg" with lines notitle, \
        "tfrc_avg_int_4.xg" with lines notitle, \
        "tfrc_avg_int_5.xg" with lines notitle, \
        "tfrc_avg_int_6.xg" with lines notitle, \
        "tfrc_avg_int_7.xg" with lines notitle, \
        "tfrc_avg_int_8.xg" with lines notitle
EOF
