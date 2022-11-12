`default_nettype   none

// 2050 read only address register (roar)
// SY22-2823-0

module x2050roar (i_clk, i_reset,
i_data_key,
i_set_ic_pb,
i_exp_fcn_pos,
i_m_reg,
i_f_reg,
i_sdr,
i_zp,
i_zf,
i_zn,
i_ab,
i_bb,
i_gpstat,
i_carry_stat,
i_one_syllable_op_stat,
i_l_sign_stat,
i_r_sign_stat,
i_io_stat,
i_edit_stat,
i_ac_log,
i_log_scan_stat,
i_stc,
i_pss,
i_gated_pass_trig,
i_gated_fail_trig,
i_iar,
i_amwp,
i_cc_reg,
i_md_reg,
i_j_reg,
i_w_reg,
i_mb_reg,
i_lb_reg,
i_g_reg,
i_g1_sign,
i_g2_sign,
i_r_reg,
i_l_reg,
i_t_reg,
i_bs_reg,
i_exception_branch,
i_hs_channel_special_branch,
i_direct_date_hole_sense_br,
i_channel_interrupt,
i_external_chan_intr,
i_timer_update_signal,
i_manual_trigger,
i_init_prog_load_sw,
i_reset_sw,
i_psw_restart_sw,
i_inv_digit_fix_add,
i_stor_prot_fix_add,
i_fix_add_q_pos_com_chan,
i_stor_spec_fix_add,
i_sel_mpx_chan_x_bit,
i_inv_add_fix_add,
i_inv_digit_add,
i_invalid_address,
i_storage_prot_violation,
i_bus_in_0,
i_ibfull,
i_io_mode,
i_fetch_stat_fcn,
i_gate_break_routine,
i_break_out,
i_ce_maint_controls,
i_ros_advance,
o_nextroar,
o_roar,
o_prevroar,
o_addr_key_not_equal,
o_tzbs,
o_base_add_2_reset);

input wire i_clk;
input wire i_reset;
input wire [31:0] i_data_key;
input wire i_set_ic_pb;
input wire [3:0] i_exp_fcn_pos;
input wire [31:0] i_m_reg;
input wire [3:0] i_f_reg;
input wire [31:0] i_sdr;
input wire [5:0] i_zp;
input wire [3:0] i_zf;
input wire [2:0] i_zn;
input wire [5:0] i_ab;
input wire [4:0] i_bb;
input wire [7:0] i_gpstat;
input wire i_carry_stat;
input wire i_one_syllable_op_stat;
input wire i_l_sign_stat;
input wire i_r_sign_stat;
input wire [4:0] i_io_stat;
input wire [2:1] i_edit_stat;
input wire i_ac_log;
input wire i_log_scan_stat;
input wire [3:0] i_stc;
input wire i_pss;
input wire i_gated_pass_trig;
input wire i_gated_fail_trig;
input wire [23:0] i_iar;
input wire [3:0] i_amwp;
input wire [1:0] i_cc_reg;
input wire [3:0] i_md_reg;
input wire [3:0] i_j_reg;
input wire [7:0] i_w_reg;	// mover latch
input wire [1:0] i_mb_reg;	// bam
input wire [1:0] i_lb_reg;	// bal
input wire [7:0] i_g_reg;	// <7:4> g1, <3:0> g2
input wire i_g1_sign;
input wire i_g2_sign;
input wire [31:0] i_r_reg;
input wire [31:0] i_l_reg;
input wire [31:0] i_t_reg;
input wire [3:0] i_bs_reg;
input wire i_exception_branch;
input wire i_hs_channel_special_branch;
input wire i_direct_date_hole_sense_br;
input wire i_channel_interrupt;
input wire i_external_chan_intr;
input wire i_timer_update_signal;
input wire i_manual_trigger;
input wire i_init_prog_load_sw;
input wire i_reset_sw;
input wire i_psw_restart_sw;
input wire i_inv_digit_fix_add;
input wire i_stor_prot_fix_add;
input wire i_fix_add_q_pos_com_chan;
input wire i_stor_spec_fix_add;
input wire i_sel_mpx_chan_x_bit;
input wire i_inv_add_fix_add;
input wire i_inv_digit_add;
input wire i_invalid_address;
input wire i_storage_prot_violation;
input wire i_bus_in_0;
input wire i_ibfull;
input wire i_io_mode;
input wire [1:0] i_fetch_stat_fcn;
input wire i_gate_break_routine;
input wire i_break_out;
input wire i_ce_maint_controls;
input wire i_ros_advance;
output wire [12:0] o_nextroar;
output reg [12:0] o_roar;
output reg [12:0] o_prevroar;
output wire o_addr_key_not_equal;
output wire o_tzbs;
output reg o_base_add_2_reset;

reg [12:0] io_backup;
wire display_ros_add_gate = i_set_ic_pb;

// SY22-2823-0
// page 29 figure 24 "read only storage address register positions 0-5"
// KK301 roar 0,1,5
// KK311 roar 2,3
// KK321 roar 4
// page 32 figure 25 "read only storage address register positions 6-9"
// KK011 fcn bit 0
// KK021 fcn bit 1
// KK031 fcn bit 2
// KK041 fcn bit 3
// page 33 figure 26 "read only storage address register - position a"
// KK191 KK201 KK211 KK221 KK231 KK251 KK261 KK291 KK313 bit a
// page 34 figure 27 "read only storage address register - position b"
// KK141 KK151 KK161 KK171 KK181 KK271 KK313 bit b

wire inhibit_normal_addr = display_ros_add_gate | add_bfr_ros_add_cntl | scan_sdr_to_roadd | i_gate_break_routine;
wire gate_next_roar = ~inhibit_normal_addr;
wire function_to_roadd = (i_zn == 3'd0);
wire gate_add_field_to_roadd = (i_zn != 3'd0);
wire jam_roar = display_ros_add_gate | scan_sdr_to_roadd;

wire m03_ros_add_cntl = function_to_roadd & (i_zf == 4'd6);
wire m47_ros_add_cntl = function_to_roadd & (i_zf == 4'd8);
wire add_bfr_ros_add_cntl = i_break_out;
wire scan_sdr_to_roadd = function_to_roadd & (i_zf == 4'd2);
wire f_reg_ros_add_cntl = function_to_roadd & (i_zf == 4'd10);
wire expf_ros_add_cntl = function_to_roadd & (i_zf == 4'd12);

wire [12:0] next_roar;
wire [6:0] hw_address;

// kk301 kk311 kk321
assign next_roar[11+1:11-5] =
	i_data_key[31-19:31-25] & {7{display_ros_add_gate}}
	| {o_roar[11+1], i_zp} & {7{ gate_next_roar }}
	| i_sdr[31-18:31-24] & {7{scan_sdr_to_roadd}}
	| io_backup[11+1:11-5] & {7{add_bfr_ros_add_cntl}}
	| hw_address;

// kk011 kk021 kk031 kk041
assign next_roar[11-6:11-9] =
	i_data_key[31-26:31-29] & {4{display_ros_add_gate}}
	| i_exp_fcn_pos & {4{expf_ros_add_cntl}}
	| i_m_reg[31-0:31-3] & {4{m03_ros_add_cntl}}
	| i_m_reg[31-4:31-7] & {4{m47_ros_add_cntl}}
	| i_f_reg & {4{f_reg_ros_add_cntl}}
	| i_zf & {4{gate_add_field_to_roadd}}
	| i_sdr[31-25:31-28] & {4{scan_sdr_to_roadd}}
	| io_backup[11-6:11-9] & {4{add_bfr_ros_add_cntl}}
	;

wire g1_eq_zero = ~|{i_g_reg[7:4]};
wire g1_neg = i_g1_sign;
wire g2_eq_zero = ~|{i_g_reg[3:0]};
wire g2_neg = i_g2_sign;
wire g2_01_eq_zero = ~|{i_g_reg[1:0]};
wire [31:0] bsmask = { {8{i_bs_reg[3-0]}},
	{8{i_bs_reg[3-1]}},
	{8{i_bs_reg[3-2]}},
	{8{i_bs_reg[3-3]}} };
assign o_tzbs = ~|(i_t_reg & bsmask);
wire t_2931_nz_or_inv_add = |{i_t_reg[31-29:31-31]} | i_invalid_address;

// k191 kk201 kk211 kk221 kk231 kk251 kk261
wire a_branch_bit = (i_ab == 6'd1)
	| (i_ab == 6'd2) & i_gpstat[7]
	| (i_ab == 6'd3) & i_gpstat[6]
	| (i_ab == 6'd4) & i_gpstat[5]
	| (i_ab == 6'd5) & i_gpstat[4]
	| (i_ab == 6'd6) & i_gpstat[3]
	| (i_ab == 6'd7) & i_gpstat[2]
	| (i_ab == 6'd8) & i_gpstat[1]
	| (i_ab == 6'd9) & i_gpstat[0]
	| (i_ab == 6'd10) & i_carry_stat
	| (i_ab == 6'd12) & i_one_syllable_op_stat
	| (i_ab == 6'd13) & i_l_sign_stat
	| (i_ab == 6'd14) & i_l_sign_stat ^ i_r_sign_stat
	| (i_ab == 6'd16) & ((i_md_reg[3-0] & i_cc_reg==2'd0)
		| (i_md_reg[3-1] & i_cc_reg==2'd1)
		| (i_md_reg[3-2] & i_cc_reg==2'd2)
		| (i_md_reg[3-3] & i_cc_reg==2'd3))
	| (i_ab == 6'd17) & ~|{i_w_reg}
	| (i_ab == 6'd18) & ~|{i_w_reg[7-0:7-3]}
	| (i_ab == 6'd19) & ~|{i_w_reg[7-4:7-7]}
	| (i_ab == 6'd20) & ~i_md_reg[3-3] & ~i_md_reg[3-0]	// FP 0,2,4,6
	| (i_ab == 6'd21) & i_mb_reg[0] & i_mb_reg[1]
	| (i_ab == 6'd22) & ~i_md_reg[3-3]
	| (i_ab == 6'd23) & g1_eq_zero
	| (i_ab == 6'd24) & g1_neg
	| (i_ab == 6'd25) & ~|{i_g_reg[7:2]}
	| (i_ab == 6'd26) & (g1_eq_zero | (~i_mb_reg[0] & ~i_mb_reg[1]))
	| (i_ab == 6'd27) & i_io_stat[0]
	| (i_ab == 6'd28) & i_io_stat[2]
	| (i_ab == 6'd29) & i_r_reg[31-31]
	| (i_ab == 6'd30) & i_f_reg[3-2]
	| (i_ab == 6'd31) & i_l_reg[31-0]
	| (i_ab == 6'd32) & ~|{i_f_reg}
	| (i_ab == 6'd33) & ~|{i_t_reg[31-8:31-11]} & ~i_gpstat[0]
	| (i_ab == 6'd34) & o_tzbs
	| (i_ab == 6'd35) & i_edit_stat[1]
	| (i_ab == 6'd36) & i_amwp[0]
	| (i_ab == 6'd37) & i_timer_update_signal & ~i_manual_trigger
	| (i_ab == 6'd39) & (g1_eq_zero & g2_eq_zero
		| i_mb_reg[1-0] & i_mb_reg[1-1])
	| (i_ab == 6'd41) & i_log_scan_stat
	| (i_ab == 6'd42) & ~|i_stc
	| (i_ab == 6'd43) & (g2_01_eq_zero & ~i_g_reg[3-2] & ~i_g_reg[3-3]
		| g2_01_eq_zero & i_lb_reg[1-0] & i_lb_reg[1-1]
		| g2_01_eq_zero & i_lb_reg[1-0] & ~i_g_reg[3-2]
		| g2_01_eq_zero & i_lb_reg[1-1] & ~i_g_reg[3-2]
		| g2_01_eq_zero & i_lb_reg[1-0] & ~i_g_reg[3-3])
	| (i_ab == 6'd45) & i_sdr[31-7]
	| (i_ab == 6'd46) & i_gated_pass_trig
	| (i_ab == 6'd47) & i_gated_fail_trig
	| (i_ab == 6'd48) & i_storage_prot_violation
	| (i_ab == 6'd49) & i_w_reg[7-6]
	| (i_ab == 6'd50) & |{i_t_reg[31-16:31-31]}
	| (i_ab == 6'd51) & ~|{i_t_reg[31-5:31-7]} & |{i_t_reg[31-16:31-31]}
	| (i_ab == 6'd52) & i_bus_in_0
	| (i_ab == 6'd53) & i_ibfull
	| (i_ab == 6'd54) & (i_io_mode & t_2931_nz_or_inv_add
		| ~i_io_mode & t_2931_nz_or_inv_add)
	| (i_ab == 6'd55) & i_ac_log
	| (i_ab == 6'd56) & i_fetch_stat_fcn[1]
	| (i_ab == 6'd57) & i_iar[31-30]
	| (i_ab == 6'd58) & (~i_manual_trigger & i_timer_update_signal
			| i_external_chan_intr)
	| (i_ab == 6'd59) & i_direct_date_hole_sense_br
	| (i_ab == 6'd60) & i_pss
	| (i_ab == 6'd61) & i_io_stat[4]
	| (i_ab == 6'd63) & i_gpstat[0] & ~i_m_reg[31-0] & i_m_reg[31-1]
	;
assign next_roar[11-10] = gate_next_roar & (a_branch_bit
		| (i_zn==3'd2) & ~b_branch_bit
		| (i_zn==3'd3) & b_branch_bit)
	| display_ros_add_gate & i_data_key[31-30]
	| scan_sdr_to_roadd & (i_sdr[31-29])
	| io_backup[11-10] & add_bfr_ros_add_cntl
	;
// kk141 kk151 kk161 kk171 kk181 kk271 kk291 kk313
wire b_branch_bit = (i_bb == 5'd1)
	| (i_bb == 5'd2) & i_gpstat[0]
	| (i_bb == 5'd3) & i_gpstat[1]
	| (i_bb == 5'd4) & i_gpstat[2]
	| (i_bb == 5'd5) & i_gpstat[3]
	| (i_bb == 5'd6) & i_gpstat[4]
	| (i_bb == 5'd7) & i_gpstat[5]
	| (i_bb == 5'd8) & i_gpstat[6]
	| (i_bb == 5'd9) & i_gpstat[7]
	| (i_bb == 5'd10) & i_r_sign_stat
	| (i_bb == 5'd11) & i_hs_channel_special_branch
	| (i_bb == 5'd12) & i_exception_branch
	| (i_bb == 5'd13) & ~|{i_w_reg[7-4:7-7]}
	| (i_bb == 5'd15) & ~|{i_t_reg[31-8:31-31]}
	| (i_bb == 5'd16) & i_t_reg[31]
	| (i_bb == 5'd17) & ~|{i_t_reg}
	| (i_bb == 5'd18) & o_tzbs
	| (i_bb == 5'd19) & i_w_reg == 8'd1
	| (i_bb == 5'd20) & ~|i_lb_reg
	| (i_bb == 5'd21) & &i_lb_reg
	| (i_bb == 5'd22) & ~|i_md_reg
	| (i_bb == 5'd23) & g2_eq_zero
	| (i_bb == 5'd24) & g2_neg
	| (i_bb == 5'd25) & (g2_eq_zero | ~|i_lb_reg)
	| (i_bb == 5'd26) & i_io_stat[1]
	| (i_bb == 5'd27) & (i_md_reg[3] | i_j_reg[3] | i_md_reg[0] | i_j_reg[0])
	| (i_bb == 5'd28) & i_invalid_address
	| (i_bb == 5'd29) & i_io_stat[3]
	// | (i_bb == 5'd30) &			// XXX need to handle late carry somehow
	// | (i_bb == 5'd31) &
	| (i_ab == 6'd35) & i_edit_stat[2]
	| (i_ab == 6'd49) & i_w_reg[7-7]
	| (i_ab == 6'd56) & i_fetch_stat_fcn[0]
	| (i_ab == 6'd58) & i_channel_interrupt
	;
assign next_roar[11-11] = gate_next_roar & (b_branch_bit
		| (i_zn==3'd6) & ~a_branch_bit
		| (i_zn==3'd7) & a_branch_bit)
	| display_ros_add_gate & i_data_key[31-31]
	| scan_sdr_to_roadd & (i_sdr[31-30])
	| io_backup[11-11] & add_bfr_ros_add_cntl
	;

assign o_nextroar = next_roar;
always @(posedge i_clk)
        if (i_reset) begin
		o_roar <= 13'b0;
        end else if (i_ros_advance | jam_roar) begin
		o_roar <= next_roar;
	end
always @(posedge i_clk)
	if (i_ros_advance)
		o_prevroar <= o_roar;

//		bit	2	3	4	5
//	 reset sw	+200		+80	+40*	2c0
//	 ipl load	+200			+40*	240
//	 maint sw	+200			+40*	240
// inv add fix add		+100	+80	+40	1c0
// store prot fix add		+100	+80	+40	1c0
// stor spec fix add		+100		+40	140
// inv add fix add		+100			100
// sel mpx chan x bit			+80		80
// fix add q pos com chan			+40	40

assign hw_address[5+1:5-1] = 3'b0;
assign hw_address[5-2] = insert_bit_in_base_add_2;
assign hw_address[5-3] = insert_bit_in_base_add_3;
assign hw_address[5-4] = insert_bit_in_base_add_4;
assign hw_address[5-5] = insert_bit_in_base_add_5;

reg set_rosdr;
reg insert_bit_in_base_add_2;
reg insert_bit_in_base_add_3;
reg insert_bit_in_base_add_4;
reg insert_bit_in_base_add_5;
always @(posedge i_clk)
	set_rosdr <= i_ros_advance;
always @(posedge i_clk)
	if (i_ce_maint_controls)
		insert_bit_in_base_add_2 <= 1'b1 ;
	else if (set_rosdr | i_reset)
		insert_bit_in_base_add_2 <= 1'b0 ;
always @(posedge i_clk)
	if (i_inv_digit_fix_add | i_stor_prot_fix_add | i_stor_spec_fix_add | i_inv_add_fix_add)
		insert_bit_in_base_add_3 <= 1'b1 ;
	else if (set_rosdr | i_reset)
		insert_bit_in_base_add_3 <= 1'b0 ;
always @(posedge i_clk)
	if (i_sel_mpx_chan_x_bit | i_stor_prot_fix_add | i_reset_sw | i_inv_add_fix_add)
		insert_bit_in_base_add_4 <= 1'b1;
	else if (i_ros_advance | i_reset)
		insert_bit_in_base_add_4 <= 1'b0;
always @(posedge i_clk)
	if (i_stor_prot_fix_add | i_fix_add_q_pos_com_chan | i_stor_spec_fix_add | i_inv_add_fix_add | i_ce_maint_controls | i_inv_digit_add)
		insert_bit_in_base_add_5 <= 1'b1;
	else if (i_ros_advance | i_reset)
		insert_bit_in_base_add_5 <= 1'b0;

assign o_addr_key_not_equal = |{i_data_key[31-19:31-31] ^ o_roar[11+1:11-11]};

// XXX probably not quite right: need to latch inputs ipl|amint|reset separately
always @(posedge i_clk)
	if (i_ros_advance)
		o_base_add_2_reset <= i_ce_maint_controls;

endmodule
