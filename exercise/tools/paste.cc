/*
 * Copyright(c) 2008-2010 University College London
 * All rights reserved.
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
#include <stdlib.h>
#include <sys/types.h>

using namespace std;

int main (int argc, char *argv[]) {

	string index = argv[1];
	string nil, hex, chex;
	string tzero, win;
	double time, ctime;
	int val;
	double cutoff = atof(argv[2]); cutoff = cutoff;
	int num = atoi(argv[3]);
	ifstream fin_tzero (argv[4]);	// tfwc_to_#.tr
	ifstream fin_win (argv[5]);		// tfwc_cwnd_#.tr
	ofstream fout, ftmp;

	vector<int> iv;	// index vector
	for (int i = 1; i <= num; i++)
		iv.push_back(i);

	// file test
	ifstream ft_t0 (argv[4]);
	ifstream ft_win (argv[5]);
	// read first line
	if (ft_win.is_open()) {
		getline(ft_win, win);
		istringstream cwnd(win);
		cwnd >> ctime >> val >> chex;
		ft_win.close();
	}

	// read first line
	if (ft_t0.is_open()) {
		getline(ft_t0, tzero);
		istringstream t0(tzero);
		t0 >> time >> hex;
		ft_t0.close();
	} else {
//		bool isThere = false;
//		stringstream ts;
//		for (u_int i = 0; i < iv.size(); i++) {
//			ts << iv.at(i);
//			if(index.compare(ts.str())) isThere = true;
//		}
//		if (isThere) {
			ftmp.open(argv[4]);
			ftmp << ctime << "\t" << chex << endl;
			ftmp.close();
//		} else
//			return 0;
	}

	// hex code is not equal
	if (chex.compare(hex)) {
		fin_win.close();
		fin_tzero.close();
		return 0;
	} 
	// hex code is equal
	else {
		// erase this index from iv
//		stringstream ts;
//		for (u_int i = 0; i < iv.size(); i++) {
//			ts << iv.at(i);
//			if (index.compare(ts.str()))
//				iv.erase(iv.begin()+i);
//		}

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
			cout << "error opening file: " << argv[4] << endl;
			exit(1);
		}

		// cwnd map
		map <double, int> winmap;
		map <double, int>::iterator winitr;
		if (fin_win.is_open()) {
			while (getline(fin_win, win)) {
				istringstream cwnd(win);
				cwnd >> time >> val >> chex;
				winmap[time] = val;
			}
			fin_win.close();
		} else {
			cout << "error opening file: " << argv[5] << endl;
			exit(1);
		}

		stringstream ss;
		ss << "trace/tfwc_to_" << index << ".xg";
		fout.open(ss.str().c_str());
		// mark timeout location at cwnd size
		for (winitr = winmap.begin(); winitr != winmap.end(); winitr++) {
			for (u_int i = 0; i < tv.size(); i++) {
				if (tv.at(i) == winitr->first)
					fout << winitr->first << "\t" << winitr->second << endl;
			}
		}
		fout.close();

		return 0;
	} // end of hex code check
}
