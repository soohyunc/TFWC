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

#include <iostream>
#include <string>
#include <fstream>
#include <sstream>
#include <vector>
#include <map>
#include <stdlib.h>

using namespace std;

// print instruction
void print_instruction () {
	cout << "Usage: ./thru_by_eq [file] [option]" << endl;
	exit (0);
}

// main body
int main (int argc, char *argv[]) {

	// print instruction
	if (argc < 3) {
		print_instruction();
	}

	ifstream fin (argv[1]);	// input file stream
	ofstream fout;			// output file stream
	string nil, hex;
	double time, tx, rto, t0, rtt, p;
	string sline;
	string option = argv[2];

	// map declaration
	map <string, map <double, double> > values;

	// iterator declaration
	map <string, map <double, double> >::iterator pitr;
	map <double, double>::iterator itr;

	if(fin.is_open()) {
		while (getline(fin, sline)) {
			istringstream isOk(sline);
			vector<string> svec;	// vector to copy string stream
			string str;

			while (isOk >> str)
				svec.push_back(str);	// push stream to vector

			// check vector size (input element should be 12)
			if(svec.size() == 12) {	
				stringstream tmp;

				// copy vector element to temporary string stream
				for (int i=0; i < 12; i++ )
					tmp << svec.at(i) << " ";

				if (tmp >> time >> nil >> tx >> nil >> rto >> nil >>  
						t0 >> nil >> rtt >> nil >> p >> hex)
					values[hex][time] = tx/1000000;
			}
		}
		fin.close();	// close file
	} else {
		cout << "error opening file!" << endl;
		exit (1);
	}

	int i;
	int size = values.size();

	for (i=0, pitr=values.begin(); i<size && pitr!=values.end(); pitr++, i++) {

		// string stream (to create file names accordingly)
		stringstream ss;
		ss << "trace/" << option << "_thru_by_eq_" << i+1 << ".xg";

		// opne a file and prepare to write
		fout.open(ss.str().c_str());

		// record "+/-/d" and then time stamp, and packet size
		for (itr = pitr->second.begin(); itr != pitr->second.end(); itr++)
			fout << itr->first << "\t" << itr->second << "\t" << endl;
		
		fout.close();
	}

	return 0;
}

