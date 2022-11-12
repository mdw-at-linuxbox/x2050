template <class VA> struct TESTB {
	VA	*m_core;
	VerilatedVcdC *m_trace;
	unsigned long m_tickcount;

	TESTB() : m_trace(nullptr), m_tickcount(0) {
		m_core = new VA;
		Verilated::traceEverOn(true);
		m_core->i_clk = 0;
		eval();	// initialize
	}
	virtual ~TESTB() {
		if (m_trace) m_trace->close();
		delete m_core;
		m_core = nullptr;
	}
	virtual void opentrace(const char *filename) {
		if (m_trace) {
			m_trace->close();
		}
		m_trace = new VerilatedVcdC;
		m_core->trace(m_trace, 99);
		m_trace->open(filename);
	}
	virtual void closetrace() {
		if (m_trace) {
			m_trace->close();
			m_trace = nullptr;
		}
	}
	virtual void eval() {
		m_core->eval();
	}
	virtual int before_posedge() {
		return 0;
	}
	virtual int after_posedge() {
		return 0;
	}
	virtual void tick(void) {
		before_posedge();
		++m_tickcount;
		eval();
		if (m_trace) m_trace->dump(10*m_tickcount-2);
		m_core->i_clk = 1;
		eval();
		if (m_trace) m_trace->dump(10*m_tickcount);
		if (after_posedge())
			if (m_trace) m_trace->dump(10*m_tickcount+2);
		m_core->i_clk = 0;
		eval();
		if (m_trace) {
			m_trace->dump(10*m_tickcount+5);
			m_trace->flush();
		}
	}
	virtual void reset() {
		m_core->i_reset = 1;
		tick();
		m_core->i_reset = 0;
	}
};
