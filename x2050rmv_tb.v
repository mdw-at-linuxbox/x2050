`default_nettype   none
`timescale 10ns / 1ns
module tb;

	reg clk, rst;
	parameter DW=32;
	parameter XW=25;	// # of adddress bits, 24=16 meg ram (max)
	localparam AW=(32+3-$clog2(DW));
	localparam LOG2_DW=$clog2(DW);
	localparam LOG2_BW=(LOG2_DW-3);

	localparam RW=39;
	wire ros_clock_on;
	reg [7:0] rosaddr;
	wire [RW-1:0] rosdr;
	wire [3:0] op = rosdr[48:35];	// 35 4 op
	wire io_mode = rosdr[34];	// 34 1 imode
	wire [1:0] mv = rosdr[33:32];	// 32 2 mv
	wire [31:0] data = rosdr[31:0];	// 0 32 data
	reg ros_advance;

	assign ros_clock_on = 1;

	// setup and test cases
	wire [RW-1:0] ros[0:255];
// op = 0 compare results
// op = 1 set m reg
// op = 2 set lb reg and mb reg
// op = 3 set bib
// op = 15 terminate
//		 op   io   lx   tc   e    expected
//		 op   io   mv   data
assign ros[0] = {4'h1,1'b0,2'd0,32'h12345678};
assign ros[1] = {4'h2,1'b0,2'd0,32'h12};
assign ros[2] = {4'h3,1'b0,2'd0,32'h3e};
assign ros[3] = {4'h0,1'b0,2'd0,32'd0};
assign ros[4] = {4'h0,1'b0,2'd1,32'h34};
assign ros[5] = {4'h0,1'b0,2'd2,32'h56};
//assign ros[x] = {4'h0,1'b0,2'd3,32'h00};	// invalid
assign ros[6] = {4'h0,1'b1,2'd0,32'd0};
//assign ros[x] = {4'h0,1'b1,2'd1,32'h00};	// invalid
assign ros[7] = {4'h0,1'b1,2'd2,32'h3e};
//assign ros[x] = {4'h0,1'b1,2'd3,32'h00};	// invalid

assign ros[8] = ~0;

	assign rosdr = ros[rosaddr];
	wire [7:0] next_addr = (rosaddr + 1);

	// sample data
	reg [31:0] m_reg;
	reg [1:0] lb_reg;
	reg [1:0] mb_reg;
	reg [8:0] mpx_buffer_in_bus;

	// actual results
	wire [7:0] v_reg;

	// expected results
	wire [7:0] expected_v = data[7:0];

wire see_error = (op == 4'h0) & (
	(v_reg != expected_v)
	) ;
wire [1:0] syndrome =
{
op == 4'h0,
v_reg != expected_v
};

// op = 0 compare results
// op = 1 set m reg
// op = 2 set lb reg and mb reg
// op = 3 set bib
reg [7:0] error_count;

always @(posedge clk) begin
	case (1)
	op == 4'h1:
		m_reg <= data;
	op == 4'h2:
		begin
			mb_reg <= data[1:0];
			lb_reg <= data[5:4];
		end
	op == 4'h3:
		mpx_buffer_in_bus[7:0] <= data[7:0];
	see_error:
		if (v_reg != expected_v) begin
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
		$dumpfile("x2050rmv.vcd");
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
$display("%4t r=%x %xmv=%x er=%x s=%x m=%x lb=%x mb=%x bib=%x v=%x exp=%x",
$time, rosaddr,
io_mode, mv,
see_error, syndrome,
m_reg,mb_reg,lb_reg,mpx_buffer_in_bus,v_reg,expected_v);
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

	x2050rmv u_rmv (.i_clk(clk), .i_reset(rst),
		.i_mv(mv),
		.i_io_mode(io_mode),
		.i_m_reg(m_reg),
		.i_mb_reg(mb_reg),
		.i_lb_reg(lb_reg),
		.i_mpx_buffer_in_bus(mpx_buffer_in_bus),
		.o_v_reg(v_reg));

endmodule
