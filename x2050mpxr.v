`default_nettype   none

// 2050 multiplexor - routine logic

// Y22-2827-0_360-50_Multiplexor_Channel_FETOM_Oct66.pdf
// page 26

module x2050mpxr (i_clk, i_reset,
	i_ros_advance,
	// other ins
	i_inhibit_io_fixed_address,
	i_pci_mpx_request_to_roar,
	i_any_ch0_op_code,
	i_mop_tic,
	i_tic,
	i_start_io,
	i_test_io,
	i_halt_io,
	i_int_test_io,
	i_foul_on_st_io,
	i_mop_valid,
	i_invalid_op,
	i_valid_addr,
	i_prev_tic,
	i_poll_ctrl_no_req_in,
	i_test_channel,
	i_poll_control,
	i_status_zero,
	i_status_equal,
	i_count_gt_1,
	i_count_ne_0,
	i_dec_count_eq_1,
	i_dec_count_eq_0,
	i_wait_for_not_op_in,
	i_a0,
	i_a1,
	i_a2,
	i_a3,
	i_a7,
	i_b0,
	i_b1,
	i_b2,
	i_b3,
	i_b5,
	i_b6,
	i_b7,
	i_c0,
	i_c1,
	i_c2,
	i_c3,
	i_c5,
	i_c6,
	i_c7,
	i_d0,
	i_d1,
	i_d2,
	i_d3,
	i_d4,
	i_d5,
	i_d7,
	i_bc3,
	i_c_br,
	i_a_ck,
	i_any_ck_on,
	i_ucw_store_trigger,
	i_seq_ctr_is_active,
	i_seq_ctr_is_idle,
	i_seq_ctrl_5,
	i_seq_ctrl_5_busy,
	i_seq_ctrls_idle,
	i_br_ctrl_0,
	i_br_ctrl_1,
	i_br_ctrl_2,
	i_br_ctrl_3,
	i_br_ctrl_4,
	i_br_ctrl_5,
	i_br_ctrl_6,
	i_br_ctrl_7,
	i_br_ctrl_8,
	i_br_ctrl_9,
	i_br_ctrl_10,
	i_br_ctrl_11,
	i_br_ctrl_12,
	i_br_ctrl_13,
	i_br_ctrl_14,
	i_br_ctrl_15,
	i_active,
	i_input,
	i_output,
	i_fwd_bkwd,
	i_skip,
	i_sili_flag,
	i_unit_status_error,
	i_error,
	i_any_busy,
	i_attention,
	i_status_mod,
	i_cu_end,
	i_busy,
	i_chan_end,
	i_device_end,
	i_unit_ck,
	i_unit_exception,
	i_stop,
	i_idle,
	i_cc_flag,
	i_new_cc_flag,
	i_cc,
	i_cc_tgr_on,
	i_cc_latch_on,
	i_cc_end_rcvd,
	i_cda_flag,
	i_prot_ck,
	i_invalid_addr,
	i_inv_bump_addr,
	i_ucw_ua_ne_if_ua,
	i_ucw_ua_ne_test_io_ua,
	i_instr_ua_ne_if_ua,
	i_intrpt_test_io,
	i_io_stat_start,
	i_prog_ck,
	i_ibfull,
	i_attn_in_ib,
	i_ib_attn,
	i_ib_devend,
	i_ch_end_rcvd,
	i_ch_end_queued,
	i_devend_queued,
	i_ch_end_in_ib,
	i_test_io_ua_eq_ib_ua,
	// out
	o_request_a0,
	o_request_a1,
	o_request_a2,
	o_request_a3,
	o_request_a7,
	o_request_b0,
	o_request_b1,
	o_request_b2,
	o_request_b3,
	o_request_b5,
	o_request_b6,
	o_request_b7,
	o_request_c0,
	o_request_c1,
	o_request_c2,
	o_request_c3,
	o_request_c5,
	o_request_c6,
	o_request_c7,
	o_request_d0,
	o_request_d1,
	o_request_d2,
	o_request_d3,
	o_request_d4,
	o_request_d5,
	o_request_d7,
	o_resume_polling,
	o_log,
	// multiplexor
	i_bus_out, i_bus_in,
	i_address_out, i_command_out, i_service_out, i_data_out,
	i_address_in, i_status_in, i_service_in, i_data_in, i_disc_in,
	i_operational_out, i_select_out, i_hold_out, i_suppress_out,
	i_operational_in, i_select_in, i_request_in);

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;

	input wire i_inhibit_io_fixed_address;
	input wire i_pci_mpx_request_to_roar;
	input wire i_any_ch0_op_code;
	input wire i_mop_tic;
	input wire i_tic;
	input wire i_start_io;
	input wire i_test_io;
	input wire i_halt_io;
	input wire i_int_test_io;
	input wire i_foul_on_st_io;
	input wire i_mop_valid;
	input wire i_invalid_op;
	input wire i_valid_addr;
	input wire i_prev_tic;
	input wire i_poll_ctrl_no_req_in;
	input wire i_test_channel;
	input wire i_poll_control;
	input wire i_status_zero;
	input wire i_status_equal;
	input wire i_count_gt_1;
	input wire i_count_ne_0;
	input wire i_dec_count_eq_1;
	input wire i_dec_count_eq_0;
	input wire i_wait_for_not_op_in;
	input wire i_a0;
	input wire i_a1;
	input wire i_a2;
	input wire i_a3;
	input wire i_a4;
	input wire i_a5;
	input wire i_a6;
	input wire i_a7;
	input wire i_b0;
	input wire i_b1;
	input wire i_b2;
	input wire i_b3;
	input wire i_b5;
	input wire i_b6;
	input wire i_b7;
	input wire i_c0;
	input wire i_c1;
	input wire i_c2;
	input wire i_c3;
	input wire i_c5;
	input wire i_c6;
	input wire i_c7;
	input wire i_d0;
	input wire i_d1;
	input wire i_d2;
	input wire i_d3;
	input wire i_d4;
	input wire i_d5;
	input wire i_d7;
	input wire i_bc3;
	input wire i_c_br;
	input wire i_a_ck;
	input wire i_any_ck_on;
	input wire i_ucw_store_trigger;
	input wire i_seq_ctr_is_active;
	input wire i_seq_ctr_is_idle;
	input wire i_seq_ctrl_5;
	input wire i_seq_ctrl_5_busy;
	input wire i_seq_ctrls_idle;
	input wire i_br_ctrl_0;
	input wire i_br_ctrl_1;
	input wire i_br_ctrl_2;
	input wire i_br_ctrl_3;
	input wire i_br_ctrl_4;
	input wire i_br_ctrl_5;
	input wire i_br_ctrl_6;
	input wire i_br_ctrl_7;
	input wire i_br_ctrl_8;
	input wire i_br_ctrl_9;
	input wire i_br_ctrl_10;
	input wire i_br_ctrl_11;
	input wire i_br_ctrl_12;
	input wire i_br_ctrl_13;
	input wire i_br_ctrl_14;
	input wire i_br_ctrl_15;
	input wire i_active;
	input wire i_input;
	input wire i_output;
	input wire i_fwd_bkwd;
	input wire i_skip;
	input wire i_sili_flag;
	input wire i_unit_status_error;
	input wire i_error;
	input wire i_any_busy;
	input wire i_attention;
	input wire i_status_mod;
	input wire i_cu_end;
	input wire i_busy;
	input wire i_chan_end;
	input wire i_device_end;
	input wire i_unit_ck;
	input wire i_unit_exception;
	input wire i_stop;
	input wire i_idle;
	input wire i_cc_flag;
	input wire i_new_cc_flag;
	input wire i_cc;
	input wire i_cc_tgr_on;
	input wire i_cc_latch_on;
	input wire i_cc_end_rcvd;
	input wire i_cda_flag;
	input wire i_prot_ck;
	input wire i_invalid_addr;
	input wire i_inv_bump_addr;
	input wire i_ucw_ua_ne_if_ua;
	input wire i_ucw_ua_ne_test_io_ua;
	input wire i_instr_ua_ne_if_ua;
	input wire i_intrpt_test_io;
	input wire i_io_stat_start;
	input wire i_prog_ck;
	input wire i_ibfull;
	input wire i_attn_in_ib;
	input wire i_ib_attn;
	input wire i_ib_devend;
	input wire i_devend_queued;
	input wire i_ch_end_rcvd;
	input wire i_ch_end_queued;
	input wire i_ch_end_in_ib;
	input wire i_test_io_ua_eq_ib_ua;

	output wire o_request_a0;
	output wire o_request_a1;
	output wire o_request_a2;
	output wire o_request_a3;
	output wire o_request_a4;
	output wire o_request_a5;
	output wire o_request_a6;
	output wire o_request_a7;
	output wire o_request_b0;
	output wire o_request_b1;
	output wire o_request_b2;
	output wire o_request_b3;
	output wire o_request_b5;
	output wire o_request_b6;
	output wire o_request_b7;
	output wire o_request_c0;
	output wire o_request_c1;
	output wire o_request_c2;
	output wire o_request_c3;
	output wire o_request_c5;
	output wire o_request_c6;
	output wire o_request_c7;
	output wire o_request_d0;
	output wire o_request_d1;
	output wire o_request_d2;
	output wire o_request_d3;
	output wire o_request_d4;
	output wire o_request_d5;
	output wire o_request_d7;
	output wire o_resume_polling;
	output wire o_log;

	input wire [8:0] i_bus_out;	// p,0-7
	input wire [8:0] i_bus_in;	// p,0-7
	input wire i_address_out;
	input wire i_command_out;
	input wire i_service_out;
	input wire i_data_out;
	input wire i_address_in;
	input wire i_status_in;
	input wire i_service_in;
/* verilator lint_off UNUSED */
	input wire i_data_in;
	input wire i_disc_in;
/* verilator lint_on UNUSED */
	input wire i_operational_out;
	input wire i_select_out;
	input wire i_hold_out;
	input wire i_suppress_out;
	input wire i_operational_in;
	input wire i_select_in;
/* verilator lint_off UNUSED */
	input wire i_request_in;
/* verilator lint_on UNUSED */

	wire b3_and_br_ctrl_7 = i_b3 & i_br_ctrl_7;
	wire b3_and_bc7_and_input = i_service_in & i_input
		& i_status_zero & b3_and_br_ctrl_7;
	wire d3_bc1_nprog = i_d3 & i_br_ctrl_1 & ~i_prog_ck;
	wire d3_bc1_cc = d3_bc1_nprog & i_new_cc_flag & i_status_zero;
	wire d3_bc1_ncc = d3_bc1_nprog & ~i_new_cc_flag & i_status_zero;
	wire d7_brc13 = i_d7 & (i_br_ctrl_1 | i_br_ctrl_3);

	wire input_skip = i_skip;	// ok?
	wire a2_svci_nsvco_bc3b7 = i_a2 & i_service_in & ~i_service_out
		& (i_bc3 | i_br_ctrl_7);
	wire a3_bc7 = i_a3 & i_br_ctrl_7;
	wire a7_bc7_svci_nsvco = i_a7 & i_br_ctrl_7
		& i_service_in & ~i_service_out;
	wire d3_bc3_st0_skip_svci = i_d3 & i_br_ctrl_3 & ~i_prog_ck
		& i_status_zero & i_input & i_skip & i_service_in;
	wire d7_svci = i_d7 & i_service_in;
	wire a4_nibfull = i_a4 & ~i_ibfull;
	wire a5_bc57 = (i_br_ctrl_5 | i_br_ctrl_7) & i_a5;
	wire d3_bc5_nibfull  = i_d3 & i_br_ctrl_5 & ~i_ibfull;
	wire nprog_ncc_userror = ~i_prog_ck & i_new_cc_flag
		& i_unit_status_error;
	wire d3_bc7_ibfull = i_d3 & i_br_ctrl_7 & i_ibfull;

	wire a2_input = i_a2 & i_input;
	wire a2_output_bc37 = i_a2 & i_output & (i_br_ctrl_3 | i_br_ctrl_7);
	wire a3_input = i_a2 & i_input;
	wire a3_output_bc7 = i_a3 & i_br_ctrl_7 & i_output;
	wire devendattnidle = i_device_end | i_attn_in_ib | i_idle;
	wire d0_bc1 = i_d0 & i_br_ctrl_1;
	wire d4_bc6_cc = i_d4 & i_br_ctrl_6 & i_cc;
	wire b1_bc1_seqidle = i_b1 & i_br_ctrl_1 & i_seq_ctrls_idle;
	wire b3_bc15 = i_b3 & i_br_ctrl_15;
	wire c3_bc3 = i_c3 & i_br_ctrl_3;
	wire mop_tic_d4bc3cda = i_mop_tic & d4bc3cda;
	wire d4bc3cda = i_d4 | i_br_ctrl_3 | i_cda_flag;
	wire anybusystatmod = i_any_busy | i_status_mod;
	wire staseli = i_status_in & i_select_in;
	wire b0_bc0_foulstio = i_b0 & i_br_ctrl_0 & i_foul_on_st_io;
	wire c1_bc2 = i_c1 & i_br_ctrl_2;
	wire no_nsi = ~i_operational_in & ~i_status_in;
	wire no_nsi_nucwstore = no_nsi & ~i_ucw_store_trigger;

	assign o_request_a0 = i_address_in & i_poll_control;
	assign o_request_a1 = i_a0 & i_br_ctrl_0;
	assign o_request_a2 = i_a1 & i_br_ctrl_1
			& i_output & ~i_status_in
		| i_a1 & i_br_ctrl_2 & i_input
			& i_fwd_bkwd & i_service_in
		| ~i_skip & b3_and_bc7_and_input
		| b3_and_bc7_and_input & i_skip
		| b3_and_br_ctrl_7 & ~i_status_zero & ~i_input
		| i_service_in & ~i_skip & i_input & d3_bc1_cc
		| d3_bc1_cc & ~i_input
		| ~i_input & d3_bc1_ncc
		| d3_bc1_ncc & i_input & ~i_skip & i_service_in
		| ~i_input & d7_brc13
		| d7_brc13 & i_input & ~i_skip & i_service_in
		;
	assign o_request_a3 = i_a1 & i_br_ctrl_3 & i_stop &
			input_skip & ~i_service_in
		| i_input & a2_svci_nsvco_bc3b7
		| a2_svci_nsvco_bc3b7 & i_output
		| ~i_service_out & i_service_in & i_input & a3_bc7
		| a3_bc7 & i_output & i_count_gt_1
		| (i_prot_ck | i_invalid_addr) & i_cda_flag & a7_bc7_svci_nsvco
		| a7_bc7_svci_nsvco & ~i_cda_flag & i_input
		| a7_bc7_svci_nsvco & ~i_cda_flag & i_output
		| ~i_new_cc_flag & d3_bc3_st0_skip_svci
		| d3_bc3_st0_skip_svci & i_new_cc_flag
		| i_br_ctrl_7 & d7_svci
		| d7_svci & i_input & i_skip & i_br_ctrl_1 & i_br_ctrl_3
		;
	assign o_request_a4 = i_a1 & i_br_ctrl_1 & i_output & i_status_in
			& ~i_cc_tgr_on
		| i_d7 & i_br_ctrl_7 & ~i_service_in & i_status_in
			& i_cc_tgr_on	// XXX like a5?
		| i_c_br & i_status_in & ~i_cc_latch_on
		;
	assign o_request_a5 = i_a1 & i_br_ctrl_1 & i_output & i_status_in
			& i_cc_tgr_on
		| i_d7 & i_br_ctrl_7 & ~i_service_in & i_status_in
			& i_cc_tgr_on	// XXX like a4?
		| i_c_br & i_status_in & i_cc_latch_on
		;
	assign o_request_a6 = i_active & i_br_ctrl_5 & a4_nibfull
		| a4_nibfull & i_br_ctrl_6 & ~i_active
		| i_a4 & i_br_ctrl_7 & i_ibfull
		| ~i_sili_flag & i_count_ne_0 & a5_bc57
		| a5_bc57 & (~i_count_ne_0 | i_sili_flag
			& (i_attention | i_busy | i_unit_ck | i_unit_exception
				| i_status_mod & ~i_device_end))
		| a5_bc57 & (~i_count_ne_0 | i_sili_flag & ~i_chan_end
			& i_device_end & i_seq_ctrl_5 & ~i_cc_end_rcvd)
		| i_prog_ck & d3_bc5_nibfull
		| d3_bc5_nibfull & nprog_ncc_userror
		| d3_bc7_ibfull & i_prog_ck
		;
	assign o_request_a7 = (i_invalid_addr | i_prot_ck)
			& a2_input
		| a2_input & i_br_ctrl_5 & i_dec_count_eq_0
		| i_dec_count_eq_1 & a2_output_bc37
		| a2_output_bc37 & i_invalid_addr
		| ( i_invalid_addr | i_prot_ck )
		| a3_input & i_br_ctrl_5 & i_dec_count_eq_0
		| i_dec_count_eq_1 & a3_output_bc7
		| a3_output_bc7 & (i_invalid_addr | i_prot_ck)
		;

	assign o_request_b0 = i_any_ch0_op_code & i_poll_ctrl_no_req_in
		& ~i_test_channel;
	assign o_request_b1 = i_b0 & i_br_ctrl_0 & i_start_io;
	assign o_request_b2 = i_b1 & i_br_ctrl_6 & i_seq_ctrls_idle
		& i_operational_in & i_address_in;
	assign o_request_b3 = i_b2 & i_br_ctrl_4 & i_status_in;
	assign o_request_b5 = i_c_br & ~i_status_in & ~i_operational_in
			& i_ucw_store_trigger & ~i_any_ck_on
		| ~i_any_ck_on & i_a_ck
		| i_b7 & i_br_ctrl_11
		| i_a5 & i_br_ctrl_3 & i_chan_end & ~i_device_end
		;
	assign o_request_b6 = i_b5 & i_br_ctrl_2
		| i_d5 | i_br_ctrl_0 & i_io_stat_start
		;
	assign o_request_b7 = i_c_br & ~i_status_in & ~i_operational_in
			& i_ucw_store_trigger & i_any_ck_on
		| i_any_ck_on & i_a_ck
		;

	assign o_request_c0 = i_inhibit_io_fixed_address
		& i_pci_mpx_request_to_roar;
	assign o_request_c1 = i_b0 & i_br_ctrl_0
		& (i_test_io | i_int_test_io);
	assign o_request_c2 = i_c0 & i_br_ctrl_6 & i_operational_in
			& i_address_in & devendattnidle
		| i_c7 & i_br_ctrl_6 & i_operational_in & i_address_in
		;
	assign o_request_c3 = i_c2 & i_br_ctrl_2 & i_address_in & i_status_in;
	assign o_request_c5 = i_b1 & i_br_ctrl_6 & i_seq_ctrls_idle
			& i_operational_in & i_status_in & ~i_select_in
		| i_c1 & i_br_ctrl_6 & ~i_operational_in & ~i_int_test_io
			& devendattnidle
		| i_c6 & i_br_ctrl_6 & ~i_operational_in & i_status_in
		| i_c7 & i_br_ctrl_6 & ~i_operational_in & ~i_int_test_io
		;
	assign o_request_c6 = i_b0 & i_br_ctrl_0 & i_halt_io;
	assign o_request_c7 = i_c1 & i_br_ctrl_1 & i_ch_end_queued
		| i_c1 & i_br_ctrl_1 & i_ch_end_in_ib & i_test_io_ua_eq_ib_ua
		;

	assign o_request_d0 = i_a5 & i_br_ctrl_6
			& (i_chan_end & i_device_end | i_cc_end_rcvd)
		| i_a7 & i_br_ctrl_6 & i_cda_flag & ~i_invalid_addr & ~i_prot_ck
		| i_b3 & i_br_ctrl_6 & i_cc_flag & i_chan_end & i_device_end
		| i_d4 & i_br_ctrl_1 & i_mop_tic & i_valid_addr & ~i_prev_tic
		| i_d3 & i_br_ctrl_6 & ~i_prog_ck & i_new_cc_flag
			& i_status_equal & ~i_error & i_device_end
		;
	assign o_request_d1 = i_cda_flag & d0_bc1
		| d0_bc1 & ~i_cda_flag & ~i_operational_in
		;
	assign o_request_d2 = i_d1 & i_br_ctrl_6 & i_operational_in
			& i_address_in
		| ~i_mop_valid & d4_bc6_cc
		| d4_bc6_cc & i_mop_valid & ~i_tic
		;
	assign o_request_d3 = i_d2 & i_br_ctrl_2 & i_status_in ;
	assign o_request_d4 = i_d1 & i_br_ctrl_2 ;
	assign o_request_d5 = i_prog_ck & b1_bc1_seqidle
		| b1_bc1_seqidle & (i_tic | i_invalid_op)
		| i_cc_flag & i_unit_status_error & b3_bc15
		| b3_bc15 & ~i_cc_flag & ~i_status_zero
		| anybusystatmod & c3_bc3
		| c3_bc3 & ~anybusystatmod & (i_chan_end | i_devend_queued)
		| i_c5 & i_br_ctrl_3
		| i_c6 & i_br_ctrl_6 & i_operational_in & i_address_in
			& i_wait_for_not_op_in
		| i_c7 & i_br_ctrl_3
		;
	assign o_request_d7 = i_d1 & i_br_ctrl_3
		| i_prev_tic & i_valid_addr & mop_tic_d4bc3cda
		| mop_tic_d4bc3cda & i_invalid_addr
		| d4bc3cda & ~i_mop_valid
		| d4bc3cda & i_mop_valid & ~i_tic
		;
	assign o_resume_polling = i_seq_ctrls_idle & b0_bc0_foulstio
		| b0_bc0_foulstio & i_seq_ctrl_5_busy
		| i_b0 & i_br_ctrl_6 & i_inv_bump_addr
		| i_b1 & i_br_ctrl_2 & i_seq_ctr_is_active
		| i_b1 & i_br_ctrl_6 & i_seq_ctr_is_idle
			& i_operational_in & i_select_in
		| i_b6 & ~i_operational_in & ~i_status_in
		| (i_busy | i_ch_end_rcvd) & c1_bc2
		| c1_bc2 & i_ch_end_in_ib & ~i_test_io_ua_eq_ib_ua
		| i_c3 & i_br_ctrl_2 & i_status_zero
			& (~i_any_busy | ~i_status_mod)
			& (~i_chan_end | i_devend_queued)
		| i_c6 & i_br_ctrl_6 & i_select_in & no_nsi
		| i_c7 & i_br_ctrl_2 & i_ucw_ua_ne_test_io_ua
		| i_d5 & no_nsi
		// I presume d7 starts a different "and" case...
		| i_d7 & i_br_ctrl_7 & ~i_service_in &
			& no_nsi_nucwstore
		| no_nsi_nucwstore & i_c_br
		;
	assign o_log = i_a0 & i_br_ctrl_6 & i_inv_bump_addr
		| i_b2 & i_br_ctrl_1 & i_ucw_ua_ne_if_ua
		| i_c1 & i_br_ctrl_6
			& (i_ib_devend | i_ib_attn | i_idle)
			& ~i_operational_in & i_intrpt_test_io & staseli
		| staseli & i_c2 & i_br_ctrl_1 & i_instr_ua_ne_if_ua
		| i_c7 & i_br_ctrl_6 & ~i_operational_in
			& i_intrpt_test_io & staseli
		| i_d1 & i_br_ctrl_6 & ~i_operational_in & staseli
		;

endmodule
