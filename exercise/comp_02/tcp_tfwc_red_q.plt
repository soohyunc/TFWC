#!/usr/local/bin/gnuplot

set	terminal	png 
set	output		'graph/aggr_q_tfwc_red_reverse.png'
set	pointsize	0.4
set	grid

set	title		"Aggregated Queue Size (TFWCs)"
set	xlabel		"time"
set	ylabel		"queue size in packets"

plot	"trace/tcp_q.xg" with linespoints, \
	"trace/tfwc_q.xg" with linespoints

#replot
#EOF

