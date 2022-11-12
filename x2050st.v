`default_nettype   none
// 2050 byte stats
// 2050 Control Field Specification
// CFC 105 - 2050 control field specification - cpu mode (ss)
// [pdf page 12]

// SS28 = c oppanel->s47 is explained on qt200
// also explained in
// SY22-2832-4
// System 360 Model 50 2050 Processing Unit
// Field Engineering Maintenance Manual
// figure 176 "control panel setting" page 188 [pdf 189]

// 0000	nil
// 0001 instr step not start
// 0010 set ic
// 0011 repeat inst
// 010x addr sync
// 011x enter channel
// 1yyz store display:
//	yy 00=main store 01=protect tags
//	   10=local store 11=mpx bump
//	z 0=display 1=store

module x2050st (i_clk, i_reset,
i_ros_advance,
i_ad,
i_e,
i_tr,
i_ss,
i_f1,
i_t1,
i_c0,
i_cx_bs,
i_fp_negative,
i_do_true_add,
i_expdiff_le16,
i_expdiff_zero,
i_oppanel,
o_gpstat);

input wire i_clk;
input wire i_reset;
input wire i_ros_advance;
input wire [3:0] i_ad;
input wire [3:0] i_e;
input wire [4:0] i_tr;
input wire [5:0] i_ss;
input wire [3:0] i_f1;
input wire [31:0] i_t1;
input wire i_c0;
input wire i_cx_bs;
input wire i_fp_negative;
input wire i_do_true_add;
input wire i_expdiff_le16;
input wire i_expdiff_zero;
input wire [3:0] i_oppanel;
output reg [7:0] o_gpstat;

wire s0 = o_gpstat[7-0];
wire s1 = o_gpstat[7-1];
wire s2 = o_gpstat[7-2];
wire s3 = o_gpstat[7-3];
wire s4 = o_gpstat[7-4];
wire s5 = o_gpstat[7-5];
wire s6 = o_gpstat[7-6];
wire s7 = o_gpstat[7-7];

wire x0 = i_t1[31-12:31-15] == 4'b0;
wire x1 = i_t1[31-16:31-19] == 4'b0;

wire next_s0 = ((i_ss == 6'd8) & i_e[3-0])
	| (i_ss == 6'd9) & i_e[3-0]		// |= ce<0>
	| (i_ss == 6'd10) & i_e[3-0]		// |= ce<0>
	| (i_ss == 6'd11) & i_e[3-0]		// |= ce<0>
	| (i_ss == 6'd12) & x0
	| ((i_ss == 6'd13) | (i_ss == 6'd14)) & i_f1 == 4'd0 & s3
	| (i_ss == 6'd16) & s0 & ~i_e[3-0]
	| (i_tr == 5'd25) & x0
	| s0 & ~( (i_ss == 6'd8) | (i_ss == 6'd12) | (i_ss == 6'd13)
		| (i_ss == 6'd14) | (i_ss == 6'd16) | (i_tr == 5'd25) );

wire next_s1 = (i_ss == 6'd8) & i_e[3-1]
	| (i_ss == 6'd9) & i_e[3-1]		// |= ce<1>
	| (i_ss == 6'd10) & i_e[3-1]		// |= ce<1>
	| (i_ss == 6'd11) & i_e[3-1]		// |= ce<1>
	| (i_ss == 6'd12) & x1
	| (i_ss == 6'd16) & s0 & ~i_e[3-1]
	| (i_ad == 4'd9 | i_ad == 4'd10) & i_c0
	| (i_ad == 4'd12) & i_cx_bs
	| (i_tr == 5'd25) & x1
	| s1 & ~( (i_ss == 6'd8) | (i_ss == 6'd12) | (i_ss == 6'd16)
		| (i_ad == 4'd9) | (i_ad == 4'd10) | (i_ad == 4'd12)
		| (i_tr == 5'd25) );

wire next_s2 = (i_ss == 6'd8) & i_e[3-2]
	| (i_ss == 6'd9) & i_e[3-2]		// |= ce<2>
	| (i_ss == 6'd10) & i_e[3-2]		// |= ce<2>
	| (i_ss == 6'd11) & i_e[3-2]		// |= ce<2>
	| (i_ss == 6'd16) & s0 & ~i_e[3-2]
	| s2 & ~( (i_ss == 6'd8) | (i_ss == 6'd16) );

wire next_s3 = (i_ss == 6'd8) & i_e[3-3]
	| (i_ss == 6'd9) & i_e[3-3]		// |= ce<3>
	| (i_ss == 6'd10) & i_e[3-3]		// |= ce<3>
	| (i_ss == 6'd11) & i_e[3-3]		// |= ce<3>
	| (i_ss == 6'd16) & s0 & ~i_e[3-3]
	| (i_ss == 6'd17) & ~|i_t1
	| (i_ss == 6'd18) & i_t1[1]
	| s3 & ~( (i_ss == 6'd8) | (i_ss == 6'd16)
		| (i_ss == 6'd17) | (i_tr == 5'd18) );

wire next_s4 = (i_ss == 6'd24) & i_e[3-0]
	| (i_ss == 6'd25) & i_e[3-0]		// |= ce<0>
	| (i_ss == 6'd26) & s4 & ~i_e[3-0]
	| (i_ss == 6'd27) & i_fp_negative
	| (i_ss == 6'd28) & i_oppanel[3-0]
	| s4 & ~( (i_ss == 6'd24) | (i_ss == 6'd26)
		| (i_ss == 6'd27) | (i_ss == 6'd28) );

wire next_s5 = (i_ss == 6'd24) & i_e[3-1]
	| (i_ss == 6'd25) & i_e[3-1]		// |= ce<1>
	| (i_ss == 6'd26) & s5 & ~i_e[3-1]
	| (i_ss == 6'd27) & i_do_true_add
	| (i_ss == 6'd28) & i_oppanel[3-1]
	| s5 & ~( (i_ss == 6'd24) | (i_ss == 6'd26)
		| (i_ss == 6'd27) | (i_ss == 6'd28) );

wire next_s6 = (i_ss == 6'd24) & i_e[3-2]
	| (i_ss == 6'd25) & i_e[3-2]		// |= ce<2>
	| (i_ss == 6'd26) & s6 & ~i_e[3-2]
	| (i_ss == 6'd27) & i_expdiff_le16
	| (i_ss == 6'd28) & i_oppanel[3-2]
	| s6 & ~( (i_ss == 6'd24) | (i_ss == 6'd26)
		| (i_ss == 6'd27) | (i_ss == 6'd28) );

wire next_s7 = (i_ss == 6'd24) & i_e[3-3]
	| (i_ss == 6'd25) & i_e[3-3]		// |= ce<3>
	| (i_ss == 6'd26) & s7 & ~i_e[3-3]
	| (i_ss == 6'd27) & i_expdiff_zero
	| (i_ss == 6'd28) & i_oppanel[3-3]
	| s7 & ~( (i_ss == 6'd24) | (i_ss == 6'd26)
		| (i_ss == 6'd27) | (i_ss == 6'd28) );

wire [7:0] next_gpstat = {next_s0, next_s1, next_s2, next_s3,
	next_s4, next_s5, next_s6, next_s7};

always @(posedge i_clk)
	if (i_reset)
		o_gpstat <= 0;
	else if (!i_ros_advance)
		;
	else o_gpstat <= next_gpstat;
endmodule
