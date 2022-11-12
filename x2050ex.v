`default_nettype   none
// 2050 exponent difference logic
// handle computing STAT 4-7 for SS27 "" used for ""
// also handle computing roar function bits for ZF12 used for ""
//
// see
// 2050 Control Field Specification
// CFC 107 - 2050 control field specification - cpu mode (ss)
// [pdf page 8]
// CFC 107 - 2050 control field specification - cpu mode (ss)
// [pdf page 8]


module x2050ex (i_clk, i_reset,
i_xin,
i_y,
i_c1,
i_gpstat,
o_fp_negative,
o_do_true_add,
o_expdiff_le16,
o_expdiff_zero,
o_exp_fcn_pos);

input wire i_clk;
input wire i_reset;
input wire i_c1;
input wire [31:0] i_xin;
input wire [31:0] i_y;
input wire [7:0] i_gpstat;
output wire o_fp_negative;	// SS27: stat 4
output wire o_do_true_add;	// SS27: stat 5
output wire o_expdiff_le16;	// SS27: stat 6
output wire o_expdiff_zero;	// SS27: stat 7
output wire [3:0] o_exp_fcn_pos;	// ZF12: roar<6:9>

wire s0 = i_gpstat[7-0];
wire s1 = i_gpstat[7-1];
wire stat0_or_stat1 = (s0 | s1);

// SS27 stat 4 calculation
assign o_fp_negative = stat0_or_stat1 & i_y[31-0] & !i_c1
	| stat0_or_stat1 & i_c1 & (i_xin[31-1] ^ i_y[31-1])
	| ~stat0_or_stat1 & (i_xin[31-1] ^ i_y[31-1]);

// SS27 stat 5 calculation
assign o_do_true_add = ~(i_xin[31-0] ^ i_y[31-0] ^ s1);

// XXX these exponent difference calculations should not be
//  using a separate adder.
wire [7:0] edx = {1'b0,i_xin[31-1:31-7]} - {1'b0,i_y[31-1:31-7]};

// SS27 stat 6 calculation
assign o_expdiff_le16 = ~|edx[7:4] | (&{edx[7:4],|edx[3:0]});

// SS27 stat 7 calculation
assign o_expdiff_zero = ~|edx;

// ZF12 roar<6:9>
assign o_exp_fcn_pos = edx[3:0];

endmodule
