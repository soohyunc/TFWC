#!/usr/local/bin/gnuplot

set	terminal	png 
set	output		'graph/aggr_thru_tfrc_red_reverse.png'
set	pointsize	0.4
set	grid

set	title		"Aggregated Throughput (TFRCs)"
set	xlabel		"time"
set	ylabel		"rate (Mb/s)"

plot	"trace/tcp_thru.xg" with linespoints, \
	"trace/tfrc_thru.xg" with linespoints

#replot
#EOF

