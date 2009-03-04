// $Id$

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
