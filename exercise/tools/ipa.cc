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

// inter-packet interval calculator

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <algorithm>
#include <vector>
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
	double tot = 0.0;
	double avg = 0.0;		// arithmetic average
	double median = 0.0;	// median
	//double div = 0.0;		// standard diviation
	int count = 0;			// total number of intervals
	int vsize = 0;			// vector size (should be equal to count)

	// inter-arrival vector
	vector<double> iav;
	vector<double>::iterator itr;

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
            diff = currtime - prevtime;

            iav.push_back(diff);
            tot += diff;
            count++;
            //cout << count << " " << diff << endl;
          }
          prevtime = currtime;
        }
      } 

      // sort inter-arrival time
      sort (iav.begin(), iav.end());
      vsize = iav.size();

      if (vsize%2) {
        // vsize is odd number
        median = iav.at((vsize + 1)/2);	
      } else {
        // vsize is even number
        median = iav.at(vsize/2) +iav.at(vsize/2 + 1);
        median /= 2;
      }

      // median
      fout << median << endl;

      // arithmetic average
      avg = tot/count;
      //cout << avg << endl;
      //fout << avg << endl;

      fin.close();
    } // if(fin.is_open())

    fout.close();
	return 0;
}
