#Create a simulator object
set ns [new Simulator]
set MAX_TIME 500
set max_queue 0

#Define different colors for data flows
$ns color 1 Blue
$ns color 2 Red

#Open the nam trace file
#set nf [open out.nam w]
#$ns namtrace-all $nf

#Define procedure to control max queue size
proc new_max_queue {} {
	global qmon max_queue
	#Get instance of simulator
	set ns [Simulator instance]
	#Set time after which procedure should be called again
	set time 0.1
	#Get instantaneous queue size in packets
	set inst_queue [$qmon set pkts_]
	#is inst_queue larger than max_queue?  if yes, set new value
	if {$inst_queue > $max_queue} {
		set max_queue $inst_queue
	}
	
	#Get current time
	set now [$ns now]
	#Re-schedule procedure
	$ns at [expr $now+$time] "new_max_queue"
}

#Define a 'finish' procedure
proc finish {} {
        global ns; # nf
	global qmon MAX_TIME max_queue
        #$ns flush-trace
	#Close the trace file
        #close $nf

	puts "Queue monitor:"
	puts [format "Arrivals          :  %7d (pkts)  %10d (bytes)" [eval $qmon set parrivals_] [eval $qmon set barrivals_]]
	puts [format "Drops             :  %7d (pkts)  %10d (bytes)" [eval $qmon set pdrops_] [eval $qmon set bdrops_]]
	set bytesInt [eval $qmon get-bytes-integrator]
	set pktsInt [eval $qmon get-pkts-integrator]
	set avg_queue_b [expr [$bytesInt set sum_]/$MAX_TIME]
	set avg_queue_p [expr [$pktsInt set sum_]/$MAX_TIME]
	puts [format "Average Queue Size:  %5.2f (pkts)  %8.2f (bytes)    [$pktsInt set sum_]" $avg_queue_p $avg_queue_b]
	puts "Max queue size    :  $max_queue (pkts)"
	#Execute nam on the trace file
        #exec nam out.nam &
        exit 0
}

#Create four nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#Create links between the nodes
$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n3 $n2 1Mb 10ms SFQ
#$ns queue-limit $n2 $n3 100

$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

#Monitor the queue for the link between node 2 and node 3
$ns duplex-link-op $n2 $n3 queuePos 0.5

#Create queue monitor
set qmon [$ns monitor-queue $n2 $n3 ""]

#Create a UDP agent and attach it to node n0
set udp0 [new Agent/UDP]
$udp0 set class_ 1
$ns attach-agent $n0 $udp0

# Create a CBR traffic source and attach it to udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

#Create a UDP agent and attach it to node n1
set udp1 [new Agent/UDP]
$udp1 set class_ 2
$ns attach-agent $n1 $udp1

# Create a CBR traffic source and attach it to udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 1000
$cbr1 set interval_ 0.005
$cbr1 attach-agent $udp1

#Create a Null agent (a traffic sink) and attach it to node n3
set null0 [new Agent/Null]
$ns attach-agent $n3 $null0

#Connect the traffic sources with the traffic sink
$ns connect $udp0 $null0  
$ns connect $udp1 $null0

#Schedule events for the CBR agents
$ns at 0.0 "new_max_queue"
$ns at 0.5 "$cbr0 start"
$ns at 1.0 "$cbr1 start"
$ns at $MAX_TIME "$cbr1 stop"
$ns at $MAX_TIME "$cbr0 stop"
#Call the finish procedure after $MAX_TIME seconds of simulation time
$ns at $MAX_TIME "finish"

#Run the simulation
$ns run


