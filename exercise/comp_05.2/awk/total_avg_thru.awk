#
# Copyright(c) 2005-2008 University College London
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

# average throughput = (total bits received) / (total simulation time)

BEGIN {
	tcp_bits	= 0;
	tfrc_bits	= 0;
	tfwc_bits	= 0;

	cutoff	= ARGV[1];
	t_sim	= ARGV[2] - ARGV[1];

	printf "" > "trace/tcp_thru_tot.dat";
	printf "" > "trace/tfrc_thru_tot.dat";
    printf "" > "trace/tfwc_thru_tot.dat";
}
                                                                                
{
	if (($1 == "r" && $5 == "tcp") && $2 > cutoff) {
		tcp_bits = tcp_bits + $6*8;
	}

    if (($1 == "r" && $5 == "tcpFriend") && $2 > cutoff) {
		tfrc_bits = tfrc_bits + $6*8;
    }

    if (($1 == "r" && $5 == "TFWC") && $2 > cutoff) {
		tfwc_bits = tfwc_bits + $6*8;
    }


}
                                                                                
END {
	tcp_thru = tcp_bits / t_sim;
	tfrc_thru = tfrc_bits / t_sim;
	tfwc_thru = tfwc_bits / t_sim;

	printf("%d\n", tcp_thru) >> "trace/tcp_thru_tot.dat";
	printf ("%d\n", tfrc_thru) >> "trace/tfrc_thru_tot.dat";
	printf ("%d\n", tfwc_thru) >> "trace/tfwc_thru_tot.dat";
}
