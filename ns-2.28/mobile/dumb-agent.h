// Copyright (c) 2000 by the University of Southern California
// All rights reserved.
//
// Permission to use, copy, modify, and distribute this software and its
// documentation in source and binary forms for non-commercial purposes
// and without fee is hereby granted, provided that the above copyright
// notice appear in all copies and that both the copyright notice and
// this permission notice appear in supporting documentation. and that
// any documentation, advertising materials, and other materials related
// to such distribution and use acknowledge that the software was
// developed by the University of Southern California, Information
// Sciences Institute.  The name of the University may not be used to
// endorse or promote products derived from this software without
// specific prior written permission.
//
// THE UNIVERSITY OF SOUTHERN CALIFORNIA makes no representations about
// the suitability of this software for any purpose.  THIS SOFTWARE IS
// PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES,
// INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
//
// Other copyrights might apply to parts of this software and are so
// noted when applicable.

// dumb-agent.h

// A simple wireless rtg agent that simply fwds pkts
// incoming pkts to dmux and outgoing pkts to lower LL
// created to test smac protocol

#ifndef NS_DUMB_AGENT_H
#define NS_DUMB_AGENT_H

#include "agent.h"
#include "ll.h"
#include "trace.h"
#include "classifier-port.h"

class DumbAgent : public Agent {
 public:
  DumbAgent();
  virtual int command(int argc, const char*const* argv);
  virtual void recv(Packet*, Handler*);
  void trace(char* fmt, ...);
 protected:
  Trace *tracetarget_;
  PortClassifier *dmux_;
};


#endif // NS_DUMB_AGENT_H

