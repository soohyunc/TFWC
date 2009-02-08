# Copyright (c) 1999 by the University of Southern California
# All rights reserved.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation in source and binary forms for non-commercial purposes
# and without fee is hereby granted, provided that the above copyright
# notice appear in all copies and that both the copyright notice and
# this permission notice appear in supporting documentation. and that
# any documentation, advertising materials, and other materials related
# to such distribution and use acknowledge that the software was
# developed by the University of Southern California, Information
# Sciences Institute.  The name of the University may not be used to
# endorse or promote products derived from this software without
# specific prior written permission.
#
# THE UNIVERSITY OF SOUTHERN CALIFORNIA makes no representations about
# the suitability of this software for any purpose.  THIS SOFTWARE IS
# PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
# Other copyrights might apply to parts of this software and are so
# noted when applicable.
#
# Event tracing support for 802.11
#   developed by Sushmita Aggarwal Singal (singal@nunki.usc.edu)

Mac/802_11 set debug_ false
Mac/802_11 instproc init {} {
	eval $self next
	set ns [Simulator instance]
	$ns create-eventtrace Event $self
}
