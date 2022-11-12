`default_nettype   none
// 2050 sign stats
// 2050 Control Field Specification
// CFC 111 - 2050 control field specification - cpu mode (ss)
// [pdf page 12]
// CFC 112 - 2050 control field specification - cpu mode (ss)
// [pdf page 13]

module x2050sn (i_clk, i_reset,
	i_ros_advance,
	i_ss,
	i_r_reg,
	i_l_reg,
	i_w_reg,
	i_u,
	o_r_sign_stat,
	o_l_sign_stat,
	o_invalid_decimal_ss);

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;

	input wire [5:0] i_ss;
	input wire [31:0] i_r_reg;
	input wire [31:0] i_l_reg;
	input wire [7:0] i_w_reg;
	input wire [7:0] i_u;
	output reg o_r_sign_stat;
	output reg o_l_sign_stat;
	output wire o_invalid_decimal_ss;

//	wire ur_positive = (i_u[3:0] == 4'ha) | (i_u[3:0] == 4'hc) |
//		(i_u[3:0] == 4'he) | (i_u[3:0] == 4'hf);
	wire ur_negative = (i_u[3:0] == 4'hb) | (i_u[3:0] == 4'hd);
	wire ur_invalid = i_u[3:0] < 4'ha;

	wire wr_positive = (i_w_reg[3:0] == 4'ha) | (i_w_reg[3:0] == 4'hc) |
		(i_w_reg[3:0] == 4'he) | (i_w_reg[3:0] == 4'hf);
//	wire wr_negative = (i_w_reg[3:0] == 4'hb) | (i_w_reg[3:0] == 4'hd);
//	wire wr_invalid = i_w_reg[3:0] < 4'ha;

	wire [1:0] next_r_sign = {
		(i_ss == 6'd5) & ur_negative & ~o_r_sign_stat
		| (i_ss == 6'd6) & ur_negative & ~o_r_sign_stat
		| (i_ss == 6'd7) & ~ur_invalid
		| (i_ss == 6'd34)
		// | (i_ss == 6'd35) & 1'b0
		| (i_ss == 6'd37) & i_r_reg[31-0],
		(i_ss == 6'd5) | (i_ss == 6'd6) | (i_ss == 6'd7) |
		(i_ss == 6'd34) | (i_ss == 6'd35) | (i_ss == 6'd37) };

	wire [1:0] next_l_sign = {
		(i_ss == 6'd5) & ur_negative
		| (i_ss == 6'd7) & ~wr_positive & o_l_sign_stat
		| (i_ss == 6'd32)
		// | (i_ss == 6'd33) & 1'b0
		| (i_ss == 6'd36) & i_l_reg[31-0],
		(i_ss == 6'd5) | (i_ss == 6'd7) |
		(i_ss == 6'd32) | (i_ss == 6'd33) | (i_ss == 6'd36) };

always @(posedge i_clk)
	if (i_reset)
		o_r_sign_stat <= 0;
	else if (!i_ros_advance)
		;
	else if (next_r_sign[0])
		o_r_sign_stat <= next_r_sign[1];

always @(posedge i_clk)
	if (i_reset)
		o_l_sign_stat <= 0;
	else if (!i_ros_advance)
		;
	else if (next_l_sign[0])
		o_l_sign_stat <= next_l_sign[1];

assign o_invalid_decimal_ss =
	((i_ss == 6'd5) | (i_ss == 6'd6)) & ur_invalid
	;

endmodule
