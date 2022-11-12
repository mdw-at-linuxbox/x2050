`default_nettype   none

// 2050 multiplexor - bus interface and buffers

// Y22-2827-0_360-50_Multiplexor_Channel_FETOM_Oct66.pdf

module x2050mpxb (i_clk, i_reset,
	i_ros_advance,
	i_ms,
	i_mg,
	i_e,
	i_ss,
	i_io_mode,
	o_iostat,
	o_mpx_buffer_in_bus,
	o_mpx_buffer_1,
	o_mpx_buffer_2,
	// common channel
	i_buffer_out_bus,
	o_buffer_in_bus,
	// multiplexor
	o_mpx_bus_out, i_mpx_bus_in,
	o_mpx_address_out, o_mpx_command_out, o_mpx_service_out, o_mpx_data_out,
	i_mpx_address_in, i_mpx_status_in, i_mpx_service_in, i_mpx_data_in, i_mpx_disc_in,
	o_mpx_operational_out, o_mpx_select_out, o_mpx_hold_out, o_mpx_suppress_out,
	i_mpx_operational_in, i_mpx_select_in, i_mpx_request_in);

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;
	input wire [2:0] i_ms;
	input wire [2:0] i_mg;
	input wire [3:0] i_e;
	input wire [5:0] i_ss;
	input wire i_io_mode;
	output wire [3:0] o_iostat;
	output wire [8:0] o_mpx_buffer_in_bus;
	output wire [8:0] o_mpx_buffer_1;
	output wire [8:0] o_mpx_buffer_2;

	input wire [8:0] i_buffer_out_bus;
	output wire [8:0] o_buffer_in_bus;

	output wire [8:0] o_mpx_bus_out;	// p,0-7
	input wire [8:0] i_mpx_bus_in;		// p,0-7
	output reg o_mpx_address_out;
	output reg o_mpx_command_out;
	output reg o_mpx_service_out;
	output wire o_mpx_data_out;
	input wire i_mpx_address_in;
	input wire i_mpx_status_in;
	input wire i_mpx_service_in;
/* verilator lint_off UNUSED */
	input wire i_mpx_data_in;
	input wire i_mpx_disc_in;
/* verilator lint_on UNUSED */
	output wire o_mpx_operational_out;
	output reg o_mpx_select_out;
	output wire o_mpx_hold_out;
	output reg o_mpx_suppress_out;
	input wire i_mpx_operational_in;
	input wire i_mpx_select_in;
/* verilator lint_off UNUSED */
	input wire i_mpx_request_in;
/* verilator lint_on UNUSED */

reg operational_out;

assign o_mpx_hold_out = o_mpx_select_out;

assign o_mpx_buffer_in_bus = mpx_buffer_in_bus;
assign o_mpx_buffer_1 = buffer_1;
assign o_mpx_buffer_2 = buffer_2;

assign o_mpx_bus_out = mpx_bus_out_latch;

// Y22-2827 page 18 figure 11 "buffer and buffer 2 sets and resets" [pdf 18]
// buffer 1 and 2: fa011
wire [8:0] buffer_1, buffer_2;
wire bob_to_bfr1;
wire busi_to_bfr1;
wire bob_to_bfr2;
wire busi_to_bfr2;
wire bfr1_to_bib;
wire bfr2_to_bib;
wire bfr2_to_buso;

assign buffer_1 = {9{bob_to_bfr1}} & i_buffer_out_bus
	| {9{busi_to_bfr1}} & mpx_bus_in;

assign buffer_2 = {9{busi_to_bfr2}} & i_buffer_out_bus
	| {9{busi_to_bfr1}} & mpx_bus_in;

// bufffer in bus 0-7: fa041
wire [8:0] mpx_buffer_in_bus;
assign mpx_buffer_in_bus = {9{bfr1_to_bib}} & buffer_1
		| {9{bfr2_to_bib}} & buffer_2;
reg [8:0] mpx_bus_out_latch;

wire outs_ord = o_mpx_address_out | o_mpx_service_out | o_mpx_command_out;
reg delayed_outs_ord;
always @(posedge i_clk) begin
	delayed_outs_ord <= outs_ord;
end
// FA052
wire buffer_out_latch_clear = delayed_outs_ord & ~outs_ord;

// FA051
always @(posedge i_clk) begin
	if (i_reset)
		mpx_bus_out_latch <= 9'b0;
	else if (bfr2_to_buso)
		mpx_bus_out_latch <= buffer_2;
	else if (buffer_out_latch_clear)
		mpx_bus_out_latch <= 9'b0;
end

// Y22-2827 page 17 figure 10 "input and output buffer gates" [pdf 17]
// FA071
assign bfr2_to_bib = i_ros_advance & i_io_mode & (i_mg == 3'd0);
assign bfr2_to_buso = i_ros_advance & i_io_mode & (i_mg == 3'd2);
assign bfr1_to_bib = i_ros_advance & i_io_mode & (i_mg == 3'd3);
assign bob_to_bfr1 = i_ros_advance & i_io_mode & (i_mg == 3'd4);
assign bob_to_bfr2 = i_ros_advance & i_io_mode & (i_mg == 3'd5);
assign busi_to_bfr1 = i_ros_advance & i_io_mode & (i_mg == 3'd6);
assign busi_to_bfr2 = i_ros_advance & i_io_mode & (i_mg == 3'd7);

// Y22-2827 page 21 figure 13 "multiplexor i/o stat 2 and
// associated gating circuits" [pdf 21]
// ms decode: fa081
wire bib03_to_ios = (i_ms == 3'd1);
wire bib47_to_ios = (i_ms == 3'd2);
wire bib03_to_ios_per_emit = (i_ms == 3'd3);
wire bib47_to_ios_per_emit = (i_ms == 3'd4);
wire set_ios_per_emit = (i_ms == 3'd5);
wire clear_ios_per_emit = (i_ms == 3'd6);
wire bib4_error_to_ios = (i_ms == 3'd7);

// ms7 used: 00ae qv340 j1, 0094 qv350 j1, 00ac qv440 j1
//  from the comments therein,
//  cc status error = bit0,2,3,6,7= 1 or bit1=1 and bit5 not =0

wire status_error = |{
	mpx_bus_in[7-0],	// attention
	mpx_bus_in[7-2],	// control unit end
	mpx_bus_in[7-3],	// busy
	mpx_bus_in[7-6],	// unit check
	mpx_bus_in[7-7],	// unit exception
	mpx_bus_in[7-1] & ~mpx_bus_in[7-5]};	// status modifier w/o devend

// iostat latch & set logic: fa111
wire [3:0] next_iostat = {4{bib03_to_ios}} & mpx_buffer_in_bus[7-0:7-3]
	| {4{bib47_to_ios}} & mpx_buffer_in_bus[7-4:7-7]
	| {4{bib03_to_ios_per_emit}} & mpx_buffer_in_bus[7-0:7-3] & i_e
	| {4{bib03_to_ios_per_emit}} & iostat & ~i_e
	| {4{bib47_to_ios_per_emit}} & mpx_buffer_in_bus[7-4:7-7] & i_e
	| {4{bib47_to_ios_per_emit}} & iostat & ~i_e
	| {4{set_ios_per_emit}} & i_e
	| {4{set_ios_per_emit}} & iostat & ~i_e
	| {4{clear_ios_per_emit}} & iostat & ~i_e
	| {4{bib4_error_to_ios}} & {mpx_buffer_in_bus[7-4],status_error,2'b0}
	| {4{bib4_error_to_ios}} & iostat & 4'd3
	| {4{~|i_ms }} & iostat
	;
reg [3:0] iostat;
always @(posedge i_clk) begin
	if (i_reset)
		iostat <= 4'b0;
	else if (!i_ros_advance | ~i_io_mode)
		;
	else
		iostat <= next_iostat;
end
assign o_iostat = iostat;

// from here on down is mostly guesswork.

// + transitions of opl-out adr-out sel-out svc-out
// clearly documented as microcode SS micro-orders, here
// 2050_Control_Field_Specification_196508.pdf"
// CFC 112 - 2050 control field specifiation - cpu mode (ss) [pdf page 13]
//
// unclear what drives - transitions for any of these signals.
//
// for now, I'm latching the received data & acking the data almost instantly.
// this might turn out to be too racy.
//
// on the real hardware, open collector signal transitions are much
// slower than the microcode, so perhaps i_mpx_data_in is used directly
// in place of mpx_bus_in here.

wire chan_wants_data = o_mpx_service_out | o_mpx_command_out;
wire dev_has_data = i_mpx_status_in | i_mpx_address_in | i_mpx_service_in;
reg dev_had_data;
reg [8:0] mpx_bus_in;	// capture data from svc-in +, data-in +, or address-in +

always @(posedge i_clk) begin
	dev_had_data <= dev_has_data;
	if (~dev_had_data & dev_has_data)
		mpx_bus_in <= i_mpx_bus_in;
end

always @(posedge i_clk)
	if (i_reset)
		operational_out <= 1'b0;
	else
		operational_out <= 1'b1;

assign o_mpx_operational_out = ~i_reset & operational_out;

always @(posedge i_clk)
	if (i_reset)
		o_mpx_select_out <= 1'b0;
	else if (!i_ros_advance)
		;
	else if (i_ss == 6'd60)
		o_mpx_select_out <= 1'b1;
	else if (i_mpx_address_in | i_mpx_status_in | i_mpx_select_in)
		o_mpx_select_out <= 1'b0;

always @(posedge i_clk)
	if (i_reset)
		o_mpx_address_out <= 1'b0;
	else if (!i_ros_advance)
		;
	else if (i_ss == 6'd61)
		o_mpx_address_out <= 1'b1;
	else if (i_mpx_operational_in | ~o_mpx_select_out)
		o_mpx_address_out <= 1'b0;

always @(posedge i_clk)
	if (i_reset)
		o_mpx_command_out <= 1'b0;
	else if (!i_ros_advance)
		;
	else if (i_ss == 6'd62)
		o_mpx_command_out <= 1'b1;
	else if ((~i_mpx_service_in & ~i_mpx_address_in) | ~i_mpx_operational_in)
		o_mpx_command_out <= 1'b0;

always @(posedge i_clk)
	if (i_reset)
		o_mpx_service_out <= 1'b0;
	else if (!i_ros_advance)
		;
	else if (i_ss == 6'd63)
		o_mpx_service_out <= 1'b1;
	else if (i_mpx_service_in | i_mpx_status_in | ~i_mpx_operational_in)
		o_mpx_service_out <= 1'b0;

always @(posedge i_clk)
	if (i_reset)
		o_mpx_suppress_out <= 1'b0;
	else if (!i_ros_advance)
		;
	else if (i_ss == 6'd48)
		o_mpx_suppress_out <= 1'b1;
	else if (o_mpx_service_out | ~i_mpx_operational_in)
		o_mpx_suppress_out <= 1'b0;

endmodule
