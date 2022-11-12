`default_nettype   none

// 2050 left mover input

// SY22-2823-0
// System 360 Model 50
// Capacitor Read Only Storage
// FETOP
// page 26
// figure 21 "decode circuits for left mover input (rosdr 1-3)"

module x2050lmv (i_clk, i_reset,
i_lu,
i_io_mode,
i_r_reg,
i_l_reg,
i_md_reg,
i_f_reg,
i_mb_reg,
i_lb_reg,
i_dd_in,
i_mpx_buffer_in_bus,
i_ilc,
i_cc,
i_progmask,
i_xtr,
o_u_reg,
o_dd_sample,
o_xtr_sample);

input wire i_clk;
input wire i_reset;
input wire [2:0] i_lu;
input wire i_io_mode;
input wire [31:0] i_r_reg;
input wire [31:0] i_l_reg;
input wire [3:0] i_md_reg;
input wire [3:0] i_f_reg;
input wire [1:0] i_mb_reg;
input wire [1:0] i_lb_reg;
input wire [7:0] i_dd_in;
input wire [8:0] i_mpx_buffer_in_bus;
input wire [1:0] i_ilc;
input wire [1:0] i_cc;
input wire [3:0] i_progmask;
input wire [7:0] i_xtr;
output wire [7:0] o_u_reg;
output wire o_dd_sample;
output wire o_xtr_sample;

wire [7:0] l_reg_bytewise[0:3];
assign l_reg_bytewise[0] = i_l_reg[31-0:31-7];
assign l_reg_bytewise[1] = i_l_reg[31-8:31-15];
assign l_reg_bytewise[2] = i_l_reg[31-16:31-23];
assign l_reg_bytewise[3] = i_l_reg[31-24:31-31];

wire [7:0] left_input [0:15];
assign left_input[0] = 8'd0;
assign left_input[1] = {i_md_reg, i_f_reg};
assign left_input[2] = i_r_reg[31-24:31-31];
assign left_input[3] = i_dd_in;
assign left_input[4] = i_xtr;
assign left_input[5] = {i_ilc, i_cc, i_progmask};
assign left_input[6] = l_reg_bytewise[i_mb_reg];
assign left_input[7] = l_reg_bytewise[i_lb_reg];
assign left_input[8+0] = 8'd0;
assign left_input[8+2] = i_r_reg[31-24:31-31];
assign left_input[8+3] = i_mpx_buffer_in_bus[7-0:7-7];
assign left_input[8+4] = i_l_reg[31-0:31-7];
assign left_input[8+5] = i_l_reg[31-8:31-15];
assign left_input[8+6] = i_l_reg[31-16:31-23];
assign left_input[8+7] = i_l_reg[31-24:31-31];

wire [3:0] lu_index = {i_io_mode,i_lu};

assign o_u_reg = left_input[lu_index];

assign o_dd_sample = lu_index == 4'd3;
assign o_xtr_sample = lu_index == 4'd4;

endmodule
