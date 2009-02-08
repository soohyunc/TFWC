#!/usr/local/bin/gnuplot

set	terminal	png 
set	output		'graph/tfrc_dt_ali.png'
set	pointsize	0.4
set	grid

set	title		"TFRC Avg Loss Interval" 
set	xlabel		"time"
set	ylabel		"Avg Loss Interval"

#set	yrange		[0:500]

plot	"trace/tfrc_avg_int_01.xg" with lines, \
	"trace/tfrc_avg_int_02.xg" with lines, \
	"trace/tfrc_avg_int_03.xg" with lines, \
	"trace/tfrc_avg_int_04.xg" with lines
#replot
#EOF

