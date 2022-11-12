`default_nettype   none

// 2050 psw<23.26>, ascii, machine check, wait state, problem state

// A22-6821-0_360PrincOps.pdf
// A22-6821-0 figure 14 "program status word" page 16 [pdf page 16]

module x2050amwp (i_clk, i_reset,
i_ros_advance,
i_ss,
i_t_reg,
o_amwp);

input wire i_clk;
input wire i_reset;
input wire i_ros_advance;
input wire [5:0] i_ss;

input wire [31:0] i_t_reg;
output reg [3:0] o_amwp;

wire set_amwp = (i_ss == 6'd55) | (i_ss == 6'd56);

always @(posedge i_clk)
	if (i_reset)
		o_amwp <= 0;
	else if (!i_ros_advance)
		;
	else if (set_amwp)
		o_amwp <= i_t_reg[31-12:31-15];

endmodule
