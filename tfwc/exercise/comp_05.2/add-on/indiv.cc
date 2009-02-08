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
#include <map>
#include <stdlib.h>

using namespace std;

// print instruction
void print_instruction () {
	cout << "Usage: ./indiv [file] [packet_type]" << endl;
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
	string nil, target, option;
	string pStatus, tPacket;
	double time, sId, dId;
	int pSize, aSeq, bSeq, psz=0;
	string sline;			// input string stream

	target = argv[2];	// target packet type

	// map declaration
	// note: we must use multimap here because time stamp can be duplicated
	typedef multimap <double, string> t_mmap;
	typedef map <double, t_mmap> t_map;
	t_map imap;

	// iterator declaration
	multimap <double, string>::iterator itr;
	map <double, t_mmap>::iterator pitr;

	if(fin.is_open()) {
		while (getline(fin, sline)) {
			istringstream isOk(sline);
			isOk >> pStatus;	// 1: packet received status
			isOk >> time;		// 2: time stamp
			isOk >> nil;		// 3: do not need this column
			isOk >> nil;		// 4: do not need this column
			isOk >> tPacket;	// 5: packet type
			isOk >> pSize;		// 6: packet size
			isOk >> nil;		// 7: do not need this column
			isOk >> nil;		// 8: do not need this column
			isOk >> sId;		// 9: source Id
			isOk >> dId;		// 10: destination Id
			isOk >> aSeq;		// 11: sequence number
			isOk >> bSeq;		// 12: sequence number

			// record map value if packet type matches
			if (!tPacket.compare(target)) {
				imap[sId].insert(t_mmap::value_type(time, pStatus));
				psz = pSize;	// this is actual packet size
			}
		}
		fin.close();	// close file
	} else {
		cout << "error opening file!" << endl;
		exit (1);
	}

	// packet classification
	if (target == "tcp")
		option = "tcp_indiv";
	else if (target == "tcpFriend")
		option = "tfrc_indiv";
	else if (target == "TFWC")
		option = "tfwc_indiv";
	else
		option = "unknown";

	int i;
	int size = imap.size();

	for (i = 0, pitr = imap.begin(); i < size && pitr != imap.end(); 
			pitr++, i++) {

		// string stream (to create file names accordingly)
		stringstream ss;
		ss << "trace/" << option << '_' << i+1 << ".tr";

		// opne a file and prepare to write
		fout.open(ss.str().c_str());

		// record "+/-/d" and then time stamp, and packet size
		for (itr = pitr->second.begin(); itr != pitr->second.end(); itr++)
			fout << itr->second << " " << itr->first << " " << psz <<endl;
		
		fout.close();
	}

	return 0;
}

