# simple simulation taken from Chung and Claypool example
# Yee-Ting Li, 24 Jan 2002.

set ns [new Simulator]


# create file to write bws to
set fileTCP [ open tcpMon.tr w ]
set fileUDP [ open udpMon.tr w ]
set fileRouterQueue [ open router.q w]

# creat file to write all trace info to
set fileTrace [ open trace.tr w ]
$ns trace-all $fileTrace

# create file for nam trace
set nf [open example4.nam w]
#$ns namtrace-all $nf



proc finish {} {
    global ns fileTrace nf fileTCP fileUDP fileRouterQueue
    $ns flush-trace

# close files
    close $fileTrace
    close $fileTCP
    close $fileUDP
    close $fileRouterQueue

#    exec nam example4.nam &

    exec xgraph tcpMon.tr udpMon.tr -geometry 800x400 &
    exec xgraph router.q -geometry 800x400 &

    exit 0
}




#=======================================================================
# Setup nodes and links

set n0 [$ns node]
set n1 [$ns node]
set r0 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $r0 1000mb 10ms DropTail
$ns duplex-link $n1 $r0 1000mb 10ms DropTail
$ns duplex-link $r0 $n3 1000mb 100ms DropTail

# set queue link for r0-n3 to 10
$ns queue-limit $r0 $n3 15



#=======================================================================
# Agents

# TCP
set tcp [ new Agent/TCP/SackRH ]
$ns attach-agent $n0 $tcp

set tcpSink [ new Agent/TCPSink/Sack1 ]
$ns attach-agent $n3 $tcpSink

$tcp set windowOption_ 8
$tcp set window_ 1000000
$tcpSink set window_ 1000000

$tcp set fid_ 0
$ns color 0 Red

# UDP
set udp [ new Agent/UDP ]
$ns attach-agent $n1 $udp

set udpSink [ new Agent/LossMonitor ]
$ns attach-agent $n3 $udpSink

$udp set fid_ 1
$ns color 1 Blue


# Tracing queue on r0
set r0QueueMon [ $ns monitor-queue $r0 $n3 ""]




#=======================================================================
# Sources

# ftp over tcp
set ftp [ new Application/FTP ]
$ftp attach-agent $tcp
#$tcp set packetSize_ 100

$ns connect $tcp $tcpSink


# cbr over udp
set cbr [ new Application/Traffic/CBR ]
$cbr attach-agent $udp
# cbr options
$cbr set type_ CBR
$cbr set packetSize_ 1000
$cbr set rate_ 200Mb
$cbr set random_ false

$ns connect $udp $udpSink


#=======================================================================
# record


proc record-data { duration } {
    global ns tcp cbr fileTCP fileUDP tcpSink udpSink fileRouterQueue r0QueueMon

    set ns [Simulator instance]


set out  "[$ns now]  [$tcp set cwnd_]  [expr [$tcp set ndatabytes_]/$duration/1000000*8]"

puts $fileTCP "$out"
puts "$out"

    $tcp set ndatabytes_ 0

    puts $fileUDP "[$ns now]  [expr [$udpSink set bytes_]/$duration/1000000]"
    $udpSink set bytes_ 0

    # stuff for queue
    puts $fileRouterQueue "[$ns now]  [$r0QueueMon set pkts_]"




    $ns after $duration "record-data $duration"
}



#=======================================================================
# Runtime

# times for agents
$ns at 0.0 "record-data 0.1"

# ftp
$ns at 1.0 "$ftp start"
$ns at 90.0 "$ftp stop"

# udp
$ns at 0.1 "$cbr start"
$ns at 90.0 "$cbr stop"


$ns at 90.0 "finish"

puts "CBR packet size = [ $cbr set packetSize_ ]"
puts "CBR interval = [$cbr set interval_ ]"

$ns run
