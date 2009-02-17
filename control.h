/*
 * Copyright(c) 2009 University College London.
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

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define POLYCOF 62.5

int TfwcAgent::control_functions (bool flag, char c, int window, double p, 
		double now, double rtt) {

	double y = 0.0;
	double peak = 0.0;
	double cutoff = 0.0;
	double median = 0.0;
	double coeff = 0.0;
	double factor = 0.0;

	switch (c) {
		case 'o':		// just once
			if (!flag)
				window++;
			set_inflated();
			factor = -1.0;
			break;
		case 'l':		// linear functions
			double cool;
			if (p < .1)
				cool = 5 * p;
			else
				cool = p;

			factor = (cool < 1.0) ? cool : 1.0;
			break;
		case 'g':		// gaussian functions
			double gauss;
			peak = 0.5;
			median = 0.1;

			if (p < .1) {
				coeff = .035;
				gauss = peak * exp(pow((p - median),2.0) 
						/ (-2.0 * pow(coeff, 2.0)));
			} else {
				coeff = .075;
				gauss = peak * exp(pow((p - median),2.0) 
						/ (-2.0 * pow(coeff, 2.0)));
			}

			factor = (gauss < 1.0) ? gauss : 1.0;
			break;
		case 'p':		// polynomial functions
			double poly;
			y = .5;
			cutoff = .2;

			if  (p < cutoff)
				poly = POLYCOF * pow((p - cutoff), 3.0) + y;
			else
				poly = pow((p - cutoff), 2.0) + y;

			factor = (poly < 1.0) ? poly : 1.0;
			break;
		case 'm':		// mixture functions
			double mix;
			peak = .5;
			median = .1;
			coeff = .035;
			cutoff = .1;

			y = peak * exp( pow((cutoff - median),2.0) 
					/ (-2.0 * pow(coeff, 2.0)) );

			if (p < .01)
				mix = 5 * p;
			else if (p >= .01 && p < cutoff)
				mix = peak * exp( pow((p - median),2.0) 
						/ (-2.0 * pow(coeff, 2.0)) );
			else
				mix = 2.0 * pow((p - .1), 2.0) + y;

			factor = (mix < 1.0) ? mix : 1.0;
			break;
		default:
			factor = -1.0;
	} // switch


	// generate random number [0:100)
	//srand (now * p);
	double n = (double) rand() / (double) 0x7fffffff;

	// finally, inflate 'window' according to the given case
	if (n < factor) {
		return (window + 1);
	} else {
		return window;
	}
}
