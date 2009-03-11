# $Id$

FROM=$1
TO=$2

# throughput
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tcp-thru.eps"

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

	plot "tcp_thru_1.xg" with lines notitle linestyle 1, \
		"tcp_thru_2.xg" with lines notitle linestyle 2, \
        "tcp_thru_3.xg" with lines notitle linestyle 3, \
        "tcp_thru_4.xg" with lines notitle linestyle 4, \
        "tcp_thru_5.xg" with lines notitle linestyle 5, \
        "tcp_thru_6.xg" with lines notitle linestyle 6, \
        "tcp_thru_7.xg" with lines notitle linestyle 7, \
        "tcp_thru_8.xg" with lines notitle linestyle 8
EOF

# measured loss rate 
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tcp-loss.eps"

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

	plot "tcp_loss_1.xg" with lines notitle linestyle 1, \
		"tcp_loss_2.xg" with lines notitle linestyle 2, \
        "tcp_loss_3.xg" with lines notitle linestyle 3, \
        "tcp_loss_4.xg" with lines notitle linestyle 4, \
        "tcp_loss_5.xg" with lines notitle linestyle 5, \
        "tcp_loss_6.xg" with lines notitle linestyle 6, \
        "tcp_loss_7.xg" with lines notitle linestyle 7, \
        "tcp_loss_8.xg" with lines notitle linestyle 8
EOF

# cwnd 
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tcp-cwnd.eps"

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

	plot "tcp_cwnd_1.xg" with lines notitle linestyle 1, \
		"tcp_cwnd_2.xg" with lines notitle linestyle 2, \
        "tcp_cwnd_3.xg" with lines notitle linestyle 3, \
        "tcp_cwnd_4.xg" with lines notitle linestyle 4, \
        "tcp_cwnd_5.xg" with lines notitle linestyle 5, \
        "tcp_cwnd_6.xg" with lines notitle linestyle 6, \
        "tcp_cwnd_7.xg" with lines notitle linestyle 7, \
        "tcp_cwnd_8.xg" with lines notitle linestyle 8
EOF

# measured queue length 
gnuplot -persist << EOF
	set terminal postscript eps enhanced color
	set output "tcp-q.eps"

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

	plot "tcp_q_1.xg" with lines notitle linestyle 1, \
		"tcp_q_2.xg" with lines notitle linestyle 2, \
        "tcp_q_3.xg" with lines notitle linestyle 3, \
        "tcp_q_4.xg" with lines notitle linestyle 4, \
        "tcp_q_5.xg" with lines notitle linestyle 5, \
        "tcp_q_6.xg" with lines notitle linestyle 6, \
        "tcp_q_7.xg" with lines notitle linestyle 7, \
        "tcp_q_8.xg" with lines notitle linestyle 8
EOF

