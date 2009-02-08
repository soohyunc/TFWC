#!/usr/local/bin/gnuplot

set	terminal	png 
set	output		'graph/tfwc_dt_ali.png'
set	pointsize	0.4
set	grid

set	title		"Avg Loss Interval with Lost Packet Marking"
set	xlabel		"time"
set	ylabel		"Avg Loss Interval"

#set	yrange		[0:500]

plot	"trace/tfwc_avg_int_01.xg" with lines, \
	"trace/tfwc_avg_int_02.xg" with lines, \
	"trace/tfwc_avg_int_03.xg" with lines, \
	"trace/tfwc_avg_int_04.xg" with lines, \
	"trace/tfwc_loss_in_hist_01.xg" with points, \
	"trace/tfwc_loss_in_hist_02.xg" with points, \
	"trace/tfwc_loss_in_hist_03.xg" with points, \
	"trace/tfwc_loss_in_hist_04.xg" with points

#replot
#EOF

