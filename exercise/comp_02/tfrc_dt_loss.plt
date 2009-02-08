#!/usr/local/bin/gnuplot

set	terminal	png 
set	output		'graph/aggr_loss_tfrc_dt.png'
set	pointsize	0.4
set	grid

set	title		"Aggregated Loss Rate (TFRCs)"
set	xlabel		"time"
set	ylabel		"loss rate"

plot	"trace/tfrc_loss.xg" with linespoints

#replot
#EOF

