# $Id$

FROM=$1
TO=$2

# throughput
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tfrc-thru.eps"

	set title "8 TFRC Flows"
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

	plot "tfrc_thru_1.xg" with lines notitle linestyle 1, \
		"tfrc_thru_2.xg" with lines notitle linestyle 2, \
        "tfrc_thru_3.xg" with lines notitle linestyle 3, \
        "tfrc_thru_4.xg" with lines notitle linestyle 4, \
        "tfrc_thru_5.xg" with lines notitle linestyle 5, \
        "tfrc_thru_6.xg" with lines notitle linestyle 6, \
        "tfrc_thru_7.xg" with lines notitle linestyle 7, \
        "tfrc_thru_8.xg" with lines notitle linestyle 8
EOF

# measured loss rate 
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tfrc-loss.eps"

	set title "8 TFRC Flows"
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

	plot "tfrc_loss_1.xg" with lines notitle linestyle 1, \
		"tfrc_loss_2.xg" with lines notitle linestyle 2, \
        "tfrc_loss_3.xg" with lines notitle linestyle 3, \
        "tfrc_loss_4.xg" with lines notitle linestyle 4, \
        "tfrc_loss_5.xg" with lines notitle linestyle 5, \
        "tfrc_loss_6.xg" with lines notitle linestyle 6, \
        "tfrc_loss_7.xg" with lines notitle linestyle 7, \
        "tfrc_loss_8.xg" with lines notitle linestyle 8
EOF

# loss rate seen by the equation
gnuplot -persist << EOF
    set terminal postscript eps enhanced color
    set output "tfrc-loss-by-eq.eps"

    set title "8 TFRC Flows"
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
    plot "tfrc_loss_by_eq_1.xg" with lines notitle linestyle 1, \
        "tfrc_loss_by_eq_2.xg" with lines notitle linestyle 2, \
        "tfrc_loss_by_eq_3.xg" with lines notitle linestyle 3, \
        "tfrc_loss_by_eq_4.xg" with lines notitle linestyle 4, \
        "tfrc_loss_by_eq_5.xg" with lines notitle linestyle 5, \
        "tfrc_loss_by_eq_6.xg" with lines notitle linestyle 6, \
        "tfrc_loss_by_eq_7.xg" with lines notitle linestyle 7, \
        "tfrc_loss_by_eq_8.xg" with lines notitle linestyle 8
EOF

# average loss interval 
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tfrc-ali.eps"

	set title "8 TFRC Flows"
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

	plot "tfrc_avg_int_1.xg" with lines notitle linestyle 1, \
		"tfrc_avg_int_2.xg" with lines notitle linestyle 2, \
        "tfrc_avg_int_3.xg" with lines notitle linestyle 3, \
        "tfrc_avg_int_4.xg" with lines notitle linestyle 4, \
        "tfrc_avg_int_5.xg" with lines notitle linestyle 5, \
        "tfrc_avg_int_6.xg" with lines notitle linestyle 6, \
        "tfrc_avg_int_7.xg" with lines notitle linestyle 7, \
        "tfrc_avg_int_8.xg" with lines notitle linestyle 8
EOF


# measured queue length 
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tfrc-q.eps"

	set title "8 TFRC Flows"
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

	plot "tfrc_q_1.xg" with lines notitle linestyle 1, \
		"tfrc_q_2.xg" with lines notitle linestyle 2, \
        "tfrc_q_3.xg" with lines notitle linestyle 3, \
        "tfrc_q_4.xg" with lines notitle linestyle 4, \
        "tfrc_q_5.xg" with lines notitle linestyle 5, \
        "tfrc_q_6.xg" with lines notitle linestyle 6, \
        "tfrc_q_7.xg" with lines notitle linestyle 7, \
        "tfrc_q_8.xg" with lines notitle linestyle 8
EOF
