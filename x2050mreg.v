`default_nettype   none

// 2050 m register

module x2050mreg (i_clk, i_reset,
	i_ros_advance,
	i_io_mode,
	i_tr,
	i_wm,
	i_mb_reg,
	i_t_reg,
	i_w_reg,
	o_m_reg);

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;
	input wire i_io_mode;

	input wire [4:0] i_tr;
	input wire [3:0] i_wm;
	input wire [1:0] i_mb_reg;
	input wire [31:0] i_t_reg;
	input wire [7:0] i_w_reg;
	output reg [31:0] o_m_reg;

	wire force_mb_3 = (i_tr == 5'd3)
		| (i_tr == 5'd28);
	wire use_t_reg = (i_tr == 5'd3)
		| (i_tr == 5'd24)
		| (i_tr == 5'd25)
		| (i_tr == 5'd28);
	wire half_reg = (i_tr == 5'd26);
	wire pass_m = ~use_t_reg & ~half_reg;

	wire [31:0] next_m1 =
		{32{use_t_reg}} & i_t_reg
		| {32{half_reg}} & {o_m_reg[31-0:31-15],i_t_reg[31-0:31-15]}
		| {32{pass_m}} & o_m_reg;

	wire do_m_mb_w = ~i_io_mode & ((i_wm == 4'd1) | (i_wm == 4'd12));
	wire [1:0] mb = force_mb_3 ? 2'd3 : i_mb_reg;
	wire [31:0] next_mreg = {
		(mb == 2'd0 & do_m_mb_w) ? i_w_reg : next_m1[31:24],
		(mb == 2'd1 & do_m_mb_w) ? i_w_reg : next_m1[23:16],
		(mb == 2'd2 & do_m_mb_w) ? i_w_reg : next_m1[15:8],
		(mb == 2'd3 & do_m_mb_w) ? i_w_reg : next_m1[7:0]
	};

// m register: rm001

always @(posedge i_clk)
	if (i_reset)
		o_m_reg <= 0;
	else if (!i_ros_advance)
		;
	else begin
		o_m_reg <= next_mreg;
	end
endmodule
