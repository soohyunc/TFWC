# -*-	Mode:tcl; tcl-indent-level:8; tab-width:8; indent-tabs-mode:t -*-
#
#  Time-stamp: <2000-09-11 15:10:21 haoboy>
# 
#  Copyright (c) 2000 by the University of Southern California
#  All rights reserved.
# 
#  Permission to use, copy, modify, and distribute this software and its
#  documentation in source and binary forms for non-commercial purposes
#  and without fee is hereby granted, provided that the above copyright
#  notice appear in all copies and that both the copyright notice and
#  this permission notice appear in supporting documentation. and that
#  any documentation, advertising materials, and other materials related
#  to such distribution and use acknowledge that the software was
#  developed by the University of Southern California, Information
#  Sciences Institute.  The name of the University may not be used to
#  endorse or promote products derived from this software without
#  specific prior written permission.
# 
#  THE UNIVERSITY OF SOUTHERN CALIFORNIA makes no representations about
#  the suitability of this software for any purpose.  THIS SOFTWARE IS
#  PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES,
#  INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
# 
#  Other copyrights might apply to parts of this software and are so
#  noted when applicable.
# 
#  Original source contributed by Gaeil Ahn. See below.
#
#  $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/ns-2.28/tcl/mpls/ns-mpls-node.tcl,v 1.1.1.1 2005/05/08 22:37:14 soohyunc Exp $

###########################################################################
# Copyright (c) 2000 by Gaeil Ahn                                	  #
# Everyone is permitted to copy and distribute this software.		  #
# Please send mail to fog1@ce.cnu.ac.kr when you modify or distribute     #
# this sources.								  #
###########################################################################

#
# XXX MPLS is NOT compatible with hierarchical routing, because:
#
# 1) MPLS classifier is explicitly coupled with unicast address classifier,
#    which does not support hierarchical routing. The reason is MPLS needs 
#    to check whether a route update is an update, a new entry, or a 
#    "no change". This is not as straightforward and efficient when the 
#    MPLS classifier is decoupled from the unicast address classifier, because
#    through add-route{} interface, Node can only tell this module that a new
#    route is added, but not whether this is an update, a new entry, or 
#    a "no change". I don't have a clean solution yet. - haoboy
#
RtModule/MPLS instproc register { node } {
	$self instvar classifier_
	$self attach-node $node
	$node route-notify $self
	$node port-notify $self
        set classifier_ [new Classifier/Addr/MPLS]
        $classifier_ set-node $node $self
	$node install-entry $self $classifier_ 0
	$self attach-classifier $classifier_
}


#RtModule/MPLS instproc route-notify { module } { }

# Done common routing module interfaces. Now is our own processing.

RtModule/MPLS instproc enable-data-driven {} {
	[$self set classifier_] cmd enable-data-driven
}

RtModule/MPLS instproc enable-control-driven {} {
	[$self set classifier_] cmd enable-control-driven
}

RtModule/MPLS instproc make-ldp {} {
	set ldp [new Agent/LDP]
	$self cmd attach-ldp $ldp
	$ldp set-mpls-module $self
	[$self node] attach $ldp
	return $ldp
}

RtModule/MPLS instproc exist-fec {fec phb} {
        return [[$self set classifier_] exist-fec $fec $phb]
}

RtModule/MPLS instproc get-incoming-iface {fec lspid} {
        return [[$self set classifier_] GetInIface $fec $lspid]
}

RtModule/MPLS instproc get-incoming-label {fec lspid} {
        return [[$self set classifier_] GetInLabel $fec $lspid]
}

RtModule/MPLS instproc get-outgoing-label {fec lspid} {
        return [[$self set classifier_] GetOutLabel $fec $lspid]
}

RtModule/MPLS instproc get-outgoing-iface {fec lspid} {
        return [[$self set classifier_] GetOutIface $fec $lspid]
}

RtModule/MPLS instproc get-fec-for-lspid {lspid} {
        return [[$self set classifier_] get-fec-for-lspid $lspid]
}

RtModule/MPLS instproc in-label-install {fec lspid iface label} {
	set dontcare [Classifier/Addr/MPLS dont-care]
	$self label-install $fec $lspid $iface $label $dontcare $dontcare
}

RtModule/MPLS instproc out-label-install {fec lspid iface label} {
	set dontcare [Classifier/Addr/MPLS dont-care]
	$self label-install $fec $lspid $dontcare $dontcare $iface $label
}

RtModule/MPLS instproc in-label-clear {fec lspid} {
	set dontcare [Classifier/Addr/MPLS dont-care]
	$self label-clear $fec $lspid -1 -1 $dontcare $dontcare
}

RtModule/MPLS instproc out-label-clear {fec lspid} {
	set dontcare [Classifier/Addr/MPLS dont-care]
	$self label-clear $fec $lspid $dontcare $dontcare -1 -1
}

RtModule/MPLS instproc label-install {fec lspid iif ilbl oif olbl} {
        [$self set classifier_] LSPsetup $fec $lspid $iif $ilbl $oif $olbl
}

RtModule/MPLS instproc label-clear {fec lspid iif ilbl oif olbl} {
        [$self set classifier_] LSPrelease $fec $lspid $iif $ilbl $oif $olbl
}

RtModule/MPLS instproc flow-erlsp-install {fec phb lspid} {
        [$self set classifier_] ErLspBinding $fec $phb $lspid
}

RtModule/MPLS instproc erlsp-stacking {erlspid tunnelid} {
        [$self set classifier_] ErLspStacking -1 $erlspid -1 $tunnelid
}

RtModule/MPLS instproc flow-aggregation {fineFec finePhb coarseFec coarsePhb} {
        [$self set classifier_] FlowAggregation $fineFec $finePhb $coarseFec \
			$coarsePhb
}

RtModule/MPLS instproc enable-reroute {option} {
        $self instvar classifier_ 
        $classifier_ set enable_reroute_ 1
        if {$option == "drop"} {
		$classifier_ set reroute_option_ 0
        } elseif {$option == "L3"} {
		$classifier_ set reroute_option_ 1
        } elseif {$option == "new"} {
		$classifier_ set reroute_option_ 2
        } else {
		$classifier_ set reroute_option_ 0
	}
}

RtModule/MPLS instproc reroute-binding {fec phb lspid} {
        [$self set classifier_] aPathBinding $fec $phb -1 $lspid
}

RtModule/MPLS instproc lookup-nexthop {node fec} {
        set ns [Simulator instance]
        set routingtable [$ns get-routelogic]
        set nexthop [$routingtable lookup $node $fec]
        return $nexthop
}

RtModule/MPLS instproc get-nexthop {fec} {
	# find a next hop for fec
        set nodeid [[$self node] id]
        set nexthop [$self lookup-nexthop $nodeid $fec]
        return $nexthop
}

RtModule/MPLS instproc get-link-status {hop} {
	if {$hop < 0} {
		return "down"
	}
	set nexthop [$self get-nexthop $hop]
	if {$nexthop == $hop} {
		set status "up"
	} else {
		set status "down"
	}
	return $status
}

RtModule/MPLS instproc is-egress-lsr { fec } {
        # Determine whether I am a egress-lsr for fec. 
        if { [[$self node] id] == $fec } {
		return  "1"
        }
        set nexthopid [$self get-nexthop $fec]
        if { $nexthopid < 0 } {
		return "-1"
        }
        set nexthop [[Simulator instance] get-node-by-id $nexthopid]
	if { [$nexthop get-module "MPLS"] == "" } {
		return  "1"
        } else {
		return  "-1"
        }
}

# distribute labels based on routing protocol
RtModule/MPLS instproc ldp-trigger-by-routing-table {} {
        if { [[$self set classifier_] cmd control-driven?] != 1 } {
		return
        }
        set ns [Simulator instance]
	for {set i 0} {$i < [$ns get-number-of-nodes]} {incr i} {
		# select a node
		set host [$ns get-node-by-id $i]
		if { [$self is-egress-lsr [$host id]] == 1 } {
			# distribute label
			$self ldp-trigger-by-control [$host id] *
		}
        }
}

RtModule/MPLS instproc ldp-trigger-by-control {fec pathvec} {
	lappend pathvec [[$self node] id]
	set inlabel [$self get-incoming-label $fec -1]
	set nexthop [$self get-nexthop $fec]
	set ldpagents [lsort [$self get-ldp-agents]]
	for {set i 0} {$i < [llength $ldpagents]} {incr i 1} {
		set ldpagent [lindex $ldpagents $i]
		if { [$ldpagent peer-ldpnode] == $nexthop } {
			continue
		}
		if { $inlabel == -1 } {
			if { [$self is-egress-lsr $fec] == 1 } {
				# This is egress LSR
				set inlabel 0
			} else {
				set inlabel [$self new-incoming-label]
				$self in-label-install $fec -1 -1 $inlabel
			}
		}
		$ldpagent new-msgid
		$ldpagent send-mapping-msg $fec $inlabel $pathvec -1
	}
}

RtModule/MPLS instproc ldp-trigger-by-data {reqmsgid src fec pathvec} {
	if { [$self is-egress-lsr $fec] == 1 } {
		# This is a egress node
		return
	}
	set outlabel [$self get-outgoing-label $fec -1]
	if { $outlabel > -1  } {
		# reroute check !! to establish altanative path
		set outiface [$self get-outgoing-iface $fec -1]
		if { [$self get-link-status $outiface] == "up" } {
			# LSP was already setup
			return
		}
	}
	lappend pathvec [[$self node] id]      
	set nexthop [$self get-nexthop $fec]
	set ldpagent [$self get-ldp-agent $nexthop]
	if { $ldpagent == "" } {
		return
	}
	if {$reqmsgid > -1} {
		# on-demand mode
		set working [$ldpagent msgtbl-get-msgid $fec -1 $src]
		if { $working < 0 } {
			# have to make new request-msg
			set newmsgid [$ldpagent new-msgid]
			$ldpagent msgtbl-install $newmsgid $fec -1 \
					$src $reqmsgid
			$ldpagent send-request-msg $fec $pathvec
		} else {
			# $self is already tring to setup a LSP
			# So, need not to send a request-msg
		}
	} else {
		# not on-demand mode
		if {$fec == $nexthop} {
			# This is a penultimate hop
			set outlabel 0
		} else {
			set outlabel [$self new-outgoing-label]
		}
		$self out-label-install $fec -1 $nexthop $outlabel
		$ldpagent new-msgid
		$ldpagent send-mapping-msg $fec $outlabel $pathvec -1
	}
}

RtModule/MPLS instproc make-explicit-route {fec er lspid rc} {
	$self ldp-trigger-by-explicit-route -1 [[$self node] id] $fec "*" \
			$er $lspid $rc
}

RtModule/MPLS instproc ldp-trigger-by-explicit-route {reqmsgid src fec \
		pathvec er lspid rc} {
	$self instvar classifier_
	set outlabel [$self get-outgoing-label $fec $lspid]
	if { $outlabel > -1 } {
		# LSP was already setup
		return
	}
	if { [[$self node] id] != $src && [[$self node] id] == $fec } {
		# This is a egress node
		set ldpagent [$self get-ldp-agent $src]
		if { $ldpagent != "" } {
			$ldpagent new-msgid
			$ldpagent send-cr-mapping-msg $fec 0 $lspid $reqmsgid
		}
		return
	}
	lappend pathvec [[$self node] id]
	set er [split $er "_"]
	set erlen [llength $er]
	for {set i 0} {$i <= $erlen} {incr i 1} {
		if { $i != $erlen } {
			set erhop [lindex $er $i]
		} else {
			set erhop $fec
		}
		set stackERhop -1
		if { $erhop >= [Classifier/Addr/MPLS minimum-lspid] } {
			# This is the ER-Hop and LSPid (ER-LSP)
			set lspidFEC [$self get-fec-for-lspid $erhop]
			set inlabel  [$self get-incoming-label -1 $erhop]
			set outlabel [$self get-outgoing-label -1 $erhop]
			if { $lspidFEC == $fec } {
				# splice two LSPs
				if { $outlabel <= -1 } {
					continue
				}
				if { $inlabel < 0 } {
					set inlabel [$self new-incoming-label]
					$self in-label-install -1 $erhop \
						$src $inlabel
				}
				set ldpagent [$self get-ldp-agent $src]
				$ldpagent new-msgid
				$ldpagent send-cr-mapping-msg $fec $inlabel \
						$lspid $reqmsgid
				return
			}
			# $lspidFEC != $fec
			# do stack operation
			set existExplicitPeer [$self exist-ldp-agent $lspidFEC]
			if { $outlabel > -1 && $existExplicitPeer == "1" } {
				set stackERhop $erhop 
				set erhop $lspidFEC
			} elseif { $outlabel > -1 && $existExplicitPeer == "0" } {
				set nexthop [$self get-outgoing-iface -1 \
						$erhop]
				set iiface  [$self get-incoming-iface -1 \
						$erhop]
				set ldpagent [$self get-ldp-agent $nexthop]
				set working [$ldpagent msgtbl-get-msgid $fec \
						$lspid $src]
				if { $working < 0 } {
					# have to make new request-msg
					set newmsgid [$ldpagent new-msgid]
					$ldpagent msgtbl-install $newmsgid \
						$fec $lspid $src $reqmsgid
					# determine whether labelpass or 
					# labelstack
					if {($iiface == $src) && \
							($inlabel > -1) } {
						$ldpagent msgtbl-set-labelpass $newmsgid
					} else {
						$ldpagent msgtbl-set-labelstack $newmsgid $erhop
					}
					$ldpagent send-cr-request-msg $fec \
							$pathvec $er $lspid $rc
				}
				return
			} else {
				continue
			}
		}
		if { [lsearch $pathvec $erhop] < 0 } {
			set nexthop [$self get-nexthop $erhop]
			if { [$self is-egress-lsr $nexthop] == 1 } {
				# not exist MPLS-node to process a required 
				# er-LSP
				set ldpagent [$self get-ldp-agent $src]
				if { $erhop == $fec } {
					# This is a final node
					$ldpagent new-msgid
					$ldpagent send-cr-mapping-msg $fec 0 \
							$lspid $reqmsgid
				} else {
					# be a wrong er list
					$ldpagent new-msgid
					$ldpagent send-notification-msg \
							"NoRoute" $lspid
				}
			} else {
				set ldpagent [$self get-ldp-agent $nexthop]
				set working [$ldpagent msgtbl-get-msgid $fec \
						$lspid $src]
				if { $working < 0 } {
					# have to make new request-msg
					set newmsgid [$ldpagent new-msgid]
					set id [$ldpagent msgtbl-install \
							$newmsgid $fec \
							$lspid $src $reqmsgid]
					## for label stack
					if { $stackERhop > -1 } {
						$ldpagent msgtbl-set-labelstack $newmsgid $stackERhop
					}
					$ldpagent send-cr-request-msg $fec $pathvec $er $lspid $rc
				}
			} 
			return
		}
	}
	set ldpagent [$self get-ldp-agent $src]
	if { $ldpagent != "" } {
		$ldpagent new-msgid
		$ldpagent send-notification-msg "NoRoute" $lspid
	}
}

RtModule/MPLS instproc ldp-trigger-by-withdraw {fec lspid} {
	set inlabel  [$self get-incoming-label $fec $lspid]
	set iniface  [$self get-incoming-iface $fec $lspid]

	$self in-label-clear $fec $lspid
	
	if {$iniface > -1} {
		set ldpagent [$self get-ldp-agent $iniface]
		if { $ldpagent != "" } {
			$ldpagent new-msgid
			$ldpagent send-withdraw-msg $fec $lspid
		}
	} else {
		# several upstream nodes may share a label.
		# so inform all upstream nodes to withdraw the label
		set nexthop [$self get-nexthop $fec]
		set ldpagents [lsort [$self get-ldp-agents]]
		for {set i 0} {$i < [llength $ldpagents]} {incr i 1} {
			set ldpagent [lindex $ldpagents $i]
			if { [$ldpagent peer-ldpnode] == $nexthop } {
				continue
			}
			$ldpagent new-msgid
			$ldpagent send-withdraw-msg $fec $lspid
		}
	}   
}

RtModule/MPLS instproc ldp-trigger-by-release {fec lspid} {
	set outlabel  [$self get-outgoing-label $fec $lspid]
	if {$outlabel < 0} {
		return
	}
	set nexthop [$self get-outgoing-iface $fec $lspid]
	$self out-label-clear $fec $lspid 
	set ldpagent [$self get-ldp-agent $nexthop]
	if { $ldpagent != "" } {
		$ldpagent new-msgid
		$ldpagent send-release-msg $fec $lspid
	}   
}

# Debugging

RtModule/MPLS instproc trace-mpls {} {
        [$self set classifier_] set trace_mpls_ 1
}

RtModule/MPLS instproc pft-dump {} {
        # dump the records within Partial Forwarding Table(PFT)
        set nodeid [[$self node] id]
        [$self set classifier_] PFTdump $nodeid
}

RtModule/MPLS instproc erb-dump {} {
        # dump the records within Explicit Route information Base(ERB)
        set nodeid [[$self node] id]
        [$self set classifier_] ERBdump $nodeid
}

RtModule/MPLS instproc lib-dump {} {
        # dump the records within Label Information Base(LIB)
        set nodeid [[$self node] id]
        [$self set classifier_] LIBdump $nodeid
}


