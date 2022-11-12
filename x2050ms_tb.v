`default_nettype   none
`timescale 10ns / 1ns
module tb;

	reg clk, rst;
	parameter DW=32;
	parameter XW=25;	// # of adddress bits, 24=16 meg ram (max)
	localparam AW=(32+3-$clog2(DW));
	localparam LOG2_DW=$clog2(DW);
	localparam LOG2_BW=(LOG2_DW-3);

	// memory
	wire [DW-1:0] ram_data;
	wire [DW-1:0] wb_data;
	reg wb_cyc, wb_stb, wb_we;
	reg [AW-1:0] wb_addr;
	reg [(DW/8)-1:0] wb_sel;

	input wire wb_stall, wb_ack, wb_err;

	localparam RW=33;
	wire ros_clock_on;
	reg [12:0] rosaddr;
	wire [RW-1:0] rosdr;
	wire [3:0] op = rosdr[32:29];	// 4
	wire [4:0] tr = rosdr[28:24];	// 5
	wire [2:0] iv = rosdr[23:21];	// 3
	wire [4:0] al = rosdr[20:16];	// 5
	wire [3:0] wm = rosdr[15:12];	// 4
	wire [5:0] ab = rosdr[11:6];	// 6
	wire [5:0] ss = rosdr[5:0];	// 6
	reg [23:0] iar;
	reg [31:0] t_reg;
	reg [3:0] bs_reg;

	assign ros_clock_on = ~data_stall | (op == 4'd1 | 4'd2);

	wire io_mode;
	wire ms_busy;
	wire data_stall;
	wire data_ready;
	wire [31:0] data_read;

	wire [RW-1:0] ros[0:4095];
//		 op   tr    iv   al    wm   ab   ss
assign ros[0] = {4'h0,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[1] = {4'h0,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[2] = {4'h1,5'h09,3'h0,5'h00,4'h0,6'h00,6'h00};	// tr9
assign ros[3] = {4'h0,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[4] = {4'h0,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[5] = {4'h1,5'h04,3'h0,5'h00,4'h0,6'h00,6'h00};	// tr4
assign ros[6] = {4'h1,5'h09,3'h0,5'h00,4'h0,6'h00,6'h00};	// tr9
assign ros[7] = {4'h0,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[8] = {4'h0,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[9] = {4'h1,5'h04,3'h0,5'h00,4'h0,6'h00,6'h00};	// tr4
assign ros[10] = {4'he,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[11] = {4'h0,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[12] = {4'h1,5'h09,3'h0,5'h00,4'h0,6'h00,6'h00};	// tr9
assign ros[13] = {4'h0,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[14] = {4'h0,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[15] = {4'h1,5'h0c,3'h0,5'h00,4'h0,6'h00,6'h00};	// tr12
assign ros[16] = {4'h0,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[17] = {4'h1,5'h09,3'h0,5'h00,4'h0,6'h00,6'h00};	// tr9
assign ros[18] = {4'h1,5'h0c,3'h0,5'h00,4'h0,6'h00,6'h00};	// tr12
assign ros[19] = {4'h0,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[20] = {4'h0,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[21] = {4'h0,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};
assign ros[22] = {4'hf,5'h00,3'h0,5'h00,4'h0,6'h00,6'h00};

	wire [12:0] next_addr = (rosaddr + 1);
	assign rosdr = ros[rosaddr];

	initial begin
		$dumpfile("x2050ms.vcd");
		$dumpvars(0, tb);
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
$display("T=%d ros=%x rosdr=%x ss=%x tr=%x op=%x", $time, rosaddr, rosdr, ss, tr, op);
end

	assign io_mode = op == 2;

always @(posedge clk) begin
	if (rst) begin
		rosaddr <= 0;
		bs_reg <= 0;
		iar <= 'h80;
		t_reg <= 'h100;
	end else begin
		if (ros_clock_on) begin
			rosaddr <= next_addr;
			if (tr == 5'd9)
				t_reg <= t_reg + 4;
			else if (op == 4'he)
				t_reg <= 'h100;
		end
	end
end

	assign wb_err = wb_addr[XW] ?
(wb_addr[XW-1:0] >= 1024)
:
(wb_addr >= 65536);

	memdev50 u_ram(.i_clk(clk), .i_reset(rst),
		.i_wb_cyc(wb_cyc), .i_wb_stb(wb_stb), .i_wb_we(wb_we), .i_wb_addr(wb_addr[16-1:0]), .i_wb_data(ram_data), .i_wb_sel(wb_sel),
		.o_wb_stall(wb_stall), .o_wb_ack(wb_ack), .o_wb_data(wb_data));

	x2050ms u_ms (.i_clk(clk), .i_reset(rst),
		.o_wb_cyc(wb_cyc), .o_wb_stb(wb_stb), .o_wb_we(wb_we), .o_wb_addr(wb_addr[AW-1:0]), .o_wb_data(ram_data), .o_wb_sel(wb_sel),
		.i_wb_stall(wb_stall), .i_wb_ack(wb_ack), .i_wb_data(wb_data), .i_wb_err(wb_err),

		.i_tr(tr),
		.i_iv(iv),
		.i_wm(wm),
		.i_ab(ab),
		.i_al(al),
		.i_ss(ss),
		.i_nextiar(iar),
		.i_t_reg(t_reg),
		.i_bs_reg(bs_reg),
		.i_ros_clock_on(ros_clock_on),
		.i_io_mode(io_mode),
		.o_ms_busy(ms_busy),
		.o_data_stall(data_stall),
		.o_data_ready(data_ready),
		.o_data_read(data_read));

endmodule
