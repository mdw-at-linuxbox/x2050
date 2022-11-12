`default_nettype   none

// 2050 length counter (g register) decrement or set logic

// see
// 2050 Control Field Specification
// CFC 105 - 2050 control field specification - cpu mode (wm,up,md,lb,mb,dg)
// [pdf page 6]
// WM9 WM10 WM11
// DG3 DG4 DG5 DG6 DG7

// for DG4 | DG6, how does WM10 interact?

module x2050greg (i_clk, i_reset,
	i_ros_advance,
	i_io_mode,
	i_dg,
	i_wm,
	i_w_reg,
	o_g_reg,
	o_g1_sign,
	o_g2_sign);

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;
	input wire i_io_mode;

	input wire [3:0] i_wm;
	input wire [2:0] i_dg;
	input wire [7:0] i_w_reg;
	output reg [7:0] o_g_reg;
	output reg o_g1_sign;
	output reg o_g2_sign;

	// g1,2 counter: kk551-561
	// g1,2 zero condition: kk571

	wire n1, n2;
	wire [3:0] incr1, incr2;
	wire [7:0] next_greg;

	assign incr2 = {4{i_dg[2]}};	// DG4 DG5 DG6 DG7
	assign incr1 = {4{
		(i_dg[1] & i_dg[0])		// DG3 DG7
		| (i_dg[2] & ~i_dg[0] & ~n2)	// DG4 DG6, borrow
	}};
	wire maybeincr1 =
		(i_dg[1] & i_dg[0])		// DG3 DG7
		| (i_dg[2] & ~i_dg[0]);		// DG4 DG6

	wire set_g1 = (i_wm == 4'd9) | (i_wm == 4'd11);
	wire set_g2 = (i_wm == 4'd10) | (i_wm == 4'd11);

	assign {n2,next_greg[3:0]} = set_g2 ?
		{1'b1, i_w_reg[3:0]} :
		{1'b0,o_g_reg[3:0]} + incr2;
	assign {n1,next_greg[7:4]} = set_g1 ?
		{1'b1, i_w_reg[7:4]} :
		{1'b0,o_g_reg[7:4]} + incr1;

	wire next_g1_sign = ~n1;
	wire next_g2_sign = ~n2;

always @(posedge i_clk)
	if (i_reset)
		o_g_reg <= 0;
	else if (!i_ros_advance)
		;
	else begin
		o_g_reg <= next_greg;
	end
always @(posedge i_clk)
	if (i_reset) begin
		o_g1_sign <= 0;
		o_g2_sign <= 0;
	end else if (!i_ros_advance | i_io_mode)
		;
	else begin
		if (set_g2)
			o_g2_sign <= 1'b0;
		else if (i_dg[2])
			o_g2_sign <= next_g2_sign;
		if (set_g1)
			o_g1_sign <= 1'b0;
		else if (maybeincr1)
			o_g1_sign <= next_g1_sign;
	end
endmodule
