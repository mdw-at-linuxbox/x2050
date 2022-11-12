`default_nettype   none
// 2050 byte counter
// 2050 Control Field Specification
// CFC 105 - 2050 control field specification - cpu mode (wm,up,md,lb,mb,dg)
// [pdf page 6]

module x2050bc (i_clk, i_reset,
i_ros_advance,
i_up,
i_sel,
i_wstb,
i_newvalue,
o_bc);

parameter W=2;
localparam [W-1:0] one = 1;

input wire i_clk;
input wire i_reset;
input wire i_ros_advance;
input wire [1:0] i_up;
input wire i_sel;
input wire i_wstb;
input wire [W-1:0] i_newvalue;
output reg [W-1:0] o_bc;

wire [W-1:0] next_bc [0:3];

assign next_bc[0] = {W{1'b0}};
assign next_bc[1] = {W{1'b1}};
assign next_bc[2] = o_bc - one;
assign next_bc[3] = o_bc + one;

// XXX only on ros exec
always @(posedge i_clk)
	if (i_reset)
		o_bc <= 0;
	else if (!i_ros_advance)
		;
	else if (i_wstb)
		o_bc <= i_newvalue;
	else if (i_sel)
		o_bc <= next_bc[i_up];

endmodule
