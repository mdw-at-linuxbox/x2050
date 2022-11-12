`default_nettype   none

// 2050 right mover input

// 2050_Control_Field_Specification_196508.pdf
// cfc 101 - 2050 control field specifications - cpu mode (lu,mv,zp,zf,zn)
// page 26
// figure 21 "decode circuits for left mover input (rosdr 1-3)"

module x2050rmv (i_clk, i_reset,
i_mv,
i_io_mode,
i_m_reg,
i_mb_reg,
i_lb_reg,
i_mpx_buffer_in_bus,
o_v_reg);

// verilator lint_off UNUSED
input wire i_clk;
input wire i_reset;
// verilator lint_on UNUSED
input wire i_io_mode;
input wire [1:0] i_mv;
input wire [31:0] i_m_reg;
input wire [1:0] i_mb_reg;
input wire [1:0] i_lb_reg;
input wire [8:0] i_mpx_buffer_in_bus;
output wire [7:0] o_v_reg;

// ds021
wire [7:0] m_reg_bytewise[0:3];
assign m_reg_bytewise[0] = i_m_reg[31-0:31-7];
assign m_reg_bytewise[1] = i_m_reg[31-8:31-15];
assign m_reg_bytewise[2] = i_m_reg[31-16:31-23];
assign m_reg_bytewise[3] = i_m_reg[31-24:31-31];

// ds021
wire [7:0] right_input [0:3];
// cpu mode
assign right_input[0] = 8'd0;
assign right_input[1] = m_reg_bytewise[i_lb_reg];
assign right_input[2] = m_reg_bytewise[i_mb_reg];
// io mode
// 0 is the same as cpu.
// 2 map that into 3.
// guess: qv320 qv320 qv321 qv430 have "b bib+v"
assign right_input[3] = i_mpx_buffer_in_bus[7-0:7-7];

wire [1:0] mv_index = {1'b0,(i_io_mode & i_mv[1])} | i_mv;

assign o_v_reg = right_input[mv_index];

// Please verilator
// verilator lint_off UNUSED
wire    unused;
assign  unused = i_mpx_buffer_in_bus[8];
// verilator lint_on  UNUSED

endmodule
