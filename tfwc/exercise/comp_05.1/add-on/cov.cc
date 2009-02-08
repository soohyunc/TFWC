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
 * Usage: ./cov [tcp|tfrc|tfwc] [avg_thru] [inst_thru] [bandwidth] [# of flows]
 */

#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
#include <stdlib.h>
#include <string.h>

using namespace std;

int main (int argc, char *argv[]) {

	if (argc < 5) {
		cout << "Usage: ./cov [tcp|tfrc|tfwc] [avg_thru] [inst_thru] [bandwidth] [# of flows]" << endl;
		exit (0);
	}

	ifstream fin (argv[3]); 
	ofstream fout;

	int	k = 0;		// index number
	double cov;		// coefficient of variation
	double inst_thru;	// instantaneous throughput
	double term = 0.0;

	double avg_thru = atof(argv[2]);
	double bw = atof(argv[4]);
	int src = atoi(argv[5]);

	if (fin.is_open()) {
		while(!fin.eof()) {
			fin >> inst_thru;
			term += pow((inst_thru - avg_thru), 2.0);
			k++;
		}
		fin.close();
	} else {
		cout << "Unable to open file!!!" << endl;
	}

	cov = sqrt(term/(k-1))/avg_thru;

	if (!strcmp(argv[1],"tcp")) {
		fout.open ("trace/tcp_cov.xg", ios::app);
		fout << bw << "   " << src << "   " << cov << endl;
		fout.close();
	} else if (!strcmp(argv[1],"tfrc")) {
        fout.open ("trace/tfrc_cov.xg", ios::app);
        fout << bw << "   " << src << "   " << cov << endl;
        fout.close();
	} else if (!strcmp(argv[1],"tfwc")) {
        fout.open ("trace/tfwc_cov.xg", ios::app);
        fout << bw << "   " << src << "   " << cov << endl;
        fout.close();
	}

	return 0;
}
