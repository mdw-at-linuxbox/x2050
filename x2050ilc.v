`default_nettype   none

// 2050 psw<32.33>, instruction length code

// A22-6821-0_360PrincOps.pdf
// A22-6821-0 figure 14 "program status word" page 16 [pdf page 16]

module x2050ilc (i_clk, i_reset,
i_ros_advance,
i_tr,
i_t_reg,
o_ilc);

input wire i_clk;
input wire i_reset;
input wire i_ros_advance;
input wire [4:0] i_tr;
input wire [31:0] i_t_reg;
output reg [1:0] o_ilc;

wire b0 = i_t_reg[31-0];
wire b1 = i_t_reg[31-1];

wire [1:0] next_ilc = {b0|b1, ~(b0^b1)};

// ilc register: rp001

always @(posedge i_clk)
	if (i_reset)
		o_ilc <= 0;
	else if (!i_ros_advance)
		;
	else if (i_tr == 5'd25)
		o_ilc <= next_ilc;

endmodule
