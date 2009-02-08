// $Header: /home/narwhal/u0/soohyunc/CVS_SERV/TFWC/nam-1.11/animator.cc,v 1.1.1.1 2005/05/08 22:37:16 soohyunc Exp $ 

#include "animator.h"

class NetworkAnimatorClass : TclClass {
public: 
	NetworkAnimatorClass() : TclClass("Animator") {}
	TclObject* create(int, const char*const*) {
		return (new NetworkAnimator());
	}
} networkanimator_class;

// We put it here in C++ because we need to keep a pointer to it 
// in NetModel, etc.
int NetworkAnimator::command(int argc, const char *const* argv) 
{
	// In case we want to put something here.
	return TclObject::command(argc, argv);
}
