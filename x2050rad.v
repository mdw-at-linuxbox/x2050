`default_nettype   none

// 2050 right adder input

module x2050rad (i_clk, i_reset,
i_lx,
i_ry,
i_r_reg,
i_m_reg,
i_h_reg,
i_sdr_parity,
o_y);

input wire i_clk;
input wire i_reset;
input wire [2:0] i_lx;
input wire [2:0] i_ry;
input wire [31:0] i_r_reg;
input wire [31:0] i_m_reg;
input wire [31:0] i_h_reg;
input wire [3:0] i_sdr_parity;
output wire [31:0] o_y;

wire lx5 = i_lx == 3'd5;
wire [1:0] ry_addr_mod = {2{lx5}};

wire [31:0] ry_modified [0:5];
assign ry_modified[0] = 32'b0;
assign ry_modified[1] = i_r_reg;
assign ry_modified[2] = i_m_reg;
assign ry_modified[3] = {16'b0,i_m_reg[31-16:31-31]};
assign ry_modified[4] = i_h_reg;
assign ry_modified[5] = {28'b0,i_sdr_parity};

assign o_y = ry_modified[i_ry] | {30'b0,ry_addr_mod};

endmodule
