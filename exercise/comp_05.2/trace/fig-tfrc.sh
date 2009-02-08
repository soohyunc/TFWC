# $Id$

FROM=$1
TO=$2

# throughput
gnuplot -persist << EOF
	set terminal postscript eps enhanced 
	set output "tfrc-thru.eps"

	set title "8 TFRC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Throughput (Mb/s)"

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
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

# measured loss rate
gnuplot -persist << EOF
	set terminal postscript eps enhanced 
	set output "tfrc-loss.eps"

	set title "8 TFRC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Loss rate"

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
	set yrange [0:.1]
	set ytics 0.02
	set mytics 2

	plot "tfrc_loss_1.xg" with lines notitle, \
		"tfrc_loss_2.xg" with lines notitle, \
        "tfrc_loss_3.xg" with lines notitle, \
        "tfrc_loss_4.xg" with lines notitle, \
        "tfrc_loss_5.xg" with lines notitle, \
        "tfrc_loss_6.xg" with lines notitle, \
        "tfrc_loss_7.xg" with lines notitle, \
        "tfrc_loss_8.xg" with lines notitle
EOF

# loss rate seen by the equation
gnuplot -persist << EOF
	set terminal postscript eps enhanced 
	set output "tfrc-loss-by-eq.eps"

	set title "8 TFRC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Loss rate seen by Eq."

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
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
	set terminal postscript eps enhanced 
	set output "tfrc-ali.eps"

	set title "8 TFRC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Ave. Loss Interval"

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
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

# measured queue length 
gnuplot -persist << EOF
	set terminal postscript eps enhanced 
	set output "tfrc-q.eps"

	set title "8 TFRC Flows"
	set xlabel "Simulation Time (sec)"
	set ylabel "Queue Size (packet)"

	set size 0.6,0.4
	set xrange [$FROM:$TO]
	set mxtics 5
	set yrange [0:15]

	plot "tfrc_q_1.xg" with lines notitle, \
		"tfrc_q_2.xg" with lines notitle, \
        "tfrc_q_3.xg" with lines notitle, \
        "tfrc_q_4.xg" with lines notitle, \
        "tfrc_q_5.xg" with lines notitle, \
        "tfrc_q_6.xg" with lines notitle, \
        "tfrc_q_7.xg" with lines notitle, \
        "tfrc_q_8.xg" with lines notitle
EOF
