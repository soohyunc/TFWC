#!/usr/local/bin/gnuplot

set	terminal	png 
set	output		'graph/tfwc_red_cwnd.png'
set	pointsize	0.4
set	grid

set	title		"TFWC CWND Dynamics"
set	xlabel		"time"
set	ylabel		"cwnd size"

plot	"trace/tfwc_cwnd_01.xg" with lines, \
	"trace/tfwc_cwnd_02.xg" with lines, \
	"trace/tfwc_cwnd_03.xg" with lines, \
	"trace/tfwc_cwnd_04.xg" with lines

#replot
#EOF

