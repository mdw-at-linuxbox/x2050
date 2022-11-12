`default_nettype   none

// 2050 central module - stitch the cpu together

module x2050 (i_clk, i_reset,
	// front panel
	o_roller_1,
	o_roller_2,
	o_roller_3,
	o_roller_4,
	o_data_ind,
	o_address_ind,
	i_roller_1_sw,
	i_roller_2_sw,
	i_roller_3_sw,
	i_roller_4_sw,
	i_data_key,
	i_address_key,
	i_init_prog_load_sw,
	i_display_pb,
	i_store_pb,
	i_reset_sw,
	i_power_on_sw,
	i_start_pb,
	i_psw_restart_sw,
	i_set_ic_pb,
	i_store_sel_sw,
	i_rate_sw,
	i_ipl,
	// direct control
	i_dd_in,
	o_dd_sample,
	// ram
	o_wb_cyc, o_wb_stb, o_wb_we, o_wb_addr, o_wb_data, o_wb_sel,
	i_wb_stall, i_wb_ack, i_wb_data, i_wb_err,
	// multiplexor
	o_mpx_bus_out, i_mpx_bus_in,
	o_mpx_address_out, o_mpx_command_out, o_mpx_service_out, o_mpx_data_out,
	i_mpx_address_in, i_mpx_status_in, i_mpx_service_in, i_mpx_data_in, i_mpx_disc_in,
	o_mpx_operational_out, o_mpx_select_out, o_mpx_hold_out, o_mpx_suppress_out,
	i_mpx_operational_in, i_mpx_select_in, i_mpx_request_in,
	// selector channel #1
	o_s1_bus_out, i_s1_bus_in,
	o_s1_address_out, o_s1_command_out, o_s1_service_out, o_s1_data_out,
	i_s1_address_in, i_s1_status_in, i_s1_service_in, i_s1_data_in, i_s1_disc_in,
	o_s1_operational_out, o_s1_select_out, o_s1_hold_out, o_s1_suppress_out,
	i_s1_operational_in, i_s1_select_in, i_s1_request_in,
	// selector channel #2
	o_s2_bus_out, i_s2_bus_in,
	o_s2_address_out, o_s2_command_out, o_s2_service_out, o_s2_data_out,
	i_s2_address_in, i_s2_status_in, i_s2_service_in, i_s2_data_in, i_s2_disc_in,
	o_s2_operational_out, o_s2_select_out, o_s2_hold_out, o_s2_suppress_out,
	i_s2_operational_in, i_s2_select_in, i_s2_request_in,
	// selector channel #3
	o_s3_bus_out, i_s3_bus_in,
	o_s3_address_out, o_s3_command_out, o_s3_service_out, o_s3_data_out,
	i_s3_address_in, i_s3_status_in, i_s3_service_in, i_s3_data_in, i_s3_disc_in,
	o_s3_operational_out, o_s3_select_out, o_s3_hold_out, o_s3_suppress_out,
	i_s3_operational_in, i_s3_select_in, i_s3_request_in);

	parameter DW=32;
//	parameter XW=24;	// # of adddress bits, 24=16 meg ram (max)
	// 16=64 model F: 16-29 word address, 30-31 byte select
	// 17=128 model G: 15-29 word address, 30-31 byte select
	// 18=256k model H: 14-29 word address, 30-31 byte select
	// 19=512k model I: 13-29 word address, 30-31 byte select
	// XXX need mem range checking
	// XXX need bump storage handling
	localparam AW=(32+3-$clog2(DW));
//	localparam LOG2_DW=$clog2(DW);
//	localparam LOG2_BW=(LOG2_DW-3);

	// front panel
	output wire [35:0] o_roller_1;
	output wire [35:0] o_roller_2;
	output wire [35:0] o_roller_3;
	output wire [35:0] o_roller_4;
	output wire [35:0] o_data_ind;
	output wire [35:0] o_address_ind;
	input wire [31:0] i_data_key;
	input wire [23:0] i_address_key;
	input wire i_init_prog_load_sw;
	input wire i_reset_sw;
	input wire i_power_on_sw;
	input wire i_start_pb;
	input wire i_psw_restart_sw;
	input wire i_set_ic_pb;
	input wire [1:0] i_store_sel_sw;
	// storage: 10 = local 00 = main 01 = stor prot 11 = bump
	input wire [1:0] i_rate_sw;
	input wire [11:0] i_ipl;	// channel,unit address
	// rate switch: 10=insn step 00=process 01=single cycle
	input wire i_display_pb;
	input wire i_store_pb;
	input wire [2:0] i_roller_1_sw;
	input wire [2:0] i_roller_2_sw;
	input wire [2:0] i_roller_3_sw;
	input wire [2:0] i_roller_4_sw;

	// direct control
	input wire [7:0] i_dd_in;
	output wire o_dd_sample;

	// memory
	input wire i_clk;
	input wire i_reset;
	input wire [DW-1:0] i_wb_data;
	output wire [DW-1:0] o_wb_data;
	output reg o_wb_cyc, o_wb_stb, o_wb_we;
	output reg [AW-1:0] o_wb_addr;
	output reg [(DW/8)-1:0] o_wb_sel;

	input wire i_wb_stall, i_wb_ack, i_wb_err;

	output wire [8:0] o_mpx_bus_out;
	input wire [8:0] i_mpx_bus_in;
	output wire o_mpx_address_out;
	output wire o_mpx_command_out;
	output wire o_mpx_service_out;
	output wire o_mpx_data_out;
	input wire i_mpx_address_in;
	input wire i_mpx_status_in;
	input wire i_mpx_service_in;
/* verilator lint_off UNUSED */
	input wire i_mpx_data_in;
	input wire i_mpx_disc_in;
/* verilator lint_on UNUSED */
	output wire o_mpx_operational_out;
	output wire o_mpx_select_out;
	output wire o_mpx_hold_out;
	output wire o_mpx_suppress_out;
	input wire i_mpx_operational_in;
	input wire i_mpx_select_in;
/* verilator lint_off UNUSED */
	input wire i_mpx_request_in;
/* verilator lint_on UNUSED */

	output wire [8:0] o_s1_bus_out;
	input wire [8:0] i_s1_bus_in;
	output wire o_s1_address_out;
	output wire o_s1_command_out;
	output wire o_s1_service_out;
	output wire o_s1_data_out;
	input wire i_s1_address_in;
	input wire i_s1_status_in;
	input wire i_s1_service_in;
/* verilator lint_off UNUSED */
	input wire i_s1_data_in;
	input wire i_s1_disc_in;
/* verilator lint_on UNUSED */
	output wire o_s1_operational_out;
	output wire o_s1_select_out;
	output wire o_s1_hold_out;
	output wire o_s1_suppress_out;
	input wire i_s1_operational_in;
	input wire i_s1_select_in;
/* verilator lint_off UNUSED */
	input wire i_s1_request_in;
/* verilator lint_on UNUSED */

	output wire [8:0] o_s2_bus_out;
	input wire [8:0] i_s2_bus_in;
	output wire o_s2_address_out;
	output wire o_s2_command_out;
	output wire o_s2_service_out;
	output wire o_s2_data_out;
	input wire i_s2_address_in;
	input wire i_s2_status_in;
	input wire i_s2_service_in;
/* verilator lint_off UNUSED */
	input wire i_s2_data_in;
	input wire i_s2_disc_in;
/* verilator lint_on UNUSED */
	output wire o_s2_operational_out;
	output wire o_s2_select_out;
	output wire o_s2_hold_out;
	output wire o_s2_suppress_out;
	input wire i_s2_operational_in;
	input wire i_s2_select_in;
/* verilator lint_off UNUSED */
	input wire i_s2_request_in;
/* verilator lint_on UNUSED */

	output wire [8:0] o_s3_bus_out;
	input wire [8:0] i_s3_bus_in;
	output wire o_s3_address_out;
	output wire o_s3_command_out;
	output wire o_s3_service_out;
	output wire o_s3_data_out;
	input wire i_s3_address_in;
	input wire i_s3_status_in;
	input wire i_s3_service_in;
/* verilator lint_off UNUSED */
	input wire i_s3_data_in;
	input wire i_s3_disc_in;
/* verilator lint_on UNUSED */
	output wire o_s3_operational_out;
	output wire o_s3_select_out;
	output wire o_s3_hold_out;
	output wire o_s3_suppress_out;
	input wire i_s3_operational_in;
	input wire i_s3_select_in;
/* verilator lint_off UNUSED */
	input wire i_s3_request_in;
/* verilator lint_on UNUSED */

	wire [12:0] rosaddr = roar;
	wire [89:0] rosdr;

	wire [3:0] exp_fcn_pos;
	wire [31:0] m_reg;
	wire [3:0] f_reg;
	wire q_reg;
	wire [31:0] sdr;
	wire [3:0] sdr_parity = {^{1'b1,sdr[31-0:31-7]},
		^{1'b1,sdr[31-8:31-15]},
		^{1'b1,sdr[31-16:31-23]},
		^{1'b1,sdr[31-24:31-31]}};
	//parity 1-30
	wire [2:0] lu = rosdr[89-1:89-3];
	wire [1:0] mv = rosdr[89-4:89-5];
	wire [5:0] zp = rosdr[89-6:89-11];
	wire [3:0] zf = rosdr[89-12:89-15];
	wire [3:0] zf_raw = rosdr_raw[89-12:89-15];
	wire [2:0] zn = rosdr[89-16:89-18];
	wire [4:0] tr = rosdr[89-19:89-23];
	//wire zr = rosdr[89-24];	// spare
	wire [2:0] ws = rosdr[89-25:89-27];
	wire [2:0] sf = rosdr[89-28:89-30];
	//parity 31-55
	wire [2:0] iv = rosdr[89-32:89-34];
	wire [2:0] ct = rosdr_raw[89-32:89-34];
	wire [4:0] al = rosdr[89-35:89-39];
	wire [3:0] wm = rosdr[89-40:89-43];
	wire [1:0] up = rosdr[89-44:89-45];	// cpumode only
	wire md = rosdr[89-46];			// cpumode only
	wire [2:0] ms = rosdr[89-44:89-46];	// iomode only
	wire lb = rosdr[89-47];
	wire mb = rosdr[89-48];
	wire [1:0] cg = rosdr[89-47:89-48];
	wire [1:0] cg_raw = rosdr_raw[89-47:89-48];
	wire [2:0] dg = rosdr[89-49:89-51];
	wire [1:0] ul = rosdr[89-52:89-53];
	wire [1:0] ur = rosdr[89-54:89-55];
	//parity 56-89
	wire [3:0] ce = rosdr[89-57:89-60];
	wire [2:0] lx = rosdr[89-61:89-63];
	wire tc = rosdr[89-64];
	wire [2:0] ry = rosdr[89-65:89-67];
	wire [3:0] ad = rosdr[89-68:89-71];
	wire [5:0] ab = rosdr[89-72:89-77];
	wire [4:0] bb = rosdr[89-78:89-82];
	//wire ux = rosdr[89-83];	// spare
	wire [5:0] ss = rosdr[89-84:89-89];
	wire [7:0] gpstat;
	wire carry_stat;
	wire one_syllable_op_stat;
	wire refetch_stat;
	wire l_sign_stat;
	wire r_sign_stat;
	wire [4:0] io_stat;
	wire [2:1] edit_stat;
	wire ac_log;
	wire log_scan_stat;
	wire [3:0] stc;
	wire pss;
	wire gated_pass_trig;
	wire gated_fail_trig;
	wire [23:0] nextiar;
	wire [23:0] iar;
	wire [24:0] sar;
	wire [3:0] spdr;
	wire [7:0] sysmask;
	wire [3:0] pkey;
	wire [3:0] amwp;
	wire [1:0] ilc;
	wire [1:0] cc_reg;
	wire [3:0] progmask;
	wire [3:0] md_reg;
	wire [3:0] j_reg;
	wire [2:0] cpu_wfn_reg;
	wire [2:0] io_wfn_reg;
	wire [7:0] u_reg;
	wire [7:0] v_reg;
	wire [7:0] w_reg;	// mover latch
	wire [1:0] mb_reg;	// bam
	wire [1:0] lb_reg;	// bal
	wire [1:0] io_reg;
	wire g1_sign;
	wire g2_sign;
	wire [7:0] g_reg;	// <7:4> g1, <3:0> g2
	wire [31:0] r_reg;
	wire [31:0] l_reg;
	wire [31:0] t_reg;
	wire [31:0] h_reg;
	wire [3:0] bs_reg;
	wire [5:0] lsa;
	wire [1:0] lsfn;
	wire [1:0] ch;
	wire [31:0] ls;
	wire [31:0] xin;
	wire [31:0] xg;
	wire [31:0] y;
	wire [31:0] t0;
	wire [3:0] f1;
	wire [31:0] t1;
	wire [32:0] dec_cor;
	wire carry_in;
	wire carry;
	wire aux;
	wire c0;
	wire c1;
	wire c8;
	wire c16;
	wire c24;
	wire cx_bs;
	wire fp_negative;
	wire do_true_add;
	wire expdiff_le16;
	wire expdiff_zero;
	wire exception_branch;
	wire hs_channel_special_branch;
	wire direct_date_hole_sense_br;
	wire channel_interrupt;
	wire external_chan_intr;
	wire timer_update_signal;
	wire manual_trigger;
	wire inv_digit_fix_add;
	wire stor_prot_fix_add;
	wire fix_add_q_pos_com_chan;
	wire stor_spec_fix_add;
	wire sel_mpx_chan_x_bit;
	wire inv_add_fix_add;
	wire add_fix_add;
	wire inv_digit_add;
	wire invalid_decimal_ss;
	wire invalid_address;
	wire storage_prot_violation;
	wire ibfull;
	wire [1:0] fetch_stat_fcn;
	wire io_mode;
	wire firstcycle;
	wire dtc1;
	wire dtc2;
	wire routine_request;
	wire routine_recd;
	wire save_r;
	wire gate_break_routine;
	wire break_in;
	wire chain;
	wire last_cycle;
	wire break_out;
	wire [12:0] nextroar;
	wire [12:0] roar;
	wire [12:0] prevroar;
	wire addr_key_not_equal;
	wire tzbs;
	wire base_add_2_reset;
	wire [7:0] xtr;		// interrupt register
	wire [6:1] ext_irpt_reg;	// external interrupt register
	wire timer_irpt;
	wire cons_irpt;
	wire xtr_sample;	// XXX need to set up to clear xtr
	wire ros_clock_on;
	wire ce_maint_controls;
	wire turn_off_load_light;
	wire rtl;		// retry threshold latch
	wire [3:0] storage_ring;
	wire reset_system;
	wire ms_busy;
	wire data_stall;
	wire data_ready;
	wire data_error;
	wire prot_key_mismatch;
	wire [31:0] data_read;
	wire [3:0] oppanel;
	wire [27:0] sar_and_parity = {
		^{1'b1,sar[31-8:31-15]},sar[31-8:31-15],
		^{1'b1,sar[31-16:31-23]},sar[31-16:31-23],
		^{1'b1,sar[31-24:31-31]},sar[31-24:31-31]};

	// common bus
	wire [8:0] buffer_out_bus;
	wire [8:0] buffer_in_bus;

	wire [3:0] mpx_iostat;
	wire [8:0] mpx_buffer_in_bus;
	wire [8:0] mpx_buffer_1;
	wire [8:0] mpx_buffer_2;

	// XXX figure out how to share this with selector:
	assign io_stat = {1'b0, mpx_iostat};

	// direct control
	wire dd_sample;	// XXX need to hook up to o_dd_sample

	wire [89:0] rosdr_1;
	wire [89:0] rosdr_raw = {90{~rosaddr[12]}} & rosdr_1
//		| {90{rosaddr[12]}} & rosdr_2
		;
	assign rosdr = {90{~save_r}} & rosdr_raw;
	assign ros_clock_on = ~data_stall;

	wire [35:0] roller1_values [0:7];
	wire [35:0] roller2_values [0:7];
	wire [35:0] roller3_values [0:7];
	wire [35:0] roller4_values [0:7];

	// roller 1/2/3/4 index: using grey code:
	// roller 1 - mpx		roller 3 - cpu #1
	// roller 2 - selector		roller 4 - cpu #2
	//	pos	index	pos	index	pos	index
	//	1	1	4	6	7	4
	//	2	3	5	7	8	0
	//	3	2	6	5
	// rollers also documented in,
	// Z22-2855-3
	// Field Engr Handbook System360 Model 50
	// pages 22-31 [pdf 23-32]
	//
	// SY22-2832-4
	// System 360 Model 50 2050 Processing Unit
	// Field Engineering Maintenance Manual
	// roller 1 position 2
	// SY22-2832-4 figure 138 page 162 [pdf 163]
	assign roller1_values[3] = {
		routine_recd,	// rtne recd
		1'b0,		// pci enable
		break_in,	// 2 break in
		1'b0,		// 3 i/o rtne
		1'b0,		// 4 early first cycle
		firstcycle,	// 5 first cycle
		1'b0,		// 6 chain first cycle
		1'b0,		// 7 ls rd
		1'b0,		// 8 ls wr
		1'b0,		// 9 chal dtc
		1'b0,		// 10 alch dtc
		chain,		// 11 chain
		last_cycle,	// 12 last cycle
		break_out,	// 13 break out
		4'b0,		// 14-17 sbcr
		1'b0,		// 18 unused
		iv[1:0],	// 19-20 ros 33-34
		cg,		// 21-22 ros 47-48
		1'b0,		// first cycle chk
		12'b0		// 23-35
	};
	// roller 1 position 3
	// SY22-2832-4 figure 137 page 162 [pdf 163]
	assign roller1_values[2][35-12:35-16] = io_stat;
	// roller 1 position 4
	// figure 140 page 163 [pdf 164]
	assign roller1_values[6][35-0:35-8] = mpx_buffer_1;
	assign roller1_values[6][35-9:35-17] = mpx_buffer_2;
	// roller 1 position 5
	// SY22-2832-4 figure 141 page 164 [pdf 165]
	assign roller1_values[7][35-0:35-10] = {
		o_mpx_select_out, i_mpx_select_in, i_mpx_operational_in,
		o_mpx_suppress_out, i_mpx_request_in, o_mpx_service_out,
		o_mpx_address_out, o_mpx_command_out, i_mpx_service_in,
		i_mpx_address_in, i_mpx_status_in};
	assign roller1_values[7][35-13:35-21] = {
		o_mpx_bus_out
	};
	// roller 1 position 6
	// SY22-2832-4 figure 142 page 164 [pdf 165]
	assign roller1_values[5][35-15] = ibfull;
	assign roller1_values[5][35-18:35-21] = {
		mpx_iostat
	};
	// roller 3 position 1
	// SY22-2832-4 figure 153 page 171 [pdf 172]
	assign roller3_values[1] = {
		^{1'b1,l_reg[31-0:31-7]},l_reg[31-0:31-7],
		^{1'b1,l_reg[31-8:31-15]},l_reg[31-8:31-15],
		^{1'b1,l_reg[31-16:31-23]},l_reg[31-16:31-23],
		^{1'b1,l_reg[31-24:31-31]},l_reg[31-24:31-31]};
	// roller 3 position 2
	// SY22-2832-4 figure 154 page 172 [pdf 173]
	assign roller3_values[3] = {
		^{1'b1,r_reg[31-0:31-7]},r_reg[31-0:31-7],
		^{1'b1,r_reg[31-8:31-15]},r_reg[31-8:31-15],
		^{1'b1,r_reg[31-16:31-23]},r_reg[31-16:31-23],
		^{1'b1,r_reg[31-24:31-31]},r_reg[31-24:31-31]
	};
	// roller 3 position 3
	// SY22-2832-4 figure 155 page 173 [pdf 174]
	assign roller3_values[2] = {
		^{1'b1,m_reg[31-0:31-7]},m_reg[31-0:31-7],
		^{1'b1,m_reg[31-8:31-15]},m_reg[31-8:31-15],
		^{1'b1,m_reg[31-16:31-23]},m_reg[31-16:31-23],
		^{1'b1,m_reg[31-24:31-31]},m_reg[31-24:31-31]
	};
	// roller 3 position 4
	// SY22-2832-4 figure 156 page 174 [pdf 175]
	assign roller3_values[6] = {
		^{1'b1,h_reg[31-0:31-7]},h_reg[31-0:31-7],
		^{1'b1,h_reg[31-8:31-15]},h_reg[31-8:31-15],
		^{1'b1,h_reg[31-16:31-23]},h_reg[31-16:31-23],
		^{1'b1,h_reg[31-24:31-31]},h_reg[31-24:31-31]
	};
	// roller 3 position 5
	// SY22-2832-4 figure 157 page 175 [pdf 176]
	assign roller3_values[7] = {
		sar_and_parity,
		1'b0,
		bs_reg, bs_reg	// XXX diff?
	};
	// roller 3 position 6
	// SY22-2832-4 figure 158 page 176 [pdf 177]
	assign roller3_values[5] = {rosdr[89-56:89-89],2'b0};
	// roller 3 position 7
	// SY22-2832-4 figure 159 page 177 [pdf 178]
	// assign roller3_values[4] = { };
	// roller 3 position 8
	// SY22-2832-4 figure 160 page 177 [pdf 178]
	// assign roller3_values[0] = { };
	// roller 4 position 1
	// SY22-2832-4 figure 161 page 178 [pdf 179]
	assign roller4_values[1] = {
		rosdr[89-0:89-18],
		1'b0,
		rosdr[89-19:89-30],
		4'b0
	};
	// roller 4 position 2
	// SY22-2832-4 figure 162 page 178 [pdf 179]
	assign roller4_values[3] = {
		rosdr[89-31:89-55],
		1'b0,
		cpu_wfn_reg, io_wfn_reg,
		4'b0
	};
	// roller 4 position 3
	// SY22-2832-4 figure 163 page 179 [pdf 180]
	assign roller4_values[2] = {
		one_syllable_op_stat,
		refetch_stat,
		3'b0,
		nextroar[11+1:11-11],
		ext_irpt_reg,
		ilc, cc_reg, progmask,
		4'b0
	};
	// roller 4 position 4
	// SY22-2832-4 figure 164 page 180 [pdf 181]
	assign roller4_values[6] = {
		io_mode,
		^{1'b1,io_reg},io_reg,
		timer_irpt,
		cons_irpt,
		^{1'b1,lb_reg},lb_reg,
		^{1'b1,mb_reg},mb_reg,
		^{1'b1,f_reg},f_reg,
		q_reg,
		edit_stat[1], edit_stat[2],
		gpstat,
		l_sign_stat,
		r_sign_stat,
		carry,
		rtl,
		storage_ring
	};
	// roller 4 position 5
	// SY22-2832-4 figure 165 page 181 [pdf 182]
	assign roller4_values[7] = {
		^{1'b1,lsa},lsa,
		lsfn,
		^{1'b1,j_reg},j_reg,
		^{1'b1,md_reg},md_reg,
		1'b0,
		g1_sign, ^{1'b1,g_reg[7:4]},g_reg[7:4],
		g2_sign, ^{1'b1,g_reg[3:0]},g_reg[3:0],
		4'b0
	};
	// roller 4 position 6
	// SY22-2832-4 figure 166 page 181 [pdf 182]
	// check bits for registers (indicates parity errors)
	// assign roller4_values[5] = { };
	// roller 4 position 7
	// SY22-2832-4 figure 167 page 182 [pdf 183]
	assign roller4_values[4] = {
		5'b0,
		roar,
		18'b0
	};
	// roller 4 position 8
	// SY22-2832-4 figure 168 page 182 [pdf 183]
	assign roller4_values[0] = {
		5'b0,
		prevroar,
		18'b0
	};

	assign o_roller_1 = roller1_values[i_roller_1_sw];
	assign o_roller_2 = roller2_values[i_roller_2_sw];
	assign o_roller_3 = roller3_values[i_roller_3_sw];
	assign o_roller_4 = roller4_values[i_roller_4_sw];

	x2050sup u_sup(.i_clk(i_clk), .i_reset(i_reset),
		.i_ros_advance(ros_clock_on),
		.i_system_reset_pb(i_reset_sw),
		.i_power_on_pb(i_power_on_sw),
		.i_psw_restart_pb(i_psw_restart_sw),
		.i_load_pb(i_init_prog_load_sw),
		.i_display_pb(i_display_pb),
		.i_store_pb(i_store_pb),
		.i_set_ic_pb(i_set_ic_pb),
		.i_start_pb(i_start_pb),
		.i_store_sel_sw(i_store_sel_sw),
		.i_rate_sw(i_rate_sw),
		.o_reset_system(reset_system),
		.o_ce_maint_controls(ce_maint_controls),
		.o_oppanel(oppanel));

	x2050br u_br(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_ms_busy(ms_busy),
		.i_zf(zf_raw),
		.i_ct(ct),
		.i_cg(cg_raw),
		.i_ss(ss),
		.i_routine_request(routine_request),
		.o_routine_recd(routine_recd),
		.o_io_mode(io_mode),
		.o_firstcycle(firstcycle),
		.o_dtc1(dtc1),
		.o_dtc2(dtc2),
		.o_gate_break_routine(gate_break_routine),
		.o_save_r(save_r),
		.o_break_in(break_in),
		.o_chain(chain),
		.o_last_cycle(last_cycle),
		.o_break_out(break_out));

	x2050ros u_ros(i_clk, reset_system, rosaddr[11:0], rosdr_1);

	x2050roar u_roar (.i_clk(i_clk), .i_reset(reset_system),
		.i_data_key(i_data_key),
		.i_set_ic_pb(i_set_ic_pb),
		.i_exp_fcn_pos(exp_fcn_pos),
		.i_m_reg(m_reg),
		.i_f_reg(f_reg),
		.i_sdr(sdr),
		.i_zp(zp),
		.i_zf(zf),
		.i_zn(zn),
		.i_ab(ab),
		.i_bb(bb),
		.i_gpstat(gpstat),
		.i_carry_stat(carry_stat),
		.i_one_syllable_op_stat(one_syllable_op_stat),
		.i_l_sign_stat(l_sign_stat),
		.i_r_sign_stat(r_sign_stat),
		.i_io_stat(io_stat),
		.i_edit_stat(edit_stat),
		.i_ac_log(ac_log),
		.i_log_scan_stat(log_scan_stat),
		.i_stc(stc),
		.i_pss(pss),
		.i_gated_pass_trig(gated_pass_trig),
		.i_gated_fail_trig(gated_fail_trig),
		.i_iar(iar),
		.i_amwp(amwp),
		.i_cc_reg(cc_reg),
		.i_md_reg(md_reg),
		.i_j_reg(j_reg),
		.i_w_reg(w_reg),
		.i_mb_reg(mb_reg),
		.i_lb_reg(lb_reg),
		.i_g_reg(g_reg),
		.i_g1_sign(g1_sign),
		.i_g2_sign(g2_sign),
		.i_r_reg(r_reg),
		.i_l_reg(l_reg),
		.i_t_reg(t_reg),
		.i_bs_reg(bs_reg),
		.i_exception_branch(exception_branch),
		.i_hs_channel_special_branch(hs_channel_special_branch),
		.i_direct_date_hole_sense_br(direct_date_hole_sense_br),
		.i_channel_interrupt(channel_interrupt),
		.i_external_chan_intr(external_chan_intr),
		.i_timer_update_signal(timer_update_signal),
		.i_manual_trigger(manual_trigger),
		.i_init_prog_load_sw(i_init_prog_load_sw),
		.i_reset_sw(i_reset_sw),
		.i_psw_restart_sw(i_psw_restart_sw),
		.i_inv_digit_fix_add(inv_digit_fix_add),
		.i_stor_prot_fix_add(stor_prot_fix_add),
		.i_fix_add_q_pos_com_chan(fix_add_q_pos_com_chan),
		.i_stor_spec_fix_add(stor_spec_fix_add),
		.i_sel_mpx_chan_x_bit(sel_mpx_chan_x_bit),
		.i_inv_add_fix_add(inv_add_fix_add),
		.i_inv_digit_add(inv_digit_add),
		.i_invalid_address(invalid_address),
		.i_storage_prot_violation(storage_prot_violation),
		.i_bus_in_0(mpx_buffer_in_bus[0]),
		.i_ibfull(ibfull),
		.i_io_mode(io_mode),
		.i_fetch_stat_fcn(fetch_stat_fcn),
		.i_ros_advance(ros_clock_on),
		.i_gate_break_routine(gate_break_routine),
		.i_break_out(break_out),
		.i_ce_maint_controls(ce_maint_controls),
		.o_nextroar(nextroar),
		.o_roar(roar),
		.o_prevroar(prevroar),
		.o_tzbs(tzbs),
		.o_addr_key_not_equal(addr_key_not_equal),
		.o_base_add_2_reset(base_add_2_reset));

	x2050mvr mover(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_io_mode(io_mode),
		.i_ul(ul),
		.i_ur(ur),
		.i_u(u_reg),
		.i_v(v_reg),
		.i_e(ce),
		.i_ss(ss),
		.i_amwp(amwp),
		.o_w_reg(w_reg),
		.o_edit_stat(edit_stat),
		.o_cpu_wfn(cpu_wfn_reg),
		.o_io_wfn(io_wfn_reg));

	x2050lmv u_mover_left_input(.i_clk(i_clk), .i_reset(reset_system),
		.i_lu(lu),
		.i_io_mode(io_mode),
		.i_r_reg(r_reg),
		.i_l_reg(l_reg),
		.i_md_reg(md_reg),
		.i_f_reg(f_reg),
		.i_mb_reg(mb_reg),
		.i_lb_reg(lb_reg),
		.i_dd_in(i_dd_in),
		.i_mpx_buffer_in_bus(mpx_buffer_in_bus),
		.i_ilc(ilc),
		.i_cc(cc_reg),
		.i_progmask(progmask),
		.i_xtr(xtr),
		.o_u_reg(u_reg),
		.o_dd_sample(dd_sample),
		.o_xtr_sample(xtr_sample));

	x2050rmv u_mover_right_input(.i_clk(i_clk), .i_reset(reset_system),
		.i_mv(mv),
		.i_io_mode(io_mode),
		.i_m_reg(m_reg),
		.i_mb_reg(mb_reg),
		.i_lb_reg(lb_reg),
		.i_mpx_buffer_in_bus(mpx_buffer_in_bus),
		.o_v_reg(v_reg));

	x2050lad u_adder_left_input(.i_clk(i_clk), .i_reset(reset_system),
		.i_io_mode(io_mode),
		.i_lx(lx),
		.i_tc(tc),
		.i_e(ce),
		.i_l_reg(l_reg),
		.i_ioreg(io_reg),
		.o_xin(xin),
		.o_xg(xg));

	x2050rad u_adder_right_input(.i_clk(i_clk), .i_reset(reset_system),
		.i_lx(lx),
		.i_ry(ry),
		.i_r_reg(r_reg),
		.i_m_reg(m_reg),
		.i_h_reg(h_reg),
		.i_sdr_parity(sdr_parity),
		.o_y(y));

	x2050add u_adder(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_ad(ad),
		.i_al(al),
		.i_carry_in(carry_in),
		.i_xg(xg),
		.i_y(y),
//		.i_l_reg(l_reg),
		.o_t0(t0),
		.o_dec_cor(dec_cor),
		.o_c0(c0),
		.o_c1(c1),
		.o_c8(c8),
		.o_c16(c16),
		.o_c24(c24),
//		.o_carry(carry),
		.o_aux(aux));
	x2050treg u_treg(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_al(al),
		.i_e(ce),
		.i_t0(t0),
		.i_gpstat(gpstat),
		.i_l_reg(l_reg),
		.i_data_key(i_data_key),
		.i_address_key(i_address_key),
		.i_data_read(data_read),
		.o_f1(f1),
		.o_t1(t1),
		.o_f_reg(f_reg),
		.o_q_reg(q_reg),
		.o_t_reg(t_reg));

	wire md_write = (tr == 5'd25) | (tr == 5'd26) | (tr == 5'd27)
		| (wm == 4'd13) | (wm == 4'd15);
	wire [3:0] md_newvalue = {4{tr == 5'd25}} & t_reg[31-12:31-15]
		| {4{tr == 5'd26}} & t_reg[31-0:31-3]
		| {4{tr == 5'd27}} & t_reg[31-8:31-11]
		| {4{(wm == 4'd13) | (wm == 4'd15)}} & w_reg[7:4];
	// XXX md is 4 bits -- does UP1 set it to 3 or 15?
	x2050bc #(4) u_md(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_up(up),
		.i_sel(md & ~io_mode),
		.i_wstb(md_write),
		.i_newvalue(md_newvalue),
		.o_bc(md_reg));

	wire lb_write = (wm == 4'd3);
	wire [1:0] lb_newvalue = w_reg[1:0];
	x2050bc u_lb(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_up(up & {2{~io_mode}}),
		.i_sel(lb),
		.i_wstb(lb_write),
		.i_newvalue(lb_newvalue),
		.o_bc(lb_reg));

	wire mb_write = (wm == 4'd2);
	wire [1:0] mb_newvalue = w_reg[1:0];
	x2050bc u_mb(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_up(up & {2{~io_mode}}),
		.i_sel(mb),
		.i_wstb(mb_write),
		.i_newvalue(mb_newvalue),
		.o_bc(mb_reg));

	x2050lreg u_lreg(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_tr(tr),
		.i_sf(sf),
		.i_ss(ss),
		.i_t_reg(t_reg),
		.i_ipl(i_ipl),
		.i_ls(ls),
		.i_dec_cor(dec_cor),
		.o_l_reg(l_reg));

	x2050rreg u_rreg(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_tr(tr),
		.i_sf(sf),
		.i_t_reg(t_reg),
		.i_ls(ls),
		.i_break_out(break_out),
		.o_r_reg(r_reg));

	x2050lsa u_lsa(.i_clk(i_clk), .i_reset(reset_system),
		.i_io_mode(io_mode),
		.i_ws(ws),
		.i_ss(ss),
		.i_save_r(save_r),
		.i_break_out(break_out),
		.i_j_reg(j_reg),
		.i_md_reg(md_reg),
		.i_e(ce),
		.i_ch(ch),
		.o_lsfn(lsfn),
		.o_lsa(lsa));

	x2050ls u_ls(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_we(~sf[1] | save_r),
		.i_newvalue(sf[2] ? l_reg : r_reg),
		.i_lsa(lsa),
		.o_ls(ls));

	x2050ms u_ms (.i_clk(i_clk), .i_reset(reset_system),
		.o_wb_cyc(o_wb_cyc), .o_wb_stb(o_wb_stb), .o_wb_we(o_wb_we),
		.o_wb_addr(o_wb_addr), .o_wb_data(o_wb_data),
		.o_wb_sel(o_wb_sel),
		.i_wb_stall(i_wb_stall), .i_wb_ack(i_wb_ack),
		.i_wb_data(i_wb_data), .i_wb_err(i_wb_err),
		.i_tr(tr), .i_iv(iv), .i_wm(wm),
		.i_e(ce),
		.i_ab(ab), .i_al(al), .i_ss(ss),
		.i_nextiar(nextiar),
		.i_t_reg(t_reg), .i_f_reg(f_reg), .i_bs_reg(bs_reg),
		.i_ros_clock_on(ros_clock_on),
		.i_io_mode(io_mode),
		.o_protection_key(pkey),
		.o_ms_busy(ms_busy),
		.o_data_stall(data_stall),
		.o_data_ready(data_ready),
		.o_data_read(data_read),
		.o_sdr(sdr),
		.o_data_error(data_error),
		.o_prot_key_mismatch(prot_key_mismatch),
		.o_storage_ring(storage_ring),
		.o_spdr(spdr),
		.o_sar(sar));

	x2050bs u_bs(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_ss(ss), .i_ce(ce), .i_mb_reg(mb_reg),
		.o_bs_reg(bs_reg));

	x2050ilc u_ilc(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_tr(tr), .i_t_reg(t_reg),
		.o_ilc(ilc));

	x2050amwp u_amwp(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_ss(ss), .i_t_reg(t_reg),
		.o_amwp(amwp));

	x2050cc u_cc(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_io_mode(io_mode),
		.i_ce(ce),
		.i_ss(ss),
		.i_wm(wm),
		.i_w_reg(w_reg),
		.i_bs_reg(bs_reg),
		.i_t_reg(t_reg),
		.i_sdr(sdr),
		.i_carry(carry),
		.i_c0(c0),
		.i_gpstat(gpstat),
		.i_tzbs(tzbs),
		.o_cc_reg(cc_reg),
		.o_progmask(progmask),
		.o_turn_off_load_light(turn_off_load_light));

	x2050st u_st(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_ad(ad),
		.i_e(ce),
		.i_tr(tr),
		.i_ss(ss),
		.i_f1(f1),
		.i_t1(t1),
		.i_c0(c0),
		.i_cx_bs(cx_bs),
		.i_fp_negative(fp_negative),
		.i_do_true_add(do_true_add),
		.i_expdiff_le16(expdiff_le16),
		.i_expdiff_zero(expdiff_zero),
		.i_oppanel(oppanel),
		.o_gpstat(gpstat));

	x2050mreg u_mreg(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_io_mode(io_mode),
		.i_tr(tr),
		.i_wm(wm),
		.i_mb_reg(mb_reg),
		.i_t_reg(t_reg),
		.i_w_reg(w_reg),
		.o_m_reg(m_reg));

	x2050jreg u_jreg(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_io_mode(io_mode),
		.i_tr(tr),
		.i_wm(wm),
		.i_t_reg(t_reg),
		.i_w_reg(w_reg),
		.o_j_reg(j_reg));

	x2050iar u_iar(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_io_mode(io_mode),
		.i_tr(tr),
		.i_iv(iv),
		.i_e(ce),
		.i_ilc(ilc),
		.i_sdr(sdr),
		.o_nextiar(nextiar),
		.o_iar(iar));

	x2050fet u_fet(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_tr(tr),
		.i_e(ce),
		.i_ss(ss),
		.i_iar(iar),
		.i_t_reg(t_reg),
		.i_invalid_address(invalid_address),
		.o_one_syllable_op_stat(one_syllable_op_stat),
		.o_ibfull(ibfull),
		.o_refetch_stat(refetch_stat),
		.o_fetch_stat_fcn(fetch_stat_fcn));

	x2050hreg u_hreg(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_tr(tr),
		.i_al(al),
		.i_t_reg(t_reg),
		.i_t0(t0),
		.i_iar(iar),
		.o_h_reg(h_reg));

	x2050sn u_sn(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_ss(ss),
		.i_r_reg(r_reg),
		.i_l_reg(l_reg),
		.i_w_reg(w_reg),
		.i_u(u_reg),
		.o_r_sign_stat(r_sign_stat),
		.o_l_sign_stat(l_sign_stat),
		.o_invalid_decimal_ss(invalid_decimal_ss));

	x2050cs u_cs(.i_clk(i_clk), .i_reset(reset_system),
		.i_bs_reg(bs_reg),
		.i_c0(c0),
		.i_c8(c8),
		.i_c16(c16),
		.i_c24(c24),
		.o_cx_bs(cx_bs));

	x2050ex u_ex(.i_clk(i_clk), .i_reset(reset_system),
		.i_xin(xin),
		.i_y(y),
		.i_c1(c1),
		.i_gpstat(gpstat),
		.o_fp_negative(fp_negative),
		.o_do_true_add(do_true_add),
		.o_expdiff_le16(expdiff_le16),
		.o_expdiff_zero(expdiff_zero),
		.o_exp_fcn_pos(exp_fcn_pos));

	x2050cy u_cy(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_io_mode(io_mode),
		.i_dg(dg),
		.i_ad(ad),
		.i_c0(c0),
		.i_c1(c1),
		.i_c8(c8),
		.o_carry_in(carry_in),
		.o_next_carry(carry_stat),
		.o_carry(carry));

	x2050greg u_greg(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_io_mode(io_mode),
		.i_dg(dg),
		.i_wm(wm),
		.i_w_reg(w_reg),
		.o_g_reg(g_reg),
		.o_g1_sign(g1_sign),
		.o_g2_sign(g2_sign));

	x2050mpxb u_mpx_bus(.i_clk(i_clk), .i_reset(reset_system),
		.i_ros_advance(ros_clock_on),
		.i_ms(ms),
		.i_mg(dg),
		.i_e(ce),
		.i_ss(ss),
		.i_io_mode(io_mode),
		.o_iostat(mpx_iostat),
		.o_mpx_buffer_in_bus(mpx_buffer_in_bus),
		.o_mpx_buffer_1(mpx_buffer_1),
		.o_mpx_buffer_2(mpx_buffer_2),
		.i_buffer_out_bus(buffer_out_bus),
		.o_buffer_in_bus(buffer_in_bus),
		.o_mpx_bus_out(o_mpx_bus_out),
		.i_mpx_bus_in(i_mpx_bus_in),
		.o_mpx_address_out(o_mpx_address_out),
		.o_mpx_command_out(o_mpx_command_out),
		.o_mpx_service_out(o_mpx_service_out),
		.o_mpx_data_out(o_mpx_data_out),
		.i_mpx_address_in(i_mpx_address_in),
		.i_mpx_status_in(i_mpx_status_in),
		.i_mpx_service_in(i_mpx_service_in),
		.i_mpx_data_in(i_mpx_data_in),
		.i_mpx_disc_in(i_mpx_disc_in),
		.o_mpx_operational_out(o_mpx_operational_out),
		.o_mpx_select_out(o_mpx_select_out),
		.o_mpx_hold_out(o_mpx_hold_out),
		.o_mpx_suppress_out(o_mpx_suppress_out),
		.i_mpx_operational_in(i_mpx_operational_in),
		.i_mpx_select_in(i_mpx_select_in),
		.i_mpx_request_in(i_mpx_request_in));

endmodule
