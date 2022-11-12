`default_nettype   none

// 2050 left adder input

module x2050lad (i_clk, i_reset,
i_io_mode,
i_lx,
i_tc,
i_e,
i_l_reg,
i_ioreg,
o_xin,
o_xg);

// verilator lint_off UNUSED
input wire i_clk;
input wire i_reset;
// verilator lint_on UNUSED
input wire i_io_mode;
input wire [2:0] i_lx;
input wire i_tc;
input wire [3:0] i_e;
input wire [31:0] i_l_reg;
input wire [1:0] i_ioreg;
output wire [31:0] o_xin;
output wire [31:0] o_xg;

wire [31:0] lx_modified [0:9];
assign lx_modified[{1'b0,~3'd0}] = 32'b0;
assign lx_modified[{1'b0,~3'd1}] = i_l_reg;
assign lx_modified[{1'b0,~3'd2}] = {1'b1,31'b0};
assign lx_modified[{1'b0,~3'd3}] = {27'b0,i_e,1'b0};
assign lx_modified[{1'b0,~3'd4}] = {i_l_reg[15:0],16'b0};
assign lx_modified[{1'b0,~3'd5}] = i_l_reg | 32'd3;
assign lx_modified[{1'b0,~3'd6}] = 32'd4;
assign lx_modified[{1'b0,~3'd7}] = 32'hc0000000;
assign lx_modified[~4'd6] = {30'b0,~i_ioreg};
assign lx_modified[~4'd7] = {30'b0,i_ioreg};

assign o_xin = lx_modified[{&{i_io_mode,i_lx[2:1]},~i_lx}];

assign o_xg = o_xin ^ {32{~i_tc}};

endmodule
