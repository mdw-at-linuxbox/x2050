`default_nettype   none
`timescale 10ns / 1ns
module tb;

	reg clk, rst;
	parameter DW=32;
	parameter XW=25;	// # of adddress bits, 24=16 meg ram (max)
	localparam AW=(32+3-$clog2(DW));
	localparam LOG2_DW=$clog2(DW);
	localparam LOG2_BW=(LOG2_DW-3);

	localparam RW=19;
	wire ros_clock_on;
	reg [12:0] roar;
	wire [RW-1:0] rosdr;
	reg [RW-1:0] sense_amps_out;
	wire [3:0] op = rosdr[18:15];	// 15 4 op
	wire [3:0] zf = rosdr[14:11];	// 11 4 zf
	wire [2:0] ct = rosdr[10:8];	// 8 3 ct
	wire [1:0] cg = rosdr[7:6];	// 6 2 cg
	wire [5:0] ss = rosdr[5:1];	// 1 5 ss
	wire      req = rosdr[0];	// 0 1 req
	reg ros_advance;
	wire requested;

	assign ros_clock_on = 1;
	reg [5:0] ms_delay;
	wire ms_busy = |{ms_delay};

	wire io_mode;
	wire firstcycle;
	wire dtc1;
	wire dtc2;
	wire gate_break_routine;
	wire save_r;
	wire break_in;
	wire chain;
	wire last_cycle;
	wire break_out;

	wire [RW-1:0] ros[0:4095];
// op = 1 no-op
// op = 2 schedule delayed req
// op = 3 memory busy operation
// op = 5 select next break-in operation. (fake dtc)
// op = 6 request chain operation.
// op = 15 terminate
// ZF_RET=4'd14;	CG_1PRI = 2'd2
// CT_FIRST = 3'd1	CG_1LYC = 2'd3
// CT_DTC1 = 3'd2	SS_IO1=5'd58
// CT_DTC2 = 3'd3	SS_IO0=5'd59
//		op    zf    ct   cg   ss    req
assign ros[0] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[1] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[2] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b1};	// single req
assign ros[3] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[4] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};

assign ros[5] = {4'h2,4'd00,3'd0,2'd0,5'd010,1'b0};
assign ros[6] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[7] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b1};	// req, 3 cycles, break
assign ros[8] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[9] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[10] = {4'h2,4'd00,3'd0,2'd0,5'd09,1'b0};
assign ros[11] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[12] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b1};	// req, 2 cycles, break
assign ros[13] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[14] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[15] = {4'h2,4'd00,3'd0,2'd0,5'd08,1'b0};
assign ros[16] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[17] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b1};	// req, 1 cycles, break
assign ros[18] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[19] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[20] = {4'h2,4'd00,3'd0,2'd0,5'd07,1'b0};
assign ros[21] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[22] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b1};	// req, 0 cycle, break
assign ros[23] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[24] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[25] = {4'h2,4'd00,3'd0,2'd0,5'd06,1'b0};
assign ros[26] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[27] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b1};	// req, also 0 cycle
assign ros[28] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[29] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[30] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[31] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[32] = {4'h5,4'd00,3'd0,2'd0,5'd00,1'b0};	// try the chain
assign ros[33] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[34] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b1};	// chain
assign ros[35] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[36] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[37] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[38] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[39] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[40] = {4'hf,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[41] = {4'hf,4'd00,3'd0,2'd0,5'd00,1'b0};

assign ros[CHAIN0+0] = {4'h1,4'd00,3'd1,2'd0,5'd00,1'b0};	// 6 cycles
assign ros[CHAIN0+1] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};	// stock
assign ros[CHAIN0+2] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[CHAIN0+3] = {4'h1,4'd00,3'd0,2'd2,5'd00,1'b0};
assign ros[CHAIN0+4] = {4'h1,4'd00,3'd0,2'd3,5'd00,1'b0};
assign ros[CHAIN0+5] = {4'h1,4'd14,3'd0,2'd0,5'd00,1'b0};
assign ros[CHAIN0+6] = {4'hf,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[CHAIN0+7] = {4'hf,4'd00,3'd0,2'd0,5'd00,1'b0};

assign ros[CHAIN1+0] = {4'h1,4'd00,3'd1,2'd0,5'd00,1'b0};	// 6 cycles
assign ros[CHAIN1+1] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};	// first part
assign ros[CHAIN1+2] = {4'h5,4'd00,3'd0,2'd0,5'd00,1'b0};	// of chain
assign ros[CHAIN1+3] = {4'h1,4'd00,3'd0,2'd2,5'd00,1'b1};
assign ros[CHAIN1+4] = {4'h1,4'd00,3'd0,2'd3,5'd00,1'b0};
assign ros[CHAIN1+5] = {4'h1,4'd14,3'd0,2'd0,5'd00,1'b0};
assign ros[CHAIN1+6] = {4'hf,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[CHAIN1+7] = {4'hf,4'd00,3'd0,2'd0,5'd00,1'b0};

assign ros[CHAIN2+0] = {4'h1,4'd00,3'd1,2'd0,5'd00,1'b0};	// 6 cycles
assign ros[CHAIN2+1] = {4'h0,4'd00,3'd0,2'd0,5'd00,1'b0};	// 2nd part
assign ros[CHAIN2+2] = {4'h1,4'd00,3'd0,2'd0,5'd00,1'b0};	// of chain
assign ros[CHAIN2+3] = {4'h1,4'd00,3'd0,2'd2,5'd00,1'b0};
assign ros[CHAIN2+4] = {4'h1,4'd00,3'd0,2'd3,5'd00,1'b0};
assign ros[CHAIN2+5] = {4'h1,4'd14,3'd0,2'd0,5'd00,1'b0};
assign ros[CHAIN2+6] = {4'hf,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[CHAIN2+7] = {4'hf,4'd00,3'd0,2'd0,5'd00,1'b0};

assign ros[EXIT] = {4'hf,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[EXIT+1] = {4'hf,4'd00,3'd0,2'd0,5'd00,1'b0};
assign ros[EXIT+2] = {4'hf,4'd00,3'd0,2'd0,5'd00,1'b0};
// 		  op   zf    ct   cg   ss    req
// ZF_RET=4'd14;	CG_1PRI = 2'd2
// CT_FIRST = 3'd1	CG_1LYC = 2'd3
// CT_DTC1 = 3'd2	SS_IO1=5'd58
// CT_DTC2 = 3'd3	SS_IO1=5'd59

reg [4:0] chain_index;
reg [12:0] roar_backup;
wire [12:0] chain_seq[0:31];
localparam CHAIN0 = 13'd100;
localparam CHAIN1 = 13'd110;
localparam CHAIN2 = 13'd120;
localparam EXIT = 13'd208;
assign chain_seq[0] = CHAIN0;
assign chain_seq[1] = CHAIN1;
assign chain_seq[2] = CHAIN2;
assign chain_seq[3] = EXIT;
assign chain_seq[4] = EXIT;
assign chain_seq[5] = EXIT;
wire [12:0] chain_addr = chain_seq[chain_index];

	always @(posedge clk) begin
		sense_amps_out <= ros[next_roar];
	end
	assign rosdr = save_r ? 0 : sense_amps_out;
	wire [12:0] next_roar = rst ? 13'b0 :
		(gate_break_routine) ? chain_seq[chain_index]
		: break_out ? roar_backup
		: (roar + 1);

	always @(posedge clk) begin
		if (save_r)
			roar_backup <= roar;
	end

	always @(posedge clk) begin
		if (op == 4'd5)
			++chain_index;
	end


	initial begin
		$dumpfile("x2050br.vcd");
		$dumpvars(0, tb);
		ros_advance <= 1;
		chain_index <= 0;
		roar_backup <= EXIT+2;
	end

	always #1 clk = ~clk;
	initial begin
		{clk,rst} <= 1;
	repeat(2) @(posedge clk);
		rst <= 0;
	repeat(2) @(posedge clk);
	while(1) @(posedge clk)
		if (op == 4'hf) $finish;
	end
always @(posedge clk) begin
$display("T=%d ros=%x rosdr=%x ct=%x cg=%x ss=%x req=%x io=%x 1st=%x op=%x", $time, roar, rosdr,
ct, cg, ss,
was_requested, io_mode, firstcycle, op
);
end
	reg breakin_delayed;
	wire [2:0] ctx;
assign ctx = (breakin_delayed & io_mode) ? 2'd1 : 2'd0;

reg [5:0] delayed_req;
reg was_requested;
wire set_requested = req | (delayed_req == 6'd1) | op == 4'd6;
assign requested = set_requested | was_requested;

always @(posedge clk) begin
	if (rst) begin
		was_requested <= 0;
		roar <= 0;
	end else begin
		if (ros_clock_on) begin
			roar <= next_roar;
		end
		breakin_delayed <= break_in;
		if (set_requested)
			was_requested <= 1;
		if (firstcycle)
			was_requested <= 0;
	end
end

reg [1:0] r_reg;
reg [1:0] saved_r;
always @(posedge clk) begin
	if (rst) begin
		r_reg <= 0;
		saved_r <= 2;
	end else if (save_r) begin
		if (r_reg != 0) $fatal (1,"wants to save IO mode R");
		saved_r <= r_reg;
	end else if (break_out) begin
		if (saved_r == 2) $fatal(1,"R was never saved");
		if (saved_r == 3) $fatal(1,"restoring old R?");
		r_reg <= saved_r;
	end else if (io_mode) begin
		r_reg <= 1;
	end else if (~io_mode) begin
		if (saved_r == 0) saved_r <= 3;
	end
end
always @(posedge clk) begin
	if (rst) begin
		ms_delay <= 0;
	end else begin
		if (op == 4'd3)
			ms_delay <= ss;
		else if (ms_busy)
			ms_delay <= ms_delay - 1;
	end
end

always @(posedge clk) begin
	if (rst)
		delayed_req <= 6'd0;
	else if (op == 4'd2)
		delayed_req <= ss;
	else if (|{delayed_req}) begin
		delayed_req <= delayed_req - 6'd1;
	end
end

	x2050br u_br (.i_clk(clk), .i_reset(rst),
		.i_ros_advance(ros_advance),
		.i_ms_busy(ms_busy),
		.i_zf(zf),
		.i_ct(ct),
		.i_cg(cg),
		// suppress ss for op = 2 or op = 3
		.i_ss((op[3:1] == 4'd1) ? 5'd0 : ss),
		.i_routine_request(requested),
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

endmodule
