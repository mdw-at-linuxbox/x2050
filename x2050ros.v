`default_nettype   none
// 2050 readonly storage - ros
// 2050_Vol18_Sep72.pdf
// 2050_Vol19_Sep72.pdf
// 2050_Vol20_Sep72.pdf

module x2050ros (i_clk, i_reset, i_addr, o_data);

// verilator lint_off UNUSED
input wire i_clk;
input wire i_reset;
// verilator lint_on UNUSED
input wire [11:0] i_addr;
output wire [89:0] o_data;


parameter ROSFILE = "data.bin";

reg [89:0] ros [0:4095];

initial $readmemb(ROSFILE,ros);

assign o_data = ros[i_addr];

endmodule
