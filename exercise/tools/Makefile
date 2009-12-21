# $Id$

CPP	:= g++
SRCS	:= $(wildcard *.cc)
OBJS	:= $(SRCS:.cc=.o)
CFLAGS	:= -Wall -g -O2
RM	:= rm -f

.PHONY:	clean distclean

all: $(SRCS)
	$(CPP) $(CFLAGS) minmax.cc -o minmax
	$(CPP) $(CFLAGS) fairness.cc -o fairness
	$(CPP) $(CFLAGS) round.cc -o round
	$(CPP) $(CFLAGS) breakline.cc -o breakline
	$(CPP) $(CFLAGS) cov.cc -o cov
	$(CPP) $(CFLAGS) avg_cov.cc -o avg_cov
	$(CPP) $(CFLAGS) average.cc -o average
	$(CPP) $(CFLAGS) average_i.cc -o average_i
	$(CPP) $(CFLAGS) map.cc -o map
	$(CPP) $(CFLAGS) indiv.cc -o indiv
	$(CPP) $(CFLAGS) loss_by_eq.cc -o loss_by_eq
	$(CPP) $(CFLAGS) thru_by_eq.cc -o thru_by_eq
	$(CPP) $(CFLAGS) s_ratio.cc -o s_ratio
	$(CPP) $(CFLAGS) timeout.cc -o timeout
	$(CPP) $(CFLAGS) paste.cc -o paste
	$(CPP) $(CFLAGS) estimated_t0.cc -o estimated_t0
	$(CPP) $(CFLAGS) anti-alias.cc -o anti-alias
	$(CPP) $(CFLAGS) ewma.cc -o ewma

clean:
	$(RM) minmax fairness round breakline cov average map indiv timeout ewma \
loss_by_eq thru_by_eq s_ratio paste average_i estimated_t0 avg_cov anti-alias

