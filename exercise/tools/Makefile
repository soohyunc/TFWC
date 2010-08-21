# $Id$

CPP	:= g++
SRCS	:= $(wildcard *.cc)
OBJS	:= $(SRCS:.cc=.o)
CFLAGS	:= -Wall -g -O2 -lstdc++
RM	:= rm -f

.PHONY:	all clean distclean

ALL = minmax fairness round breakline cov avg_cov average average_i map indiv loss_by_eq thru_by_eq s_ratio timeout paste estimated_t0 anti-alias ewma ipa

all: $(ALL)

minmax: minmax.cc
	$(CPP) $(CFLAGS) $< -o $@
fairness: fairness.cc
	$(CPP) $(CFLAGS) $< -o $@
round: round.cc
	$(CPP) $(CFLAGS) $< -o $@
breakline: breakline.cc
	$(CPP) $(CFLAGS) $< -o $@
cov: cov.cc
	$(CPP) $(CFLAGS) $< -o $@
avg_cov: avg_cov.cc
	$(CPP) $(CFLAGS) $< -o $@
average: average.cc
	$(CPP) $(CFLAGS) $< -o $@
average_i: average_i.cc
	$(CPP) $(CFLAGS) $< -o $@
map: map.cc
	$(CPP) $(CFLAGS) $< -o $@
indiv: indiv.cc
	$(CPP) $(CFLAGS) $< -o $@
loss_by_eq: loss_by_eq.cc
	$(CPP) $(CFLAGS) $< -o $@
thru_by_eq: thru_by_eq.cc
	$(CPP) $(CFLAGS) $< -o $@
s_ratio: s_ratio.cc
	$(CPP) $(CFLAGS) $< -o $@
timeout: timeout.cc
	$(CPP) $(CFLAGS) $< -o $@
paste: paste.cc
	$(CPP) $(CFLAGS) $< -o $@
estimated_t0: estimated_t0.cc
	$(CPP) $(CFLAGS) $< -o $@
anti-alias: anti-alias.cc
	$(CPP) $(CFLAGS) $< -o $@
ewma: ewma.cc
	$(CPP) $(CFLAGS) $< -o $@
ipa: ipa.cc
	$(CPP) $(CFLAGS) $< -o $@

clean:
	$(RM) $(ALL)

