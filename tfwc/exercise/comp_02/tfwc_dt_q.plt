#!/usr/local/bin/gnuplot

set	terminal	png
set	output		'graph/aggr_q_tfwc_dt.png'
set	pointsize	0.4
set	grid

#set	xrange		[50:50.5]

set	title		"Aggregated Queue Size (TFWCs)"
set	xlabel		"time"
set	ylabel		"queue size in packets"

plot	"trace/tfwc_q.xg" with linespoints

#replot
#EOF

