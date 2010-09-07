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
#include "flags.h"
#include "tfwc-vec.h"

/*
 * Ack Vector Constructor
 */
AckVec::AckVec() {
	headp_ = NULL;
	tailp_ = NULL;
	size_ = 0;
}

/*
 * Ack Vector Destructor
 */
AckVec::~AckVec() {
	ackv_del_all();
}

/*
 * Ack Vector Size
 */
int AckVec::ackv_size() {
	return size_;
}

/*
 * Ack Vector Insert from Head
 */
void AckVec::ackv_insert_head(int seqno) {
	AckVecElm *elm = new AckVecElm(seqno);

	if (!headp_)
		headp_ = tailp_ = elm;
	else {
		elm->next(headp_);
		headp_ = elm;
	}
	sizeup();
}

/*
 * Ack Vector Insert from Tail
 */
void AckVec::ackv_insert_tail(int seqno) {
	if (!tailp_)
		tailp_ = headp_ = new AckVecElm(seqno);
	else
		tailp_ = new AckVecElm(seqno, tailp_);

	sizeup();
}

/*
 * Ack Vector Insert
 */
void AckVec::ackv_insert(int seqno, AckVecElm *elm){
	new AckVecElm(seqno, elm);
	sizeup();
}

/*
 * Search an Ack Vector
 */
AckVecElm* AckVec::ackv_search(int seqno) {
	AckVecElm *elm = headp_;
	while (elm) {
		if (elm->getval() == seqno)
			break;
		elm = elm->next();
	}

	return elm;
}

/*
 * Bool Search
 */
bool AckVec::ackv_bool_search(int seqno) {
	AckVecElm *elm = headp_;
	bool retval = false;

	while (elm) {
		if (elm->getval() == seqno){
			retval = true;
			break;
		} else
			elm = elm->next();
	}

	return retval;
}

/*
 * Print an Ack Vector
 */
void AckVec::ackv_print(ostream &out) {
	//out << " []-- (" << size_ << ") (";
	out << " --(";

	AckVecElm *elm = headp_;
	while (elm) {
		out << elm->getval() << " ";
		elm = elm->next();
	}

	out << ")--\n";
}

/*
 * Delete AckVecElm from Head
 */
void AckVec::ackv_del_head() {
	if (headp_) {
		AckVecElm *elm = headp_;
		headp_ = headp_->next();

		sizedown();
		delete elm;
	}
}

/*
 * Delete AckVecElm all
 */
void AckVec::ackv_del_all() {
	while (headp_)
		ackv_del_head();

	size_ = 0;
	headp_ = tailp_ = 0;
}

/*
 * Delete AckVecElm
 */
void AckVec::ackv_del(int seqno) {
	AckVecElm *elm = headp_;
	AckVecElm *prev = elm;

	while(elm) {
		if (elm->getval() <= seqno) {
			prev->next(elm->next());
			delete elm;
			sizedown();
			elm = prev->next();
		} else {
			prev = elm;
			elm = elm->next();
		}
	}
}

/*
 * Ack Vector Element Comparison
 */
int AckVec::ackv_comp() {
	AckVecElm *elm = headp_;

	int current_seqnum = elm->getval();
	elm = elm->next();
	int prev_seqnum = elm->getval();

	return (current_seqnum - prev_seqnum);
}

/*
 * Copy Ack Vector
 */
void AckVec::ackv_clone(AckVec* orig) {
	AckVecElm *elm = orig->ackv_head();

	while(elm != NULL) {
		ackv_insert_tail(elm->getval());
		elm = elm->next();
	}
}

/*
 * Get the Ack Vector Header Value
 */
int AckVec::ackv_headval() {
	AckVecElm *elm = headp_;

	return elm->getval();
}

/*
 * Get the Ack Vector Tail Value
 */
int AckVec::ackv_tailval() {
	AckVecElm *elm = tailp_;

	return elm->getval();
}

/*
 * Get the n'th Ack Vector value from Head
 */
int AckVec::ackv_nthval(int nth) {
	/*
	 * (1) ackv_nthval() returns '0' if the ackvec is NULL.
	 *
	 * (2) ackv_nthval() returns the data value of the last ackvec,
	 *     when 'nth' is greater than the ackvec size.
	 */

	AckVecElm *elm = headp_;

	if(!headp_)
		return 0;

	/*
	 * if ackvec size is less than nth,
	 * then, nth value should not exceed the ackvec size
	 */
	nth = (size_ < nth) ? size_ : nth;

	for(int i = 1; i < nth; i++) {
		elm = elm->next();
	}

	return elm->getval();
}

/*
 * Ack Vector Element Constructor
 */
AckVecElm::AckVecElm(int seqno, AckVecElm *elm) : seqno_(seqno) {
	if (!elm)
		next_ = NULL;
	else {
		next_ = elm->next_;
		elm->next_ = this;
	}
}
