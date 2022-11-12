`default_nettype   none
// 2050 condition code register
// 2050 Control Field Specification
// CFC 105 - 2050 control field specification - cpu mode (ss)
// [pdf page 12]

module x2050cc (i_clk, i_reset,
i_ros_advance,
i_io_mode,
i_ce,
i_ss,
i_wm,
i_w_reg,
i_bs_reg,
i_t_reg,
i_sdr,
i_carry,
i_c0,
i_gpstat,
i_tzbs,
o_cc_reg,
o_progmask,
o_turn_off_load_light);

input wire i_clk;
input wire i_reset;
input wire i_ros_advance;
input wire i_io_mode;
input wire [3:0] i_ce;
input wire [5:0] i_ss;
input wire [3:0] i_wm;
input wire [7:0] i_w_reg;
input wire [3:0] i_bs_reg;
input wire [31:0] i_t_reg;
input wire [31:0] i_sdr;
input wire i_carry;
input wire i_c0;
input wire [7:0] i_gpstat;
input wire i_tzbs;
output reg [1:0] o_cc_reg;
output reg [3:0] o_progmask;
output wire o_turn_off_load_light;

// cc register: rp011, rp012
// prog mask: rp001

wire tnz = |i_t_reg;

wire [1:0] crlog = i_tzbs ? 2'd0 : ~i_c0 ? 2'd1 : 2'd2;
wire [1:0] crs4 = {~i_gpstat[7-4], i_gpstat[7-4]};

wire [1:0] test_set_cc = {1'b0, i_bs_reg[3-0] & i_sdr[31-0]
	| i_bs_reg[3-1] & i_sdr[23-0]
	| i_bs_reg[3-2] & i_sdr[15-0]
	| i_bs_reg[3-3] & i_sdr[7-0]};
wire [1:0] cc_ss = {2{i_ss == 6'd3}} & test_set_cc
	| {2{i_ss == 6'd29}} & {i_carry, tnz}
	| {2{i_ss == 6'd40}} & i_ce[3-2:3-3]
	| {2{i_ss == 6'd41}} & {|{~i_t_reg[31-0],i_t_reg[31-1:31-31]},i_t_reg[31-0]}
	| {2{i_ss == 6'd42}} & crlog
	| {2{i_ss == 6'd43}} & crs4
	| {2{i_ss == 6'd44}} & ~crs4
// XXX need to carry old cc if not any of these
	;
wire wm4 = ~i_io_mode & (i_wm == 4'd4);
assign o_turn_off_load_light = wm4 & i_ros_advance;
wire [1:0] cc_wm = {2{wm4}} & i_w_reg[7-2:7-3];

always @(posedge i_clk)
	if (i_reset)
		o_cc_reg <= 0;
	else if (!i_ros_advance)
		;
	else o_cc_reg <= cc_ss | cc_wm;
always @(posedge i_clk)
	if (i_reset)
		o_progmask <= 0;
	else if (!i_ros_advance)
		;
	else if (wm4)
		o_progmask <= i_w_reg[3:0];
endmodule
