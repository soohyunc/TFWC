# $Id$

SOURCES=$(wildcard *.cc)
CPP = g++
CFLAGS = -Wall -g -O2
RM	:= rm -f

all: $(SOURCES)
	$(CPP) $(CFLAGS) minmax.cc -o minmax
	$(CPP) $(CFLAGS) fairness.cc -o fairness
	$(CPP) $(CFLAGS) round.cc -o round
	$(CPP) $(CFLAGS) breakline.cc -o breakline
	$(CPP) $(CFLAGS) cov.cc -o cov
	$(CPP) $(CFLAGS) average.cc -o average
	$(CPP) $(CFLAGS) map.cc -o map
	$(CPP) $(CFLAGS) indiv.cc -o indiv
	$(CPP) $(CFLAGS) loss_by_eq.cc -o loss_by_eq
	$(CPP) $(CFLAGS) thru_by_eq.cc -o thru_by_eq

clean:
	$(RM) minmax fairness round breakline cov average map indiv \
		loss_by_eq thru_by_eq

