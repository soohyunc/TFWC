# $Id$

FROM=$1
TO=$2

# throughput
gnuplot -persist << EOF
	set terminal postscript eps enhanced 
	set output "tfwc-thru.eps"

	set title "8 TFWC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Throughput (Mb/s)"

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
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

# measured loss rate 
gnuplot -persist << EOF
	set terminal postscript eps enhanced 
	set output "tfwc-loss.eps"

	set title "8 TFWC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Loss rate"

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
	set yrange [0:.2]

	plot "tfwc_loss_1.xg" with lines notitle, \
		"tfwc_loss_2.xg" with lines notitle, \
        "tfwc_loss_3.xg" with lines notitle, \
        "tfwc_loss_4.xg" with lines notitle, \
        "tfwc_loss_5.xg" with lines notitle, \
        "tfwc_loss_6.xg" with lines notitle, \
        "tfwc_loss_7.xg" with lines notitle, \
        "tfwc_loss_8.xg" with lines notitle
EOF

# loss rate seen by the equation
gnuplot -persist << EOF
    set terminal postscript eps enhanced 
    set output "tfwc-loss-by-eq.eps"

    set title "8 TFWC Flows"
    set xlabel "Simulation Time (sec)"
    set ylabel "Loss rate seen by Eq."

    set size 0.6,0.4
    set xrange [$FROM:$TO]
	set mxtics 5
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

# cwnd 
gnuplot -persist << EOF
	set terminal postscript eps enhanced 
	set output "tfwc-cwnd.eps"

	set title "8 TFWC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "cwnd (packet)"

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
	set yrange [0:35]

	plot "tfwc_cwnd_1.xg" with lines notitle, \
		"tfwc_cwnd_2.xg" with lines notitle, \
        "tfwc_cwnd_3.xg" with lines notitle, \
        "tfwc_cwnd_4.xg" with lines notitle, \
        "tfwc_cwnd_5.xg" with lines notitle, \
        "tfwc_cwnd_6.xg" with lines notitle, \
        "tfwc_cwnd_7.xg" with lines notitle, \
        "tfwc_cwnd_8.xg" with lines notitle
EOF

# average loss interval (tfrc/tfwc)
gnuplot -persist << EOF
	set terminal postscript eps enhanced 
	set output "tfwc-ali.eps"

	set title "8 TFWC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Ave. Loss Interval"

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
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


# measured queue length 
gnuplot -persist << EOF
	set terminal postscript eps enhanced 
	set output "tfwc-q.eps"

	set title "8 TFWC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Queue Size (packet)"

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
	set yrange [0:15]

	plot "tfwc_q_1.xg" with lines notitle, \
		"tfwc_q_2.xg" with lines notitle, \
        "tfwc_q_3.xg" with lines notitle, \
        "tfwc_q_4.xg" with lines notitle, \
        "tfwc_q_5.xg" with lines notitle, \
        "tfwc_q_6.xg" with lines notitle, \
        "tfwc_q_7.xg" with lines notitle, \
        "tfwc_q_8.xg" with lines notitle
EOF
