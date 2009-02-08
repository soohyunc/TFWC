
# This is an exercise for ns-2.
# Written by Soo-Hyun Choi

# Create a simulator object.
set ns [new Simulator]

# Open file for writing that is going to be used for the nam trace data.
set nf [open out.nam w]
$ns namtrace-all $nf
set f [open out.tr w]

proc finish {} {
		global ns nf f
		$ns flush-trace
		close $nf
		close $f
		exec nam out.nam &
		exec xgraph out.tr &
		exit 0
		}

# Two nodes, one link
set n0 [$ns node]
set n1 [$ns node]

$ns duplex-link $n0 $n1 1Mb 10ms DropTail

# Sending data
# Create a UDP agent and attach it to node n0
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

# Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

# Creat a NULL agent
set null0 [new Agent/Null]
$ns attach-agent $n1 $null0

# Connect two agent
$ns connect $udp0 $null0

# When to send data and when to stop sending
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"

#
#
# Simulator object to execute the 'finish' procedure after 5.0.
$ns at 5.0 "finish"

# Starts the simulation
$ns run

#-----------------------------------------------------------

