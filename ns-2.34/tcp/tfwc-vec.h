/*
 * Copyright(c) 2003-2010 University College London
 * All rights reserved.
 *
 * AUTHOR: Soo-Hyun Choi <s.choi@.cs.ucl.ac.uk>
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

#ifndef ns_tfwc_vec_h
#define ns_tfwc_vec_h

#include <iostream>
#include "agent.h"
#include "packet.h"
#include "ip.h"
#include "timer-handler.h"
#include "random.h"

class AckVecElm;

/*
 * TFWC Ack Vector Class
 */
class AckVec {
    public:
	// default constructor
	AckVec();

	// destructor
	~AckVec();

	// ackvec size
	int ackv_size();

	// insert from head
	void ackv_insert_head(int seqno);

	// insert from tail
	void ackv_insert_tail(int seqno);

	// insert an ackvec 
	void ackv_insert(int seqno, AckVecElm *elm);

	// search an ackvec
	AckVecElm* ackv_search(int seqno);

	// bool search
	bool ackv_bool_search(int seqno);

	// print an ackvec
	void ackv_print(ostream &out = cout);

	// delete AckVecElm from head
	void ackv_del_head();

	// delete AckVecElm all
	void ackv_del_all();

	// delete AckVecElm
	void ackv_del(int seqno);

	// copy ack vector
	void ackv_clone(AckVec* orig);

	// compare AckVecElm between headp and headp - 1
	int ackv_comp(); 

	// get the value of what the header contains
	int ackv_headval();

	// get the value of what the tail contains
	int ackv_tailval();

	// get the value of what the nth ackvec contains
	int ackv_nthval(int nth);

	// head pointer
	AckVecElm* ackv_head() { return headp_; }

    private:
	void sizeup() { ++size_; }		// increase AckVec size
	void sizedown() { --size_; }	// decrease AckVec size

	AckVecElm *headp_;	// tfwcAV head pointer
	AckVecElm *tailp_;	// tfwcAV tail pointer
	int size_;			// tfwcAV size
};

/*
 * TFWC Ack Vector Element Class
 */
class AckVecElm {
public:
	// friend declaration with AckVec class
	friend class AckVec;

	// ackvec elm constructor w/ parameters
	AckVecElm(int seqno, AckVecElm *elm = NULL);

	// set as next AckVecElm
	void next(AckVecElm* link) { next_ = link; }

	// next AckVecElm
	AckVecElm* next() { return next_; }	

	// put AckVecElm value
	void putval(int val) { seqno_ = val; }

	// get AckVecElm value
	int getval() { return seqno_; }

private:
	AckVecElm *next_;	// next AckVecElm pointer
	int seqno_;			// AckVecElm item
};
#endif
