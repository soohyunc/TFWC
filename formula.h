#define MAXRATE 25000000.0 
#define SAMLLFLOAT 0.0000001

/*
 * This takes as input the packet drop rate, and outputs the sending 
 *   rate in bytes per second.
 */
static double p_to_b(double p, double rtt, double tzero, int psize, int bval) 
{
	double tmp1, tmp2, res;

	if (p < 0 || rtt < 0) {
		return MAXRATE ; 
	}
	res = rtt * sqrt(2.0*bval*p/3.0);
	tmp1 = 3.0 * sqrt(3.0*bval*p/8.0);

	if (tmp1 > 1.0) 
		tmp1 = 1.0;

	tmp2 = tzero * p * (1.0 + 32.0 * p * p);
	res += tmp1 * tmp2;

//	if (formula_ == 1 && p > 0.25) { 
//		// Get closer to RFC 3714, Table 1.
//		// This is for TCP-friendliness with a TCP flow without ECN
//		//   and without timestamps.
//		// Just for experimental purposes. 
//		if p > 0.70) {
//			res=res*18.0;
//		} else if p > 0.60) {
//			res=res*7.0;
//		} else if p > 0.50) {
//			res=res*5.0;
//		} else if p > 0.45) {
//			res=res*4.0;
//		} else if p > 0.40) {
//			res=res*3.0;
//		} else if p > 0.25) {
//			res=res*2.0;
//		}
//	}

	double temp = res;	// res value (packets per second)

	// At this point, 1/res gives the sending rate in pps:
	// 1/(rtt*sqrt(2*bval*p/3) + 3*sqrt(3*bval*p/8)*tzero*p*(1+32*p*p))
	if (res < SAMLLFLOAT) {
		res=MAXRATE;
	} else {
		// change from 1/pps to Bps. (bytes per second)
		res=psize/res;
	}
	if (res > MAXRATE) {
		res = MAXRATE ; 
	}

	double now = Scheduler::instance().clock();
	double Tx = 8.0 * res;	// unit of Tx is "bits" per second
	printf (" %f tfrcTx: %.4f temp: %f rtt: %.5f tzero: %.4f p: %.4f\n", 
			now, Tx, temp, rtt, tzero, p);

	return res;
}
