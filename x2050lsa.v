`default_nettype   none

// 2050 local store address register

// Y22-2827-0_360-50_Multiplexor_Channel_FETOM_Oct66.pdf
// Z22-2855-3_Field_Engr_Handbook_System360_Model_50_4th_Ed_196703.pdf

module x2050lsa (i_clk, i_reset,
	i_io_mode,
	i_ws,
	i_ss,
	i_save_r,
	i_break_out,
	i_j_reg,
	i_md_reg,
	i_e,
	i_ch,
	o_lsfn,
	o_lsa);
	input wire i_clk;
	input wire i_reset;
	input wire i_io_mode;
	input wire [2:0] i_ws;
	input wire [5:0] i_ss;
	input wire i_save_r;
	input wire i_break_out;
	input wire [3:0] i_j_reg;
	input wire [3:0] i_md_reg;
	input wire [3:0] i_e;
	input wire [1:0] i_ch;
	output wire [5:0] o_lsa;
	output wire [1:0] o_lsfn;

wire [5:0] lsa_values[0:15];

wire [1:0] lsfn = {2{(i_ss == 6'd14) | (i_ss == 6'd39)}} & i_e[1:0];

assign o_lsfn = lsfn;

// true during break-in and break-out cycles, for
//  saving and restoring cpu mode r register
wire force_44 = i_save_r | i_break_out;

// channel LS address map in io mode
// Y22-2827-0 figure 23 "local storage' page 34 [pdf page 33]
// Z22-2855-3 local storage address segments page 38 [pdf page 42]

// cpu mode
assign lsa_values[1] = 6'b010001;	// WS1
assign lsa_values[2] = 6'b010010;	// WS2
assign lsa_values[3] = {2'b01,i_e};
assign lsa_values[4] = {lsfn,i_j_reg};
assign lsa_values[5] = {lsfn,i_j_reg[3:1],1'b1};
assign lsa_values[6] = {lsfn,i_md_reg};
assign lsa_values[7] = {lsfn,i_md_reg[3:1],1'b1};
// io mode
assign lsa_values[8 + 0] = {2'd2,2'd3,2'd0};	// r register backup
assign lsa_values[8 + 1] = {2'd2,2'd3,2'd1};	// l register backup
assign lsa_values[8 + 2] = {2'd2,2'd3,2'd2};	// interrupt buffer
assign lsa_values[8 + 3] = {2'd2,2'd3,2'd3};	// backup buffer #3
assign lsa_values[8 + 4] = {2'd0,i_ch,2'd0};	// ca
assign lsa_values[8 + 5] = {2'd0,i_ch,2'd1};	// da
assign lsa_values[8 + 6] = {2'd0,i_ch,2'd2};	// cnt
assign lsa_values[8 + 7] = {2'd0,i_ch,2'd3};	// data in sel / ua in mpx

assign o_lsa = lsa_values[{i_io_mode | force_44,i_ws}];

endmodule
