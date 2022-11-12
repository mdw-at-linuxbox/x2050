`default_nettype   none

// 2050 r register

module x2050rreg (i_clk, i_reset,
	i_ros_advance,
	i_tr,
	i_sf,
	i_t_reg,
	i_ls,
	i_break_out,
	o_r_reg);

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;

	input wire [4:0] i_tr;
	input wire [2:0] i_sf;
	input wire [31:0] i_t_reg;
	input wire [31:0] i_ls;
	input wire i_break_out;
	output reg [31:0] o_r_reg;

	wire [32:0] next_rreg =
		((i_tr == 5'd1) ? {i_t_reg,1'b1} : 0)
		| ((i_tr == 5'd2) ? {i_t_reg[31-0:31-7],o_r_reg[31-8:31-31],1'b1} : 0)
		| ((i_tr == 5'd6) ? {i_t_reg,1'b1} : 0)
		| ((i_tr == 5'd9) ? {i_t_reg,1'b1} : 0)
		| ((i_tr == 5'd10) ? {i_t_reg,1'b1} : 0)
		| ((i_tr == 5'd11) ? {i_t_reg,1'b1} : 0)
		| ((i_tr == 5'd14) ? {o_r_reg[31-0:31-7],i_t_reg[31-8:31-31],1'b1}: 0)
		| ((i_sf == 3'd2) ? {i_ls,1'b1}: 0)
		| ((i_sf == 3'd5) ? {i_ls,1'b1}: 0)
		| (i_break_out ? {i_ls,1'b1}: 0)
		;

// XXX only on ros exec
always @(posedge i_clk)
	if (i_reset)
		o_r_reg <= 0;
	else if (!i_ros_advance)
		;
	else if (next_rreg[0]) o_r_reg <= next_rreg[32:1];
endmodule
