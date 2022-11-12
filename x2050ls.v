`default_nettype   none

// 2050 local storage

module x2050ls (i_clk, i_reset,
	i_ros_advance,
	i_we,
	i_newvalue,
	i_lsa,
	o_ls);
	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;
	input wire i_we;
	input wire [31:0] i_newvalue;
	input wire [5:0] i_lsa;
	output wire [31:0] o_ls;

	reg [31:0] regfile[0:63];

assign o_ls = regfile[i_lsa];

always @(posedge i_clk)
	if (i_we & i_ros_advance)
		regfile[i_lsa] <= i_newvalue;

endmodule
