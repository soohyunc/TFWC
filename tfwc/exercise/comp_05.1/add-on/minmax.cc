/*
 * Copyright(c) 2006-2008 University College London
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *      This product includes software developed by the Computer Systems
 *      Engineering Group at Lawrence Berkeley Laboratory.
 * 4. Neither the name of the University nor of the Laboratory may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * $Id$
 */

/*
 * compute min, max, and average from an input file
 *
 * Usage: ./minmax [tcp|tfrc|tfwc] [inst|avg] [queue_weight] [input_file]
 */

#include <iostream>
#include <fstream>
#include <string>
#include <stdlib.h>
#include <string.h>

using namespace std;

int main (int argc, char *argv[]) {
	double	min	= 1000000.0;
	double	max 	= -1.0;
	double	sum 	= 0.0;
	double	avg 	= 0.0;
	int	count 	= 0;
	double	val;

	if (argc < 4) {
		cout << "Usage: ./minmax [tcp|tfrc|tfwc] [inst|avg] [queue_weight] [input_file]" << endl;
		exit (0);
	}

	ifstream fname (argv[4]); 
	ofstream frec;

	if (fname.is_open()) {
		while(!fname.eof()) {
			fname >> val;
			//cout << val << endl;

			min = (min > val) ? val : min;
			max = (max < val) ? val : max;
			sum += val;
			count++;
		}
		fname.close();
	} else {
		cout << "Unable to open file!!!" << endl;
	}

	avg = sum / (count-1);

	if (!strcmp(argv[1],"tcp")) {
		if (!strcmp(argv[2],"inst")) {
			frec.open ("trace/tcp_q_weight_inst.xg", ios::app);
			frec << argv[3] << "   " << avg << "   " << min << "   " << max << endl;
			frec.close();
		} else if (!strcmp(argv[2],"avg")) {
			frec.open ("trace/tcp_q_weight_avg.xg", ios::app);
			frec << argv[3] << "   " << avg << "   " << min << "   " << max << endl;
			frec.close();
		}
	} else if (!strcmp(argv[1],"tfrc")) {
		if (!strcmp(argv[2],"inst")) {
			frec.open ("trace/tfrc_q_weight_inst.xg", ios::app);
			frec << argv[3] << "   " << avg << "   " << min << "   " << max << endl;
			frec.close();
		} else if (!strcmp(argv[2],"avg")) {
			frec.open ("trace/tfrc_q_weight_avg.xg", ios::app);
			frec << argv[3] << "   " << avg << "   " << min << "   " << max << endl;
			frec.close();
		}
	} else if (!strcmp(argv[1],"tfwc")) {
		if (!strcmp(argv[2],"inst")) {
			frec.open ("trace/tfwc_q_weight_inst.xg", ios::app);
			frec << argv[3] << "   " << avg << "   " << min << "   " << max << endl;
			frec.close();
		} else if (!strcmp(argv[2],"avg")) {
			frec.open ("trace/tfwc_q_weight_avg.xg", ios::app);
			frec << argv[3] << "   " << avg << "   " << min << "   " << max << endl;
			frec.close();
		}
	}

	return 0;
}
