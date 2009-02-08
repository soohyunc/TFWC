#
# Copyright(c) 2005-2007 University College London
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright 
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright 
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the
#    distribution.
#
# 3. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE
#
# $Id$

# Pattern findingg and Throughput calculation
# (Find an outgoing packet from the queue at a bottleneck node)

BEGIN {
	granul = 0.5;
	bits = 0;
	last_bits = 0;
	cutoff = ARGV[1];
	time = 0;

	printf "" > "trace/tfwc_thru.xg";
}

{
	if ($1 == "r" && $5 == "TFWC") {
		bits = bits + $6*8;

		if (($2 - time) > granul) {
			time = time + granul;
			rate = ((bits-last_bits)/1000000)/granul;

			if ($2 > cutoff) 
				print time, rate >> "trace/tfwc_thru.xg";

			last_bits = bits;
		}

		while (($2 - time) > 2* granul) {

			if ($2 > cutoff) 
				print time, 0 >> "trace/tfwc_thru.xg";

			bits = 0;
			last_bits = 0;
			time = time + granul;
		}
	}
}

END {
	}

