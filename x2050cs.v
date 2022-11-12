`default_nettype   none
// 2050 byte selectable carry status.
// handle computing STAT 1 for AD12 "A DCBS", used for decimal add,
// subtract, compare
// 2050 Control Field Specification
// CFC 107 - 2050 control field specification - cpu mode (ilc,tc,ry,ad)
// [pdf page 8]

module x2050cs (i_clk, i_reset,
i_bs_reg,
i_c0,
i_c8,
i_c16,
i_c24,
o_cx_bs);

input wire i_clk;
input wire i_reset;
input wire i_c0, i_c8, i_c16, i_c24;
input wire [3:0] i_bs_reg;
output wire o_cx_bs;

assign o_cx_bs = i_bs_reg[3-0] ? i_c0 :
	i_bs_reg[3-1] ? i_c8 :
	i_bs_reg[3-2] ? i_c16 :
	i_bs_reg[3-3] ? i_c24 :
	1'b0;

endmodule
