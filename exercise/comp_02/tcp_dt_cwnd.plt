#!/usr/local/bin/gnuplot

set	terminal	png 
set	output		'graph/tcp_dt_cwnd.png'
set	pointsize	0.4
set	grid

#set	yrange		[0:30]

set	title		"TCP CWND Dynamics"
set	xlabel		"time"
set	ylabel		"cwnd size"

plot	"trace/tcp_cwnd_01.xg" with lines, \
	"trace/tcp_cwnd_02.xg" with lines, \
	"trace/tcp_cwnd_03.xg" with lines, \
	"trace/tcp_cwnd_04.xg" with lines

#replot
#EOF

