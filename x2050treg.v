`default_nettype   none

// 2050 t register

module x2050treg (i_clk, i_reset,
	i_ros_advance,
	i_al,
	i_e,
	i_t0,
	i_gpstat,
	i_l_reg,
	i_data_key,
	i_address_key,
	i_data_read,
	o_f1,
	o_t1,
	o_f_reg,
	o_q_reg,
	o_t_reg);

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;

	input wire [23:0] i_address_key;
	input wire [31:0] i_data_key;
	input wire [4:0] i_al;
	input wire [3:0] i_e;
	input wire [31:0] i_t0;
	input wire [7:0] i_gpstat;
	input wire [31:0] i_l_reg;
	input wire [31:0] i_data_read;
	output wire [31:0] o_t1;
	output wire [3:0] o_f1;
	output reg [3:0] o_f_reg;
	output reg o_q_reg;
	output reg [31:0] o_t_reg;

// f register: rf001
// adder latch 0-20: kc401
// adder latch 20-31 overflow: kc411
// adder output latch: ba001

wire [31:0] next_t[0:31];
wire next_q[0:31];
wire [3:0] next_f[0:31];

assign next_f[0] = o_f_reg;
assign next_q[0] = o_q_reg;
assign next_t[0] = i_t0;

assign next_q[1] = o_q_reg;
assign next_f[1] = {i_t0[0],o_f_reg[3:1]};
assign next_t[1] = {o_q_reg,i_t0[31-0:31-30]};

assign next_f[2] = o_f_reg;
assign next_q[2] = o_q_reg;
assign next_t[2] = {~i_gpstat[7-4], i_l_reg[31-1:31-7], i_t0[31-8:31-31]};

assign next_f[3] = o_f_reg;
assign next_q[3] = o_q_reg;
assign next_t[3] = {1'b0, i_t0[31-1:31-31]};

assign next_f[4] = o_f_reg;
assign next_q[4] = o_q_reg;
assign next_t[4] = {1'b1, i_t0[31-1:31-31]};

assign next_f[5] = o_f_reg;
assign next_q[5] = o_q_reg;
assign next_t[5] = {i_gpstat[7-4], i_l_reg[31-1:31-7], i_t0[31-8:31-31]};

assign next_f[6] = o_f_reg;
assign next_q[6] = o_q_reg;
assign next_t[6] = i_t0;

assign next_f[7] = {o_f_reg[2:0],~i_t0[31-0]};
assign next_q[7] = o_q_reg;
assign next_t[7] = {i_t0[31-1:31-31],o_q_reg};

assign next_f[8] = {o_f_reg[2:0],i_t0[31-0]};
assign next_q[8] = o_q_reg;
assign next_t[8] = {i_t0[31-1:31-31],o_q_reg};

assign next_f[9] = {o_f_reg[2:0],i_t0[31-0]};
assign next_q[9] = o_q_reg;
assign next_t[9] = {i_t0[31-1:31-31],o_f_reg[3-0]};

assign next_f[10] = o_f_reg;
assign next_q[10] = i_t0[31-0];
assign next_t[10] = {i_t0[31-1:31-31],1'b0};

assign next_f[11] = o_f_reg;
assign next_q[11] = o_q_reg;
assign next_t[11] = {i_t0[31-1:31-31],o_q_reg};

assign next_f[12] = {i_t0[31-31],o_f_reg[3:1]};
assign next_q[12] = o_q_reg;
assign next_t[12] = {1'b0,i_t0[31-0:31-30]};

assign next_f[13] = o_f_reg;
assign next_q[13] = i_t0[31-31];
assign next_t[13] = {1'b0,i_t0[31-0:31-30]};

assign next_f[14] = o_f_reg;
assign next_q[14] = i_t0[31-31];
assign next_t[14] = {o_q_reg,i_t0[31-0:31-30]};

assign next_f[15] = {o_f_reg[3-1:3-3],1'b0};
assign next_q[15] = i_t0[31-0];
assign next_t[15] = {i_t0[31-1:31-31],o_f_reg[3-0]};

assign next_f[16] = {i_t0[31-0:31-3]};
assign next_q[16] = o_q_reg;
assign next_t[16] = {i_t0[31-4:31-31],4'b0};

assign next_f[17] = {i_t0[31-0:31-3]};
assign next_q[17] = o_q_reg;
assign next_t[17] = {i_t0[31-4:31-31],o_f_reg};

assign next_f[18] = o_f_reg;
assign next_q[18] = o_q_reg;
assign next_t[18] = {i_t0[31-0:31-7],i_t0[31-12:31-31],4'b0};

assign next_f[19] = o_f_reg;
assign next_q[19] = o_q_reg;
assign next_t[19] = {i_t0[31-0:31-7],i_t0[31-12:31-31],o_f_reg};

assign next_f[20] = {i_t0[31-28:31-31]};
assign next_q[20] = o_q_reg;
assign next_t[20] = {4'b0,i_t0[31-0:31-27]};

assign next_f[21] = {i_t0[31-28:31-31]};
assign next_q[21] = o_q_reg;
assign next_t[21] = {o_f_reg,i_t0[31-0:31-27]};

assign next_f[22] = {i_t0[31-28:31-31]};
assign next_q[22] = o_q_reg;
assign next_t[22] = {i_t0[31-0:31-7],4'b0,i_t0[31-8:31-27]};

assign next_f[23] = {i_t0[31-28:31-31]};
assign next_q[23] = o_q_reg;
assign next_t[23] = {i_t0[31-0:31-7],4'b1,i_t0[31-8:31-27]};

assign next_f[24] = o_f_reg;
assign next_q[24] = o_q_reg;
assign next_t[24] = {i_t0[31-0:31-3],i_t0[31-0:31-27]};

assign next_f[25] = o_f_reg;
assign next_q[25] = o_q_reg;
assign next_t[25] = {o_f_reg,i_t0[31-0:31-27]};

assign next_f[26] = o_f_reg;
assign next_q[26] = o_q_reg;
assign next_t[26] = {i_t0[31-0:31-7],i_t0[31-12:31-31],i_e};

assign next_f[27] = o_f_reg;
assign next_q[27] = i_t0[31-31];
assign next_t[27] = {o_f_reg[3-3],i_t0[31-0:31-30]};

assign next_f[28] = i_data_key[31-28:31-31];
assign next_q[28] = o_q_reg;
assign next_t[28] = {i_data_key};

// XXX 29: needs bus from selector channels

assign next_f[30] = o_f_reg;
assign next_q[30] = o_q_reg;
assign next_t[30] = i_data_read;

assign next_f[31] = o_f_reg;
assign next_q[31] = o_q_reg;
assign next_t[31] = {8'b0,i_address_key};

assign o_t1 = next_t[i_al];	// for setting gpstat
assign o_f1 = next_f[i_al];	// for setting gpstat

// XXX only on ros exec
always @(posedge i_clk)
	if (i_reset) begin
		o_f_reg <= 0;
		o_q_reg <= 0;
		o_t_reg <= 0;
	end
	else if (!i_ros_advance)
		;
	else begin
		o_f_reg <= o_f1;
		o_q_reg <= next_q[i_al];
		o_t_reg <= o_t1;
	end
endmodule
