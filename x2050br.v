`default_nettype   none
// 2050 break in
//
// 2050 byte stats
// 2050 Control Field Specification
// CFC 112 - 2050 control field specification - cpu mode (ss)
// [pdf page 13]
//
// Y22-2827-0
// 360/50 Multiplexor Channel FETOM
// description pages 6,28-33 [pdf 6,28-33]
// figure 19 pages 29-30 [pdf 29-30]
// timing is shown in detail, but there's little information about
// the circuits used to achieve the result.

module x2050br (i_clk, i_reset,
i_ros_advance,
i_ms_busy,
i_zf,
i_ct,
i_cg,
i_ss,
i_routine_request,
o_routine_recd,
o_io_mode,
o_firstcycle,
o_dtc1,
o_dtc2,
o_gate_break_routine,
o_save_r,
o_break_in,
o_chain,
o_last_cycle,
o_break_out);

input wire i_clk;
input wire i_reset;
input wire i_ros_advance;
input wire i_ms_busy;
input wire [3:0] i_zf;
input wire [2:0] i_ct;
input wire [1:0] i_cg;
input wire [5:0] i_ss;
input wire i_routine_request;
output reg o_routine_recd;
output wire o_io_mode;
output wire o_firstcycle;
output wire o_dtc1;
output wire o_dtc2;
output wire o_gate_break_routine;
output wire o_save_r;
output wire o_break_in;
output wire o_chain;
output wire o_last_cycle;
output wire o_break_out;
wire one_pri;
wire ok_to_break_in;
wire cg2;
wire cg3;
reg break_out_delayed;
reg pri_was_set;
reg routine_mode;

wire set_routine_recd = i_routine_request & (one_pri | ok_to_break_in) & ~o_gate_break_routine;
wire clear_routine_recd = o_gate_break_routine;
wire set_iomode = (i_ss == 6'd58)
	| ((~routine_mode & ~i_ms_busy) & o_routine_recd)
	;
wire clear_iomode = (i_ss == 6'd59) & routine_mode
	| o_break_out & ~o_gate_break_routine
	;

assign o_firstcycle = routine_mode & (i_ct == 3'd1);

// XXX some ibm logic shows this as ignoring i_ct[2]...?
// such as Z22-2833-R page iop 111 [pdf 106]
assign o_dtc1 = o_io_mode & (i_ct == 3'd2);
assign o_dtc2 = o_io_mode & (i_ct == 3'd3);

assign o_break_out = routine_mode & (i_zf == 4'd14);

wire suppress_save_r = o_break_out | o_firstcycle | o_firstcycle;

assign ok_to_break_in = (~routine_mode
| o_last_cycle
| o_break_out
);

assign o_gate_break_routine = ok_to_break_in & o_routine_recd;
assign o_break_in = o_gate_break_routine & routine_mode;
assign o_save_r = o_gate_break_routine & ~routine_mode & ~suppress_save_r;
assign cg2 = routine_mode & (i_cg == 2'd2) & ~o_save_r;
assign cg3 = routine_mode & (i_cg == 2'd3);

assign one_pri = cg2 | pri_was_set;

assign o_chain = one_pri & o_routine_recd & o_last_cycle;

assign o_last_cycle = cg3;
assign o_io_mode = set_iomode | routine_mode;

always @(posedge i_clk) begin
	if (i_reset)
		break_out_delayed <= 0;
	else break_out_delayed <= o_break_out;
end

always @(posedge i_clk) begin
	if (i_reset)
		pri_was_set <= 0;
	else if (!i_ros_advance)
		;
	else if (cg2)
		pri_was_set <= 1;
	else if (o_break_out | o_gate_break_routine)
		pri_was_set <= 0;
end

always @(posedge i_clk) begin
	if (i_reset)
		o_routine_recd <= 0;
	else if (!i_ros_advance)
		;
	else if (set_routine_recd)
		o_routine_recd <= 1;
	else if (clear_routine_recd)
		o_routine_recd <= 0;
end

// io_mode bit: kc531
// ss_decode to set io_mode: ks671
always @(posedge i_clk)
	if (i_reset) begin
		routine_mode <= 1'b0;
	end else if (!i_ros_advance)
		;
	else if (clear_iomode)
		routine_mode <= 1'b0;
	else if (set_iomode)
		routine_mode <= 1'b1;
endmodule
