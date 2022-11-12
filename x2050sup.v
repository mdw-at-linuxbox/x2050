`default_nettype   none

// 2050 supervisory circuits

// SY22-2832-4
// System 360 Model 50
// 2050 Processing Unit
// Field Engineering Maintenance Manual
// page 37-38
// figure 19 "supervisory controls"

module x2050sup (i_clk, i_reset,
i_ros_advance,
i_system_reset_pb,
i_power_on_pb,
i_psw_restart_pb,
i_load_pb,
i_display_pb,
i_store_pb,
i_set_ic_pb,
i_start_pb,
i_store_sel_sw,
i_rate_sw,
o_reset_system,
o_ce_maint_controls,
o_oppanel);

// verilator lint_off UNUSED
input wire i_clk;
input wire i_reset;
input wire i_ros_advance;
input wire i_system_reset_pb;
input wire i_power_on_pb;
input wire i_psw_restart_pb;
input wire i_load_pb;
input wire i_display_pb;
input wire i_store_pb;
input wire i_set_ic_pb;
input wire i_start_pb;
input wire [1:0] i_store_sel_sw;
// storage: 10 = local 00 = main 01 = stor prot 11 = bump
input wire [1:0] i_rate_sw;
// rate switch: 10=insn step 00=process 01=single cycle
output wire o_reset_system;
output reg o_ce_maint_controls;
output [3:0] o_oppanel;

// SY22-2832-4
// System 360 Model 50 2050 Processing Unit
// Field Engineering Maintenance Manual
// figure 176 "control panel setting" page 188 [pdf 189]

wire insn_step_mode;

// 0000	nil
// 0001 instr step not start
// 0010 set ic
// 0011 repeat inst
// 010x addr sync
// 011x enter channel
// 1yyz store display:
//	yy 00=main store 01=protect tags
//	   10=local store 11=mpx bump
//	z 0=display 1=store

wire op_disp_stor = (i_display_pb | i_store_pb);

assign o_oppanel = {
	op_disp_stor,
	{2{op_disp_stor}} & i_store_sel_sw
		| {1'b0, i_set_ic_pb},
	i_store_pb
		| ~(i_display_pb | i_set_ic_pb) & i_start_pb
// XXX more functions here - set_ic_pb
// repeat_instruction_iar address_compare_iar
// wait_bit (psw 14)
	};

reg reset_reg;
reg system_reset_req;
reg power_on_req;
reg psw_restart_req;
reg load_req;

always @(posedge i_clk)
	if (i_system_reset_pb | i_power_on_pb | i_psw_restart_pb | i_load_pb | i_reset)
		reset_reg <= 1'b1;
	else
		reset_reg <= 1'b0;

assign o_reset_system = reset_reg | i_reset;

always @(posedge i_clk)
	if (i_reset)
		system_reset_req <= 0;
	else if (i_system_reset_pb)
		system_reset_req <= 1;
	else if (o_ce_maint_controls)
		system_reset_req <= 0;

always @(posedge i_clk)
	if (i_reset)
		power_on_req <= 0;
	else if (i_power_on_pb)
		power_on_req <= 1;
	else if (o_ce_maint_controls)
		power_on_req <= 0;

always @(posedge i_clk)
	if (i_reset)
		psw_restart_req <= 0;
	else if (i_psw_restart_pb)
		psw_restart_req <= 1;
	else if (o_ce_maint_controls)
		psw_restart_req <= 0;

always @(posedge i_clk)
	if (i_reset)
		load_req <= 0;
	else if (i_load_pb)
		load_req <= 1;
	else if (o_ce_maint_controls | i_power_on_pb)
		load_req <= 0;

always @(posedge i_clk)
	if (i_reset)
		o_ce_maint_controls <= 0;
	else if (system_reset_req | psw_restart_req | load_req)
		o_ce_maint_controls <= 1;
	else if (i_ros_advance)
		o_ce_maint_controls <= 0;

endmodule
