// $Id$

#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int main (int argc, char *argv[]) {

    ifstream fin (argv[1]);
    ofstream fout;
    int k = 0;      // index number
	double avg, item, total=0;

    if(fin.is_open()) {
		while (fin >> item) {
        	total += item;
    	    k++;
		}
		fin.close();
    }

    avg = total/k;
	cout << avg << endl;

	return 0;
}
