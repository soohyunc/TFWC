#!/usr/local/bin/gnuplot

set	terminal	png 
set	output		'graph/aggr_thru_tfwc_red.png'
set	pointsize	0.4
set	grid

set	title		"Aggregated Throughput (TFWCs)"
set	xlabel		"time"
set	ylabel		"rate (Mb/s)"

plot	"trace/tfwc_thru.xg" with linespoints

#replot
#EOF

