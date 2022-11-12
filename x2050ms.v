`default_nettype   none

// 2050 main store interface

// 0n the actual hardware, the main storage consists of:
//	2 microcrosecond core storage - integral to the cpu
//		power of 2 size from 64k to 512k, 36 bits wide
//		also includes a small amount of extra "bump" storage
//		used by the multiplexor channel
//		the parity bits are used as extra data lines
//		by flt logic in the cpu.
//	8 microsecond large capacity store (lcs) - separate unit ibm 2361
//		1 mb or 2 mb per unit
//		acces time is 3.6 microseconds, cycle time 8 microseconds.

// in this implementation:
//	wishbone memory addres space:
//		0-16mb -- reserved for cpu main storage
//				need not be fully populated
//		16mb+ -- bump storage for channels

// XXX future considerations:
//	parity? (per word, via 4 extra tag lines)
//	moving protection keys to here? (via extra tag lines) (every 2k words)

module x2050ms (i_clk, i_reset,
	o_storage_ring,
	// ram
	o_wb_cyc, o_wb_stb, o_wb_we, o_wb_addr, o_wb_data, o_wb_sel,
	i_wb_stall, i_wb_ack, i_wb_data, i_wb_err,
	// ros
	i_tr,
	i_iv,
	i_wm,
	i_e,
	i_ab,
	i_al,
	i_ss,
	// other cpu state
	i_nextiar,
	i_t_reg,
	i_f_reg,
	i_bs_reg,
	i_ros_clock_on,
	i_io_mode,
	// output to rest of x2050
	o_protection_key,
	o_ms_busy,
	o_data_stall,
	o_data_ready,
	o_data_error,
	o_prot_key_mismatch,
	o_data_read,
	o_sdr,
	o_spdr,
	o_sar);

// 0-16 m = main store
// 16-32 m = bump storage
	localparam DW=32;
//	localparam XW=(25+3-$clog2(DW));	// 32 megs, fixed
	localparam AW=(32+3-$clog2(DW));	// 4 g fixed
//	localparam LOG2_DW=$clog2(DW);
//	localparam LOG2_BW=(LOG2_DW-3);
	localparam BUMP = 24;

	// memory
	input wire i_clk;
	input wire i_reset;
	input wire [DW-1:0] i_wb_data;
	output reg [DW-1:0] o_wb_data;
	output reg o_wb_cyc, o_wb_stb, o_wb_we;
	output wire [AW-1:0] o_wb_addr;
	output reg [(DW/8)-1:0] o_wb_sel;
	output reg [3:0] o_spdr;

	input wire i_wb_stall, i_wb_ack, i_wb_err;

	input wire [4:0] i_tr;
	input wire [2:0] i_iv;
	input wire [3:0] i_wm;
	input wire [4:0] i_al;
	input wire [3:0] i_e;
	input wire [5:0] i_ab;
	input wire [5:0] i_ss;
	input wire [23:0] i_nextiar;
	input wire [31:0] i_t_reg;
	input wire [3:0] i_f_reg;
	input wire [3:0] i_bs_reg;
	input wire i_ros_clock_on;
	input wire i_io_mode;

	output wire [3:0] o_protection_key;
	output wire o_ms_busy;
	output wire o_data_stall;
	output reg o_data_ready;
	output wire o_data_error;
	output wire o_prot_key_mismatch;
	output wire [31:0] o_data_read;
	output wire [3:0] o_storage_ring;
	output reg [24:0] o_sar;
	output wire [31:0] o_sdr;
	wire [23:0] hwaddr;

	assign o_protection_key = protection_key;
	assign o_sdr = o_wb_data;

	wire store_via_t = (i_tr == 5'd6) |
		| (i_tr == 5'd9) |
		| (i_tr == 5'd10) |
		| (i_tr == 5'd11) |
		| (i_tr == 5'd15) |
		| (i_tr == 5'd16);
	wire store_via_iar = ~i_io_mode & ((i_iv == 3'd4) |
		| (i_iv == 3'd7) |
		| (i_wm == 4'd8));
	wire store_via_ha = (i_tr == 5'd8);
	wire expecting_read_data = (i_tr == 5'd12)
		| (i_ab == 6'd7)
		| (i_al == 5'd30)
		| (i_ss == 6'd3);
	wire set_protection_key = (i_tr == 5'd28);
	wire expecting_write_data = (i_tr == 5'd4 || i_tr == 5'd29);
	// wire fetch_storage_key = (i_ss == 6'd30);
	wire store_storage_key = (i_ss == 6'd31);

	assign o_ms_busy = o_wb_cyc;
	assign o_data_stall = o_wb_cyc & (expecting_read_data & ~i_wb_ack & ~o_data_ready
		| expecting_write_data & ~i_wb_ack ) & ~i_wb_err
		| set_sar & ~o_wb_stb;

	// 80 or 84
	assign hwaddr = {16'b0, 1'b1, 4'b0, i_e[3-1], 2'b0};

// XXX bump storage?
	wire [24:0] new_address =
		store_via_ha ? {1'b0, hwaddr} :
		store_via_t ? {1'b0, i_t_reg[23:0]} : {1'b0,i_nextiar[23:0]};
	assign o_wb_addr = {8'd0, new_address[23:2]};

	wire set_sar = (store_via_t | store_via_iar | store_via_ha);

	wire [(DW/8)-1:0] bsreg = i_tr == 5'd29 ? i_bs_reg : 4'hf;

	reg was_waiting;
	reg complete;

	assign o_data_error = i_wb_err & o_wb_cyc;
	assign o_data_read = i_wb_data;

	assign o_storage_ring[3-0] = set_sar & ~was_waiting;
	assign o_storage_ring[3-1] = expecting_read_data;
	assign o_storage_ring[3-2] = o_wb_cyc & (i_wb_ack | i_wb_err);
	assign o_storage_ring[3-3] = o_wb_cyc & o_wb_we;

	reg [3:0] storage_keys[0:(1<<13)-1];	// protection keys
	wire [12:0] spar = o_sar[23:11];

	reg [3:0] protection_key;

// Z22-2855-3
// Field Engr Handbook System360 Model 50
// "storage protect data flow" page 45 [pdf page 42]

// XXX in I/O mode there might be a different key "chan sp bits"
assign o_prot_key_mismatch = ~o_sar[BUMP] &
	|protection_key & |o_spdr & |{protection_key ^ o_spdr};

always @(posedge i_clk) begin
	if (set_protection_key)
		protection_key <= i_t_reg[31-8:31-11];
end

always @(posedge i_clk) begin
	o_spdr <= storage_keys[spar];
	if (i_reset) begin
		o_wb_stb <= 0;
		o_wb_cyc <= 0;
		o_wb_sel <= 0;
		o_wb_we <= 0;
		o_data_ready <= 0;
		complete <= 0;
	end
	if (o_wb_cyc) begin
		o_wb_stb <= 0;
		if (expecting_read_data & i_ros_clock_on)
			o_data_ready <= 0;
		if (~was_waiting & ~expecting_write_data & ~expecting_read_data)
			o_wb_cyc <= 0;
		if (~i_wb_stall && expecting_write_data) begin
			o_wb_sel <= bsreg;
			o_wb_we <= 1;
			o_wb_data <= i_t_reg;
			o_wb_stb <= 1;
			was_waiting <= 1;
		end
		if (i_wb_err) begin
			o_wb_cyc <= 0;
			o_wb_stb <= 0;
			o_wb_we <= 0;
			o_data_ready <= 0;
			was_waiting <= 0;
		end else if (i_wb_ack) begin
			o_data_ready <= ~o_wb_we & ~expecting_read_data;
			o_wb_stb <= 0;
			o_wb_cyc <= ~o_wb_we & ~complete;
			o_wb_we <= 0;
			was_waiting <= 0;
			o_wb_data <= i_wb_data;
		end else if (set_sar) begin
			o_data_ready <= 0;
			o_wb_we <= 0;
			if (was_waiting) begin
				o_wb_cyc <= 0;
				o_wb_stb <= 0;
				was_waiting <= 0;
			end else if (~i_wb_stall) begin
				complete <= 0;
				o_sar <= new_address;	// sets o_wb_addr
				o_wb_stb <= 1;
				was_waiting <= 1;
			end
		end
		if (store_storage_key) begin
			storage_keys[spar] <= i_f_reg;
			if (!was_waiting) begin
				o_wb_cyc <= 0;
			end else complete <= 1;
		end
	end else if (set_sar) begin
		complete <= 0;
		o_sar <= new_address;	// sets o_wb_addr
		o_wb_cyc <= 1;
		o_wb_stb <= 1;
		o_wb_we <= 0;
		o_data_ready <= 0;
		was_waiting <= 1;
	end
end
endmodule
