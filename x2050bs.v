`default_nettype   none
// 2050 byte stats
// 2050 Control Field Specification
// CFC 105 - 2050 control field specification - cpu mode (ss)
// [pdf page 12]

module x2050bs (i_clk, i_reset,
i_ros_advance,
i_ss,
i_ce,
i_mb_reg,
o_bs_reg);

input wire i_clk;
input wire i_reset;
input wire i_ros_advance;
input wire [5:0] i_ss;
input wire [3:0] i_ce;
input wire [1:0] i_mb_reg;
output reg [3:0] o_bs_reg;

// XXX only on ros exec
always @(posedge i_clk)
	if (i_reset)
		o_bs_reg <= 0;
	else if (!i_ros_advance)
		;
	else case (i_ss)
	6'd11:
		o_bs_reg <= 0;
	6'd19:
		o_bs_reg <= i_ce;
	6'd20:
		o_bs_reg <= o_bs_reg | (4'd1 << ~(i_mb_reg));
	default:
		;
	endcase
endmodule
