#
# This is test code for TCP basics written by Soo-Hyun Choi
#

set ns [new Simulator]

set f [open out.tr w]
$ns trace-all $f
set nf [open out.nam w]
$ns namtrace-all $nf

# Define topology
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n2 5Mb 2ms DropTail
$ns duplex-link $n1 $n2 5Mb 2ms DropTail
$ns duplex-link $n2 $n3 1.5Mb 10ms DropTail

# UDP Agent
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
#set cbr0 [new Application/Traffic/CBR]
#$cbr0 attach-agent $udp0
#$udp0 set class_ 0

# FTP over TCP/Tahoe from node1 to node3
set tcp [new Agent/TCP]
$tcp set class_ 1
$ns attach-agent $n1 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 1.2 "$ftp start"

$ns connect $tcp $sink
$ns at 1.35 "$ns detach-agent $n0 $tcp; $ns detach-agent $n3 $sink"


# A simulation runs for 3s
$ns at 3.0 "finish"
proc finish {} {
		global ns f nf
		$ns flush-trace
		close $f
		close $nf

		puts "running nam..."
		exec nam out.nam &
		exit 0 
}


# Start simulation
$ns run


