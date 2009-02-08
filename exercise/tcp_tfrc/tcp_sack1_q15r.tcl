#----------------------------------------------------------/
# On comparison between TCP Sack1 and TFRC
#----------------------------------------------------------/
#
# This is a test code for TCP basics written by Soo-Hyun Choi
#
# Soo-Hyun Choi (s.choi@cs.ucl.ac.uk)
# Computer Science Department
# University College London
# (Apr 28, 2004)
#
#----------------------------------------------------------/

#----------------------------------------------------------/
# Create a simulator object
#----------------------------------------------------------/
set ns [new Simulator]

#----------------------------------------------------------/
# File opening for nam 
#----------------------------------------------------------/
set output [open out.tr w]
$ns trace-all $output

set nam_out [open out.nam w]
$ns namtrace-all $nam_out

set queue_out [open out.queue w]
set f0 [open out0.tr w]
set f1 [open out1.tr w]
set tf_rtt [open tf_rtt.rands w]
set tcp_rtt [open tcp_rtt.rands w]

#----------------------------------------------------------/
# Define topology
#----------------------------------------------------------/
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n2 5Mb 2ms DropTail orient right-down
$ns duplex-link $n1 $n2 5Mb 2ms DropTail orient right-up
$ns duplex-link $n2 $n3 1.5Mb 10ms DropTail orient right


#----------------------------------------------------------/
# Queue definition
#----------------------------------------------------------/
$ns queue-limit $n2 $n3 15

#----------------------------------------------------------/
# Set Dummy UDP Agent
#----------------------------------------------------------/
set udp_dummy [new Agent/UDP]
$ns attach-agent $n0 $udp_dummy

#----------------------------------------------------------/
# Create 4 TCP/Sack1 and 4 TFRC Agents
#----------------------------------------------------------/
set tcp01 [new Agent/TCP/Sack1]
set tcp02 [new Agent/TCP/Sack1]
set tcp03 [new Agent/TCP/Sack1]
set tcp04 [new Agent/TCP/Sack1]

set tfrc01 [new Agent/TFRC]
set tfrc02 [new Agent/TFRC]
set tfrc03 [new Agent/TFRC]
set tfrc04 [new Agent/TFRC]

$ns attach-agent $n1 $tcp01
$ns attach-agent $n1 $tcp02
$ns attach-agent $n1 $tcp03
$ns attach-agent $n1 $tcp04

$ns attach-agent $n1 $tfrc01
$ns attach-agent $n1 $tfrc02
$ns attach-agent $n1 $tfrc03
$ns attach-agent $n1 $tfrc04

#----------------------------------------------------------/
# Create a TCP/TFRC Sink Agent
#----------------------------------------------------------/
set tcp_sink01 [new Agent/TCPSink/Sack1]
set tcp_sink02 [new Agent/TCPSink/Sack1]
set tcp_sink03 [new Agent/TCPSink/Sack1]
set tcp_sink04 [new Agent/TCPSink/Sack1]

Agent/TCP/Sack1 set window_ 100
Agent/TCP set minrto_ 0
                                                                                
set tfrc_sink01 [new Agent/TFRCSink]
set tfrc_sink02 [new Agent/TFRCSink]
set tfrc_sink03 [new Agent/TFRCSink]
set tfrc_sink04 [new Agent/TFRCSink]
                                                                                
Agent/TFRCSink set discount 0
                                                                                
$ns attach-agent $n3 $tcp_sink01
$ns attach-agent $n3 $tcp_sink02
$ns attach-agent $n3 $tcp_sink03
$ns attach-agent $n3 $tcp_sink04
                                                                                
$ns attach-agent $n3 $tfrc_sink01
$ns attach-agent $n3 $tfrc_sink02
$ns attach-agent $n3 $tfrc_sink03
$ns attach-agent $n3 $tfrc_sink04
                                                                                
                                                                                
#----------------------------------------------------------/
# Create FTPs from n1 to n3
#----------------------------------------------------------/
set ftp01 [new Application/FTP]
set ftp02 [new Application/FTP]
set ftp03 [new Application/FTP]
set ftp04 [new Application/FTP]
                                                                                
set ftp05 [new Application/FTP]
set ftp06 [new Application/FTP]
set ftp07 [new Application/FTP]
set ftp08 [new Application/FTP]
                                                                                
$ftp01 attach-agent $tcp01
$ftp02 attach-agent $tcp02
$ftp03 attach-agent $tcp03
$ftp04 attach-agent $tcp04
                                                                                
$ftp05 attach-agent $tfrc01
$ftp06 attach-agent $tfrc02
$ftp07 attach-agent $tfrc03
$ftp08 attach-agent $tfrc04
                                                                                
$ns at 0.3 "$ftp01 start"
$ns at 0.3 "$ftp02 start"
$ns at 0.3 "$ftp03 start"
$ns at 0.3 "$ftp04 start"
                                                                                
$ns at 1.5 "$ftp05 start"
$ns at 1.5 "$ftp06 start"
$ns at 1.5 "$ftp07 start"
$ns at 1.5 "$ftp08 start"

$ns connect $tcp01 $tcp_sink01
$ns connect $tcp02 $tcp_sink02
$ns connect $tcp03 $tcp_sink03
$ns connect $tcp04 $tcp_sink04
                                                                                
$ns connect $tfrc01 $tfrc_sink01
$ns connect $tfrc02 $tfrc_sink02
$ns connect $tfrc03 $tfrc_sink03
$ns connect $tfrc04 $tfrc_sink04
                                                                                
$ns at 170.0 "$ns detach-agent $n1 $tcp01; $ns detach-agent $n3 $tcp_sink01"
$ns at 170.0 "$ns detach-agent $n1 $tcp02; $ns detach-agent $n3 $tcp_sink02"
$ns at 170.0 "$ns detach-agent $n1 $tcp03; $ns detach-agent $n3 $tcp_sink03"
$ns at 170.0 "$ns detach-agent $n1 $tcp04; $ns detach-agent $n3 $tcp_sink04"
                                                                                
$ns at 150.0 "$ns detach-agent $n1 $tfrc01; $ns detach-agent $n3 $tfrc_sink01"
$ns at 150.0 "$ns detach-agent $n1 $tfrc02; $ns detach-agent $n3 $tfrc_sink02"
$ns at 150.0 "$ns detach-agent $n1 $tfrc03; $ns detach-agent $n3 $tfrc_sink03"
$ns at 150.0 "$ns detach-agent $n1 $tfrc04; $ns detach-agent $n3 $tfrc_sink04"


#----------------------------------------------------------/
# Create Inverse TCP traffic
#----------------------------------------------------------/

set tcp_inv01 [new Agent/TCP/Sack1]
set tcp_inv_sink01 [new Agent/TCPSink/Sack1]

$ns attach-agent $n3 $tcp_inv01
$ns attach-agent $n1 $tcp_inv_sink01
$ns queue-limit $n2 $n1 2 

set ftp_inv01 [new Application/FTP]
$ftp_inv01 attach-agent $tcp_inv01

$ns at 0.3 "$ftp_inv01 start"
$ns connect $tcp_inv01 $tcp_inv_sink01

$ns at 180.0 "$ns detach-agent $n1 $tcp_inv_sink01; $ns detach-agent $n3 $tcp_inv01"

#----------------------------------------------------------/
# Make a queue trace
#----------------------------------------------------------/
$ns trace-queue $n2 $n3 $queue_out


#----------------------------------------------------------/
# Simulation Process 
#----------------------------------------------------------/

$ns at 180.0 "finish"
proc finish {} {
		global ns output nam_out queue_out f0 f1
		$ns flush-trace
		close $output
		close $nam_out
		close $queue_out
		close $f0
		close $f1


                #----------------------------------------------------------/
                # Manipulationg Output Data
                #----------------------------------------------------------/
                exec perl ../../ns-2.26/bin/set_flow_id -s out.tr
                exec perl ../../ns-2.26/bin/getrc -s 2 -d 3 < out.tr > foo
                #exec perl ../../ns-2.26/bin/raw2xg -s 0.01 -m 90 < foo > temp.rands
                                                                                
                #----------------------------------------------------------/
                # Draw individual TCP Time sequence plot
                #----------------------------------------------------------/
                #exec awk -f tcp_seq01.awk foo
                #exec perl ../../ns-2.26/bin/raw2xg -s 0.01 -m 90 < tcp_seq01.temp > tcp_seq01.rands
		#exec awk -f tcp_seq02.awk foo
		#exec perl ../../ns-2.26/bin/raw2xg -s 0.01 -m 90 < tcp_seq02.temp > tcp_seq02.rands
		#exec awk -f tcp_seq03.awk foo
		#exec perl ../../ns-2.26/bin/raw2xg -s 0.01 -m 90 < tcp_seq03.temp > tcp_seq03.rands
		#exec awk -f tcp_seq04.awk foo
		#exec perl ../../ns-2.26/bin/raw2xg -s 0.01 -m 90 < tcp_seq04.temp > tcp_seq04.rands
                                                                                
                                                                                
                #----------------------------------------------------------/
                # Draw individual TFRC Time sequence plot
                #----------------------------------------------------------/
                #exec awk -f tf_seq01.awk foo
                #exec perl ../../ns-2.26/bin/raw2xg -s 0.01 -m 90 < tf_seq01.temp > tf_seq01.rands
                                                                                
                                                                                
                #----------------------------------------------------------/
                # TCP/TFRC Time Sequence Plot
                #----------------------------------------------------------/
                #exec xgraph -bb -tk -nl -m -x time -y packets -t "Sack1/TFRC (all) w/ DT (Q=15)" -geometry 1200x400 temp.rands &
                #exec xgraph -bb -tk -nl -m -x time -y packets -t "TCP Sack1 #1 w/ DT (Q=15)" -geometry 1200x400 tcp_seq01.rands &
                #exec xgraph -bb -tk -nl -m -x time -y packets -t "TCP Sack1 #2 w/ DT (Q=15)" -geometry 1200x400 tcp_seq02.rands &
                #exec xgraph -bb -tk -nl -m -x time -y packets -t "TCP Sack1 #3 w/ DT (Q=15)" -geometry 1200x400 tcp_seq03.rands &
                #exec xgraph -bb -tk -nl -m -x time -y packets -t "TCP Sack1 #4 w/ DT (Q=15)" -geometry 1200x400 tcp_seq04.rands &


                #exec xgraph -bb -tk -nl -m -x time -y packets -t "TFRC #1 w/ DT (Q=15)" -geometry 1200x400 tf_seq01.rands &
                                                                                
                                                                                
                                                                                
                #----------------------------------------------------------/
                # Overall Transmission Rate Plot
                #----------------------------------------------------------/
                #exec xgraph -P -x time -y "rate (Mb/s)" -t "Aggregated Tx rate (Sack1s and TFRCs) w/ DT (Q=15)" -geometry 1200x400 out0.tr out1.tr &
                                                                                
                                                                                
                #----------------------------------------------------------/
                # Aggregated/Combined Thruput Plot
                #----------------------------------------------------------/
                # exec awk -f thru.awk out.queue
                # exec xgraph -P -x time -y "rate (Mb/s)" -t "Aggregated/Combined Thruput (Sack1s and TFRCs) w/ DT (Q=15)" -geometry 1200x400 thru.rands &

                #----------------------------------------------------------/
                # Aggregated Thruput Plot
                #----------------------------------------------------------/
                exec awk -f tcp_thru.awk out.queue
                exec awk -f tf_thru.awk out.queue
                exec xgraph -P -x time -y "rate (Mb/s)" -t "Aggregated Thruput (4Sack1+1R & 4TFRCs) w/ DT (Q=15)" -geometry 1200x400 tcp_thru.rands tf_thru.rands &

		exec perl ../../../Chart-Graph-2/graph.pl -i "tcp_thru.rands,tf_thru.rands" -x "time" -y "rate (Mb/s)" -t "Aggregated Thruput (4Sack1+1R & 4TFRC) w/ DT (Q=15)" -d 1200x400 -o ./graph/aggr_thru_sack1_q15r.png -s linespoints &


                #----------------------------------------------------------/
                # Loss Rate
                #----------------------------------------------------------/
                exec awk -f tcp_loss.awk out.queue 
                exec awk -f tf_loss.awk out.queue
                exec xgraph -P -x time -y "Loss Rate" -t "Aggregated 4Sack1+1R/4TFRC Loss Rate w/ DT (Q=15)" -geometry 1200x400 tcp_loss.rands tf_loss.rands &

		exec perl ../../../Chart-Graph-2/graph.pl -i "tcp_loss.rands,tf_loss.rands" -x "time" -y "Loss Rate" -t "Aggregated 4Sack1+1R/4TFRC Loss Rate w/ DT (Q=15)" -d 1200x400 -o ./graph/aggr_loss_sack1_q15r.png -s linespoints &


                #exec awk -f tcp01_loss.awk out.tr
                #exec xgraph -P -x time -y "Loss Rate" -t "Sack1 #1 Loss Rate w/ DT (Q=15)" -geometry 1200x400 tcp01_temp.loss &
                #exec awk -f tcp02_loss.awk out.tr
                #exec xgraph -P -x time -y "Loss Rate" -t "Sack1 #2 Loss Rate w/ DT (Q=15)" -geometry 1200x400 tcp02_temp.loss &
                #exec awk -f tcp03_loss.awk out.tr
                #exec xgraph -P -x time -y "Loss Rate" -t "Sack1 #3 Loss Rate w/ DT (Q=15)" -geometry 1200x400 tcp03_temp.loss &
                #exec awk -f tcp04_loss.awk out.tr
                #exec xgraph -P -x time -y "Loss Rate" -t "Sack1 #4 Loss Rate w/ DT (Q=15)" -geometry 1200x400 tcp04_temp.loss &

                #exec xgraph -P -x time -y "Loss Rate" -t "Sack1r Loss Rate w/ DT (Q=15)" -geometry 1200x400 tcp01_loss.rands tcp02_loss.rands tcp03_loss.rands tcp04_loss.rands &

                #----------------------------------------------------------/
                # Instaneous Queue Size
                #----------------------------------------------------------/
                exec awk -f q_size.awk out.queue
                exec xgraph -P -x time -y "Q size" -t "Aggregated/Combined 4Sack1+1R/4TFRC Q-size w/ DT (Q=15)" -geometry 1200x400 q_size.rands &

		exec perl ../../../Chart-Graph-2/graph.pl -i "q_size.rands" -x time -y "Q size" -t "Aggregated/Combined 4Sack1+1R/4TFRC Q-size w/ DT (Q=15)" -d 1200x400 -o ./graph/all_sack1_q_size_q15r.png -s linespoints &

		exec xgraph -P -x time -y "Q size" -t "Aggregated 4Sack1+1R/4TFRC Q-size w/ DT (Q=15)" -geometry 1200x400 tcp_q.rands tf_q.rands &


		exec perl ../../../Chart-Graph-2/graph.pl -i "tcp_q.rands,tf_q.rands" -x time -y "Q size" -t "Aggregated 4Sack1+1R/4TFRC Q-size w/ DT (Q=15)" -d 1200x400 -o ./graph/aggr_q_sack1_q15r.png -s linespoints &


                #----------------------------------------------------------/
		# RTT Measurement
		#----------------------------------------------------------/

		exec xgraph -P -x time -y RTT -t "Aggregated 4TFRC+1R RTT w/ DT (Q=15)" -geometry 1200x400 tf_rtt.rands &

		exec perl ../../../Chart-Graph-2/graph.pl -i "tf_rtt.rands" -x time -y RTT -t "Aggregated 4TFRC+1R RTT w/ DT (Q=15)" -d 1200x400 -o ./graph/aggr_tfrc_rtt_sack1_q15r.png -s linespoints &

		exit 0
		}

#----------------------------------------------------------/
# Set the last bytes' value
#----------------------------------------------------------/
set last_bytes_01 0
set last_bytes_02 0
set last_bytes_03 0
set last_bytes_04 0
                                                                         
set tf_last_bytes_01 0
set tf_last_bytes_02 0
set tf_last_bytes_03 0
set tf_last_bytes_04 0

proc record {} {
                global f0 f1 tcp01 tcp02 tcp03 tcp04 tfrc01 tfrc02 tfrc03 tfrc04
		global last_bytes_01 last_bytes_02 last_bytes_03 last_bytes_04 
		global tf_last_bytes_01 tf_last_bytes_02 tf_last_bytes_03 tf_last_bytes_04


                set ns [Simulator instance]
                set time 0.5

                #----------------------------------------------------------/
                # Number of bytes
                #----------------------------------------------------------/
                set bw1 [$tcp01 set ndatabytes_]
                set bw2 [$tcp02 set ndatabytes_]
                set bw3 [$tcp03 set ndatabytes_]
                set bw4 [$tcp04 set ndatabytes_]
                              
                set tfbw1 [$tfrc01 set ndatapack_]
                set tfbw2 [$tfrc02 set ndatapack_]
                set tfbw3 [$tfrc03 set ndatapack_]
                set tfbw4 [$tfrc04 set ndatapack_]
       
                #----------------------------------------------------------/
                # Get the current time
                #----------------------------------------------------------/
                set now [$ns now]

                #----------------------------------------------------------/
                # Calculate the sending rate (Mb/s)
                #----------------------------------------------------------/
                puts $f0 "$now [expr (($bw1-$last_bytes_01)+($bw2-$last_bytes_02)+($bw3-$last_bytes_03)+($bw4-$last_bytes_04))/$time*8/1000000]"
                puts $f1 "$now [expr (($tfbw1*1000-$tf_last_bytes_01)+($tfbw2*1000-$tf_last_bytes_02)+($tfbw3*1000-$tf_last_bytes_03)+($tfbw4*1000-$tf_last_bytes_04))/$time*8/1000000]"


                #----------------------------------------------------------/
                # Reset the bytes value
                #----------------------------------------------------------/
                set last_bytes_01 $bw1
                set last_bytes_02 $bw2
                set last_bytes_03 $bw3
                set last_bytes_04 $bw4

                set tf_last_bytes_01 $tfbw1*1000
                set tf_last_bytes_02 $tfbw2*1000
                set tf_last_bytes_03 $tfbw3*1000
                set tf_last_bytes_04 $tfbw4*1000
                                                         
                #----------------------------------------------------------/
                # Re-schedule the procedure
                #----------------------------------------------------------/
                $ns at [expr $now+$time] "record"
                }


#----------------------------------------------------------/
# Trace the TFRC RTT
#----------------------------------------------------------/

proc record_rtt {} {

        global tf_rtt tcp_rtt
	global tfrc01 tfrc02 tfrc03 tfrc04
	global tcp01 tcp02 tcp03 tcp04

	set ns [Simulator instance]
	set now [$ns now]
	set granul 1.0

	set tf01 [$tfrc01 set rtt_]
	set tf02 [$tfrc02 set rtt_]
	set tf03 [$tfrc03 set rtt_]
	set tf04 [$tfrc04 set rtt_]
	set tp01 [$tcp01 set rtt_]
	set tp02 [$tcp02 set rtt_]
	set tp03 [$tcp03 set rtt_]
	set tp04 [$tcp04 set rtt_]

	puts $tf_rtt "$now  [expr ($tf01+$tf02+$tf03+$tf04)/4]"
	puts $tcp_rtt "$now  [expr ($tp01+$tp02+$tp03+$tp04)/4]"

	$ns at [expr $now+$granul] "record_rtt"
}


#----------------------------------------------------------/
# Start simulation
#----------------------------------------------------------/
#$ns at 0.0 "record"
$ns at 0.0 "record_rtt"
$ns run


