`default_nettype   none

// 2050 j register

module x2050jreg (i_clk, i_reset,
	i_ros_advance,
	i_io_mode,
	i_tr,
	i_wm,
	i_t_reg,
	i_w_reg,
	o_j_reg);

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;
	input wire i_io_mode;

	input wire [4:0] i_tr;
	input wire [3:0] i_wm;
	input wire [31:0] i_t_reg;
	input wire [7:0] i_w_reg;
	output reg [3:0] o_j_reg;

	wire [4:0] next_jreg =
		((i_tr == 5'd25) ? {i_t_reg[31-12:31-15],1'b1} : 0)
		| ((i_tr == 5'd31) ? {i_t_reg[31-12:31-15],1'b1} : 0)
		| ((~i_io_mode & (i_wm == 4'd6)) ? {i_w_reg[7-4:7-7],1'b1}: 0)
		;

// j register: rj001

// XXX only on ros exec
always @(posedge i_clk)
	if (i_reset)
		o_j_reg <= 0;
	else if (!i_ros_advance)
		;
	else if (next_jreg[0]) o_j_reg <= next_jreg[4:1];
endmodule
