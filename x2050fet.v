`default_nettype   none

// 2050 instrution fetch stats

// SY22-2823-0
// System 360 Model 50
// Capacitor Read Only Storage
// FETOP
// "Tests controlled by ROSDR 72-77" page 31 [pdf 30]
//  the description about "A Br Ctl 56" for A branch bit and B branch bit
// precisely defines what goes into o_fetch_stat_fcn here.

module x2050fet (i_clk, i_reset,
	i_ros_advance,
	i_tr,
	i_e,
	i_ss,
	i_iar,
	i_t_reg,
	i_invalid_address,
	o_one_syllable_op_stat,
	o_ibfull,
	o_refetch_stat,
	o_fetch_stat_fcn);

	input wire i_clk;
	input wire i_reset;
	input wire i_ros_advance;

	input wire [4:0] i_tr;
	input wire [3:0] i_e;
	input wire [5:0] i_ss;
	input wire [23:0] i_iar;
	input wire [31:0] i_t_reg;
	input wire i_invalid_address;
	output reg o_one_syllable_op_stat;
	output reg o_ibfull;
	output reg o_refetch_stat;
	output wire [1:0] o_fetch_stat_fcn;

	// QT105
	// truth table:
	//	00 = !refetch && (iar & 2)
	//	01 = refetch && (iar & 2)
	//	02 = !(iar & 2)
	//	03 = invalid_address
	// used by AB56
	//	94 places, including qt105 g7, qg409 qr,q5 etc. "R I-FETCH"
	assign o_fetch_stat_fcn = {
		i_invalid_address | ~i_iar[31-30],
		i_invalid_address | i_iar[31-30] & o_refetch_stat
	};

always @(posedge i_clk)
	if (i_reset)
		o_refetch_stat <= 0;
	else if (!i_ros_advance)
		;
	else if (i_tr == 5'd25)
		o_refetch_stat <= 0;
	else if (i_ss == 6'd45)
		o_refetch_stat <= 1;

wire set_one_syllable_op_stat = (i_tr == 5'd25) | (i_ss == 6'd12) | (i_ss == 6'd15);
always @(posedge i_clk)
	if (i_reset)
		o_one_syllable_op_stat <= 0;
	else if (!i_ros_advance)
		;
	else if (i_tr == 5'd25)
		o_one_syllable_op_stat <= 0;
	else if (set_one_syllable_op_stat)
		o_one_syllable_op_stat <= i_t_reg[31-30];

// ibfull: fa311
always @(posedge i_clk)
	if (i_reset)
		o_ibfull <= 0;
	else if (!i_ros_advance)
		;
	else if (i_ss == 6'd50)
		o_ibfull <= i_e[3-0];

endmodule
