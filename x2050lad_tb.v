`default_nettype   none
`timescale 10ns / 1ns
module tb;

	reg clk, rst;
	parameter DW=32;
	parameter XW=25;	// # of adddress bits, 24=16 meg ram (max)
	localparam AW=(32+3-$clog2(DW));
	localparam LOG2_DW=$clog2(DW);
	localparam LOG2_BW=(LOG2_DW-3);

	localparam RW=45;
	wire ros_clock_on;
	reg [7:0] rosaddr;
	wire [RW-1:0] rosdr;
	wire [3:0] op = rosdr[44:41];	// 41 4 op
	wire io_mode = rosdr[40];	// 40 1 imode
	wire [2:0] lx = rosdr[39:37];	// 37 3 lx
	wire tc = rosdr[36];		// 36 1 tc
	wire [3:0] e = rosdr[35:32];	// 32 4 e
	wire [31:0] data = rosdr[31:0];	// 0 32 expected
	reg ros_advance;

	assign ros_clock_on = 1;

	// setup and test cases
	wire [RW-1:0] ros[0:255];
// op = 0 compare results
// op = 1 set lreg
// op = 2 set ioreg
// op = 15 terminate
//		 op   io   lx   tc   e    expected
assign ros[0] = {4'h1,1'b0,3'd0,1'b0,4'd0,32'h12345678};
assign ros[1] = {4'h2,1'b0,3'd0,1'b0,4'd0,32'd2};
assign ros[2] = {4'h0,1'b0,3'd0,1'b1,4'd0,32'd0};
assign ros[3] = {4'h0,1'b0,3'd0,1'b0,4'd0,32'hffffffff};
assign ros[4] = {4'h0,1'b0,3'd1,1'b1,4'd0,32'h12345678};
assign ros[5] = {4'h0,1'b0,3'd1,1'b0,4'd0,32'hedcba987};
assign ros[6] = {4'h0,1'b0,3'd2,1'b1,4'd0,32'h80000000};
assign ros[7] = {4'h0,1'b0,3'd2,1'b0,4'd0,32'h7fffffff};
assign ros[8] = {4'h0,1'b0,3'd3,1'b1,4'd7,32'd14};
assign ros[9] = {4'h0,1'b0,3'd3,1'b0,4'd7,32'hfffffff1};
assign ros[10] = {4'h0,1'b0,3'd4,1'b1,4'd0,32'h56780000};
assign ros[11] = {4'h0,1'b0,3'd4,1'b0,4'd0,32'ha987ffff};
assign ros[12] = {4'h0,1'b0,3'd5,1'b1,4'd0,32'h1234567b};
assign ros[13] = {4'h0,1'b0,3'd5,1'b0,4'd0,32'hedcba984};
assign ros[14] = {4'h0,1'b0,3'd6,1'b1,4'd0,32'd4};
assign ros[15] = {4'h0,1'b0,3'd6,1'b0,4'd0,32'hfffffffb};
assign ros[16] = {4'h0,1'b0,3'd7,1'b1,4'd0,32'hc0000000};
assign ros[17] = {4'h0,1'b0,3'd7,1'b0,4'd0,32'h3fffffff};
assign ros[18] = {4'h2,1'b1,3'd0,1'b1,4'd0,32'd5};
assign ros[19] = {4'h2,1'b1,3'd0,1'b0,4'd0,32'hfffffffa};
assign ros[20] = {4'h0,1'b1,3'd1,1'b1,4'd0,32'h12345678};
assign ros[21] = {4'h0,1'b1,3'd1,1'b0,4'd0,32'hedcba987};
assign ros[22] = {4'h0,1'b1,3'd2,1'b1,4'd0,32'h80000000};
assign ros[23] = {4'h0,1'b1,3'd2,1'b0,4'd0,32'h7fffffff};
assign ros[24] = {4'h0,1'b1,3'd3,1'b1,4'd7,32'd14};
assign ros[25] = {4'h0,1'b1,3'd3,1'b0,4'd7,32'hfffffff1};
assign ros[26] = {4'h0,1'b1,3'd4,1'b1,4'd0,32'h56780000};
assign ros[27] = {4'h0,1'b1,3'd4,1'b0,4'd0,32'ha987ffff};
assign ros[28] = {4'h0,1'b1,3'd5,1'b1,4'd0,32'h1234567b};
assign ros[29] = {4'h0,1'b1,3'd5,1'b0,4'd0,32'hedcba984};

assign ros[30] = {4'h0,1'b1,3'd6,1'b1,4'd0,32'd1};
assign ros[31] = {4'h0,1'b1,3'd6,1'b0,4'd0,32'hfffffffe};
assign ros[32] = {4'h0,1'b1,3'd7,1'b1,4'd0,32'd2};
assign ros[33] = {4'h0,1'b1,3'd7,1'b0,4'd0,32'hfffffffd};

assign ros[34] = {4'h2,1'b0,3'd0,1'b0,4'd0,32'd1};
assign ros[35] = {4'h0,1'b1,3'd6,1'b1,4'd0,32'd2};
assign ros[36] = {4'h0,1'b1,3'd6,1'b0,4'd0,32'hfffffffd};
assign ros[37] = {4'h0,1'b1,3'd7,1'b1,4'd0,32'd1};
assign ros[38] = {4'h0,1'b1,3'd7,1'b0,4'd0,32'hfffffffe};

assign ros[39] = {4'h2,1'b0,3'd0,1'b0,4'd0,32'd3};
assign ros[40] = {4'h0,1'b1,3'd6,1'b1,4'd0,32'd0};
assign ros[41] = {4'h0,1'b1,3'd6,1'b0,4'd0,32'hffffffff};
assign ros[42] = {4'h0,1'b1,3'd7,1'b1,4'd0,32'd3};
assign ros[43] = {4'h0,1'b1,3'd7,1'b0,4'd0,32'hfffffffc};

assign ros[44] = ~0;

	assign rosdr = ros[rosaddr];
	wire [7:0] next_addr = (rosaddr + 1);

	// sample data
	reg [31:0] l_reg;
	reg [1:0] ioreg;

	// actual results
	wire [31:0] xin;
	wire [31:0] xg;

	// expected results
	wire [31:0] expected_xg = data;
	wire [31:0] expected_xin = data ^ {32{~tc}};

wire see_error = (op == 4'h0) & (
	(xg != expected_xg) | (xin != expected_xin)
	) ;
wire [2:0] syndrome =
{
op == 4'h0,
xg != expected_xg,
xin != expected_xin
};

reg [7:0] error_count;

always @(posedge clk) begin
	case (1)
	op == 4'h1:
		l_reg <= data;
	op == 4'h2:
		ioreg <= data[1:0];
	see_error:
		if (op == 0 && xg != data) begin
$display("T=%4t saw error", $time);
			error_count <= error_count + 1;
		end
	op == 4'hf:
		begin
$display("T=%d error_count = %d", $time, error_count);
			if (| {error_count} )
				$fatal(1,"(failed test)");

			$finish;
		end
	default:
		;
	endcase
end

	initial begin
		$dumpfile("x2050lad.vcd");
		$dumpvars(0, tb);
		ros_advance <= 1;
	end

	always #1 clk = ~clk;
	initial begin
		{clk,rst} <= 1;
	repeat(2) @(posedge clk);
		rst <= 0;
	repeat(2) @(posedge clk);
	while(1) @(posedge clk)
		;
	end
always @(posedge clk) begin
#(1);
if (see_error)
$display("%4t r=%x er=%b %xlx.tc=%x.%x e=%x s=%x xg=%x %x xin=%x %x", $time, rosaddr,
see_error,
io_mode,lx,tc,e,
syndrome,
xg,
expected_xg,
xin,
expected_xin);
end

always @(posedge clk) begin
	if (rst) begin
		rosaddr <= 0;
		error_count <= 0;
	end else begin
		if (ros_clock_on) begin
			rosaddr <= next_addr;
		end
	end
end

	x2050lad u_lad (.i_clk(clk), .i_reset(rst),
		.i_io_mode(io_mode),
		.i_lx(lx),
		.i_tc(tc),
		.i_e(e),
		.i_l_reg(l_reg),
		.i_ioreg(ioreg),
		.o_xin(xin),
		.o_xg(xg));

endmodule
