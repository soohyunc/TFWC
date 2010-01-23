/*
 * Copyright(c) 2010 University College London
 * All rights reserved.
 *
 * AUTHOR: Soo-Hyun Choi <s.choi@cs.ucl.ac.uk>
 *         UCL Computer Science Department
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
		cout << "Usage: ./ipa [tcp|tfrc|tfwc] [thru|loss|...] [index] [cutoff] [trace_file]" << endl;
		exit (0);
	}

	string option = argv[1];
	string signal = argv[2];
	int index = atoi(argv[3]);
	double cutoff = atof(argv[4]);
	ifstream fin (argv[5]); 
	ofstream fout;

	// variables
	string items, stat;
	int psize;
	double currtime = 0.0;
	double prevtime = 0.0;
	double diff = 0.0;
	int count = 0;

	if (fin.is_open()) {
		// preparing for the output file
		stringstream ssxg, sstr;
		ssxg << "trace/" << option << "_" << signal 
			<< "_" << index << ".dat";
		fout.open(ssxg.str().c_str());

		// get input file stream
		while (getline(fin, items)) {
			istringstream is(items);
			is >> stat >> currtime >> psize;
			// when only received status
			if(!strcmp(stat.c_str(), "r")) {
				if (currtime > cutoff) {
					diff += (currtime - prevtime);
					count++;
				}
				prevtime = currtime;
			}
		}
		diff = diff/count;
		fout << diff << endl;

		fin.close();
		fout.close();
	}

	return 0;
}
