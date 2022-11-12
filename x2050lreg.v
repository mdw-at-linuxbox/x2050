`default_nettype   none

module x2050lreg (i_clk, i_reset,
	i_ros_advance,
	i_tr,
	i_sf,
	i_ss,
	i_t_reg,
	i_ipl,
	i_ls,
	i_dec_cor,
	o_l_reg);

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;

	input wire [4:0] i_tr;
	input wire [2:0] i_sf;
	input wire [5:0] i_ss;
	input wire [31:0] i_t_reg;
	input wire [11:0] i_ipl;
	input wire [31:0] i_ls;
	input wire [32:0] i_dec_cor;
	output reg [31:0] o_l_reg;

	// ks611
	wire [31:0] treg = (i_ss == 6'd55) ?
		{i_ipl[7:0], 12'b0, i_ipl[11:8], 8'b0}
		: i_t_reg;

	// dr111 dr131
	wire [32:0] next_lreg =
		((i_tr == 5'd5) ? {i_t_reg[31-0:31-7],o_l_reg[31-8:31-31],1'b1} : 0)
		| ((i_tr == 5'd7) ? {treg,1'b1} : 0)
		| ((i_tr == 5'd16) ? {i_t_reg,1'b1} : 0)
		| ((i_tr == 5'd24) ? {i_t_reg,1'b1} : 0)
		| ((i_tr == 5'd25) ? {i_t_reg,1'b1} : 0)
		| ((i_tr == 5'd26) ? {i_t_reg,1'b1} : 0)
		| ((i_tr == 5'd30) ? {o_l_reg[31-0:31-7],i_t_reg[31-8:31-31],1'b1}: 0)
		| ((i_sf == 3'd1) ? {i_ls,1'b1}: 0)
		| ((i_sf == 3'd6) ? {i_ls,1'b1}: 0)
		| i_dec_cor
		;

// XXX only on ros exec
always @(posedge i_clk)
	if (i_reset)
		o_l_reg <= 0;
	else if (!i_ros_advance)
		;
	else if (next_lreg[0]) o_l_reg <= next_lreg[32:1];
endmodule
