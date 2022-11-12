`default_nettype   none
module pri8(i_clk, i_rst,
	i_in, o_found, o_out);

parameter N=16;

/* verilator lint_off UNUSED */
input wire i_clk;
input wire i_rst;
/* verilator lint_on UNUSED */
input wire [N-1:0] i_in;
output wire o_found;
output wire [N-1:0] o_out;

assign o_found = |i_in;

assign o_out[N-1] = i_in[N-1];
genvar i;
generate for (i = N-2; i >= 0; i = i - 1)
assign o_out[i] = ~|{i_in[N-1:i+1]} & i_in[i];
endgenerate

endmodule
