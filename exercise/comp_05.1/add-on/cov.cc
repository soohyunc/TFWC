/*
 * Copyright(c) 2008 University College London
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright 
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright 
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the
 *    distribution.
 *
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

/*
 * compute coefficient of variance (CoV)
 *
 * Usage: ./cov [tcp|tfrc|tfwc] [index] [avg_thru] [inst_thru] [bandwidth] 
 */

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
		cout << "Usage: ./cov [tcp|tfrc|tfwc] [index] [avg_thru] [inst_thru] \
[bandwidth]" << endl;
		exit (0);
	}

	string option = argv[1];
	int index = atoi(argv[2]);
	ifstream favg (argv[3]);
	ifstream fin (argv[4]); 
	double bw = atof(argv[5]);

	int	k = 0;		// index number
	double cov;		// coefficient of variation
	double inst_thru;	// instantaneous throughput
	double term = 0.0;
	double avg_thru;
	ofstream fout;
	string thru;

	// get average throughput value
	if(favg.is_open()) {
		while (!favg.eof())	{
			favg >> avg_thru;
		}
		favg.close();
	}

	if (fin.is_open()) {
		while (getline(fin, thru)) {
			istringstream t(thru);
			t >> inst_thru;
			term += pow((inst_thru - avg_thru), 2.0);
			k++;
		}
		fin.close();
	} else {
		cout << "Unable to open file!!!" << endl;
	}

	cov = sqrt(term/(k-1))/avg_thru;

	stringstream ss;
	ss << "trace/" << option << "_cov_" << index << ".dat";
	fout.open(ss.str().c_str());
	fout << bw << "\t" << cov << endl;
	fout.close();

	return 0;
}
