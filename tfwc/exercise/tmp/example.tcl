# declare new simualtor
set ns [new Simulator]   

# create file for write out
set nf [open out.nam w]
set out_all [open a.out w]

# put all output to file handle nf
$ns namtrace-all $nf

# proc to finish off and execute nam with code
proc finish {} {
    global ns nf out_all
    $ns flush-trace
    close $nf
    close $out_all


    exec perl ../../ns-2.26/bin/set_flow_id -s a.out
    exec perl ../../ns-2.26/bin/getrc -s 0 -d 1 < a.out > foo
    exec perl ../../ns-2.26/bin/raw2xg -s 0.01 -m 90 < foo > temp.rands

    exec xgraph -bb -tk -nl -m -x time -y packets -geometry 1200x400 temp.rands & 
    exec nam out.nam &
    exit 0
}

# make a new node n0 and n1
set n0 [$ns node]
set n1 [$ns node]


# creates a duplex link between n0 and n1 with link cap of 1Mb and delay of 10ms using a droptail mechanism
$ns duplex-link $n0 $n1 1Mb 10ms DropTail


# Create an agent and source and attach to n0

# Create a UDP agen and attatch to n0
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

# Create a CBR traffic source and attach to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500   # bytes
$cbr0 set interval_ 0.005   # seconds, ie 200/second
$cbr0 attach-agent $udp0


# Create a NULL agent to sink traffic, attach to n1
set null0 [new Agent/Null]
$ns attach-agent $n1 $null0

# Connect the two agents together
$ns connect $udp0 $null0

# Start chr0 traffic at 0.5 sec and end at 4.5 sec
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"




$ns at 5.0 "finish"     

$ns run                 
