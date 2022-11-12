`default_nettype   none

// 2050 carry logic

module x2050cy (i_clk, i_reset,
i_ros_advance,
i_io_mode,
i_dg,
i_ad,
i_c0,
i_c1,
i_c8,
o_carry_in,
o_next_carry,
o_carry);

input wire i_clk;
input wire i_reset;
input wire i_ros_advance;
input wire i_io_mode;
input wire [2:0] i_dg;
input wire [3:0] i_ad;
input wire i_c0;
input wire i_c1;
input wire i_c8;
output wire o_carry_in;
output wire o_next_carry;
output reg o_carry;

assign o_carry_in = ~i_io_mode & (i_dg == 3'd1) & o_carry
	| ~i_io_mode & ((i_dg == 3'd2) | (i_dg == 3'd4) ) & 1'b1;

wire [1:0] next_carry = {
	(i_ad == 4'd4) & i_c0
		| (i_ad == 4'd5) & (i_c0 ^ i_c1)
		| (i_ad == 4'd6) & i_c1
		| (i_ad == 4'd7) & i_c8 ,
	((i_ad == 4'd4) | (i_ad == 4'd5)
		| (i_ad == 4'd6) | (i_ad == 4'd7))
	};

assign o_next_carry = next_carry[0] ? next_carry[1] : o_carry;

always @(posedge i_clk)
	if (i_reset)
		o_carry <= 0;
	else if (!i_ros_advance)
		;
	else if (next_carry[0])
		o_carry <= next_carry[1];

endmodule
