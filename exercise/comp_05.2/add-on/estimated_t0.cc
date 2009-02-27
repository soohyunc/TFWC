// $Id$

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
