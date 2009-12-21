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
#include <stdlib.h>

using namespace std;

int main (int argc, char *argv[]) {

	string option = argv[1];
	int index = atoi(argv[2]);
	ifstream fin (argv[3]);
	ofstream fout_thru, fout_avg;
	int k = 0;      // index number
	double avg, item, time, total=0;

	if(fin.is_open()) {
		stringstream ss_thru;
		ss_thru << "trace/" << option << "_thru_" << index << ".dat";
		fout_thru.open(ss_thru.str().c_str());
		while (fin >> time >> item) {
			total += item;
			k++;
			fout_thru << item << endl;
		}
		fout_thru.close();
		fin.close();
	}

	avg = total/k;

	stringstream ss_avg;
	ss_avg << "trace/" << option << "_thru_avg_" << index << ".dat";
	fout_avg.open(ss_avg.str().c_str());
	fout_avg << avg << endl;
	fout_avg.close();

	return 0;
}
