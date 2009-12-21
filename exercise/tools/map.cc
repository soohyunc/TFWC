/*
 * Copyright(c) 2008-2010, Soo-Hyun Choi <s.choi@cs.ucl.ac.uk>
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
#include <string>
#include <fstream>
#include <sstream>
#include <vector>
#include <map>
#include <string.h>
#include <stdlib.h>

using namespace std;

// print instruction
void print_instruction () {
	cout << "Usage: ./map [file] [option]" << endl;
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
	string sline;			// input string line
	string nil, hex, option;
	double time, val;

	option = argv[2];

	// map declaration
	typedef multimap <double, double> t_mmap;
	typedef map <string, t_mmap> t_map;
	t_map imap;

	// iterator declaration
	multimap <double, double>::iterator itr;
	map <string, t_mmap>::iterator pitr;

	if(fin.is_open()) {
		while (getline(fin, sline)) {
			istringstream isOk(sline);
			vector<string> svec;		// vector to copy string stream
			string str;

			while (isOk >> str)
				svec.push_back(str);	// push stream to vector

			// check vector size 
			// the number of input element should be exactly 5
			if (svec.size() == 5) {
				stringstream tmp;

				for (int i = 0; i < 5; i++)
					tmp << svec.at(i) << " ";

				if (tmp >> nil >> nil >> time >> val >> hex) 
					imap[hex].insert(t_mmap::value_type(time, val));
			}
		}
		fin.close();	// close file
	} else {
		cout << "error opening file!" << endl;
		exit (1);
	}

	int i;
	int size = imap.size();	// map size (no. of pointers)
	ofstream foxg;

	for (i=0, pitr=imap.begin(); i<size && pitr!=imap.end(); pitr++, i++) {

		// string stream (to create file names accordingly)
		stringstream sstr;
		if(!strcmp(option.c_str(), "tfwc_cwnd")) {
			stringstream ssxg;
			sstr << "trace/" << option << '_' << i+1 << ".tr";
			ssxg << "trace/" << option << '_' << i+1 << ".xg";
	    	fout.open(sstr.str().c_str()); 
	    	foxg.open(ssxg.str().c_str());
		} else {
			sstr << "trace/" << option << '_' << i+1 << ".xg";
	    	fout.open(sstr.str().c_str());
		}

		// recording imap
		if(!strcmp(option.c_str(), "tfwc_cwnd")) {
			for (itr = pitr->second.begin(); itr != pitr->second.end(); itr++) {
				foxg << itr->first << "\t" << itr->second << endl;
				fout << itr->first << "\t" << itr->second 
					<< "\t" << pitr->first << endl;
			}
			foxg.close();	// close file
			fout.close();	// close file
		} else {
			for (itr = pitr->second.begin(); itr != pitr->second.end(); itr++)
				fout << itr->first << "\t" << itr->second << endl;
			fout.close();	// close file
		}
	}

	return 0;
}

