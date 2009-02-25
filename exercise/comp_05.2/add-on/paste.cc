// $Id$

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>
#include <map>
#include <stdlib.h>

using namespace std;

int main (int argc, char *argv[]) {

	string index = argv[1];
	string nil, hex;
	string tzero, win;
	double time;
	int val;
    ifstream fin_tzero (argv[2]); // tfwc_to_?.tr
    ifstream fin_win (argv[3]);	// tfwc_cwnd_?.xg
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
		cout << "error opening file: " << argv[2] << endl;
		exit(1);
	}

	// cwnd map
	map <double, int> winmap;
	map <double, int>::iterator winitr;
	if (fin_win.is_open()) {
		while (getline(fin_win, win)) {
			istringstream cwnd(win);
			cwnd >> time >> val;
			winmap[time] = val;
		}
		fin_win.close();
	} else {
		cout << "error opening file: " << argv[3] << endl;
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
}
