`default_nettype none

module memdev64(i_clk, i_reset,
	i_wb_cyc, i_wb_stb, i_wb_we, i_wb_addr, i_wb_data, i_wb_sel,
	o_wb_stall, o_wb_ack, o_wb_data);

	parameter MEMSZ=32768;
	parameter DW=64;
	parameter EXTRACLOCK= 0;
	parameter HEXFILE="";

	localparam AW = $clog2(MEMSZ)-($clog2(DW)-3);

	input wire i_clk, i_reset;
	input wire i_wb_cyc, i_wb_stb, i_wb_we;
	input wire [AW-1:0] i_wb_addr;
	input wire [DW-1:0] i_wb_data;
	input wire [DW/8-1:0] i_wb_sel;
	output wire o_wb_stall;
	output reg o_wb_ack;
	output reg [DW-1:0] o_wb_data;

	wire w_wstb, w_stb;
	wire [DW-1:0] w_data;
	wire [AW-1:0] w_addr;
	wire [DW/8-1:0] w_sel;

	reg [DW-1:0] mem [0:(1<<AW)-1];

	generate if (HEXFILE != 0)
	begin: preload
		initial $readmemh(HEXFILE, mem);
	end endgenerate

	generate
	if (!|EXTRACLOCK) begin
		assign w_wstb = i_wb_stb&i_wb_we;
		assign w_stb = i_wb_stb;
		assign w_addr = i_wb_addr;
		assign w_data = i_wb_data;
		assign w_sel = i_wb_sel;
		assign o_wb_stall = 0;
	end else begin
		reg saved_we, delayed_stb;
		reg [AW-1:0] saved_addr;
		reg [DW-1:0] saved_data;
		reg [DW/8-1:0] saved_sel;
		reg [6:0] count;
		always @(posedge i_clk) begin
			if (!o_wb_stall) begin
				saved_data <= i_wb_data;
				saved_addr <= i_wb_addr;
				saved_sel <= i_wb_sel;
				saved_we <= i_wb_we;
			end
			delayed_stb <= 0;
			count <= 0;
			if (i_reset)
				;
			else if (count==EXTRACLOCK) begin
				delayed_stb <= 1;
			end else if (|count)
				count <= count+1;
			else if (i_wb_stb)
				count <= 1;
		end
		assign w_wstb = delayed_stb&saved_we;
		assign w_stb = delayed_stb;
		assign w_addr = saved_addr;
		assign w_data = saved_data;
		assign w_sel = saved_sel;
		assign o_wb_stall = |count;
	end endgenerate;

	generate if (!|EXTRACLOCK)
	always @(posedge i_clk)
		o_wb_data <= mem[w_addr];
	else
	always @(posedge i_clk)
		if (w_stb & i_wb_cyc)
			o_wb_data <= mem[w_addr];
		else
			o_wb_data <= 0;
	endgenerate

	genvar i;
	generate
		for (i = DW/8-1; i>=0; i=i-1) begin : write_a_byte
			always @(posedge i_clk)
				if (w_wstb&w_sel[i])
					mem[w_addr][7+8*i:8*i] <= w_data[7+8*i:8*i];
		end
	endgenerate

	always @(posedge i_clk)
		if (i_reset)
			o_wb_ack <= 0;
		else
			o_wb_ack <= w_stb&i_wb_cyc;
endmodule
