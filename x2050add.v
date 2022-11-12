`default_nettype   none

// 2050 adder

module x2050add (i_clk, i_reset,
i_ros_advance,
i_ad,
i_al,
i_carry_in,
i_xg,
i_y,
o_t0,
o_dec_cor,
o_c0,
o_c1,
o_c8,
o_c16,
o_c24,
// o_carry,
o_aux);

input wire i_clk;
input wire i_reset;
input wire i_ros_advance;
input wire [3:0] i_ad;
input wire [4:0] i_al;
input wire i_carry_in;
input wire [31:0] i_xg;
input wire [31:0] i_y;
output wire [31:0] o_t0;
output wire [32:0] o_dec_cor;
output wire o_aux;
output wire o_c0;
output wire o_c1;
output wire o_c8;
output wire o_c16;
output wire o_c24;
// output wire o_carry;

wire ad6 = i_ad == 4'd6;
wire ad11 = i_ad == 4'd11;
wire al23 = i_al == 5'd23;
wire c7_in;
wire c1;
wire c4,c12,c20,c28;

reg aux;

// verilator lint_off WIDTH
assign {c28,o_t0[3:0]} = {1'b0,i_xg[3:0]} + i_y[3:0] + i_carry_in;
assign {o_c24,o_t0[7:4]} = {1'b0,i_xg[7:4]} + i_y[7:4] + c28;
assign {c20,o_t0[11:8]} = {1'b0,i_xg[11:8]} + i_y[11:8] + o_c24;
assign {o_c16,o_t0[15:12]} = {1'b0,i_xg[15:12]} + i_y[15:12] + c20;
assign {c12,o_t0[19:16]} = {1'b0,i_xg[19:16]} + i_y[19:16] + o_c16;
assign {o_c8,o_t0[23:20]} = {1'b0,i_xg[23:20]} + i_y[23:20] + c12;
assign c7_in = ad6 ? al23 : o_c8;
assign {c4,o_t0[27:24]} = {1'b0,i_xg[27:24]} + i_y[27:24] + c7_in;
assign {o_c1,o_t0[30:28]} = {1'b0,i_xg[30:28]} + i_y[30:28] + c4;
assign {o_c0,o_t0[31]} = {1'b0,i_xg[31]} + i_y[31] + o_c1;
// verilator lint_on WIDTH

// wire new_carry[0:15];
// assign new_carry[1] = i_carry_in;
// assign new_carry[2] = i_carry_in;
// assign new_carry[3] = i_carry_in;
// assign new_carry[8] = i_carry_in;
// assign new_carry[9] = i_carry_in;
// assign new_carry[10] = i_carry_in;
// assign new_carry[11] = i_carry_in;
// assign new_carry[12] = i_carry_in;
//
// assign new_carry[4] = o_c0;
// assign new_carry[5] = o_c0 ^ o_c1;
// assign new_carry[6] = o_c1;
// assign new_carry[7] = o_c8;
//
// assign o_carry = new_carry[i_ad];

wire [31:0] ad8_value = {
	{4{aux}} & 4'd6,
	{4{o_t0[31-2]}} & 4'd6,
	{4{o_t0[31-6]}} & 4'd6,
	{4{o_t0[31-10]}} & 4'd6,
	{4{o_t0[31-14]}} & 4'd6,
	{4{o_t0[31-18]}} & 4'd6,
	{4{o_t0[31-22]}} & 4'd6,
	{4{o_t0[31-26]}} & 4'd6
};
wire [31:0] ad9_value = {
	{4{o_c0}} & 4'd6, {4{c4}} & 4'd6,
	{4{o_c8}} & 4'd6, {4{c12}} & 4'd6,
	{4{o_c16}} & 4'd6, {4{c20}} & 4'd6,
	{4{o_c24}} & 4'd6, {4{c28}} & 4'd6
};
wire [31:0] ad10_value = {
	{4{o_t0[31-0:31-3]>=4'd5}} & 4'd6,
	{4{o_t0[31-4:31-7]>=4'd5}} & 4'd6,
	{4{o_t0[31-8:31-11]>=4'd5}} & 4'd6,
	{4{o_t0[31-12:31-15]>=4'd5}} & 4'd6,
	{4{o_t0[31-16:31-19]>=4'd5}} & 4'd6,
	{4{o_t0[31-20:31-23]>=4'd5}} & 4'd6,
	{4{o_t0[31-24:31-27]>=4'd5}} & 4'd6,
	{4{o_t0[31-28:31-31]>=4'd5}} & 4'd6
};
wire [31:0] ad11_value = {
	4'b0,
	{4{o_t0[31-2]}} & 4'd6,
	{4{o_t0[31-6]}} & 4'd6,
	{4{o_t0[31-10]}} & 4'd6,
	{4{o_t0[31-14]}} & 4'd6,
	{4{o_t0[31-18]}} & 4'd6,
	{4{o_t0[31-22]}} & 4'd6,
	{4{o_t0[31-26]}} & 4'd6
};
wire [31:0] dec_fixes[0:15];
assign dec_fixes[8] = ad8_value;
assign dec_fixes[9] = ad9_value;
assign dec_fixes[10] = ad10_value;
assign dec_fixes[11] = ad11_value;
wire do_dec_cor = i_ad[3]&~i_ad[2];	// ad8|ad9|ad10|ad11
assign o_dec_cor = {dec_fixes[i_ad], do_dec_cor};

assign o_aux = aux;

always @(posedge i_clk)
	if (i_reset)
		aux <= 1'b0;
	else if (!i_ros_advance)
		;
	else if (ad11)
		aux <= o_t0[31-30];

endmodule
