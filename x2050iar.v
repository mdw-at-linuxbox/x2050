`default_nettype   none

// 2050 psw<40:63> instruction address register
//
// 2050 byte stats
// 2050 Control Field Specification
// CFC 112 - 2050 control field specification - cpu mode (ss)
// [pdf page 13]

// A22-6821-0_360PrincOps.pdf
// A22-6821-0 figure 14 "program status word" page 16 [pdf page 16]

module x2050iar (i_clk, i_reset,
	i_ros_advance,
	i_io_mode,
	i_tr,
	i_iv,
	i_e,
	i_ilc,
	i_sdr,
	o_nextiar,
	o_iar);

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;
	input wire i_io_mode;

	input wire [4:0] i_tr;
	input wire [2:0] i_iv;
	input wire [3:0] i_e;
	input wire [1:0] i_ilc;
	input wire [31:0] i_sdr;
	output wire [23:0] o_nextiar;
	output reg [23:0] o_iar;

// iar: ca211

	wire [23:0] hwaddr = 24'h84;

	// TR12 only loads 20 bits of the iar - not sure why.
	// it's only used by diagnoise / flt logic, does this matter?
	wire iar_load = (i_tr == 5'd12) | (i_tr == 5'd21);
	// IV4 has the same action as CT4, and CT5,6,7 not defined or used.
	wire iar_incr2 = (i_iv == 3'd5) & ~i_ilc[1-0] | (i_iv == 3'd6);
	wire iar_incr4 = (i_iv == 3'd5) & i_ilc[1-0] | (i_iv == 3'd4);
	wire iar_ha = (i_tr == 5'd8) & i_e[3-1];
	wire iar_nil = ~(iar_load | iar_incr2 | iar_incr4 | iar_ha);

	wire [23:0] next_iar = {24{iar_load}} & i_sdr[31-8:31-31]
		| {24{iar_incr2}} & (o_iar + 24'd2)
		| {24{iar_incr4}} & (o_iar + 24'd4)
		| {24{iar_ha}} & hwaddr
		| {24{iar_nil}} & o_iar;

	assign o_nextiar = next_iar;

always @(posedge i_clk)
	if (i_reset)
		o_iar <= 0;
	else if (!i_ros_advance)
		;
	else begin
		o_iar <= next_iar;
	end
endmodule
