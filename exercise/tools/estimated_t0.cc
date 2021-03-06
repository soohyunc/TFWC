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

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>
#include <map>
#include <cmath>
#include <math.h>
#include <stdlib.h>
#include <sys/types.h>

using namespace std;

int main (int argc, char *argv[]) {

	string index = argv[1];
	string nil, hex;
	string tzero, thru;
	double time;
	double val;
	int cutoff = atoi(argv[2]);
	ifstream fin_tzero (argv[3]); // tfwc_to_?.tr
	ifstream fin_thru (argv[4]);// tfwc_thru_?.xg
	ofstream fout;

	// timeout vector
	vector<double> tv;
	if (fin_tzero.is_open()) {
		while (getline(fin_tzero, tzero)) {
			istringstream t0(tzero);
			t0 >> time >> hex;
			tv.push_back(time);
		}
		fin_tzero.close();
	} else {
		cout << "error opening file: " << argv[3] << endl;
		fout.open(argv[3]);
		fout << cutoff << "\t" << 0 << endl;
		fout.close();
	}

	// throughput map
	map <double, double> thrumap;
	map <double, double>::iterator thruitr;
	if (fin_thru.is_open()) {
		while (getline(fin_thru, thru)) {
			istringstream thruput(thru);
			thruput >> time >> val;
			thrumap[time] = val;
		}
		fin_thru.close();
	} else {
		cout << "error opening file: " << argv[4] << endl;
		exit(1);
	}

	stringstream ss;
	ss << "trace/tfwc_to_est_" << index << ".xg";
	fout.open(ss.str().c_str());
	// mark timeout location at throughput value
	int instance = 0;
	for (thruitr = thrumap.begin(); thruitr != thrumap.end(); thruitr++) {
		for (u_int i = 0; i < tv.size(); i++) {
			if (abs(tv.at(i) - thruitr->first) < 0.5) {
				fout << thruitr->first << "\t" << thruitr->second << endl;
				tv.erase(tv.begin()+i);
				instance++;
			}
		}
	}
	// make a bogus line (for gnuplot)
	if (!instance)
		fout << cutoff << "\t" << 0 << endl;
	fout.close();

	return 0;
}
