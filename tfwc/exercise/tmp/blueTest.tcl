
# Yoon, Hyoup Sang Jan-25-2003



set AQM [lindex $argv 0] 
set initNum [lindex $argv 1]
set addNum [lindex $argv 2]
set b_rtt [lindex $argv 3]

#set AppType [lindex $argv 4]

set times 10
set btlnck 3
set link 10
set b_qsize 30
set stopTime 150

Queue set limit_ 50
Application/Telnet set interval_ 1
Agent/TCP set ecn_ 1

if {"$AQM" == "B"} {
	Queue/BLUE1 set iholdtime_ 0.01
	Queue/BLUE1 set dholdtime_ 0.01 
	Queue/BLUE1 set linterm_ 100
	Queue/BLUE1 set setbit_ 1 
	Queue/BLUE1 set limit_b_ 20 
	Queue/BLUE1 set limit_b_low_ 0 
	Queue/BLUE1 set increment_ 0.002
	Queue/BLUE1 set decrement_ 0.002 
	Queue/BLUE1 set dalgorithm_ 0
	Queue/BLUE1 set ialgorithm_ 0
	
	set AQM BLUE1
	
}

if {"$AQM" == "R"} {
	Queue/RED set setbit_ 1
	Queue/RED set adaptive_ 1
	Queue/RED set linterm_ 10
	Queue/RED set thresh_ 0
	Queue/RED set maxthresh_ 0
	set AQM RED
}


set ns [new Simulator]


#Define different colors for data flows
$ns color 1 Blue
$ns color 2 Red


#Pareto Traffic setting
#if {"$AppType" == "P"} {
#Application/Traffic/Pareto set burst_time_ 2s
#Application/Traffic/Pareto set idle_time_ 3s
#Application/Traffic/Pareto set rate_ 50KB
#Application/Traffic/Pareto set packetSize_ 1KB
#Application/Traffic/Pareto set shape_ 1.5
#set AppType Traffic/Pareto
#}



# Open the NAM trace file
#set nf [open out.nam w]
#$ns namtrace-all $nf

# Open the trace file
#set nt [open out.tr w]
#$ns trace-all $nt



# source host
set node_(s0) [$ns node]
set node_(s1) [$ns node]
set node_(s2) [$ns node]
set node_(s3) [$ns node]
set node_(s4) [$ns node]

#router
set node_(r0) [$ns node]
set node_(r1) [$ns node]

# destination host
set node_(d0) [$ns node]
set node_(d1) [$ns node]
set node_(d2) [$ns node]
set node_(d3) [$ns node]
set node_(d4) [$ns node]


$ns duplex-link $node_(s0) $node_(r0) ${link}Mb 3ms DropTail 
$ns duplex-link $node_(s1) $node_(r0) ${link}Mb 5ms DropTail 
$ns duplex-link $node_(s2) $node_(r0) ${link}Mb 7ms DropTail
$ns duplex-link $node_(s3) $node_(r0) ${link}Mb 9ms DropTail
$ns duplex-link $node_(s4) $node_(r0) ${link}Mb 11ms DropTail

$ns duplex-link $node_(r0) $node_(r1) ${btlnck}Mb ${b_rtt}ms $AQM 
$ns queue-limit $node_(r0) $node_(r1) $b_qsize 
$ns queue-limit $node_(r1) $node_(r0) $b_qsize 

$ns duplex-link $node_(d0) $node_(r1) ${link}Mb 3ms DropTail 
$ns duplex-link $node_(d1) $node_(r1) ${link}Mb 5ms DropTail 
$ns duplex-link $node_(d2) $node_(r1) ${link}Mb 7ms DropTail 
$ns duplex-link $node_(d3) $node_(r1) ${link}Mb 9ms DropTail 
$ns duplex-link $node_(d4) $node_(r1) ${link}Mb 11ms DropTail 


proc setMonitor {node1 node2} {
	global ns
	set slink [$ns link $node1 $node2]; # link to collect stats on
	set fmon [$ns makeflowmon Fid]
	$ns attach-fmon $slink $fmon
	set squeue [$slink queue]
	return $fmon
}

set fmon [ setMonitor $node_(r0) $node_(r1) ]

proc printall { fmon stoptime rate } {
    set drops [ $fmon set pdrops_ ]
	set bytes [ $fmon set bdepartures_ ]
	set pkts [ $fmon set pdepartures_ ]
	set totalbytes [ expr $stoptime * $rate / 8 ]
        set fracbytes [ expr 100 * $bytes / $totalbytes ]
        #puts "aggregate per-link total_drops $drops"
        #puts "aggregate per-link total_packets $pkts"
	puts "aggregate per-link drops(%) [ expr 100.0*$drops/($pkts+$drops) ]"
    	#puts "aggregate per-link total_bytes $bytes"
		#puts "aggregate per-link totalbytes $totalbytes"
	puts "aggregate per-link throughput(%) [ expr 100.0 * ( $bytes / 1000000 ) / $totalbytes ]"
}

# node_(s) --> node_(d) pareto


# Random Number Generation
set rng [new RNG]
$rng seed 3


for {set i 0} {$i < $initNum} {incr i} {
	set host_s [$rng integer 5]
	set host_d [$rng integer 5]
	set tcpi [$ns create-connection TCP/Reno $node_(s${host_s}) TCPSink $node_(d${host_d}) $i]
	set traffic_i [$tcpi attach-app FTP]
	set time [$rng uniform 0 2]
	$ns at $time "$traffic_i start"
	for {set j 0} {$j < $times} {incr j} {
		set host_s [$rng integer 5]
		set host_d [$rng integer 5]
		set tcpi [$ns create-connection TCP/Reno $node_(s${host_s}) TCPSink $node_(d${host_d}) $i]
		set traffic_i [$tcpi attach-app Telnet]
		set time [$rng uniform 0 2]
		$ns at $time "$traffic_i start"
	}
}

for {set i 0} {$i < $addNum} {incr i} {
	set host_s [$rng integer 5]
	set host_d [$rng integer 5]
	set tcpi [$ns create-connection TCP/Reno $node_(s${host_s}) TCPSink $node_(d${host_d}) $i]
	set traffic_i [$tcpi attach-app FTP]
	set time [$rng uniform 40 42]
	$ns at $time "$traffic_i start"
	set time [expr $time + 20]
	$ns at $time "$traffic_i stop"
	for {set j 0} {$j < $times} {incr j} {
		set tcpi [$ns create-connection TCP/Reno $node_(s${host_s}) TCPSink $node_(d${host_d}) $i]
		set traffic_i [$tcpi attach-app Telnet]
		set time [$rng uniform 40 42]
		$ns at $time "$traffic_i start"
		set time [expr $time + 20]
		$ns at $time "$traffic_i stop"
	}
}





# Tracing a queue
set redq1 [[$ns link $node_(r0) $node_(r1)] queue]
set tchan_ [open all.q w]

if {$AQM == "RED"} {
	$redq1 trace ave_
}

$redq1 trace curq_
$redq1 trace prob1_
$redq1 attach $tchan_


$ns at $stopTime "printall $fmon $stopTime $btlnck"
$ns at $stopTime "finish"

# Define 'finish' procedure (include post-simulation processes)
proc finish {} {
    global tchan_  
#    global nf nt 
    global ns AQM initNum addNum b_rtt stopTime
    $ns flush-trace
    set awkCode {
	{
	    if ($1 == "Q" && NF>2) {
		print $2, $3 >> "temp.q";
		set end $2
	    }
	    else if ($1 == "p" && NF>2)
	    print $2, $3 >> "temp.p";
	    
	    else if ($1 == "a" && NF>2)
	    print $2, $3 >> "temp.a";

    }
    }
    
    set awkCode2 {
    {
    	dif = $2 - old2
    	if (dif==0) {
    		dif = 1
    	} 
    	if (dif > 0) {
    		printf ("%d\t%f\n", $2, ($1 - old1) / dif)
    		old1 = $1
    		old2 = $2
    	}
    }
    }
    		
    set f [open temp.queue w]
    set f1 [open temp.curp w]
    puts $f "TitleText: $AQM I:$initNum A:$addNum R:$b_rtt"
    puts $f1 "TitleText: $AQM I:$initNum A:$addNum R:$b_rtt"
    puts $f "Device: Postscript"
    puts $f1 "Device: Postscript"
    
    if { [info exists tchan_] } {
		close $tchan_ 
    }

    
    if {$AQM == "RED"} {
    exec rm -f temp.q temp.a temp.p 
    exec touch temp.p temp.a temp.q
    
    exec awk $awkCode all.q

set result [ open temp.q r ]
set q_avg [ new Integrator ]
while { [ gets $result line ] >= 0 } {
	scan $line "%f %f" x y
	$q_avg newpoint $x $y
}
close $result
set q_size [ $q_avg set sum_ ]
set q_size [ expr $q_size / $stopTime ]
puts "average queue size $q_size"


    puts $f \"queue
    exec cat temp.q >@ $f 
    puts $f \n"ave_queue
    exec cat temp.a >@ $f 
    puts $f1 \"prob
    exec cat temp.p >@ $f1
    }
    
    if {$AQM == "BLUE1"} {
    exec rm -f temp.q temp.p 
    exec touch temp.p temp.q
    
    exec awk $awkCode all.q
    
#Computation Average queue    
set result [ open temp.q r ]
set q_avg [ new Integrator ]
while { [ gets $result line ] >= 0 } {
	scan $line "%f %f" x y
	$q_avg newpoint $x $y
}
close $result
set q_size [ $q_avg set sum_ ]
set q_size [ expr $q_size / $stopTime ]
puts "average queue size $q_size"

    puts $f \"queue
    exec cat temp.q >@ $f 
    puts $f1 \"prob
    exec cat temp.p >@ $f1
	}
	
    close $f
    close $f1
#    close $nf
#    close $nt

#    exec nam out.nam &
#    exec cat out.tr | grep " 3 4 tcp " | grep ^r | ./column 1 10 | awk $awkCode2 > jitter.txt
    exec xgraph -bb -tk -x time -y queue temp.queue &
    exec xgraph -bb -tk -x time -y prob temp.curp &
#    exec xgraph -bb -tk -x time -y jitter jitter.txt &  
    exit 0
}

$ns run
