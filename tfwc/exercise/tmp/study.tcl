#Create simulator object
set ns [new Simulator]
set MAX_TIME 100; #set maximum simulation time

#Use dinamic routing
$ns rtproto DV

#Open files for trace
set nf [open out.nam w]
set tr [open out.tr w]
set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f2 [open out2.tr w]
set f3 [open out3.tr w]
$ns namtrace-all $nf
$ns trace-all $tr

#Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

#Connect nodes
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 3Mb 10ms DropTail
$ns duplex-link $n2 $n4 3Mb 10ms DropTail
$ns duplex-link $n2 $n5 3Mb 10ms DropTail
$ns duplex-link $n6 $n2 3Mb 10ms DropTail
$ns duplex-link $n2 $n7 3Mb 10ms DropTail
$ns duplex-link $n0 $n5 3Mb 10ms DropTail

#Set visual orientation for nam
$ns duplex-link-op $n0 $n1 queuePos 0.5
$ns duplex-link-op $n1 $n2 queuePos 0.5
$ns duplex-link-op $n2 $n3 queuePos 0.5
$ns duplex-link-op $n2 $n4 queuePos 0.5
$ns duplex-link-op $n2 $n5 queuePos 0.5
$ns duplex-link-op $n6 $n2 queuePos 0.5
$ns duplex-link-op $n2 $n7 queuePos 1.5
$ns duplex-link-op $n0 $n5 queuePos 0.5

$ns duplex-link-op $n0 $n1 orient up
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n2 $n4 orient right-up
$ns duplex-link-op $n2 $n5 orient down
$ns duplex-link-op $n2 $n6 orient up
$ns duplex-link-op $n2 $n7 orient right-down
$ns duplex-link-op $n0 $n5 orient right

#Create null agent (sink)
set sink0 [new Agent/LossMonitor]
set sink1 [new Agent/LossMonitor]
set sink2 [new Agent/LossMonitor]
set sink3 [new Agent/LossMonitor]
$ns attach-agent $n3 $sink0
$ns attach-agent $n4 $sink1
$ns attach-agent $n0 $sink2
$ns attach-agent $n7 $sink3

#Create queue monitors
set qmon0 [$ns monitor-queue $n0 $n1 ""]
set qmon1 [$ns monitor-queue $n1 $n2 ""]
set qmon2 [$ns monitor-queue $n2 $n3 ""]
set qmon3 [$ns monitor-queue $n2 $n4 ""]
set qmon4 [$ns monitor-queue $n2 $n5 ""]
set qmon5 [$ns monitor-queue $n2 $n6 ""]
set qmon6 [$ns monitor-queue $n2 $n7 ""]
set qmon7 [$ns monitor-queue $n0 $n5 ""]

#Procedure exponential traffic generator
proc attach-expoo-traffic { node sink size burst idle rate class color} {
        
	#get simulator instance
	set ns [Simulator instance]

        #Create UDP agent and attach it to the node
	set source [new Agent/UDP]
        $ns attach-agent $node $source
        $source set class_ $class
        $ns color $class $color

        #Create Expoo traffic agent and set its configuration parameters
	set traffic [new Application/Traffic/Exponential]
        $traffic set packetSize_ $size
        $traffic set burst_time_ $burst
        $traffic set idle_rate_ $rate
        $traffic set rate_ $rate

        #Attach traffic source to traffic generator
	$traffic attach-agent $source
        #Connect source and sink
	$ns connect $source $sink
        return $traffic
}

#Create exponential generators
set traffgen0 [attach-expoo-traffic $n0 $sink0 3000 800ms 2ms 5M 1 Green]
set traffgen1 [attach-expoo-traffic $n2 $sink1 8000 250ms 50ms 6M 2 Blue]
set traffgen2 [attach-expoo-traffic $n5 $sink2 3000 300ms 50ms 3M 3 White]
set traffgen3 [attach-expoo-traffic $n6 $sink3 3000 200ms 50ms 2M 4 Yellow]

#Create xgraph record procedure
proc record {} {
	global sink0 sink1 sink2 sink3 f0 f1 f2 f3
	#Get instance of simulator
	set ns [Simulator instance]
	#Set time after which procedure should be called again
	set time 0.5
	#How many bytes have been received by traffic sinks?
	set bw0 [$sink0 set bytes_]
	set bw1 [$sink1 set bytes_]
	set bw2 [$sink2 set bytes_]
	set bw3 [$sink3 set bytes_]
	#Get current time
	set now [$ns now]
	#Calculate bandwidth (MBit/s) and write to files
	puts $f0 "$now [expr $bw0/$time*8/1000000]"
	puts $f1 "$now [expr $bw1/$time*8/1000000]"
	puts $f2 "$now [expr $bw2/$time*8/1000000]"
	puts $f3 "$now [expr $bw3/$time*8/1000000]"
	#Reset bytes_ values on traffic sinks
	$sink0 set bytes_ 0
	$sink1 set bytes_ 0
	$sink2 set bytes_ 0
	$sink3 set bytes_ 0
	#Re-schedule procedure
	$ns at [expr $now+$time] "record"
}

#Schedule
$ns at 0.0 "record"
#$ns rtmodel-at 3.0 down $n0 $n5
#$ns rtmodel-at 6.0 up $n0 $n5
#$ns rtmodel-at 3.0 down $n2 $n3
#$ns rtmodel-at 5.0 up $n2 $n3
$ns at 0.0 "puts \"Simulation Start...\""
$ns at 0.0 "$traffgen0 start"
$ns at 0.0 "$traffgen1 start"
$ns at 0.0 "$traffgen2 start"
$ns at 0.0 "$traffgen3 start"
$ns at $MAX_TIME "$traffgen0 stop"
$ns at $MAX_TIME "$traffgen1 stop"
$ns at $MAX_TIME "$traffgen2 stop"
$ns at $MAX_TIME "$traffgen3 stop"
$ns at $MAX_TIME "finish"

#Finish procedure
proc finish {} {
	global ns nf tr f0 f1 f2 f3 
	global qmon0 qmon1 qmon2 qmon3 qmon4 qmon5 qmon6 qmon7
	global MAX_TIME
	$ns flush-trace
	#close trace files
	close $nf
	close $tr
	close $f0
	close $f1
	close $f2
	close $f3
	
	puts "End Simulation.  Simulation Time:  $MAX_TIME s"
	puts "                                 ====="	
		
	puts "\nStats:"  
	puts "                          Arrived                Lost               Departed"
	puts "                    Packets      Bytes    Packets     Bytes     Packets     Bytes"
	puts "-----------------------------------------------------------------------------------"
	
	set j 0
	foreach i {$qmon0 $qmon1 $qmon2 $qmon3 $qmon4 $qmon5 $qmon6 $qmon7} {
		incr j
		puts -nonewline [format "Queue Monitor $j:   %7d   %10d" [eval $i set parrivals_] [eval $i set barrivals_]]
		puts -nonewline [format "  %7d   %10d" [eval $i set pdrops_] [eval $i set bdrops_]]
		puts [format "  %7d   %10d" [eval $i set pdepartures_] [eval $i set bdepartures_]]	
	}

	puts "\nAverage Queue Size:        Packets         Bytes    sum_ (pkts)"
	puts "-----------------------------------------------------------------------"
	
	set j 0
	foreach i {$qmon0 $qmon1 $qmon2 $qmon3 $qmon4 $qmon5 $qmon6 $qmon7} {
		incr j
		set bytesInt($j) [eval $i get-bytes-integrator]
		set pktsInt($j) [eval $i get-pkts-integrator]
		set avg_queue_b($j) [expr [$bytesInt($j) set sum_]/$MAX_TIME]
		set avg_queue_p($j) [expr [$pktsInt($j) set sum_]/$MAX_TIME]
		puts [format "           Queue $j:          %5.2f      %8.2f    [$pktsInt($j) set sum_]" $avg_queue_p($j) $avg_queue_b($j)]
	}

	puts -nonewline "\nQueue 1:  0 -> 1"
	puts "    Queue 2:  1 -> 2"
	puts -nonewline "Queue 3:  2 -> 3"	
	puts "    Queue 4:  2 -> 4"
	puts -nonewline "Queue 5:  2 -> 5"
	puts "    Queue 6:  2 -> 6"
	puts -nonewline "Queue 7:  2 -> 7"
	puts "    Queue 8:  0 -> 5"
	exec nam out.nam &
	#exec xgraph out0.tr out1.tr out2.tr out3.tr -geometry 800x600 &
	exit 0
}

$ns run

















