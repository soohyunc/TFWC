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

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <math.h>
#include "tfwc-sink.h"
#include "flags.h"

static class TfwcSinkClass : public TclClass {
public:
	TfwcSinkClass() : TclClass("Agent/TFWCSink") {}
	TclObject* create(int, const char*const*) {
		return (new TfwcSinkAgent());
	}
} class_tfwcSink;

TfwcSinkAgent::TfwcSinkAgent() : Agent(PT_TFWC_ACK), 
	seqno_(0), ackpktSize_(40) 
{
}

/*
 * TFWC Sink Main Reception Path
 */
void TfwcSinkAgent::recv(Packet* pkt, Handler*) {
	hdr_tfwc *tfwch = hdr_tfwc::access(pkt);

	// acking
	last_ts_ = tfwch->ts_;			// for ts_ echoing
	seqno_ = tfwch->seqno_;			// data packet's ackno_ 
	ackofack_ = tfwch->ackofack_;	// ack of ack
	//printf("\n (data receiver) received seqno from sender: %d\n", seqno_);

	/*
	 * building up an ack vector
	 */
	ackvec_.ackv_insert_head(seqno_);

	/*
	 * deleting an item that has been acknowledged by the data sender
	 */
	//printf(" (data receiver) ackofack_ = %d\n", ackofack_);
	ackvec_.ackv_del(ackofack_);

	ack();	// sending an ack message
	Packet::free(pkt);
}

int TfwcSinkAgent::command(int argc, const char*const* argv)
{
	//printf(" argv[1] = %s\n", argv[1]);
	if (argc == 2) {
		if (strcmp(argv[1], "reset") == 0) {
			/* 
			 * XXX if ack() is uncommented here, then tfwcAck will be 
			 * the first packet in the transmission, which is weird.
			 */ 
			//ack(pkt);
			return TCL_OK;
		}
		if (strcmp(argv[1], "resize_buffers") == 0) {
			return TCL_OK;
		}       
	}
	return (Agent::command(argc, argv));
}

/*
 * Sending an ACK
 */
void TfwcSinkAgent::ack() {

	Packet* pkt = allocpkt();
	hdr_tfwc_ack *tfwcah = hdr_tfwc_ack::access(pkt);
	hdr_cmn *cmnh = hdr_cmn::access(pkt);
	cmnh->size_ = ackpktSize_;	// ack packet size

	// timestamp echo
	tfwcah->ts_echo_ = last_ts_;	// last_ts_ is defined at recv()

	// update ackno
	tfwcah->ackno_ = seqno_;
	//printf(" (data receiver) sending an ack for: %d\n", tfwcah->ackno_);

	// building an ack vector
	tfwcah->tfwcAV.ackv_clone(&ackvec_);

	// printing tfwcAV contents
	//printf(" (data receiver)");
	//tfwcah->tfwcAV.ackv_print();

	// sending an ack
	send(pkt, 0);
}
