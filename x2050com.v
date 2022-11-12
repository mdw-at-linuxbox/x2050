`default_nettype   none

// 2050 common channel facilities

// Y22-2827-0_360-50_Multiplexor_Channel_FETOM_Oct66.pdf

// figure 21 "channel 0 buffer latches" page 32 [pdf page 31]
// figure 22 "buffer latches sequencing" page 33`[pdf page 32]

// Z22-2833-R_2050_Processing_Unit_Field_Engineering_Diagram_Manual_Jul66.pdf
// iop 111 "initiate i-o operation (sheet 1 of 2)" [pdf page 105]

module x2050com (i_clk, i_reset,
	i_ros_advance,
	i_io_mode,
	i_wm,
	i_l_reg,
	i_buffer_out_bus,

	i_firstcycle,
	i_routine_recd,
	i_routine_requesting,
	i_reset_c1,
	i_reply_latch_pulse,
	o_wcc,
	o_ch_select,
	o_start_io,
	o_halt_io,
	o_test_io,
	o_test_channel,
	o_foul,
	o_timeout,
	o_timeout_check,
	o_int_test_io,
	o_set_buffer_13,
	o_set_buffer_2,
	o_com_buffer1,	// current registered routine request
	o_com_buffer2,
	o_com_buffer3);	// previously registered routine request

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;
	input wire i_io_mode;
	input wire [3:0] i_wm;
	input wire [31:0] i_l_reg;
	input wire [8:0] i_buffer_out_bus;
	input wire i_firstcycle;
	input wire i_routine_recd;

	input wire [3:0] i_routine_requesting;
	input wire i_reset_c1;
	input wire i_reply_latch_pulse;
	output wire o_wcc;
	output reg [2:0] o_ch_select;
	output wire o_start_io;
	output wire o_halt_io;
	output wire o_test_io;
	output wire o_test_channel;
	output wire o_foul;
	output wire o_timeout;
	output wire o_timeout_check;
	output wire o_int_test_io;
	output wire o_set_buffer_13;
	output wire o_set_buffer_2;
	output reg [3:0] o_com_buffer1;
	output reg [3:0] o_com_buffer2;
	output reg [3:0] o_com_buffer3;

	reg [7:0] current_command;

	wire wcc_gated;
	wire io_instruction;
	wire register_d;	// how is this set?

	assign o_wcc = i_ros_advance & ~i_io_mode & (i_wm == 4'd7);

	// Z22-2833-R iop 111 [pdf page 105]
	assign wcc_gated = ~io_instruction & o_wcc;
	wire reset_foul = i_reset_c1 | i_reply_latch_pulse;
	wire load_command_latch = wcc_gated | i_reset_c1 | i_reply_latch_pulse;

	// GUESSS - how is this different from wcc_gate?
	assign register_d = wcc_gated;

	// ke021
	always @(posedge i_clk) if (i_reset) begin
		o_ch_select <= 0;
	end else begin
		if (load_command_latch)
			o_ch_select <= i_l_reg[31-21:31-23]
				& {3{wcc_gated}};
	end

	always @(posedge i_clk) if (i_reset) begin
		current_command <= 0;
	end else begin
		if (wcc_gated) begin
			current_command[7-0:7-3] = i_buffer_out_bus[7-0:7-3];
			current_command[7-7] = i_buffer_out_bus[7-7];
		end
		if (register_d) begin
			current_command[7-1] = i_buffer_out_bus[7-1];
			current_command[7-2] = i_buffer_out_bus[7-2];
		end
	end
	// ke001
	assign o_start_io = current_command[7-7];
	// ke001
	assign o_halt_io = current_command[7-6];
	// ke001
	assign o_test_io = current_command[7-5];
	// ke001
	assign o_test_channel = current_command[7-4];
	// ke091
	assign o_foul = current_command[7-3];
	// ke091
	assign o_timeout = current_command[7-2];
	// ke091
	assign o_timeout_check = current_command[7-1];
	// ke001
	assign o_int_test_io = current_command[7-0];

	assign o_set_buffer_13 = i_routine_recd & i_ros_advance;
	assign o_set_buffer_2 = i_firstcycle & i_ros_advance;

	always @(posedge i_clk) if (i_reset) begin
		o_com_buffer1 <= 0;
		o_com_buffer2 <= 0;
		o_com_buffer3 <= 0;
	end
	else begin
		if (o_set_buffer_13) begin
			o_com_buffer1 <= i_routine_requesting;
			o_com_buffer3 <= o_com_buffer2;
		end
		if (o_set_buffer_2) begin
			o_com_buffer2 <= o_com_buffer1;
		end
	end

endmodule
