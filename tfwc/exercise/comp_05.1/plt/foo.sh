# $Id$

gnuplot -persist << EOF

	set terminal png
	set output "../tcp_indiv_thru.png"

	plot "../trace/tcp_thru_01.xg" with lines, \
		"../trace/tcp_thru_02.xg" with lines, \
		"../trace/tcp_thru_03.xg" with lines, \
		"../trace/tcp_thru_04.xg" with lines
EOF

gnuplot -persist << EOF

    set terminal png
    set output "../tfrc_indiv_thru.png"

    plot "../trace/tfrc_thru_01.xg" with lines, \
        "../trace/tfrc_thru_02.xg" with lines, \
        "../trace/tfrc_thru_03.xg" with lines, \
        "../trace/tfrc_thru_04.xg" with lines
EOF

gnuplot -persist << EOF

    set terminal png
    set output "../tfwc_indiv_thru.png"

    plot "../trace/tfwc_thru_01.xg" with lines, \
        "../trace/tfwc_thru_02.xg" with lines, \
        "../trace/tfwc_thru_03.xg" with lines, \
        "../trace/tfwc_thru_04.xg" with lines
EOF



