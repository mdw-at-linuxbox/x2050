CFLAGS=-g -I. -O0
CXXFLAGS=-g -I. -Iobj -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -std=c++17
O=verilated.o verilated_vcd_c.o
P=-lpthread
A=testx2050ros x2050ms_tb x2050br_tb
all: $(A)
testx2050ros: Vx2050ros.h Vx2050ros__ALL.a testx2050ros.o $O
	$(CXX) $(CXXFLAGS) -o testx2050ros testx2050ros.o $O Vx2050ros__ALL.a $P
Vx2050ros.h Vx2050ros__ALL.a: x2050ros.v
	verilator -Wall --MMD -trace -y . --Mdir . -cc x2050ros.v
	$(MAKE) -C . -f Vx2050ros.mk
verilated.o: /usr/share/verilator/include/verilated.cpp
	$(CXX) $(CXXFLAGS) -c -o verilated.o /usr/share/verilator/include/verilated.cpp
verilated_vcd_c.o: /usr/share/verilator/include/verilated_vcd_c.cpp
	$(CXX) $(CXXFLAGS) -c -o verilated_vcd_c.o /usr/share/verilator/include/verilated_vcd_c.cpp
CPU=x2050.v x2050ros.v x2050roar.v x2050mvr.v x2050lmv.v x2050rmv.v x2050bc.v x2050lreg.v x2050rreg.v x2050lsa.v x2050ls.v x2050ms.v x2050bs.v x2050ilc.v x2050amwp.v x2050sup.v x2050br.v x2050lad.v x2050rad.v x2050add.v x2050treg.v x2050st.v x2050mreg.v x2050jreg.v x2050iar.v x2050fet.v x2050hreg.v x2050sn.v x2050cs.v x2050ex.v x2050cy.v x2050greg.v x2050mpxb.v data.bin
x2050.json: $(CPU)
	yosys -p "read -sv x2050.v ; hierarchy -simcheck -nodefaults -libdir . -top x2050 ; synth_ice40 -top x2050 -json x2050.json"
x2050ms_tb: x2050ms_tb.v x2050ms.v memdev50.v
	iverilog -pfileline=1 -y . -g2005-sv -o x2050ms_tb x2050ms_tb.v
x2050br_tb: x2050br_tb.v x2050br.v
	iverilog -pfileline=1 -y . -g2005-sv -o x2050br_tb x2050br_tb.v
x2050lad_tb: x2050lad_tb.v x2050lad.v
	iverilog -pfileline=1 -y . -g2005-sv -o x2050lad_tb x2050lad_tb.v
x2050rmv_tb: x2050rmv_tb.v x2050rmv.v
	iverilog -pfileline=1 -y . -g2005-sv -o x2050rmv_tb x2050rmv_tb.v
x2050com_tb: x2050com_tb.v x2050com.v
	iverilog -pfileline=1 -y . -g2005-sv -o x2050com_tb x2050com_tb.v
Vx2050.h Vx2050__ALL.a: $(CPU)
	verilator -Wall --MMD -trace -y . --Mdir . -cc x2050.v
	$(MAKE) -C . -f Vx2050.mk
clean:
	rm -f $O $A
	rm -f testx2050ros.o
	rm -f Vx2050*.*
	rm -f x2050*.vcd
	rm -f x2050.json
