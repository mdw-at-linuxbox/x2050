`default_nettype   none

// 2050 h register

module x2050hreg (i_clk, i_reset,
	i_ros_advance,
	i_tr,
	i_al,
	i_t_reg,
	i_t0,
	i_iar,
	o_h_reg);

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;

	input wire [4:0] i_tr;
	input wire [4:0] i_al;
	input wire [31:0] i_t_reg;
	input wire [31:0] i_t0;
	input wire [23:0] i_iar;
	output reg [31:0] o_h_reg;

// h register: rh001
// h register set: kc222

always @(posedge i_clk)
	if (i_reset)
		o_h_reg <= 0;
	else if (!i_ros_advance)
		;
	else if (i_al == 5'd6)
		o_h_reg[31-8:31-31] <= i_iar;
	else if (i_al == 5'd24)
		o_h_reg[31-0:31-3] <= i_t0[31-28:31-31];
	else if (i_tr == 5'd20)
		o_h_reg <= i_t_reg;

endmodule
