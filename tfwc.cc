/*
 * Copyright(c) 2003-2009 University College London.  
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
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *      This product includes software developed by the Computer Systems
 *      Engineering Group at Lawrence Berkeley Laboratory.
 * 4. Neither the name of the University nor of the Laboratory may be used
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

#include <stdlib.h>
#include <math.h>
#include <sys/types.h>
#include <iostream>
#include <assert.h>
#include "basetrace.h"
#include "tfwc.h"

int hdr_tfwc::offset_;          // header offset
int hdr_tfwc_ack::offset_;      // header offset of an ACK

/*
 * OTcl linkage for packet headers
 */
static class TFWCHeaderClass : public PacketHeaderClass {
public:
	TFWCHeaderClass() : PacketHeaderClass ("PacketHeader/TFWC", 
			sizeof(hdr_tfwc)){
		bind_offset(&hdr_tfwc::offset_);
	}
} class_tfwchdr;

static class TFWC_ACKHeaderClass : public PacketHeaderClass {
public:
	TFWC_ACKHeaderClass() : PacketHeaderClass ("PacketHeader/TFWC_ACK", 
			sizeof(hdr_tfwc_ack)) {
		bind_offset(&hdr_tfwc_ack::offset_);
	}
} class_tfwc_ackhdr;

static class TfwcClass : public TclClass {
public:
	TfwcClass() : TclClass("Agent/TFWC") {}
	TclObject* create(int, const char*const*) {
		return (new TfwcAgent());
	}
} class_tfwc;

/*
 * TfwcAgent declaration
 */
int TfwcAgent::command(int argc, const char*const* argv)
{
	//printf(" command in tfwc called - %s\n", argv[0]);
	//printf(" command in tfwc called - %s\n", argv[1]);
	//Tcl& tcl = Tcl::instance();
	if (argc==3) {
		if (strcmp(argv[1],"send")==0) {
			alive_ = 1;
			output(seqno_);
			return TCL_OK;
		}
		if (strcmp(argv[1],"stop")==0) {
			stop();
			return TCL_OK;
		}  
	}
	return (Agent::command(argc, argv));
}

void TfwcRtxTimer::expire(Event*) {
	a_ -> timeout(TFWC_TIMER_RTX);
}

TfwcAgent::TfwcAgent() : Agent(PT_TFWC), rtx_timer_(this) {
	//printf(" * TfwcAgent() called *\n");

	// bind("cwnd_", &cwnd_);
	// bind("ndatapkt_", &ndatapkt_);

	/*
	 * TFWC variables
	 */
	isTFWC_	= false;		// TFWC Control
	seqno_	= 0;			// initial TFWC packet sequence number

	tfwc_tick_	= 0.01;		// tfwc_tick_
	alpha_	= 0.125;
	beta_	= 0.25;
	g_		= 0.01;
	k_		= 4;
	minrto_	= 0.0;
	maxrto_	= 100000.0;
	rto_	= 3.0;			// by RFC1122
	isRateDriven_= false;	// rate-based timer driven
	srtt_	= -1.0;			// smoothed RTT
	rttvar_	= 0.0;
	rtt_sample_	= 0.0;		// instantaneous RTT
	srtt_init_	= 0;
	rttvar_init_= 12;
	rttvar_exp_	= 2;
	df_		= 0.95;			// decay factor for RTT calculation
	tcp_tick_	= 0.1;
	t_srtt_	= int(srtt_init_/tcp_tick_) << T_SRTT_BITS;
	t_rttvar_	= int(rttvar_init_/tcp_tick_) << T_RTTVAR_BITS;
	sqrtrtt_	= 1.0;
	t0_		= 6.0;			// initial t0_ value
	last_ack_	= -1;
	ackofack_	= -1;		// initial ackofack_ value
	firstLostPkt_= -1;		// first lost packet sequence number
	isRtxTimerReset_= false;

	nackpkt_	= 0;
	ndatapkt_	= 0;
	pktSize_	= 1040;		// TFWC packet size

	/*
	 * window control variables
	 */
	window_	= 10000;		// receiver's window size
	cwnd_	= 1;
	ssthresh_	= window_;	// set initial ssthresh 
	dupacks_	= 0; 		// initial dupacks_ value
	congest_iteration_ = 0;
	isThere_	 = false;	// true if a seqno is in AckVec

	/*
	 * cwndCtrl variables
	 */
	isFirstLostSeen_ = false;	// is this a first loss?
	t_win_	= 1.0;			// temp cwnd size
	ts_		= 0.0;			// timestamp for last lost packet
	avg_interval_	= 0.0;	// average loss interval
	I_tot0_		= 0.0;		
	I_tot1_		= 0.0;
	tot_weight_	= 0.0;

	tsvec_ = (double *)malloc(sizeof(double)*TSZ);

	/*
	 * XXX TEST PURPOSE ONLY: faking loss rate
	 *
	 *	case 1: 
	 *		loss rate = 0.01 (periodic loss rate)
	 *	case 2:
	 *		loss rate = 0.05 (periodic loss rate)
	 *	case 3:
	 *		loss rate = 0.1 (periodic loss rate)
	 *	case 4:
	 *		loss pattern = (XO...OX)
	 *		              |<- 100 ->|
	 *	case 5:
	 *		bi-packet loss pattern = (OXOXOXOX......) 
	 *	case 6:
	 *		loss rate = 0.01 (random loss; not periodic)
	 *	case 7:
	 *		loss rate = 0.05 (random loss; not periodic)
	 *	case 8:
	 *		loss rate = 0.1 (random loss; not periodic)
	 *	case 9:
	 *		loss pattern = (OXOX...O)
	 *		              |<-  100  ->|
	 *	case 10:
	 *		loss pattern = (OXOXXO...O)
	 *		              |<-  100  ->|
	 *	default:
	 *		default sending method
	 *
	 */
	isFakeLoss_= true;	// is faking loss probability on?
	f_init_	= 0;		// initial fake count 
	f_case_	= 0;		// fake loss scenarios
	f_sent_	= false;	// is the previous packet has been sent?

	// Breaking Phase Effect (TEST PURPOSE ONLY)
	isBreakPhase_ = false;	// artificially break phase effect?
	p_case_	= 0;		// break phase effect scenarios 

	// Other test purpose
	isDupAck_	= false;

	// smoothing 'cwnd_'
	smoothing_ = true;
	if (smoothing_) {
		winvec_		= (int *) malloc(sizeof(int) * TSZ);
		timevec_	= (double *) malloc(sizeof(double) * TSZ);
		timevec_[0]	= 0.0;
		tvrec_		= 0.0;	// timestampe for the last cwnd_ 
		numvec_		= 1;	// vector index (or numver of vector)
		is_inflated_ = false;
		num_infl_	= 0;
		num_asis_	= 0;
	}
}

/*
 * Main TFWC Reception Path
 */
void TfwcAgent::recv(Packet* pkt, Handler*) {

	hdr_tfwc_ack *tfwcah = hdr_tfwc_ack::access(pkt);

	newack(tfwcah);	// store tfwcAV head as last_ack_
	++nackpkt_;		// increase the number of the received ack pkt

	/* printing received AckVec */
	//print_ackvec(tfwcah);

	/*
	 * generate margin vector
	 * (e.g.)
	 *	if tfwcAV = (10 9 8 7 6 4)
	 *	then, margin[0] = 9, margin[1] = 8, margin[2] = 7
	 */
	marginvec(tfwcah);

	/*
	 * check if there is any missing AckVecElm
	 * by examining from ackofack_ upto margin_[2]-1
	 *
	 *	begin : ackofack_
	 *	end   : margin_[NUMDUPACK-1]-1
	 *
	 *	(e.g.)
	 *	if tfwcAV = (10 9 8 7 6 4), and ackofack_ = 4,
	 *	then, tempvec[0] = 5, tempvec[1] = 6
	 *
	 *	finally, 
	 *	compare tfwcAV to tempvec[] to find out any missed packet.
	 *	(in this example, we can see seqno 5 is missing.)
	 */
	isLoss_ = isHole(tfwcah, margin_[NUMDUPACK-1]-1, ackofack_);

	// print Average Loss Interval whenever a packet loss occurs
	if(isLoss_)
		printf(" [.] pkt_drop_in_avg_hist %f %.1f %p\n",
				now(), avg_interval_, this); 

	/*
	 * Main TFWC Reception Path
	 *  o  if 'isTFWC_' is not turned on,
	 *     increase congestion window like TCP Tahoe.
	 *  o  if 'isTFWC_' is turned on,
	 *     the various TFWC methods will be activated. 
	 */
	if(!isTFWC_) {
		if(isLoss_) { 
			isTFWC_ = true;
			dupack_action();
			ts_ = tsvec_[firstLostPkt_%TSZ]; 
		}
		opencwnd();			// TCP-like cwin control
	} else
		ctrl_win(tfwcah);	// TFWC cwnd control

	// marking AckofAck
	ackofack_ = ackofack();

	// update RTT
	update_rtt(now() - tfwcah->ts_echo_);

	// driven by rate-based? or win-based?
	if (isRateDriven_)
		new_rto(rtt_sample_);	// rate-based timer driven
	else
		output(seqno_);			// normal TFWC procedures

	Packet::free(pkt);
}

/*
 * find a lost packet by examining an AckVec
 * (from sequence number 'begin' to 'end')
 *
 *	@return FALSE if there is no hole,
 *	@return TRUE if there is a hole.
 */
bool TfwcAgent::isHole(hdr_tfwc_ack* tfwcah, int end, int begin) {
	bool retval;	// 'true' when there is a hole in AckVec
	int numVec;		// total number of tempvec
	int numLoss = 0;// number of lost packet

	/*
	 * create a temp vector which can accommodate
	 * from the ackofack_ to right before margin[NUMDUPACK-1]
	 * (but, ackofack_ is EXCLUDED from the tempvec[]!)
	 *
	 * end: margin[NUMDUPACK - 1] - 1
	 * begin: ackofack_
	 * (note: tempvec is an expected packet sequence from the receiver)
	 */
	//printf(" [.] begin (ackofack_) = %d,", begin);
	//printf(" end (margin_[2] - 1) = %d\n", end);

	numVec = (end - begin < 0 ) ? 0 : end - begin; 
	int tempvec[numVec];

	for(int i = 0; i < numVec; i++) {

		tempvec[i] = (begin + 1) + i;
		isThere_ = tfwcah->tfwcAV.ackv_bool_search(tempvec[i]);

		// increase loss count if there is any missing seqno
		if (!isThere_) {
			// recording the very first lost packet
			if(!isFirstLostSeen_) firstLostPkt_ = tempvec[i];
			numLoss++;
		}
	} 

	/* copying tempvec[] for updating loss history */
	firstvec_ = tempvec[0];			// first tempvec element
	lastvec_ = firstvec_ + (numVec - 1);	// last tempvec element

	return retval = (numLoss > 0) ? true : false;
}

/*
 * generate margin vector
 */
void TfwcAgent::marginvec(hdr_tfwc_ack* tfwcah) {

	/*
	 * fill up margin with the latest three expected packets from an AckVec 
	 * (excluding the current packet) 
	 *
	 * (e.g.)
	 *	if an AckVec is (10 9 8 7 6 4)
	 *	then, margin[0] = 9, margin[1] = 8, margin[2] = 7
	 */
	for(int i = 0; i < NUMDUPACK; i++){
		margin_[i] = tfwcah->tfwcAV.ackv_headval() - (i + 1);

		/* wrap up margin_[] to -1 if it is less than 0 */
		margin_[i] = (margin_[i] < 0) ? -1 : margin_[i];
	}
	//printf(" [.] margin --(%d %d %d)--\n", 
	//		margin_[0], margin_[1], margin_[2]);
}

/*
 * newack method
 */
void TfwcAgent::newack(hdr_tfwc_ack* tfwcah) {
	// store tfwcAV head as last_ack_ everytime it gets an ACK
	last_ack_ = tfwcah->tfwcAV.ackv_headval();
}

/*
 * Main TFWC output method
 */
void TfwcAgent::output(int seqno) {

	printf("   [.] cwnd_	%f	%d	%p\n", now(), cwnd_, this);

	assert (seqno != -1);	// invalid sequence number
	seqno_ = seqno;

	/*
	 * send more packets while (next seqno <= unacked + cwnd) 
	 *
	 *                   <---- (higher seqno)
	 * --------------------------------------
	 *      |<---    cwin    --->|
	 * --------------------------------------
	 *      ^                    ^
	 *      |                    |
	 *     next                unacked
	 *    (seqno_)            (last_ack_)
	 */
	if(isBreakPhase_ && alive_) {
		break_phase();		// XXX - test only
	} 
	else if (alive_) { // check if we have shut off. 
		if(isRateDriven_) {
			// if we are in the new RTO based (rate based) timer
			// mode, then we want to send a packet soley by the
			// timer driven. 
			send_more(seqno_);
			seqno_++;
		} else {
			// if we are in the normal TFWC mode, then we want to
			// send a packet as long as the cwnd+last_ack allows to
			// send the next available packets.
			while (seqno_ <= last_ack_ + cwnd_) {
				//printf("\n seqno: %d\n",	seqno_);
				//printf(" last_ack: %d\n",	last_ack_);
				//printf(" cwnd: %d\n\n",	cwnd_);

				send_more(seqno_);
				seqno_++;
			}
		} // if(isRateDriven_)
	} // if(isBreakPhase_)

	/* set retransmission timer */
	set_rtx_timer();
}

/*
 * Breaking Phase Effect
 *  o  different cases for breaking phase effect
 */
void TfwcAgent::break_phase() {
	switch (p_case_) {
		case 1:
			if (rand()%100 > 50) {
				while (seqno_ <= last_ack_ + cwnd_) {
					send_more(seqno_);
					seqno_++;
				}
			} else {
				/* DO NOTHING */
			}
			break;
		case 2:
			if (rand()%100 > 20) {
				while (seqno_ <= last_ack_ + cwnd_) {
					send_more(seqno_);
					seqno_++;
				}
			} else {
				/* DO NOTHING */
			}
			break;
		case 3:
			if (rand()%100 > 10) {
				while (seqno_ <= last_ack_ + cwnd_) {
					send_more(seqno_);
					seqno_++;
				}
			} else {
				/* DO NOTHING */
			}
			break;
		case 4:
			if (rand()%100 > 5) {
				while (seqno_ <= last_ack_ + cwnd_) {
					send_more(seqno_);
					seqno_++;
				}
			} else {
				/* DO NOTHING */
			}
			break;
		case 5:
			if (rand()%100 > 2) {
				while (seqno_ <= last_ack_ + cwnd_) {
					send_more(seqno_);
					seqno_++;
				}
			} else {
				/* DO NOTHING */
			}
			break;
		default:
			// default TFWC output method
			while (seqno_ <= last_ack_ + cwnd_) {
				send_more(seqno_);
				seqno_++;
			}
	}
}

/*
 * Send data as much as it can
 */
void TfwcAgent::send_more(int seqno) {

	Packet* pkt = allocpkt();
	hdr_tfwc *tfwch = hdr_tfwc::access(pkt);
	hdr_cmn *cmnh = hdr_cmn::access(pkt);

	tfwch->seqno_ = seqno;
	tfwch->ackofack_ = ackofack_;
	tfwch->ts_ = now();
	cmnh->size_ = pktSize_;

	// print packet timestamp
	//print_timestamp(tfwch);

	// timestamp vector for loss history update
	tsvec_[seqno%TSZ] = tfwch->ts_;	

	// timestamp vector for smoother
	if (smoothing_) 
		timevec_[(numvec_-1)%TSZ] = now();

	if (isFakeLoss_) {
		// XXX TEST PURPOSE ONLY
		fake_loss(pkt);
	} else {
		// normal TFWC send method
		send(pkt, 0);
		//printf(" ==> sending data seqno: %d", tfwch->seqno_);
		//printf(" ==> appending ackofack : %d\n", tfwch->ackofack_);
	}

	ndatapkt_++;  // increase the number of data pkt sent
}

/*
 * Faking Packet Loss Probability (TEST PURPOSE ONLY)
 */
void TfwcAgent::fake_loss(Packet* pkt) {
	hdr_tfwc *tfwch = hdr_tfwc::access(pkt);

	/*
	 *	o  sending out a packet from the below
	 *	   faking loss rate for protocol validation purpose
	 *
	 *	case 1: 
	 *		loss rate = 0.01 (periodic loss rate)
	 *	case 2:
	 *		loss rate = 0.05 (periodic loss rate)
	 *	case 3:
	 *		loss rate = 0.1 (periodic loss rate)
	 *	case 4:
	 *		two packet loss in a same window (loss rate = 0.01)
	 *	case 5:
	 *		loss pattern = (OXOXOXOX......) 
	 *	case 6:
	 *		loss rate = 0.01 (random loss; not periodic)
	 *	case 7:
	 *		loss rate = 0.05 (random loss; not periodic)
	 *	case 8:
	 *		loss rate = 0.1 (random loss; not periodic)
	 *	case 9:
	 *		loss pattern = (OXOX...O) <- 100 packets
	 *	case 10:
	 *		loss pattern = (OXOXXO...O) <- 100 packets
	 *	default:
	 *		default sending method
	 */
	switch (f_case_){
		case 1: /* periodic loss with 1% loss probability */
			if (f_init_ < 100) {
				send(pkt, 0);
				++f_init_;
			} else {
				/* DO NOTHING */
				f_init_ = 1;
			}
			break;
		case 2: /* periodic loss with 5% loss probability */
			if (f_init_ < 20) {
				send(pkt, 0);
				++f_init_;
			} else {
				/* DO NOTHING */
				f_init_ = 1;
			}
			break;
		case 3: /* periodic loss with 10% loss probability */
			if (f_init_ < 10) {
				send(pkt, 0);
				++f_init_;
			} else {
				/* DO NOTHING */
				f_init_ = 1;
			}
			break;
		case 4: /* two back-to-back packet losses in a same window */
			if (f_init_ < 100) {
				// force sending the very first packet
				if (f_init_==0 && tfwch->seqno_==0)
					send(pkt, 0);
				else if (f_init_ != 0)
					send(pkt, 0);

				++f_init_;
			} else {
				/* DO NOTHING */
				f_init_ = 1;
			}
			break;
		case 5: /* bi-packet loss (e.g. OXOXOXOX...) */
			if (!f_sent_) {
				send(pkt, 0);
				f_sent_ = true;
			} else {
				/* DO NOTHING */
				f_sent_ = false;
			}
			break;
		case 6: /* random loss with 1% loss probability */
			if ((rand()%100) > 0) {
				send(pkt, 0);
			} else {
				/* DO NOTHING */
			}
			break;
		case 7: /* random loss with 5% loss probability */
			if ((rand()%100) > 4) {
				send(pkt, 0);
			} else {
				/* DO NOTHING */
			}
			break;
		case 8: /* random loss with 10% loss probability */
			if ((rand()%100) > 9) {
				send(pkt, 0);
			} else {
				/* DO NOTHING */
			}
			break;
		case 9: /* loss pattern = (OXOX...O) */
			if (f_init_ < 100) {
				if ( f_init_ == 1 || f_init_ == 3) {
					++f_init_;
					break;
				} else {
					++f_init_;
					send(pkt, 0);
				}
			} else {
				/* DO NOTHING */
				f_init_ = 1;
			}
			break;
		case 10: /* loss pattern = (OXOXXO..O) */
			if (f_init_ < 100) {
				if ( f_init_==1 || f_init_==3 || f_init_==4) {
					++f_init_;
					break;
				} else {
					++f_init_;
					send(pkt, 0);
				}
			} else {
				/* DO NOTHING */
				f_init_ = 1;
			}
			break;
		default:
			send(pkt, 0);
			break;
	} // switch (f_case_)

}

/*
 * RTT Update
 */
void TfwcAgent::update_rtt(double tao) {

	rtt_sample_ = tao;
	t_rtt_ = int(rtt_sample_/tcp_tick_ + 0.5);

	if (t_rtt_ == 0)
		t_rtt_ = 1;

	/*
	 * The following piece of code basically does...
	 *
	 *	(let)
	 *		srtt = t_srtt_/8, 
	 *		rttvar = t_rttvar_/4,
	 *		rtt_delta = rtt - srtt
	 *
	 *	(then)
	 * 		srtt = (rtt - srtt)/8 + srtt
	 * 		rttvar = |(rtt - srtt)/4| + rttvar
	 */
	if (t_srtt_ != 0) {
		register short rtt_delta;
		rtt_delta = t_rtt_ - (t_srtt_ >> T_SRTT_BITS);

		if ((t_srtt_ += rtt_delta) <= 0)
			t_srtt_ = 1;

		if (rtt_delta < 0)
			rtt_delta = -rtt_delta;

		rtt_delta -= (t_rttvar_ >> T_RTTVAR_BITS);

		if ((t_rttvar_ += rtt_delta) <= 0)
			t_rttvar_ = 1;
	} else {
		t_srtt_ = t_rtt_ << T_SRTT_BITS;
		t_rttvar_ = t_rtt_ << (T_RTTVAR_BITS-1);
	}

	/*
	 * t0_ = (smoothed RTT) + 4*(RTT variance)
	 */
	t0_ = (((t_rttvar_ << (rttvar_exp_ + (T_SRTT_BITS - T_RTTVAR_BITS))) 
				+ t_srtt_)  >> T_SRTT_BITS ) * tcp_tick_;

	if (t0_ < minrto_)
		t0_ = minrto_;

	if (srtt_ < 0) {
		// the first RTT observation
		srtt_ = rtt_sample_;
		rttvar_ = rtt_sample_/2.0;
		sqrtrtt_ = sqrt(rtt_sample_);
	} else {
		//srtt_ = srtt_ + alpha_ * (rtt_sample_ - srtt_);
		srtt_ = df_ * srtt_ + (1 - df_) * rtt_sample_;
		rttvar_ = rttvar_ + beta_ * (fabs(srtt_ - rtt_sample_) - rttvar_);
		sqrtrtt_ = df_ * sqrtrtt_ + (1 - df_) * sqrt(rtt_sample_);
	}

	/* update the current RTO value */
	if (!isRateDriven_) {
		// RTO <- SRTT + max (g_, k*RTTVAR)
		if (k_ * rttvar_ > g_)
			rto_ = srtt_ + k_ * rttvar_;
		else
			rto_ = srtt_ + g_;

		// 'rto' could be rounded down to 'maxrto_'
		if (rto_ > maxrto_)
			rto_ = maxrto_;
	}
}

/*
 * Open Congestion Window
 */
void TfwcAgent::opencwnd(){

	/* assert if cwnd_ is greater than the receiver's window */
	assert(cwnd_ <= window_);

	/* TCP-like cwnd_ increment */
	if(cwnd_ < ssthresh_)
		cwnd_ += 1;
	else
		congestion_avoid(cwnd_);
}

void TfwcAgent::congestion_avoid(int cwnd) {
	printf(" - congestion_avoid() called \n");
	printf(" - YOU SHOULD NOT CALL THIS METHOD!!! \n");

	congest_iteration_++;

	if (cwnd == congest_iteration_) {
		cwnd_ = cwnd + 1;
		congest_iteration_ = 0;
	} else
		cwnd_ = cwnd;
}

/*
 * dupack action
 *	o  halve cwnd_
 *	o  making pseudo probability and history
 *
 * THIS METHOD SHOULD BE ONLY CALLED ONCE
 * WHEN IT SEES THE VERY FIRST LOST PACKET
 */
void TfwcAgent::dupack_action() {

	isDupAck_ = true;
	isFirstLostSeen_ = true;

	/* we now have just one meaningful history information  */
	hsz_ = 1;

	/* halve the current cwnd_ value */
	cwnd_ = cwnd_ / 2;

	/* cwnd_ never goes below 1 */
	if (cwnd_ < 1)
		cwnd_ = 1;	

	/* temp cwnd used to calculate pseudo packet loss probability */
	tmp_cwnd_ = cwnd_;

	/* creating a faked loss probability and history */
	pseudo_p();		// calculating a faked p_ value
	pseudo_history();	// creating a faked loss history
	gen_weight();	// generating weights

	/* printing all history information */
	// print_history();
}

/*
 * TFWC windows control after the first packet loss
 *	o  loss history calculation
 *	o  average loss interval calculation
 *	o  loss event rate calculation
 *	o  update cwnd_ using TCP throughput equation
 */
void TfwcAgent::ctrl_win(hdr_tfwc_ack* tfwcah){

	loss_history(tfwcah);	// update loss history
	avg_loss_interval();	// computing average loss interval

	/* Loss Event Rate */
	p_ = 1.0 / avg_interval_;

	/* simplified TCP throughput equation */
	double tmp1	= 12.0 * sqrt(p_ * 3.0/8.0);
	double tmp2 = p_ * (1.0 + 32.0 * pow(p_, 2.0));
	double term1 = sqrt(p_ * 2.0/3.0);
	double term2 = tmp1 * tmp2;
	f_p_ = term1 + term2;

	/* TFWC window size */
	t_win_ = 1 / f_p_;		// 't_win_' is a floating point value
	cwnd_ = (int) t_win_;	// 'cwnd_' is an integer value

	// are we inflating 'cwnd_' in the same RTT for smoothing?
	if (smoothing_)
		cwnd_ = smoother (cwnd_);

	/* TFWC is driven by rate-based timer if cwnd is less than 2 */
	if (t_win_ < 2.0)
		isRateDriven_ = true;
	else
		isRateDriven_ = false;

	/* printing loss rate seen by TCP Eq. */
	printf("	[.]	loss_by_cal	%f	%f	%p\n", now(), p_, this);
}

/*
 * Inflate 'cwnd_' in the same RTT
 * @window:	cwnd_
 * return:	inflated 'cwnd_'
 */
int TfwcAgent::smoother (int window) {
	bool isNewRTT = false;
	//for (int i = 0; i < numvec_; i++) {
		// check if this cwnd triggers a new RTT
		//if(timevec_[i%TSZ] - tvrec_ > srtt_)
		if(timevec_[(numvec_ - 1)%TSZ] - tvrec_ > srtt_)
			isNewRTT = true;

		// same RTT
		if (!isNewRTT) {
			window = control_functions ('p', window);
		}
		// new RTT
		else {
			//window = force_inflate (cwnd_);
			//tvrec_ = timevec_[i%TSZ];
			tvrec_ = timevec_[(numvec_ - 1)%TSZ];

			printf(" num_inf: %d total: %d startRTT: %f now: %f %p\n", 
					num_infl_, (num_infl_ + num_asis_), 
					timevec_[0], now(), this);

			reset_smoother();
		}

		// store current cwnd value
		winvec_[numvec_-1] = window;
	//}

	if (!isNewRTT) 
		numvec_++;

	return window;
}

/*
 * Calculate the packet loss probability by using TCP thruput equation 
 * to get the loss_interval_ eventually.
 */
void TfwcAgent::pseudo_p(){

	for (pseudo_p_ = 0.00001; pseudo_p_ < 1.0; pseudo_p_ += 0.00001) {
		f_p_ = sqrt((2.0/3.0) * pseudo_p_) + 12.0 * pseudo_p_ * 
			(1.0 + 32.0 * pow(pseudo_p_, 2.0)) * sqrt((3.0/8.0) * pseudo_p_);

		t_win_ = 1 / f_p_;

		if(t_win_ < tmp_cwnd_) 
			break;
	}
	p_ = pseudo_p_;
}

/* 
 * creating a pseudo loss interval history
 * ( loss_interval_history = 1 / packets_probability ) 
 */
void TfwcAgent::pseudo_history(){

	pseudo_interval_ = 1 / p_;

	/* bzero for all history information */
	for(int i = 0; i <= HSZ+1; i++)
		history_[i] = 0;

	/* (let) most recent history information be 0 */
	history_[0] = 0;

	/* (let) the pseudo interval be the first history information */
	history_[1] = (int) pseudo_interval_;
}

/*
 * generating weithgts for history averaging
 *	(this equation is brought from RFC 3448)
 */
void TfwcAgent::gen_weight(){
#ifdef SHORT_HISTORY
	// this is just weighted moving average (WMA)
	for(int i = 0; i <= HSZ; i++){
		if(i < HSZ/2)
			weight_[i] = 1.0;
		else
			weight_[i] = 1.0 - (i-(HSZ/2 - 1.0)) / (HSZ/2 + 1.0);
	}
#else
	// this is exponentially weighted moving average (EWMA)
	for (int i=0; i <= HSZ; i++) {
		if (i < HSZ/4)
			weight_[i] = 1.0;
		else
			weight_[i] = 2.0 / (i - 1.0);
	}
#endif
}

/*
 * updating loss history
 */
void TfwcAgent::loss_history(hdr_tfwc_ack* tfwcah){

	bool isGap;			// is there a gap in the received AckVec?
	bool isNewEvent;		// is this a new loss event?
	int numVec = lastvec_ - firstvec_ + 1;	// tot number of tempvec
	int tempvec[numVec];	// identical to tempvec[] in isHole() method

	/* copying tempvec[] based on the information from isHole() */
	for(int i = 0; i < numVec; i++)
		tempvec[i] = firstvec_ + i;

	/*
	 * compare tempvec[] with AckVec
	 *	o  everytime it sees a gap,
	 *	   it will compare the timestamp with RTT.
	 *
	 *	o  if the time difference is greater than RTT,
	 *	   then this loss will start a new loss event.
	 *	o  if the time difference is less than RTT,
	 *	   then we do nothing.
	 *
	 *	o  if there is no gap,
	 *	   increase current loss interval by one.
	 *
	 *	o  ackv_bool_search() returns FALSE,
	 *	   if tempvec[i] is NOT in the AckVec
	 */
	for(int i = 0; i < numVec; i++) {
		// packet loss??
		isGap = !(tfwcah->tfwcAV.ackv_bool_search(tempvec[i]));

		// this loss triggers a new loss event?
		if (isGap) {
			isNewEvent = (tsvec_[tempvec[i]%TSZ] - ts_ > srtt_) 
				? true : false;
		}

		// packet loss with new loss event
		if(isGap && isNewEvent) {
			// increase current history size: hsz_
			hsz_ = (hsz_ < HSZ) ? ++hsz_ : HSZ;

			// new loss event started!
			// (shift up history_[] accordingly)
			for (int j = HSZ; j > 0; j--)
				history_[j] = history_[j-1];

			// record lost packets's timestamp
			ts_ = tsvec_[tempvec[i]%TSZ];

			// let the most recent history information be one
			history_[0] = 1;
			//print_history();
		} 
		// this is not a new loss event
		else {	
			// increase current history information
			history_[0]++;
			//print_history();
		}
	} // for( ; ; ) 
}

/* 
 * calculate average loss interval 
 */
void TfwcAgent::avg_loss_interval(){

	I_tot0_ = 0;
	I_tot1_ = 0;
	tot_weight_ = 0;

	/* make a decision whether to include the most recent loss interval */
	//printf(" HIST_0 [");
	for(int i = 0; i < hsz_; i++){
		I_tot0_ += weight_[i] * history_[i];
		tot_weight_ += weight_[i];

		//print_history_element(i);
	}
	//printf("]\n");

	//printf(" HIST_1 [");
	for(int i = 1; i < hsz_+1; i++){
		I_tot1_ += weight_[i-1] * history_[i];

		//print_history_element(i);
	}
	//printf("]\n");

	//printf("\n I_tot0_: %.1f I_tot1_: %.1f\n", I_tot0_, I_tot1_);

	/* compare I_tot0_ with I_tot1_, and return the large one */
	if (I_tot0_ < I_tot1_)
		I_tot_ = I_tot1_;
	else
		I_tot_ = I_tot0_;
	//printf("\n   [.] I_tot_: %.1f %f %p\n", I_tot_, now(), this);

	/* average loss interval <- I_tot_ / tot_weight_ */
	avg_interval_ = I_tot_ / tot_weight_;

	//printf("\n   [.] tot_weight_ %f %f %p\n", tot_weight_, now(), this);
	printf("\n   [.] avg_interval_ %f %.1f %p\n", now(), avg_interval_, this);
}

/*
 * set retransmit timer using current rtt estimate.
 */
void TfwcAgent::set_rtx_timer() {
	rtx_timer_.resched(rto_);
	//printf("\n XXX rto_ 	%f 	rtt_	%f\n", rto_, srtt_);
}

/*
 * we've got a timer out because there is no feedback from the data receiver.
 */
void TfwcAgent::reset_rtx_timer(int backoff) {
	/* 'backoff' is 1 when the timer should be backed off, otherwise 0  */
	if (backoff) 
		backoff_timer();

	set_rtx_timer();
}

/* 
 * double the 'rto_' value as the timer is backed off 
 */
void TfwcAgent::backoff_timer() {
	rto_ = 2 * rto_;

	if (rto_ > maxrto_)
		rto_ = maxrto_;
}

void TfwcAgent::timeout(int tno) {
	printf("\n TIMEOUT 	%f	%p\n", now(), this);

	/* retransmit timer */
	if (tno == TFWC_TIMER_RTX) {
		//isRtxTimerReset_ = true;
		if (!isRateDriven_)
			reset_rtx_timer(1);
		else
			reset_rtx_timer(0);

		if(!isRateDriven_)
			last_ack_++;	// artificially inflate the last ack

		output(seqno_);
	}
}

void TfwcAgent::new_rto(double rtt) {

	double tmp1 = 3.0 * sqrt(p_*3.0/8.0);
	double tmp2 = t0_ * p_ * (1.0 + 32.0 * pow(p_, 2.0));

	if (tmp1 > 1.0)
		tmp1 = 1.0;

	double term1 = rtt * sqrt(p_*2.0/3.0);
	double term2 = tmp1 * tmp2;

	rto_ = term1 + term2;
	rto_ = rto_ * sqrt(rtt)/sqrtrtt_;

	double Tx = 8000 / rto_;
	printf(" %f tfwcTx: %.4f rto_: %f t0_: %.4f rtt: %.5f p_: %.4f %p\n", 
			now(), Tx, rto_, t0_, rtt, p_, this);
}

/*
 * Printing Received AckVec
 */
void TfwcAgent::print_ackvec(hdr_tfwc_ack* tfwcah) {
	printf(" [.] received AckVec");
	tfwcah->tfwcAV.ackv_print();
	printf(" [.] current AckofAck = %d\n", ackofack_);
}

/*
 * Printinig a packet's timestamp 
 * (this packet is sending packet)
 */
void TfwcAgent::print_timestamp(hdr_tfwc* tfwch) {
	printf("   [.] seqno = %d, tsvec_[%d] = %f \n", 
			tfwch->seqno_, tfwch->seqno_, tfwch->ts_);
}

/* 
 * printing history information  
 */
void TfwcAgent::print_history() {
	printf(" HISTORY [");
	for(int i = 0; i < HSZ; i++){
		printf("%d", history_[i]);
		if(i < HSZ - 1) printf(", ");
	}
	printf("]\n");
}

void TfwcAgent::print_history_element(int i) {
	printf("%d", history_[i]);
	if(i < hsz_ - 1) printf(", ");
}

/*
 * Shut down TfwcAgent
 */
void TfwcAgent::stop() {
	alive_ = 0;
	rtx_timer_.force_cancel();
}

/*
 * Various Control Functions
 */
int TfwcAgent::control_functions (char c, int window) {

	double y = 0.0;
	double peak = 0.0;
	double cutoff = 0.0;
	double median = 0.0;
	double coeff = 0.0;
	double factor = 0.0;

	switch (c) {
		case 'o':       // just once
		{
			if (!is_inflated_) {
				is_inflated_ = true;
				factor = 1.0;
			}
		}
			break;
		case 'l':       // linear functions
		{
			double cool;
			if (p_ < .1)
				cool = 5 * p_;
			else
				cool = p_;

			factor = (cool < 1.0) ? cool : 1.0;
		}
			break;
		case 'g':       // gaussian functions
		{
			double gauss;
			peak = 0.5;
			median = 0.1;

			if (p_ < .1) {
				coeff = .035;
				gauss = peak * exp(pow((p_ - median),2.0)
						/ (-2.0 * pow(coeff, 2.0)));
			} else {
				coeff = .075;
				gauss = peak * exp(pow((p_ - median),2.0)
						/ (-2.0 * pow(coeff, 2.0)));
			}

			factor = (gauss < 1.0) ? gauss : 1.0;
		}
			break;
		case 'p':       // polynomial functions
		{
			double poly;
			double POLYCOF = 62.5;
			y = .5;
			cutoff = .2;

			if  (p_ < cutoff)
				poly = POLYCOF * pow((p_ - cutoff), 3.0) + y;
			else
				poly = pow((p_ - cutoff), 2.0) + y;

			factor = (poly < 1.0) ? poly : 1.0;
		}
			break;
		case 'm':       // mixture functions
		{
			double mix;
			peak = .5;
			median = .1;
			coeff = .035;
			cutoff = .1;

			y = peak * exp( pow((cutoff - median),2.0)
					/ (-2.0 * pow(coeff, 2.0)) );

			if (p_ < .01)
				mix = 5 * p_;
			else if (p_ >= .01 && p_ < cutoff)
				mix = peak * exp( pow((p_ - median),2.0)
						/ (-2.0 * pow(coeff, 2.0)) );
			else
				mix = 2.0 * pow((p_ - .1), 2.0) + y;

			factor = (mix < 1.0) ? mix : 1.0;
		}
			break;
		default:
			factor = -1.0;
	} // switch


	// generate random number [0:1)
	//srand (now * p_);
	double n = (double) rand() / (double) 0x7fffffff;

	// finally, inflate 'window' according to the given case
	if (n < factor) {
		num_infl_++;
		return (window + 1);
	} else {
		num_asis_++;
		return window;
	}
}

/*
 * Reset TFWC smoother
 */
void TfwcAgent::reset_smoother() {
	is_inflated_ = false;
	numvec_ = 1;
	num_infl_ = 0;
	num_asis_ = 0;
}

/*
 * Force inflate
 */
int TfwcAgent::force_inflate(int window) {
	if (num_infl_ == 0) {
		window++;
		num_infl_++;
	}
	return window;
}
