`default_nettype   none
`timescale 10ns / 1ns
module tb;

	reg clk, rst;
	parameter DW=32;
	parameter XW=25;	// # of adddress bits, 24=16 meg ram (max)
	localparam AW=(32+3-$clog2(DW));
	localparam LOG2_DW=$clog2(DW);
	localparam LOG2_BW=(LOG2_DW-3);

	localparam RW=10;
	reg [5:0] rosaddr;
	wire [RW-1:0] rosdr;
	wire ros_advance = 1'b1;
	wire [3:0] op = rosdr[9:6];			// 6 4 op
	wire firstcycle = rosdr[5];			// 5 1 1st
	wire routine_recd = rosdr[4];			// 4 1 recd
	wire [3:0] routine_requesting = rosdr[3:0];	// 0 4 requesting
	wire set_buffer_13;
	wire set_buffer_2;
	wire [3:0] com_buffer1;
	wire [3:0] com_buffer2;
	wire [3:0] com_buffer3;

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
//		op    1st  recd req
assign ros[0] = {4'h0,1'b0,1'b0,4'h0};
assign ros[1] = {4'h0,1'b0,1'b0,4'h1};
assign ros[2] = {4'h0,1'b0,1'b1,4'h1};
assign ros[3] = {4'h0,1'b0,1'b1,4'h1};
assign ros[4] = {4'h0,1'b1,1'b0,4'h0};
assign ros[5] = {4'h0,1'b0,1'b0,4'h0};
assign ros[6] = {4'h0,1'b0,1'b0,4'h4};
assign ros[7] = {4'h0,1'b0,1'b1,4'h4};
assign ros[8] = {4'h0,1'b1,1'b0,4'h0};
assign ros[9] = {4'h0,1'b0,1'b0,4'h0};
assign ros[10] = {4'h0,1'b0,1'b0,4'h2};
assign ros[11] = {4'h0,1'b0,1'b1,4'h2};
assign ros[12] = {4'h0,1'b1,1'b0,4'h0};
assign ros[13] = {4'h0,1'b0,1'b0,4'h0};
assign ros[14] = {4'h0,1'b0,1'b1,4'h1};
assign ros[15] = {4'h0,1'b0,1'b1,4'h1};
assign ros[16] = {4'h0,1'b1,1'b0,4'h0};
assign ros[17] = {4'h0,1'b0,1'b0,4'h0};
assign ros[18] = {4'h0,1'b0,1'b0,4'h0};
assign ros[19] = {4'h0,1'b0,1'b0,4'h0};
assign ros[20] = {4'h0,1'b0,1'b0,4'h0};
assign ros[21] = ~0;

	assign rosdr = ros[rosaddr];
	wire [5:0] next_addr = (rosaddr + 1);

	initial begin
		$dumpfile("x2050com.vcd");
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
$display("T=%t r=%x op=%x 1st=%x recd=%x req=%x set13=%x set2=%x buf=%x,%x,%x",
$time, rosaddr,
op, firstcycle, routine_recd, routine_requesting,
set_buffer_13, set_buffer_2,
com_buffer1,
com_buffer2,
com_buffer3);
end

always @(posedge clk) begin
	if (rst) begin
		rosaddr <= 0;
	end else begin
		if (ros_advance) begin
			rosaddr <= next_addr;
		end
	end
end

	x2050com u_com (.i_clk(clk), .i_reset(rst),
		.i_ros_advance(ros_advance),
		.i_firstcycle(firstcycle),
		.i_routine_recd(routine_recd),
		.i_routine_requesting(routine_requesting),
		.o_set_buffer_13(set_buffer_13),
		.o_set_buffer_2(set_buffer_2),
		.o_com_buffer1(com_buffer1),
		.o_com_buffer2(com_buffer2),
		.o_com_buffer3(com_buffer3));

endmodule
