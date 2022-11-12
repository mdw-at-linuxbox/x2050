`default_nettype   none
// 2050 mover

// Z22-2855-3
// Field Engineering Handbook, System 360 Model 50, 4th Ed
// block diagram and its place in the cpu:
// figure page 7 [pdf page 8]

// 2050 Control Field Specification
// SS38
// CFC 112 - 2050 control field specification - cpu mode (ss)
// [pdf page 13]
// UR, UL fields
// CFC 106 - 2050 control field specification - cpu mode (ul,ur,ce)
// [pdf page 7]

// IO mode wfn appears to be bit flipped; in the microcode listings,
// observe E values used with SS38, E(13)->WFN
//           xor      or       and
// cpu mode: QB400 E1 QB400 C1 QB400 A1
//  io mode: QV330 J1 QV330 J2 QV330 L3

module x2050mvr (i_clk, i_reset,
i_ros_advance,
i_io_mode,
i_ul,
i_ur,
i_e,
i_ss,
i_u,
i_v,
i_amwp,
o_w_reg,
o_edit_stat,
o_cpu_wfn,
o_io_wfn);

// verilator lint_off UNUSED
input wire i_clk;
input wire i_reset;
input wire i_ros_advance;
input wire i_io_mode;
input wire [1:0] i_ul;
input wire [1:0] i_ur;
input wire [3:0] i_e;
input wire [5:0] i_ss;
input wire [7:0] i_u;
input wire [7:0] i_v;
input wire [3:0] i_amwp;
output wire [7:0] o_w_reg;
output wire [2:1] o_edit_stat;
output wire [2:0] o_cpu_wfn;
output wire [2:0] o_io_wfn;

wire ascii_mode = i_amwp[3-0];

reg [2:0] wfn_ [0:1];
wire [2:0] wfn = wfn_[i_io_mode];

wire [2:0] i_wfn_munged = i_io_mode
	? {i_e[3-3], i_e[3-2], i_e[3-1]}	// flipped
	: i_e[3-1:3-3];				// straight

wire [3:0] e_mixin = {ascii_mode ? ~i_e[3-0] | ~i_e[2] : i_e[3-0],
	ascii_mode ? i_e[3-2] | ~i_e[3-1] : i_e[3-1],
	ascii_mode ? ~i_e[3-2] : i_e[3-2],
	i_e[3-3]};

wire [7:0] mover_function [0:7];
wire [3:0] mover_left [0:3];
wire [3:0] mover_right [0:3];
// mover decode: kq011
assign mover_function[0] = {i_u[7-4:7-7],i_u[7-0:7-3]};
assign mover_function[1] = i_u | i_v;
assign mover_function[2] = i_u & i_v;
assign mover_function[3] = i_u ^ i_v;
assign mover_function[4] = i_u;
assign mover_function[5] = {i_u[7-0:7-3],i_v[7-4:7-7]};
assign mover_function[6] = {i_v[7-0:7-3],i_u[7-4:7-7]};
// 7 is undefined
assign mover_left[0] = e_mixin;
assign mover_left[1] = i_u[7-0:7-3];
assign mover_left[2] = i_v[7-0:7-3];
assign mover_left[3] = mover_function[wfn][7-0:7-3];
assign mover_right[0] = e_mixin;
assign mover_right[1] = i_u[7-4:7-7];
assign mover_right[2] = i_v[7-4:7-7];
assign mover_right[3] = mover_function[wfn][7-4:7-7];

// w reg: aw011
assign o_w_reg = {mover_left[i_ul], mover_right[i_ur]};
assign o_edit_stat[1] = (i_v != 8'h20) & (i_v != 8'h21);
assign o_edit_stat[2] = (i_v != 8'h20) & (i_v != 8'h22);

assign o_cpu_wfn = wfn_[1'b0];
assign o_io_wfn = wfn_[1'b1];

always @(posedge i_clk) begin
	if (!i_ros_advance)
		;
	else if (i_ss == 6'd38)
		wfn_[i_io_mode] <= i_wfn_munged;
end

endmodule
