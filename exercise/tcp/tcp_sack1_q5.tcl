# TCP Sack1 w/ DropTail, queue=5
#
# This is a test code for TCP basics written by Soo-Hyun Choi
# (s.choi@cs.ucl.ac.uk)
#
# Computer Science Department
# University College London
# (Feb. 03, 2004)
#

# Creat a simulatro object
set ns [new Simulator]

# File opening for nam 
set output [open out.tr w]
$ns trace-all $output

set nam_out [open out.nam w]
$ns namtrace-all $nam_out

set queue_out [open out.queue w]
set f0 [open out0.tr w]

# Define topology
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n2 5Mb 2ms DropTail
$ns duplex-link $n1 $n2 5Mb 2ms DropTail 
$ns duplex-link $n2 $n3 1.5Mb 10ms DropTail

# Queue definition
# Queue/DropTail set limit_ 3 
$ns queue-limit $n2 $n3 5 

# Set Dummy UDP Agent
set udp_dummy [new Agent/UDP]
$ns attach-agent $n0 $udp_dummy

# Create a TCP Tahoe Agent
set tcp [new Agent/TCP/Sack1]
$ns attach-agent $n1 $tcp

# Create a TCP Sink Agent
set sink [new Agent/TCPSink/Sack1]
Agent/TCPSink set packetSize_ 40
$ns attach-agent $n3 $sink

# Create an FTP from n1 to n3
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.3 "$ftp start"

$ns connect $tcp $sink
$ns at 5.0 "$ns detach-agent $n0 $tcp; $ns detach-agent $n3 $sink"

# Make a queue trace
$ns trace-queue $n2 $n3 $queue_out

# A simulation runs for 3 sec.
$ns at 5.0 "finish"
proc finish {} {
		global ns output nam_out queue_out f0
		$ns flush-trace
		close $output
		close $nam_out
		close $queue_out
		close $f0

		# exec nam out.nam &
		exec perl ../../ns-2.26/bin/set_flow_id -s out.tr 
		exec perl ../../ns-2.26/bin/getrc -s 2 -d 3 < out.tr > foo
		exec perl ../../ns-2.26/bin/raw2xg -s 0.01 -m 90 < foo > temp.rands
		exec xgraph -bb -tk -nl -m -x time -y packets -t "TCP Sack1 w/ DT Q=5" temp.rands &
		exec xgraph -P -x time -y "rate (Mb/s)" -t "Tx rate for TCP Sack1 w/ DT Q=5" out0.tr &

		# thruput calculation
		exec awk -f thru.awk out.queue
		exec xgraph -P -x time -y "rate (Mb/s)" -t "Thruput for TCP Sack1 w/ DT Q=5" temp.thru &

		exit 0
		}
# Set the last bytes' value
set last_bytes 0
                                                                                          
proc record {} {
                global f0 f1 tcp last_bytes
                set ns [Simulator instance]
                set time 0.05
                                                                                          
                                                                                          
                # Number of bytes
                set bw0 [$tcp set ndatabytes_]
                                                                                          
                # Get the current time
                set now [$ns now]
                                                                                          
                # Calculate the sending rate (Mb/s)
                puts $f0 "$now [expr ($bw0-$last_bytes)/$time*8/1000000]"
                                                                                          
                # Reset the bytes value
                set last_bytes $bw0
                                                                                          
                # Re-schedule the procedure
                $ns at [expr $now+$time] "record"
                }
                                                                                          
                                                                                          
# Start simulation
$ns at 0.0 "record"
$ns run


