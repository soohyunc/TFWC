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

#ifndef ns_tfwc_h
#define ns_tfwc_h

#include "agent.h"
#include "packet.h"
#include "flags.h"
#include "ip.h"
#include "tcp.h"
#include "timer-handler.h"
#include "random.h"
#include "tfwc-vec.h"

//#define SHORT_HISTORY	// set history size
#ifdef	SHORT_HISTORY
#define HSZ	8	// history size for avg loss history
#else
#define HSZ	16	// history size for avg loss history
#endif

#define NUMDUPACK 3	// number of dupacks
#define TSZ	10000	// tsvec[] size

#define TFWC_TIMER_RTX		0
#define TFWC_TIMER_RESET	1

#define	T_RTTVAR_BITS		2
#define	T_SRTT_BITS			3

class TfwcAgent;

// TFWC packet header structure
struct hdr_tfwc {
	int seqno_;		// data packet sequence number
	int ackofack_;	// ack of ack
	double ts_;     // time stamp

	// packet header access functions 
	static int offset_;     // offset for this header
	inline static int& offset() { return offset_; }
	inline static hdr_tfwc* access(const Packet* p) {
		return (hdr_tfwc*) p->access(offset_);
	}
};

// TFWC ACK packet header structure
struct hdr_tfwc_ack {
	int ackno_;			// highest sequence number for TFWC_ACK header
	double ts_echo_;	// time stamp echo that the data pkt sent
	AckVec tfwcAV;		// TFWC Ack Vector 

	// packet header access functions 
	static int offset_;	// offset for this header
	inline static int& offset() { return offset_; }
	inline static hdr_tfwc_ack* access(const Packet* p) {
		return (hdr_tfwc_ack*) p->access(offset_);
	}
};

class TfwcRtxTimer : public TimerHandler {
public:
	TfwcRtxTimer(TfwcAgent *a) : TimerHandler() { a_ = a; }

protected:
	virtual void expire(Event *e);
	TfwcAgent *a_;
};

class TfwcAgent : public Agent {
public:

	// constructor - a new TFWC agent
	TfwcAgent();
	int command(int argc, const char* const* argv);

	// receive a packet
	virtual void recv(Packet*, Handler*);

	// send a packet
	virtual void output(int seqno);
	void send_more(int seqno);

	// new acker
	void newack(hdr_tfwc_ack* tfwcah);

	// main method for dealing with rtx timeout
	void timeout(int tno);

	// stop transmission
	void stop();

protected:
	// current simulator time
	inline double now() { return Scheduler::instance().clock(); }

	/*
	 * cwnd action
	 */
	void opencwnd();		// open up the congestion window
	void congestion_avoid(int);	// congestion avoidance
	void marginvec(hdr_tfwc_ack* tfwcah);	// generating a margin vector
	int ackofack() { 
		return (margin_[NUMDUPACK-1] - 1 < 0) ? 
			-1 : margin_[NUMDUPACK-1] - 1; 
	}

	bool isTFWC_;		// TFWC Control after the first pkt lost
	int window_;		// receiver's window size
	int cwnd_;			// congestion control window size
	int ctrl_cwnd_;		// window's controlled cwnd size
	int tmp_cwnd_;		// temporary cwnd value
	int ssthresh_;		// slow start threshold
	int congest_iteration_;

	// latest 3 packets that are expected to be received
	int margin_[NUMDUPACK];
	// "isThere" becomes true when a seqno is in AckVec
	bool isThere_;

	/*
	 * RTT action
	 */
	// update RTT
	virtual void update_rtt(double tao);

	// calculate a new RTO when cwnd goes less than 2
	void new_rto(double tao);

	double tfwc_tick_;	// tfwc tick
	double boot_time_;	// where between ticks from this system came up

	double rtt_sample_;	// sampled rtt
	double srtt_;		// smoothed round trip time
	double rttvar_;		// rtt variation
	double rto_;
	double minrto_;		// minimum rto allowed
	double maxrto_;		// maximum rto
	bool isRateDriven_;	// is rate-based timer driven?
	double alpha_;		// smoothing factor for rtt/rto calculation
	double beta_;		// smoothing factor for rtt/rto calculation
	double g_;			// timer granularity
	int k_;				// k value
	int t_rtt_;			// RTT
	int t_rttvar_;		// RTT Variance
	int t_srtt_;		// Smoothed RTT
	int srtt_init_;		// initial value for t_srtt_
	int rttvar_init_;	// initial value for t_rttvar_
	int rttvar_exp_;	// exponent of multiple for t0_
	double sqrtrtt_;	// the mean of the sqrt of RTT
	double t0_;			// t0 value at the TCP throughput equation
	double df_;			// decay factor
	double tcp_tick_;	// TCP tick

	// first lost packet
	// (used for ts_ measurement only at the very first lost packet)
	int firstLostPkt_;	

	/*
	 * TFWC action after the first loss
	 */
	// find a missing packet sequence number in the received AckVec
	bool isHole(hdr_tfwc_ack* tfwcah, int end, int begin);

	// dupack action
	void dupack_action();

	// main TFWC cwnd control method
	void ctrl_win(hdr_tfwc_ack* tfwcah);

	// update loss history
	void loss_history(hdr_tfwc_ack* tfwcah);

	void pseudo_p();			// calculating a faked p_
	void pseudo_history();		// creating a faked loss history
	void gen_weight();			// generating weights
	void avg_loss_interval();	// computing average loss interval

	bool isDupAck_;	// is dupack_action() called before?
	double f_p_;	// f(p) = sqrt(2/3)*p + 12*p*(1+32*p^2)*sqrt(3/8)*p
	double pseudo_p_;// a faked packet loss probability
	double pseudo_interval_;// a faked packet loss interval
	double p_;		// packet loss probability
	double t_win_;		// temporal cwin size to get p_ value
	double ts_;		// timestamp for last lost packet
	double *tsvec_;		// timestamp vector
	double avg_interval_;	// average loss interval
	int firstvec_;		// first tempvec element
	int lastvec_;		// last tempvec element
	int history_[HSZ+1];	// loss interval history
	double weight_[HSZ+1];	// weight for calculating avg_loss_interval_
	double I_tot_;		// total sum 
	double I_tot0_;		// from 0 to n-1
	double I_tot1_;		// from 1 to n
	double tot_weight_;	// total weight
	bool isFirstLostSeen_;	// is this first packet loss event?
	bool isLoss_;		// were there any lost packet?
	int hsz_;		// current history size
	int alive_;		// have we shut down?

	/*
	 * Rtx Timer
	 */
	TfwcRtxTimer rtx_timer_;
	bool isRtxTimerReset_;		// has the RtxTimer been reset?
	void set_rtx_timer();		// set retransmission timer
	void reset_rtx_timer(int);	// reset retransmission timer
	void backoff_timer();		// backoff the timer
	int backoff_;				// multiplier, 1 if not backed off 

	/*
	 * Dynamic state
	 */
	int seqno_;			// pkt sequence number
	int last_ack_;		// last ack received so far
	int ackofack_;		// initial ackofack_ value
	int nackpkt_;		// number of ack pkt received
	int ndatapkt_;		// number of data pkt sent
	int dupacks_;		// duplicate ack
	int lost_pkt_seq_;	// lost packet sequence number
	int pktSize_;		// data packet size

	/*
	 * Faking loss rate for TFWC protocol validation
	 */
	bool isFakeLoss_;	// is faking the loss probability on?
	int f_init_;		// initial fake count
	int f_case_;		// fake loss scenarios
	bool f_sent_;		// is the previous packet has been sent?
	void fake_loss(Packet* pkt);

	/*
	 * Breaking Phase Effect
	 */
	bool isBreakPhase_;	// artificially break phase effect?
	int p_case_;		// break phase effect scenarios
	void break_phase();	// different cases for breaking phase effect

	/*
	 * Printings
	 */
	//print history information
	void print_history();
	void print_history_element(int i);

	// print received AckVec
	void print_ackvec(hdr_tfwc_ack* tfwcah);

	// print packet timestamp
	void print_timestamp(hdr_tfwc* tfwch);
};
#endif
