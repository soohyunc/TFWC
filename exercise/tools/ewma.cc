/*
 * Copyright(c) 2008-2010 University College London
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
 *    documentation and/or other materials provided with the
 *    distribution.
 * 3. Neither the name of the University nor of the Laboratory may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE
 *
 * $Id$
 */

// EWMA Low-pass Filter
// Usage: ./ewma [tcp|tfrc|tfwc] [index] [granul] [cutoff] [trace_file] 

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <math.h>
#include <stdlib.h>
#include <string.h>

using namespace std;

int main (int argc, char *argv[]) {

	if (argc < 5) {
		cout << "Usage: ./ewma [tcp|tfrc|tfwc] [thru|loss|...] [index] [granul] [cutoff] [trace_file]" << endl;
		exit (0);
	}

	string option = argv[1];
	string signal = argv[2];
	int index = atoi(argv[3]);
	double granul = atof(argv[4]);
	double cutoff = atof(argv[5]);
	ifstream fin (argv[6]); 
	ofstream fout_xg, fout_tr;

	// variables
	string items, stat;
	double currtime;
	int psize;
	double currthru = 0.0;
	double prevthru = 0.0;
	double time = 0.0;
	int bits = 0;
	double a = 0.2;

	if (fin.is_open()) {
		// preparing for the output file
		stringstream ssxg, sstr;
		ssxg << "trace/" << option << "_ewma_" << signal 
			<< "_" << index << ".xg";
		sstr << "trace/" << option << "_ewma_" << signal 
			<< "_" << index << ".tr";
		fout_xg.open(ssxg.str().c_str());
		fout_tr.open(sstr.str().c_str());

		// get input file stream
		while (getline(fin, items)) {
			istringstream is(items);
			is >> stat >> currtime >> psize;

			// when only received status
			if(!strcmp(stat.c_str(), "r")) {
				// add bits
				if (currtime-time <= granul)
					bits += psize * 8;

				if (currtime-time > granul) {
					// timestamp
					time += granul;
					// currthru = bits/second
					currthru = (double)bits/granul;
					// Mb/s
					currthru /= 1000000.0;

					// EWMA equation
					currthru = a * currthru + (1-a) * prevthru;

					if (currtime > cutoff)  {
						fout_xg << time << " " << currthru << endl;
						fout_tr << stat << " " << time << " " 
							<< psize << endl;
					}
					prevthru = currthru;
					bits = psize * 8;
				}

				// we still need do EWMA while this condition is met
				while (currtime-time > 2 * granul) {
					// move timestamp
					time += granul;
					// leftover bits
					currthru = (double)bits/granul;
					currthru /= 1000000.0;
					// EWMA
					currthru = a * currthru + (1-a) * prevthru;

					if (currtime > cutoff)
						fout_xg << time << " " << currthru << endl;

					// store currthru
					prevthru = currthru;
					// init bits
					bits = 0.0;
				}
			} // if received
		} // while

		fin.close();
		fout_xg.close();
		fout_tr.close();
	} else {
			cout << "Unable to open file!: " << argv[6] << endl;
	}

	return 0;
}
