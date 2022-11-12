`default_nettype   none

// 2050 multiplexor - control signals

// Y22-2827-0_360-50_Multiplexor_Channel_FETOM_Oct66.pdf

// Z22-2833-R_2050_Processing_Unit_Field_Engineering_Diagram_Manual_Jul66.pdf



module x2050mpxc (i_clk, i_reset,
	i_ros_advance,
	i_e,
	i_ibfull,
	// multiplexor
	i_address_out, i_command_out, i_service_out, i_data_out,
	i_address_in, i_status_in, i_service_in, i_data_in, i_disc_in,
	i_operational_out, i_select_out, i_hold_out, i_suppress_out,
	i_operational_in, i_select_in, i_request_in,
	// common channel
	i_halt_io,
	i_timeout,
	i_com_buffer1,
	i_ch_select,
	i_delayed_io_instruction,
	// mpx
	i_iostat,
	i_dtc1_latch,
	i_any_check_latch,
	i_ch0_dtc1,
	i_ch0_firstcycle,
	i_ch0_reset_1st_cycle_no,
	i_ch0_routine_mode,
	i_ch0_pci_enable,
	i_reset_to_ch0,
	i_step_to_a3,
	i_d1_d4_c1_interrupt,
	i_routine_bit_decoder_0,
	i_routine_bit_decoder_2,
	i_scan_in_mpx_ch_group_1,
	i_scan_in_mpx_ch_group_2,
	i_scan_in_pci_request,
	i_scan_in_priority_2,
	i_scan_in_priority_3,
	i_any_ch0_op_code,
	i_ch0_early_first_cycle,
	i_set_a,
	i_set_e1,
	i_set_e2,
	i_set_e3,
	i_set_e4,
	i_reset_quadrant,
	i_request_a0,
	i_request_b0,
	i_request_c4,
	i_control_check_latch,
	// outs
	o_a0, o_a1, o_a2, o_a3, o_a4, o_a5, o_a6, o_a7,
	o_b0, o_b1, o_b2, o_b3,       o_b5, o_b6, o_b7,
	o_c0, o_c1, o_c2, o_c3,       o_c5, o_c6, o_c7,
	o_d0, o_d1, o_d2, o_d3, o_d4, o_d5,       o_d7,
	o_pci_request_trigger,
	o_priority_2_trigger,
	o_priority_3_trigger,
	o_rtne_req_buffer,
	o_br_ctrl_0,
	o_br_ctrl_1,
	o_br_ctrl_2,
	o_br_ctrl_3,
	o_br_ctrl_4,
	o_br_ctrl_5,
	o_br_ctrl_6,
	o_br_ctrl_7,
	o_br_ctrl_8,
	o_br_ctrl_9,
	o_br_ctrl_10,
	o_br_ctrl_11,
	o_ucw_store_trigger,
	o_poll_control,
	o_burst_mode,
	o_set_cc_2,
	o_log_out_control,
	o_log_out,
	o_initiate_log_out,
	o_reset_count,
	o_if_disconnect_control,
	o_if_disconnect);

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;
	// cpu
	input wire [3:0] i_e;
	input wire i_ibfull;
	// multiplexor
	input wire i_address_out;
	input wire i_command_out;
	input wire i_service_out;
	input wire i_data_out;
	input wire i_address_in;
	input wire i_status_in;
	input wire i_service_in;
	input wire i_data_in;
	input wire i_disc_in;
	input wire i_operational_out;
	input wire i_select_out;
	input wire i_hold_out;
	input wire i_suppress_out;
	input wire i_operational_in;
	input wire i_select_in;
	input wire i_request_in;
	// common channel
	input wire i_halt_io;
	input wire i_timeout;
	input wire [3:0] i_com_buffer2;
	input wire [2:0] i_ch_select;
	input wire i_delayed_io_instruction;
	// mpx
	input wire [3:0] i_iostat;
	input wire i_dtc1_latch;
	input wire i_any_check_latch;
	input wire i_ch0_dtc1;
	input wire i_ch0_firstcycle;
	input wire i_ch0_reset_1st_cycle_no;
	input wire i_ch0_routine_mode;
	input wire i_ch0_pci_enable;
	input wire i_reset_to_ch0;
	input wire i_any_ch0_op_code;
	input wire i_ch0_early_first_cycle;
	input wire i_step_to_a3;
	input wire i_d1_d4_c1_interrupt;
	input wire i_routine_bit_decoder_0;
	input wire i_routine_bit_decoder_2;
	input wire i_scan_in_mpx_ch_group_1;
	input wire i_scan_in_mpx_ch_group_2;
	input wire i_scan_in_pci_request;
	input wire i_scan_in_priority_2;
	input wire i_scan_in_priority_3;
	input wire i_set_a;
	input wire i_set_e1;
	input wire i_set_e2;
	input wire i_set_e3;
	input wire i_set_e4;
	input wire i_reset_quadrant;
	input wire i_request_a0;
	input wire i_request_b0;
	input wire i_request_c4;
	input wire i_control_check_latch;
	// output
	output wire o_a0, o_a1, o_a2, o_a3, o_a4, o_a5, o_a6, o_a7;
	output wire o_b0, o_b1, o_b2, o_b3,       o_b5, o_b6, o_b7;
	output wire o_c0, o_c1, o_c2, o_c3,       o_c5, o_c6, o_c7;
	output wire o_d0, o_d1, o_d2, o_d3, o_d4, o_d5,       o_d7;
	output reg o_pci_request_trigger;
	output reg o_priority_2_trigger;
	output reg o_priority_3_trigger;
	output reg [4:0] o_rtne_req_buffer;
	output wire o_br_ctrl_0;
	output wire o_br_ctrl_1;
	output wire o_br_ctrl_2;
	output wire o_br_ctrl_3;
	output wire o_br_ctrl_4;
	output wire o_br_ctrl_5;
	output wire o_br_ctrl_6;
	output wire o_br_ctrl_7;
	output wire o_br_ctrl_8;
	output wire o_br_ctrl_9;
	output wire o_br_ctrl_10;
	output wire o_br_ctrl_11;
	output reg o_ucw_store_trigger;
	output reg o_poll_control;
	output reg o_burst_mode;
	output reg o_set_cc_2;
	output reg o_log_out_control;
	output reg o_log_out;
	output wire o_initiate_log_out;
	output wire o_reset_count;
	output reg o_if_disconnect_control;
	output reg o_if_disconnect;

	wire select_channel_0;
	wire select_ch0_delayed;
	wire ch0_dtc2;

	wire step_to_c4;
	wire routine_quad_decoder_a;
	wire routine_quad_decoder_b;
	wire routine_quad_decoder_c;
	wire routine_quad_decoder_d;
	wire routine_bit_decoder_0;
	wire routine_bit_decoder_1;
	wire routine_bit_decoder_2;
	wire routine_bit_decoder_3;
	wire routine_bit_decoder_4;
	wire routine_bit_decoder_5;
	wire routine_bit_decoder_6;
	wire routine_bit_decoder_7;

	wire ch0_bfr2_gated = i_com_buffer2[MPX_CH];

parameter MPX_CH = 3'd0;

// Y22-2827-0_360-50_Multiplexor_Channel_FETOM_Oct66.pdf
// figure 14 "branch control register and decoding" page 23 [pdf page 23]

	reg [3:0] br_reg;

	// fa063
	always @(posedge i_clk)
		if (i_reset)
			br_reg <= 0;
		else if (!i_ros_advance)
			;
		else if (~i_dtc1_latch)
			br_reg <= i_e;

	// fa181
	assign {o_br_ctrl_11, o_br_ctrl_10, o_br_ctrl_9, o_br_ctrl_8,
		o_br_ctrl_7, o_br_ctrl_6, o_br_ctrl_5, o_br_ctrl_4,
		o_br_ctrl_3, o_br_ctrl_2, o_br_ctrl_1, o_br_ctrl_0}
		= (12'b1 << br_reg);

// Y22-2827-0_360-50_Multiplexor_Channel_FETOM_Oct66.pdf
// figure 15 "unit control word (ucw) store trigger" page 23 [pdf page 23]

	wire a2_a3 = o_a2 | o_a3;
	wire status_1_reg = i_iostat[3-1];
	// fa251
	wire ucw_store_trigger_set = i_ch0_firstcycle &
			(o_a7 | o_b3 | o_d3 | o_d7)
		| i_any_check_latch & a2_a3
		| i_step_to_a3 & ~status_1_reg & a2_a3 // XXX huh?
		| i_step_to_a3 & a2_a3
		| i_ch0_pci_enable & a2_a3 & dtc1_reg
		;
// XXX just a guess 22-2827; shows a feedback loop here...
	wire ucw_store_trigger_clear =
		i_routine_bit_decoder_0 | i_scan_in_mpx_ch_group_1
		;

	// fa251
	always @(posedge i_clk)
		if (i_reset)
			o_ucw_store_trigger <= 0;
		else if (!i_ros_advance)
			;
		else if (ucw_store_trigger_clear)
			o_ucw_store_trigger <= 0;
		else if (ucw_store_trigger_set)
			o_ucw_store_trigger <= 1;

// Y22-2827-0_360-50_Multiplexor_Channel_FETOM_Oct66.pdf
// figure 16 "routine request circuits (1 of 3)" page 24 [pdf page 24]

	// fa171
	wire turn_on_a = dtc1_reg & i_set_a | step_to_c4;
	wire turn_on_e1 = i_request_b0 | i_set_a & dtc1_reg;

	// fa161
	wire routine_req_quad_gated_latch_clock = (i_reset_quadrant & dtc1_reg
		| i_request_a0 | turn_on_a | turn_on_e1) & i_ros_advance
		;

	// fa161
	wire set_routine_request = turn_on_a | turn_on_e1 | i_set_e2
		| i_set_e3 | i_set_e4;

	wire routine_req_gated_latch_clock = set_routine_request
		& i_ros_advance;

	// fa171
	reg [4:0] ch0_fn;
	always @(posedge i_clk)
		if (i_reset)
			ch0_fn <= 0;
		else if (!i_ros_advance)
			;
		else begin
			if (routine_req_quad_gated_latch_clock)
				ch0_fn[4:3] <= {
					turn_on_a, turn_on_e1
					};
			if (routine_req_gated_latch_clock)
				ch0_fn[2:0] <= {
					i_set_e2, i_set_e3,
					i_set_e4
					};
		end

	// fa201
	always @(posedge i_clk)
		if (i_reset)
			o_rtne_req_buffer <= 0;
		else if (!i_ros_advance)
			;
		else if (i_ch0_early_first_cycle)
			o_rtne_req_buffer <= ch0_fn;

	// fa191
	assign {routine_quad_decoder_d, routine_quad_decoder_c,
		routine_quad_decoder_b, routine_quad_decoder_a} =
		4'b1 << o_rtne_req_buffer[4:3];

	// fa201
	assign {routine_bit_decoder_7, routine_bit_decoder_6,
		routine_bit_decoder_5, routine_bit_decoder_4,
		routine_bit_decoder_3, routine_bit_decoder_2,
		routine_bit_decoder_1, routine_bit_decoder_0} =
		8'b1 << o_rtne_req_buffer[2:0];

	// fa211-221
	assign o_a0 = routine_quad_decoder_a&routine_bit_decoder_0;
	assign o_a1 = routine_quad_decoder_a&routine_bit_decoder_1;
	assign o_a2 = routine_quad_decoder_a&routine_bit_decoder_2;
	assign o_a3 = routine_quad_decoder_a&routine_bit_decoder_3;
	assign o_a4 = routine_quad_decoder_a&routine_bit_decoder_4;
	assign o_a5 = routine_quad_decoder_a&routine_bit_decoder_5;
	assign o_a6 = routine_quad_decoder_a&routine_bit_decoder_6;
	assign o_a7 = routine_quad_decoder_a&routine_bit_decoder_7;
	assign o_b0 = routine_quad_decoder_b&routine_bit_decoder_0;
	assign o_b1 = routine_quad_decoder_b&routine_bit_decoder_1;
	assign o_b2 = routine_quad_decoder_b&routine_bit_decoder_2;
	assign o_b3 = routine_quad_decoder_b&routine_bit_decoder_3;
//	assign o_b4 = routine_quad_decoder_b&routine_bit_decoder_4;
	assign o_b5 = routine_quad_decoder_b&routine_bit_decoder_5;
	assign o_b6 = routine_quad_decoder_b&routine_bit_decoder_6;
	assign o_b7 = routine_quad_decoder_b&routine_bit_decoder_7;
	assign o_c0 = routine_quad_decoder_c&routine_bit_decoder_0;
	assign o_c1 = routine_quad_decoder_c&routine_bit_decoder_1;
	assign o_c2 = routine_quad_decoder_c&routine_bit_decoder_2;
	assign o_c3 = routine_quad_decoder_c&routine_bit_decoder_3;
//	assign o_c4 = routine_quad_decoder_c&routine_bit_decoder_4;
	assign o_c5 = routine_quad_decoder_c&routine_bit_decoder_5;
	assign o_c6 = routine_quad_decoder_c&routine_bit_decoder_6;
	assign o_c7 = routine_quad_decoder_c&routine_bit_decoder_7;
	assign o_d0 = routine_quad_decoder_d&routine_bit_decoder_0;
	assign o_d1 = routine_quad_decoder_d&routine_bit_decoder_1;
	assign o_d2 = routine_quad_decoder_d&routine_bit_decoder_2;
	assign o_d3 = routine_quad_decoder_d&routine_bit_decoder_3;
	assign o_d4 = routine_quad_decoder_d&routine_bit_decoder_4;
	assign o_d5 = routine_quad_decoder_d&routine_bit_decoder_5;
//	assign o_d6 = routine_quad_decoder_d&routine_bit_decoder_6;
	assign o_d7 = routine_quad_decoder_d&routine_bit_decoder_7;

// Y22-2827-0_360-50_Multiplexor_Channel_FETOM_Oct66.pdf
// figure 16 "routine request circuits (2 of 3)" page 24 [pdf page 25]
// Z22-2833-R_2050_Processing_Unit_Field_Engineering_Diagram_Manual_Jul66.pdf
// iop 111 "initiate i-o operation (sheet 2 of 3)" [pdf page 106]

	wire status_0_reg = i_iostat[3-0];
	// fa441
	assign ch0_dtc2 = i_dtc2 & ch0_bfr2_gated;

	// XXX set/clear logic muddled; 22-2827 shows ph feedback?
	// fa261
	wire pci_request_trigger_set = ch0_dtc2 & ~i_ibfull & status_0_reg
		& a2_a3;
	wire pci_request_trigger_clear = (~a2_a3 & dtc1_reg) |
		i_scan_in_mpx_ch_group_1;
	// fa261
	always @(posedge i_clk)
		if (i_reset)
			o_pci_request_trigger <= 0;
		else if (!i_ros_advance)
			;
		else if (pci_request_trigger_clear)
			o_pci_request_trigger <= 0;
		else if (pci_request_trigger_set)
			o_pci_request_trigger <= 1;

	// XXX set/clear logic muddled; 22-2827 shows ph feedback?
	wire priority_2_trigger_set = set_routine_request & i_step_to_a3;
	wire priority_2_trigger_clear = i_scan_in_mpx_ch_group_1
		| i_ch0_reset_1st_cycle_no;
	// fa261
	always @(posedge i_clk)
		if (i_reset)
			o_priority_2_trigger <= 0;
		else if (!i_ros_advance)
			;
		else if (priority_2_trigger_clear)
			o_priority_2_trigger <= 0;
		else if (priority_2_trigger_set)
			o_priority_2_trigger <= 1;

	// XXX set/clear logic muddled; 22-2827 shows ph feedback?
	wire priority_3_trigger_set = set_routine_request & ~i_step_to_a3
		& ~i_reset_to_ch0;
	wire priority_3_trigger_clear = i_scan_in_mpx_ch_group_1
		| i_ch0_reset_1st_cycle_no;
	// fa261
	always @(posedge i_clk)
		if (i_reset)
			o_priority_3_trigger <= 0;
		else if (!i_ros_advance)
			;
		else if (priority_3_trigger_clear)
			o_priority_3_trigger <= 0;
		else if (priority_3_trigger_set)
			o_priority_3_trigger <= 1;

	// fa261
	assign step_to_c4 = (~o_pci_request_trigger | ~o_priority_2_trigger
		| ~o_priority_3_trigger) & i_control_check_latch;

// Y22-2827-0_360-50_Multiplexor_Channel_FETOM_Oct66.pdf
// figure 25 "poll control trigger" page 35 [pdf page 34]

	wire dtc1_reg = i_dtc1_latch;
	wire d3_brctl1_b3_brctl7 = o_d3 & o_br_ctrl_1
		| o_b3 & o_br_ctrl_7;

	wire poll_control_set = ~ o_priority_2_trigger
		& ~ o_priority_3_trigger
		& i_operational_out
		& ~i_ch0_routine_mode
		& ~i_operational_in
		& ~i_status_in
		& ~i_dtc1_latch;
	wire poll_control_clear = ~i_operational_out |
		o_priority_3_trigger
		| i_scan_in_mpx_ch_group_2;
	// fa341
	always @(posedge i_clk)
		if (i_reset)
			o_poll_control <= 0;
		else if (!i_ros_advance)
			;
		else if (poll_control_clear)
			o_poll_control <= 0;
		else if (poll_control_set)
			o_poll_control <= 1;
// 22-2833-R iop 111 "initiate i-o operation (sheet 1 of 2)" [pdf page 105]

	// ke031
	assign select_channel_0 = i_ch_select == MPX_CH;
	// k3031
	assign select_ch0_delayed = select_channel_0 & i_delayed_io_instruction;

// 22-2827-0
// figure 27 "miscellaneous latches" page 37 [pdf page 36]

//	also
// 22-2833-R iop 111 "initiate i-o operation (sheet 1 of 2)" [pdf page 105]

	wire burst_mode_set = select_ch0_delayed | i_timeout | ~ o_log_out_control;
	wire burst_mode_clear = o_log_out_control;

	// fa311
	always @(posedge i_clk)
		if (i_reset)
			o_burst_mode <= 0;
		else if (!i_ros_advance)
			;
		else if (burst_mode_clear)
			o_burst_mode <= 0;
		else if (burst_mode_set)
			o_burst_mode <= 1;

	wire set_cc2_set = o_if_disconnect & i_halt_io & o_burst_mode;
	wire set_cc2_clear = o_burst_mode & ~i_halt_io & i_any_ch0_op_code;

	// fa321
	always @(posedge i_clk)
		if (i_reset)
			o_set_cc_2 <= 0;
		else if (!i_ros_advance)
			;
		else if (set_cc2_clear)
			o_set_cc_2 <= 0;
		else if (set_cc2_set)
			o_set_cc_2 <= 1;

	wire log_out_control_set = o_poll_control;
	wire log_out_control_clear = o_b3 | o_a1 & ch0_dtc2;

	// fa341
	always @(posedge i_clk)
		if (i_reset)
			o_log_out_control <= 0;
		else if (!i_ros_advance)
			;
		else if (log_out_control_clear)
			o_log_out_control <= 0;
		else if (log_out_control_set)
			o_log_out_control <= 1;

	wire log_out_set = o_log_out_control & i_timeout;
	wire log_out_clear = dtc1_reg & o_br_ctrl_1 & i_routine_bit_decoder_2
		| i_status_in & i_d1_d4_c1_interrupt & o_br_ctrl_6
		| o_br_ctrl_6 & i_d1_d4_c1_interrupt & i_select_in
		| o_initiate_log_out
		| i_reset_to_ch0
		;

	// fa341
	always @(posedge i_clk)
		if (i_reset)
			o_log_out <= 0;
		else if (!i_ros_advance)
			;
		else if (log_out_clear)
			o_log_out <= 0;
		else if (log_out_set)
			o_log_out <= 1;

	wire haltio_log_out_control_set = o_burst_mode |
		~i_timeout | i_halt_io;
	wire haltio_log_out_control_clear = o_poll_control |
		o_if_disconnect_control;
	// fa12
	reg haltio_log_out_control;
	always @(posedge i_clk)
		if (i_reset)
			haltio_log_out_control <= 0;
		else if (!i_ros_advance)
			;
		else if (haltio_log_out_control_clear)
			haltio_log_out_control <= 0;
		else if (haltio_log_out_control_set)
			haltio_log_out_control <= 1;

	assign o_initiate_log_out = haltio_log_out_control & i_timeout
		& i_halt_io;
	assign o_reset_count = ~ haltio_log_out_control & i_timeout
		& o_burst_mode;
	wire d3_br_ctrl1_b3_br_ctrl7 = o_d3 & o_br_ctrl_1 
		| o_b3 & o_br_ctrl_7 ;

	wire if_disconnect_control_set = i_address_in & o_poll_control
		| d3_brctl1_b3_brctl7 & i_ch0_dtc1;
	wire if_disconnect_control_clear = ~i_status_in & ~i_operational_in;

	// fa131
	always @(posedge i_clk)
		if (i_reset)
			o_if_disconnect_control <= 0;
		else if (!i_ros_advance)
			;
		else if (if_disconnect_control_clear)
			o_if_disconnect_control <= 0;
		else if (if_disconnect_control_set)
			o_if_disconnect_control <= 1;

	wire if_disconnect_set = o_if_disconnect_control & i_operational_in
			& i_halt_io & o_burst_mode
		| i_status_in & i_address_out
		| i_operational_in & ~i_select_out & o_c6
		| ~i_status_in & ~i_operational_in
		;
	wire if_disconnect_clear = ~i_status_in & ~i_operational_in;

	// fa131
	always @(posedge i_clk)
		if (i_reset)
			o_if_disconnect <= 0;
		else if (!i_ros_advance)
			;
		else if (if_disconnect_clear)
			o_if_disconnect <= 0;
		else if (if_disconnect_set)
			o_if_disconnect <= 1;

endmodule
