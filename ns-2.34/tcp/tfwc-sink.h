/*
 * Copyright(c) 2003-2010 University College London
 * All rights reserved.
 *
 * AUTHOR: Soo-Hyun Choi <s.choi@cs.ucl.ac.uk>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University nor of the Laboratory may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * $Id$
 */

#ifndef ns_tfwc_sink_h
#define ns_tfwc_sink_h

#include "agent.h"
#include "packet.h"
#include "ip.h"
#include "timer-handler.h"
#include "random.h"
#include "tfwc.h"

/*
 * TFWC Sink Agent Class
 */
class TfwcSinkAgent : public Agent {
public:
	TfwcSinkAgent();
	int command(int argc, const char* const* argv);
	virtual void recv(Packet*, Handler*);

protected:
	AckVec ackvec_;		// real ack vector

	// sending an ack
	void ack();

	int seqno_;			// pkt seqno that the receiver has just got
	int ackpktSize_;	// ack packet size
	int nextpkt_;		// expected pkt sequence number
	double last_ts_;	// timestamp of last new, in-order pkt arrival
	int ackofack_;		// ack of ack
};
#endif
