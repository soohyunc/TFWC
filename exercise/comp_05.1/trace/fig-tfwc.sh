# $Id$

FROM=$1
TO=$2

# throughput
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tfwc-thru.eps"

	set title "8 TFWC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Throughput (Mb/s)"

    set style line 1 lt 1 pt 2 lw 1.5
    set style line 2 lt 2 pt 3 lw 1.5
    set style line 3 lt 3 pt 4 lw 1.5
    set style line 4 lt 4 pt 5 lw 1.5
    set style line 5 lt 5 pt 6 lw 1.5
    set style line 6 lt 6 pt 8 lw 1.5
    set style line 7 lt 7 pt 9 lw 1.5
    set style line 8 lt 8 pt 10 lw 1.5

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
	set yrange [0:1.4]

	plot "tfwc_thru_1.xg" with lines notitle linestyle 1, \
		"tfwc_thru_2.xg" with lines notitle linestyle 2, \
        "tfwc_thru_3.xg" with lines notitle linestyle 3, \
        "tfwc_thru_4.xg" with lines notitle linestyle 4, \
        "tfwc_thru_5.xg" with lines notitle linestyle 5, \
        "tfwc_thru_6.xg" with lines notitle linestyle 6, \
        "tfwc_thru_7.xg" with lines notitle linestyle 7, \
        "tfwc_thru_8.xg" with lines notitle linestyle 8
EOF

# measured loss rate 
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tfwc-loss.eps"

	set title "8 TFWC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Loss rate"

    set style line 1 lt 1 pt 2 lw 1.5
    set style line 2 lt 2 pt 3 lw 1.5
    set style line 3 lt 3 pt 4 lw 1.5
    set style line 4 lt 4 pt 5 lw 1.5
    set style line 5 lt 5 pt 6 lw 1.5
    set style line 6 lt 6 pt 8 lw 1.5
    set style line 7 lt 7 pt 9 lw 1.5
    set style line 8 lt 8 pt 10 lw 1.5

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
	set yrange [0:.2]

	plot "tfwc_loss_1.xg" with lines notitle linestyle 1, \
		"tfwc_loss_2.xg" with lines notitle linestyle 2, \
        "tfwc_loss_3.xg" with lines notitle linestyle 3, \
        "tfwc_loss_4.xg" with lines notitle linestyle 4, \
        "tfwc_loss_5.xg" with lines notitle linestyle 5, \
        "tfwc_loss_6.xg" with lines notitle linestyle 6, \
        "tfwc_loss_7.xg" with lines notitle linestyle 7, \
        "tfwc_loss_8.xg" with lines notitle linestyle 8
EOF

# loss rate seen by the equation
gnuplot -persist << EOF
    set terminal postscript eps enhanced color
    set output "tfwc-loss-by-eq.eps"

    set title "8 TFWC Flows"
    set xlabel "Simulation Time (sec)"
    set ylabel "Loss rate seen by Eq."

    set style line 1 lt 1 pt 2 lw 1.5
    set style line 2 lt 2 pt 3 lw 1.5
    set style line 3 lt 3 pt 4 lw 1.5
    set style line 4 lt 4 pt 5 lw 1.5
    set style line 5 lt 5 pt 6 lw 1.5
    set style line 6 lt 6 pt 8 lw 1.5
    set style line 7 lt 7 pt 9 lw 1.5
    set style line 8 lt 8 pt 10 lw 1.5

    set size 0.6,0.4
    set xrange [$FROM:$TO]
	set mxtics 5
    set yrange [0:.05]

    set pointsize .6
    plot "tfwc_loss_by_cal_1.xg" with lines notitle linestyle 1, \
        "tfwc_loss_by_cal_2.xg" with lines notitle linestyle 2, \
        "tfwc_loss_by_cal_3.xg" with lines notitle linestyle 3, \
        "tfwc_loss_by_cal_4.xg" with lines notitle linestyle 4, \
        "tfwc_loss_by_cal_5.xg" with lines notitle linestyle 5, \
        "tfwc_loss_by_cal_6.xg" with lines notitle linestyle 6, \
        "tfwc_loss_by_cal_7.xg" with lines notitle linestyle 7, \
        "tfwc_loss_by_cal_8.xg" with lines notitle linestyle 8
EOF

# cwnd 
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tfwc-cwnd.eps"

	set title "8 TFWC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "cwnd (packet)"

    set style line 1 lt 1 pt 2 lw 1.5
    set style line 2 lt 2 pt 3 lw 1.5
    set style line 3 lt 3 pt 4 lw 1.5
    set style line 4 lt 4 pt 5 lw 1.5
    set style line 5 lt 5 pt 6 lw 1.5
    set style line 6 lt 6 pt 8 lw 1.5
    set style line 7 lt 7 pt 9 lw 1.5
    set style line 8 lt 8 pt 10 lw 1.5

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
	set yrange [0:35]

	plot "tfwc_cwnd_1.xg" with lines notitle linestyle 1, \
		"tfwc_cwnd_2.xg" with lines notitle linestyle 2, \
        "tfwc_cwnd_3.xg" with lines notitle linestyle 3, \
        "tfwc_cwnd_4.xg" with lines notitle linestyle 4, \
        "tfwc_cwnd_5.xg" with lines notitle linestyle 5, \
        "tfwc_cwnd_6.xg" with lines notitle linestyle 6, \
        "tfwc_cwnd_7.xg" with lines notitle linestyle 7, \
        "tfwc_cwnd_8.xg" with lines notitle linestyle 8, \
		"tfwc_to_1.xg" with points notitle linestyle 1, \
		"tfwc_to_2.xg" with points notitle linestyle 2, \
		"tfwc_to_3.xg" with points notitle linestyle 3, \
		"tfwc_to_4.xg" with points notitle linestyle 4, \
		"tfwc_to_5.xg" with points notitle linestyle 5, \
		"tfwc_to_6.xg" with points notitle linestyle 6, \
		"tfwc_to_7.xg" with points notitle linestyle 7, \
		"tfwc_to_8.xg" with points notitle linestyle 8
EOF

# average loss interval (tfrc/tfwc)
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tfwc-ali.eps"

	set title "8 TFWC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Ave. Loss Interval"

    set style line 1 lt 1 pt 2 lw 1.5
    set style line 2 lt 2 pt 3 lw 1.5
    set style line 3 lt 3 pt 4 lw 1.5
    set style line 4 lt 4 pt 5 lw 1.5
    set style line 5 lt 5 pt 6 lw 1.5
    set style line 6 lt 6 pt 8 lw 1.5
    set style line 7 lt 7 pt 9 lw 1.5
    set style line 8 lt 8 pt 10 lw 1.5

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
	set yrange [0:350]

	plot "tfwc_avg_int_1.xg" with lines notitle linestyle 1, \
		"tfwc_avg_int_2.xg" with lines notitle linestyle 2, \
        "tfwc_avg_int_3.xg" with lines notitle linestyle 3, \
        "tfwc_avg_int_4.xg" with lines notitle linestyle 4, \
        "tfwc_avg_int_5.xg" with lines notitle linestyle 5, \
        "tfwc_avg_int_6.xg" with lines notitle linestyle 6, \
        "tfwc_avg_int_7.xg" with lines notitle linestyle 7, \
        "tfwc_avg_int_8.xg" with lines notitle linestyle 8
EOF


# measured queue length 
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tfwc-q.eps"

	set title "8 TFWC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Queue Size (packet)"

    set style line 1 lt 1 pt 2 lw 1.5
    set style line 2 lt 2 pt 3 lw 1.5
    set style line 3 lt 3 pt 4 lw 1.5
    set style line 4 lt 4 pt 5 lw 1.5
    set style line 5 lt 5 pt 6 lw 1.5
    set style line 6 lt 6 pt 8 lw 1.5
    set style line 7 lt 7 pt 9 lw 1.5
    set style line 8 lt 8 pt 10 lw 1.5

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
	set yrange [0:15]

	plot "tfwc_q_1.xg" with lines notitle linestyle 1, \
		"tfwc_q_2.xg" with lines notitle linestyle 2, \
        "tfwc_q_3.xg" with lines notitle linestyle 3, \
        "tfwc_q_4.xg" with lines notitle linestyle 4, \
        "tfwc_q_5.xg" with lines notitle linestyle 5, \
        "tfwc_q_6.xg" with lines notitle linestyle 6, \
        "tfwc_q_7.xg" with lines notitle linestyle 7, \
        "tfwc_q_8.xg" with lines notitle linestyle 8
EOF

# smoothing ratio
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tfwc-sr.eps"

	set title "8 TFWC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Smoothing Ratio (num_infl/num_total)"

    set style line 1 lt 1 pt 2 lw 1.5
    set style line 2 lt 2 pt 3 lw 1.5
    set style line 3 lt 3 pt 4 lw 1.5
    set style line 4 lt 4 pt 5 lw 1.5
    set style line 5 lt 5 pt 6 lw 1.5
    set style line 6 lt 6 pt 8 lw 1.5
    set style line 7 lt 7 pt 9 lw 1.5
    set style line 8 lt 8 pt 10 lw 1.5

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
	set yrange [0:1]

	plot "tfwc_sr_1.xg" with lines notitle linestyle 1, \
		"tfwc_sr_2.xg" with lines notitle linestyle 2, \
        "tfwc_sr_3.xg" with lines notitle linestyle 3, \
        "tfwc_sr_4.xg" with lines notitle linestyle 4, \
        "tfwc_sr_5.xg" with lines notitle linestyle 5, \
        "tfwc_sr_6.xg" with lines notitle linestyle 6, \
        "tfwc_sr_7.xg" with lines notitle linestyle 7, \
        "tfwc_sr_8.xg" with lines notitle linestyle 8
EOF
