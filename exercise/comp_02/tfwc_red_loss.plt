#!/usr/local/bin/gnuplot

set	terminal	png 
set	output		'graph/aggr_loss_tfwc_red.png'
set	pointsize	0.4
set	grid

set	title		"Aggregated Loss Rate (TFWCs)"
set	xlabel		"time"
set	ylabel		"loss rate"

plot	"trace/tfwc_loss.xg" with linespoints

#replot
#EOF

