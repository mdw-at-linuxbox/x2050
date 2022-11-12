#include <stdio.h>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <sys/socket.h>
#include <string.h>
#include <cerrno>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vx2050ros.h"
#include "testb.h"

#define UARTSETUP 25

int countbits(unsigned x)
{
	int r = 0;
	while (x) {
		if (x&1) ++r;
		x >>= 1;

	}
	return r;
}

struct MYDATA;
typedef unsigned int microword[3];

// ucode-bit verilator-word verilator-bit
// 00 2 25 01 2 24 02 2 23 03 2 22
// 04 2 21 05 2 20 06 2 19 07 2 18
// 08 2 17 09 2 16 10 2 15 11 2 14
// 12 2 13 13 2 12 14 2 11 15 2 10
// 16 2  9 17 2  8 18 2  7 19 2  6
// 20 2  5 21 2  4 22 2  3 23 2  2
// 24 2  1 25 2  0 26 1 31 27 1 30
// 28 1 29 29 1 28 30 1 27 31 1 26
// 32 1 25 33 1 24 34 1 23 35 1 22
// 36 1 21 37 1 20 38 1 19 39 1 18
// 40 1 17 41 1 16 42 1 15 43 1 14
// 44 1 13 45 1 12 46 1 11 47 1 10
// 48 1  9 49 1  8 50 1  7 51 1  6
// 52 1  5 53 1  4 54 1  3 55 1  2
// 56 1 YY 57 1  0 58 0 31 59 0 30
// 60 0 29 61 0 28 62 0 27 63 0 26
// 64 0 25 65 0 24 66 0 23 67 0 22
// 68 0 21 69 0 20 70 0 19 71 0 18
// 72 0 17 73 0 16 74 0 15 75 0 14
// 76 l 13 77 0 12 78 0 11 79 0 10
// 80 0  9 81 0  8 82 0  7 83 0  6
// 84 0  5 85 0  4 86 0  3 87 0  2
// 88 0  1 89 0  0
unsigned int mask[3];
#define IBM_BIT_TO_VERILATOR_WORD(i)	((89-(i))>>5)
#define IBM_BIT_TO_VERILATOR_BIT(i)	((89-(i))&31)
#define IBM_BIT_TO_VERILATOR_MASK(i)	(1<<(IBM_BIT_TO_VERILATOR_BIT(i)))

// bit0:	'h20000000000000000000000
// bit1:	'h10000000000000000000000
// bit89:	'h00000000000000000000001
// ros0	'h0000200005c008200000000	       0  5c0082     200
// ros1	'h2003e00398046d604680000	 4680000398046d6 2003e00
// ros2	'h00ac2058c8010d4c60010a6	c60010a68c8010d4   ac205
//			word ->		0	1	2
//			byte in word ->	 3 2 1 0 3 2 1 0 3 2 1 0
//			bit in byte	1 0	4 2	10 4	40 6
//					2 1	8 3	20 5	80 7

std::ostream& operator<<(std::ostream& oss, const microword &word )
{
  std::stringstream ss;
  for (int i = 0; i < 3; ++i)
   ss << std::setw(8) << std::hex << word[i];
  oss << ss.str();
  return oss;
}


struct MYDATA {
bool x_done = false;
bool starting = 1;
int settle;
int x_val;
int wrong = 0;

template <typename T>
bool bad_parity(T & holes, T & expected) {
	bool bit = 0;
	bool sum = 1;
	bool not_all_zero = 0;
	int xxx[8];
	int xxxi = 0;
	int i;
	for (i = 0; i < 3; ++i) {
		expected[i] = 0;
		mask[i] |= holes[i];
	}
	for (i = 0; i <= 30; ++i) {
		not_all_zero |= !!(holes[IBM_BIT_TO_VERILATOR_WORD(i)] & IBM_BIT_TO_VERILATOR_MASK(i));
		bit ^= !!(holes[IBM_BIT_TO_VERILATOR_WORD(i)] & IBM_BIT_TO_VERILATOR_MASK(i));
	}
	sum &= bit;
	if (!bit) expected[IBM_BIT_TO_VERILATOR_WORD(0)] |= IBM_BIT_TO_VERILATOR_MASK(0);
	if (!bit) xxx[xxxi++] = 0;
	bit = 0;
	for (i = 31; i <= 55; ++i) {
		not_all_zero |= !!(holes[IBM_BIT_TO_VERILATOR_WORD(i)] & IBM_BIT_TO_VERILATOR_MASK(i));
		bit ^= !!(holes[IBM_BIT_TO_VERILATOR_WORD(i)] & IBM_BIT_TO_VERILATOR_MASK(i));
	}
	sum &= bit;
	if (!bit) expected[IBM_BIT_TO_VERILATOR_WORD(31)] |= IBM_BIT_TO_VERILATOR_MASK(31);
	if (!bit) xxx[xxxi++] = 31;
	bit = 0;
	for (i = 56; i <= 89; ++i) {
		not_all_zero |= !!(holes[IBM_BIT_TO_VERILATOR_WORD(i)] & IBM_BIT_TO_VERILATOR_MASK(i));
		bit ^= !!(holes[IBM_BIT_TO_VERILATOR_WORD(i)] & IBM_BIT_TO_VERILATOR_MASK(i));
	}
	if (!bit) expected[IBM_BIT_TO_VERILATOR_WORD(56)] |= IBM_BIT_TO_VERILATOR_MASK(56);
	if (!bit) xxx[xxxi++] = 56;
if (xxxi && not_all_zero) {
std::cout << " bits(";
for (int j = 0; j < xxxi; ++j) std::cout << " " << xxx[j];
std::cout << ")";
}
	sum &= bit;
	return !sum;
}

template <typename T>
u_short next_value(T & holes)
{
	T expected;
	if (starting) {
		x_val = 0;
		starting = 0;
		settle = 5;
		return x_val;
	}
	if (settle--) return x_val;
	settle = 5;
	auto saved_flags { std::cout.flags() };
	std::cout << std::setw(3) << std::hex << x_val
		<< " " << std::setw(5) << std::hex << holes;
	std::cout.flags(saved_flags);
	if (bad_parity(holes, expected)) {
		++wrong;
		std::cout << "; bad parity" << expected;
	}
	std::cout << std::endl;
	++x_val;
	x_done = x_val >= 0x1000;
	return x_val;
}
bool done()
{
	if (x_done) {
		std::cout << std::dec << wrong << " had bad parity" << std::endl;
		std::cout << mask << " mask" << std::endl;
	}
	return x_done;
}
};

struct X2050ROS_TB : public TESTB<Vx2050ros> {
	unsigned long m_tx_busy_count;
//	UARTSIM m_uart;
	MYDATA m_data[1];
	bool m_done;

	X2050ROS_TB(int port=0) : m_done(false) {}
	void trace(const char *filename) {
		std::cerr << "opening TRACE(" << filename << ")" << std::endl;
		opentrace(filename);
	}
	void close() {
		TESTB<Vx2050ros>::closetrace();
	}
	void tick() {
		if (m_done) return;
		m_core->i_addr = m_data->next_value(m_core->o_data);
		TESTB<Vx2050ros>::tick();
	}
	bool done(void) {
		if (m_done)
			return true;
		if (Verilated::gotFinish() || m_data->done())
			m_done = true;
		return m_done;
	}
};

vluint64_t main_time = 0;
double sc_time_stamp()
{
	return main_time;
}

pthread_mutex_t stdio_mutex[1];

void
flush_std_things()
{
	pthread_mutex_lock(stdio_mutex);
	fflush(stdout);
	fflush(stderr);
	pthread_mutex_unlock(stdio_mutex);
}

struct x2050ros_arg {
	char *vcd_out;
	X2050ROS_TB *tb;
};

void *
run_x2050ros(void *a)
{
	int count;
	auto tb = new X2050ROS_TB(-1);
	struct x2050ros_arg *ap = (struct x2050ros_arg *) a;

	ap->tb = tb;
	if (ap->vcd_out)
		tb->trace(ap->vcd_out);
	tb->reset();
//	if (ap->w > 0)
//		tb->m_uart.add_fds(ap->r, ap->w);
	count = 0;
	while (!tb->done()) {
		++main_time;
		tb->tick();
		if (++count > 1000)
		{
			count = 0;
			flush_std_things();
		}
	}
	tb->close();
	ap->tb = 0;
	delete tb;
	return NULL;
}

int
main(int ac, char **av)
{
	char *ap;
	struct x2050ros_arg arg[1];
	int count;
	int r;

	memset(arg, 0, sizeof *arg);
	Verilated::commandArgs(ac, av);
	while (--ac > 0) if (*(ap = *++av) == '-') while (*++ap) switch(*ap) {
	case 'o':
		if (--ac <= 0) {
			std::cerr << "-o: missing file" << std::endl;
			goto Usage;
		}
		arg->vcd_out = *++av;
		break;
	default:
		std::cerr << "don't grok switch " << *ap << std::endl;
	Usage:
		std::cerr << "Usage: x2050ros [-o trace.vcd]\n";
		exit(0);
	} else if (!memcmp(ap, "+verilator", 10))
		;
	else {
		std::cerr << "don't know what to do with " << ap << std::endl;
		goto Usage;
	}
	run_x2050ros(arg);
	exit(r);
}
