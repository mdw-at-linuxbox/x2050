# read in data.bin, print out the io lines
use common::sense;

my $vflag;
my $aflag;
my @patterns;

my $dtype = "cpu";

sub process_opts
{
	my @r;
	my $f;
	my $p;
	for my $j ( @_ ) {
		if (defined($f)) {
			&$f($j);
			undef $f;
			next;
		}
#		if ($j eq "-x") {
#			$f = sub {
#				my ($f) = @_;
#				my @q = split(",", $f);
#				$p = {};
#				push @patterns, $p;
#				$p->{bitoff} = $q[0];
#				$p->{bitsize} = 1+$q[1]-$q[0];
#			};
#			next;
#		}
		if ($j eq "-i") {
			$dtype = "io";
			next;
		}
		push @r, $j;
	}
	return @r;
}

sub read_in_data_bin
{
	my ($f) = @_;
	my $r = {};
	open(my $fh, "<".$f) or die "Cannot read data.bin from $f: $!\n";
	while (<$fh>) {
		next if /^#/;
		chomp;
		if (!m%@([^ ]+)  *([0-9a-fA-F_]*)(?:|  *// (.*))$%) {
			print STDERR "can't parse <$_>\n";
			next;
		}
		my $addr = substr($_, $-[1], $+[1]-$-[1]);
		my $data = substr($_, $-[2], $+[2]-$-[2]);
		my ($sheet, $cld);
		if (defined($-[3])) {
			my @s = split(' ', substr($_, $-[3], $+[3]-$-[3]));
			($sheet, $cld) = @s;
		}
		$addr = hex($addr);
		my $format;
		if ($data =~ /^._..._.._......_...._..._....._._._.._..._._..._....._..._._..._.._..._.._.._._...._..._._..._..._._......_....._._......$/) {
			$format = "io";
		} elsif ($data =~ /^._..._.._......_...._..._....._._..._..._._..._....._...._.._._._._..._.._.._._...._..._._..._...._......_....._._......$/) {
			$format = "cpu";
		} else {
			$format = "ones";
		}
		$data =~ s%_%%g;
		my $e = {};
		$r->{$addr} = $e;
		$e->{type} = $format;
		$e->{address} = $addr;
		$e->{ros} = $data;
		$e->{sheet} = $sheet if $sheet;
		$e->{cld} = $cld if $cld;
	}
	close $fh;
	return $r;
}

my $io_format = [
#{"P" => 56},
{"LU" => [1,3]}, {"MV" => [4,5]},
{"ZP" => [6,11]}, {"ZF" => [12,15]},
{"ZN" => [16,18]}, {"TR" => [19,23]},
{"ZR" => 24},
{"CS" => 25}, {"SA" => [26,27]},
{"SF" => [28,30]},

{"CT" => [32,34]}, {"AL" => [35,39]},
{"WL" => [40,42]},
{"HC" => 43},
{"MS" => [44,46]},
{"CG" => [47,48]},
{"MG" => [49,51]}, {"UL" => [52,53]},
{"UR" => [54,55]},

{"CE" => [57,60]},
{"LX" => [61,63]},
{"TC" => 64},
{"RY" => [65,67]},
{"CL" => [68,70]},
{"?" => 71},
{"AB" => [72,77]},
{"BB" => [78,82]},
{"UX" => 83},
{"SS" => [84,89]},
];

my $cpu_format = [
#{"P" => 56},
{"LU" => [1,3]}, {"MV" => [4,5]},
{"ZP" => [6,11]}, {"ZF" => [12,15]},
{"ZN" => [16,18]}, {"TR" => [19,23]},
{"ZR" => 24},
{"WS" => [25,27]}, {"SF" => [28,30]},

{"IV" => [32,34]}, {"AL" => [35,39]},
{"WM" => [40,43]}, {"UP" => [44,45]},
{"MD" => 46},
{"LB" => 47},
{"MB" => 48},
{"DG" => [49,51]}, {"UL" => [52,53]},
{"UR" => [54,55]},

{"CE" => [57,60]},
{"LX" => [61,63]},
{"TC" => 64},
{"RY" => [65,67]},
{"AD" => [68,71]}, {"AB" => [72,77]},
{"BB" => [78,82]},
{"UX" => 83},
{"SS" => [84,89]},
];

my $ssformat = [
"",		# 0
undef,		# 1
undef,		# 2
"D->CR*BS",	# 3
"E->SCANCTL",	# 4
"L,RSGNS",	# 5
"IVD/RSGNS",	# 6
"EDITSGN",	# 7
"E->S03",	# 8
"S03->E,1->LSGN",	# 9
"S03->E",	# 10
"S03->E,0->BS",	# 11
"X0,B0,1SYL",	# 12
"FPZERO",	# 13
"FPZERO,E->FN",	# 14
"B0,1SYL",	# 15
"S03&=~E",	# 16
"(T=0)->E",	# 17
"E->BS,T(30)->S3",# 18
"E->BS",	# 19
"1->BS*MB",	# 20
"DIRCTL*E",	# 21
undef,		# 22
"MANUAL->STOP",	# 23
"E->S47",	# 24
"S47|=E",	# 25
"S47&=~E",	# 26
"S47,ED*FP",	# 27
"OPPANEL->S47",	# 28
"CAR,(T->0)->CR",	# 29
"KEY->F",	# 30
"F->KEY",	# 31
"1->LSGNS",	# 32
"0->LSGNS",	# 33
"1->RSGNS",	# 34
"0->RSGNS",	# 35
"L(0)->LSGNS",	# 36
"R(0)->RSGNS",	# 37
"E(13)->WFN",	# 38
"E(23)->LSFN",	# 39
"E(23)->CR",	# 40
"SETCRALG",	# 41
"SETCRLOG",	# 42
"->S4,S4->CR",	# 43
"S4,->->CR",	# 44
"1->REFETCH",	# 45
"SYNC->OPPANEL",	# 46
"SCAN*E",	# 47
"1->SUPOUT",	# 48
"MPXSELRESET",	# 49
"E(0)->IBFULL",	# 50
undef,		# 51
"E->CH",	# 52
undef,		# 53
"1->TIMERIRPT",	# 54
"T->PSW,IPL->T",	# 55
"T->PSW",	# 56
"SCAN*E,00",	# 57
"1->IOMODE",	# 58
"0->IOMODE",	# 59
"1->SELOUT",	# 60
"1->ADROUT",	# 61
"1->COMOUT",	# 62
"1->SERVOUT",	# 63
];

my $zfformat = [
"",	# 0
undef,	# 1
"D->ROAR,SCAN",	# 2
undef,	# 3
undef,	# 4
undef,	# 5
"M(03)->ROAR",	# 6
undef,	# 7
"M(47)->ROAR",	# 8
undef,	# 9
"F->ROAR",	# 10
undef,	# 11
"ED->ROAR",	# 12
undef,	# 13
"RETURN->ROAR",	# 14
undef,	# 15
];

my $znformat = [
"--roar--",	# 0
"SMIF",	# 1
"AQ(B=0)->A",	# 2 "hypothesis"
"AQ(B=1)->A",	# 3
"",	# 4
"FNTRAP",	# 5
"BQ(A=0)->B",	# 6
"BQ(A=1)->B",	# 7
];
my $ulformat = [
"E",	# 0
"U",	# 1
"V",	# 2
"?",	# 3
];
my $urformat = [
"E",	# 0
"U",	# 1
"V",	# 2
"?",	# 3
];
my $ceformat = [
"E 0000",	# 0
"E 0001",	# 1
"E 0010",	# 2
"E 0011",	# 3
"E 0100",	# 4
"E 0101",	# 5
"E 0110",	# 6
"E 0111",	# 7
"E 1000",	# 8
"E 1001",	# 9
"E 1010",	# 10
"E 1011",	# 11
"E 1100",	# 12
"E 1101",	# 13
"E 1110",	# 14
"E 1111",	# 15
];
my $sfformat = [
"R->LS",	# 0
"LS->L,R->LS",	# 1
"LS->R->LS",	# 2
"LS->R->LS",	# 3
"L->LS",	# 4
"LS->R,L->LS",	# 5
"LS->L->LS",	# 6
"",	# 7 (no-op, only use w/ WS4)
];
my $alformat = [
"",	# 0
"Q->SR1->F",	# 1
"L0,~s4->",	# 2
"+SGN->",	# 3
"-SGN->",	# 4
"L0,S4->",	# 5
"IA->H",	# 6
"Q->SL->-F",	# 7
"Q->SL->F",	# 8
"F->SL1->F",	# 9
"SL1-<Q",	# 10
"Q->SL1",	# 11
"SR1->F",	# 12
"SR1->Q",	# 13
"Q->SR1->QS",	# 14
"F->SL1->Q",	# 15
"SL4->F",	# 16
"F->SL4->F",	# 17
"FPSL4",	# 18
"F->FPSL4",	# 19
"SR4->F",	# 20
"F->SR4->F",	# 21
"FPSR4->F",	# 22
"1->FPSR4+F",	# 23
"SR4->H",	# 24
"F->SR4",	# 25
"E->FPSL4",	# 26
"F->SR1+Q",	# 27
"DKEY",	# 28
"CH",	# 29
"D",	# 30
"AKEY",	# 31
];
my $tcformat = [
"-",	# 0
"+",	# 1
];
my $ryformat = [
"0",	# 0
"R",	# 1
"M",	# 2
"M23M",	# 3
"H",	# 4
"SEMT",	# 5
undef,	# 6
undef,	# 7
];
my $abformat = [
"0",	# 0
"1",	# 1
"S0",	# 2
"S1",	# 3
"S2",	# 4
"S3",	# 5
"S4",	# 6
"S5",	# 7
"S6",	# 8
"S7",	# 9
"CSTAT",	# 10
undef,	# 11
"1SYLS",	# 12
"LSGNS",	# 13
"^SGNS",	# 14
undef,	# 15
"CRMD",	# 16
"W=0",	# 17
"WL=0",	# 18
"WR=0",	# 19
"MD=FP",	# 20
"MB=3",	# 21
"MD3=0",	# 22
"G1=0",	# 23
"G1<0",	# 24
"G<4",	# 25
"G1MBZ",	# 26
"IOS0",	# 27
"IOS1",	# 28
"R(31)",	# 29
"F(2)",	# 30
"L(0)",	# 31
"F=0",	# 32
"UNORM",	# 33
"TZ*BS",	# 34
"EDITPAT",	# 35
"PROB",	# 36
"TIUP",	# 37
undef,	# 38
"GZ/MB3",	# 39
undef,	# 40
"STC=0",	# 41
undef,	# 42
"G2<=LB",	# 43
undef,	# 44
"D(7)",	# 45
"SCPS",	# 46
"SCFS",	# 47
"STORV",	# 48
"W(67)->ab",	# 49
"Z23!=0",	# 50
"CCW2OK",	# 51
"MXBIO",	# 52
"IBFULL",	# 53
"CANG",	# 54
"CHLOG",	# 55
"I-FETCH",	# 56
"IA(30)",	# 57
"EXT,CHIRPT",	# 58
"DCHOLD",	# 59
"PSS",		# 60
"IOS4",		# 61
undef,		# 62
"RX,S0",	# 63
];
my $bbformat = [
"0",		# 0
"1",		# 1
"S0",		# 2
"S1",		# 3
"S2",		# 4
"S3",		# 5
"S4",		# 6
"S5",		# 7
"S6",		# 8
"S7",		# 9
"RSGNS",	# 10
"HSCH",		# 11
"EXC",		# 12
"WB=0",		# 13
undef,		# 14
"T13=0",	# 15
"T(0)",		# 16
"T=0",		# 17
"TZ*BS",	# 18
"W=1",		# 19
"LB=0",		# 20
"LB=3",		# 21
"MD=0",		# 22
"G2=0",		# 23
"G2<0",		# 24
"G2LBZ",	# 25
"IOS1",		# 26
"MD/J",		# 27
"IVA",		# 28
"IOS3",		# 29
"(CAR)",	# 30
"Z00",		# 31
];

my $io2_format = {
"LU" => [	# 3-7 different in IOmode
"",		# 0
"MD,F->U",	# 1
"R3->U",	# 2
"BIB->U",	# 3
"L0->U",	# 4
"L1->U",	# 5
"L2->U",	# 6
"L3->U",	# 7
],
# seq -f '"",	# %g' 0 63
"MV" => [	# different in IO mode
"",	# 0
undef,	# 1
"BIB->V",	# 2
undef,	# 3	1401/7010
],
# ZP
"ZF" => $zfformat,
"ZN" => $znformat,
"TR" => [	# io: only 27 and 31 differ
"T",	# 0
"R",	# 1
"R0",	# 2
"M",	# 3
"D",	# 4
"L0",	# 5
"R,A",	# 6
"L",	# 7
"HA->A",	# 8
"R,AN",	# 9
"R,AW",	# 10
"R,AD",	# 11
"D->IaR",	# 12
"SCAN+D",	# 13
"R13",	# 14
"A",	# 15
"L,A",	# 16
"R,D",	# 17
undef,	# 18
"R,IO",	# 19
"H",	# 20
"IA",	# 21
"FOLD,D",	# 22
undef,	# 23
"L,M",	# 24
"MLJK",	# 25
"MHL",	# 26
"D*BI",	# 27 IO diference store under ioreg byte select lines
"M,SP",	# 28
"D*BS",	# 29
"L13",	# 30
"IO",	# 31 IO different: t<12:15>->ioreg
],
"ZR" => [
"", undef
],
"CS" => [
"L XXX ?/LSA",	# 0
"L XXX ?/LSA",	# 1
],
"SA" => [
"L XXX ?/LSA",	# 0
"L XXX ?/LSA",	# 1
"L XXX ?/LSA",	# 2
"L XXX ?/LSA",	# 3
],
"SF" => $sfformat,
"CT" => [
"",	# 0
"FIRSTCYCLE",	# 1
"DTC1",	# 2
"DTC2",	# 3
"IA+4->A,IR",	# 4
undef,	# 5
undef,	# 6
undef,	# 7
],
"AL" => $alformat,
"WL" => [
"",	# 0
"W->L0",	# 1
"W->L1",	# 2
"W->L2",	# 3
"W->L3",	# 4
"W,E->A(BUMP)",	# 5
"W,E->A(BUMP)S",	# 6
undef,	# 7
],
"HC" => [
"",	# 0
"HOT1",	# 1
],
"MS" => [
"",	# 0
"BIB(03)->IOS",	# 1
"BIB(47)->IOS",	# 2
"BIB03->IOS*E",	# 3
"BIB47->IOS*E",	# 4
"IOSQE",	# 5
"IOS,~E",	# 6
"BIB4,ERR->IOS",	# 7
],
"CG" => [
"",	# 0
"CH->BI",	# 1
"1->PRI",	# 2
"1->LCY",	# 3
],
"MG" => [
"BFR2->BIB",	# 0
"CHPOSTEST",	# 1
"BFR2->BUSO",	# 2
"BFR1->BIB",	# 3
"BOB->BFR1",	# 4
"BOB->BFR2",	# 5
"BUSI->BFF1",	# 6
"BUSI->BFR2",	# 7
],
"UL" => $ulformat,
"UR" => $urformat,
"CE" => $ceformat,
"LX" => [	# different in IO mode
"",	# 0
"L",	# 1
"SGN",	# 2
"E",	# 3
"LRL",	# 4
"LWA",	# 5
"IOC",	# 6
"IO",	# 7
],
"TC" => $tcformat,
"RY" => $ryformat,
"CL" => [
"",	# 0
undef,	# 1
undef,	# 2
"CCW2TEST",	# 3
"CATEST",	# 4
"UATEST",	# 5
"LSWDTEST",	# 6
undef,	# 7
],
"?" => [
"", undef
],
"AB" => $abformat,
"BB" => $bbformat,
"UX" => [
"", undef
],
"SS" => $ssformat
};

my $cpu2_format = {
"LU" => [
"",		# 0
"MD,F->U",	# 1
"R3->U",	# 2
"DCI->U",	# 3
"XTR->U",	# 4
"PSW4->U",	# 5
"LMB->U",	# 6
"LLB->U",	# 7
],
"MV" => [	# different in IO mode
"",	# 0
"MLB->V",	# 1
"MMB->V",	# 2
undef,	# 3	1401/7010
],
# ZP
"ZF" => $zfformat,
"ZN" => $znformat,
"TR" => [	# io: only 27 and 31 differ
"T",	# 0
"R",	# 1
"R0",	# 2
"M",	# 3
"D",	# 4
"L0",	# 5
"R,A",	# 6
"L",	# 7
"HA->A",	# 8
"R,AN",	# 9
"R,AW",	# 10
"R,AD",	# 11
"D->IaR",	# 12
"SCAN+D",	# 13
"R13",	# 14
"A",	# 15
"L,A",	# 16
"R,D",	# 17
undef,	# 18
"R,IO",	# 19
"H",	# 20
"IA",	# 21
"FOLD,D",	# 22
undef,	# 23
"L,M",	# 24
"MLJK",	# 25
"MHL",	# 26
"MD",	# 27 IO diference store under ioreg byte select lines
"M,SP",	# 28
"D*BS",	# 29
"L13",	# 30
"J",	# 31 IO different: t<12:15>->ioreg
],
"ZR" => [
"", undef
],
"WS" => [
undef,	# 0
"WS1->LSA",	# 1
"WS2->LSA",	# 2
"WS,E->LSA",	# 3
"FN,J->LSA",	# 4
"FN,J,1->LSA",	# 5
"FN,MD->LSA",	# 6
"FN,MD,1->LSA",	# 7
],
"SF" => $sfformat,
"IV" => [
"",	# 0
"WL->IVD",	# 1
"WR->IVD",	# 2
"W->IVD",	# 3
"IA/4->A,IA",	# 4
"IA+2/4",	# 5
"IA+2",		# 6
"IA+0/2->A",	# 7
],
"AL" => $alformat,
"WM" => [
"",		# 0
"W->MMB",	# 1
"W67->MB",	# 2
"W67->LB",	# 3
"W27->PSW4",	# 4
"W->PSW0",	# 5
"WL->J",	# 6
"W->CHCTL",	# 7
"W,E->A(BUMP)",	# 8
"WL->G1",	# 9
"WR->G2",	# 10
"W->G",		# 11
"W->MMB(E)",	# 12
"WL->MD",	# 13
"WR->F",	# 14
"W->MD,F"	# 15
],
"UP" => [
"0", "3", "-", "+"
],
"MD" => [
"","MD"
],
"LB" => [
"","LB"
],
"MB" => [
"","MD"
],
"DG" => [
"",		# 0
"CSTAT->ADDER",	# 1
"HOT1->ADDER",	# 2
"G1-1",		# 3
"HOT1,G-1",	# 4
"G2-1",		# 5
"G-1",		# 6
"G1,2-1",	# 7
],
"UL" => $ulformat,
"UR" => $urformat,
"CE" => $ceformat,
"LX" => [	# different in IO mode
"",	# 0
"L",	# 1
"SGN",	# 2
"E",	# 3
"LRL",	# 4
"LWA",	# 5
"4",	# 6
"64C",	# 7
],
"TC" => $tcformat,
"RY" => $ryformat,
"AD" => [
undef,	# 0
"",	# 1
"BCFO",	# 2
undef,	# 3
"BCO",	# 4
"BC->C",	# 5
"BC1B",		# 6
"BC8",		# 7
"DHL",		# 8
"DC0",		# 9
"DDC0",		# 10
"DHH",		# 11
"DCBS",		# 12
undef, undef, undef	# 13-15
],
"AB" => $abformat,
"BB" => $bbformat,
"UX" => [
"", undef
],
"SS" => $ssformat
};

sub print_io
{
	my ($data) = @_;
	my ($format, $format2);
	if ($dtype eq "io") {
		$format = $io_format;
		$format2 = $io2_format;
	} else {
		$format = $cpu_format;
		$format2 = $cpu2_format;
	}
	for my $addr (sort {$a <=> $b} keys %$data) {
		my $e = $data->{$addr};
		next if $e->{type} ne $dtype;
		printf "%04x %s %s %s\n",
			$e->{address}, $e->{ros}, $e->{sheet}, $e->{cld};
		for my $f ( @$format) {
			my @kk = keys %$f;
			if ($#kk != 0) {
				die "help!\n";
			}
			my $k = $kk[0];
			my $b = $f->{$k};
			my $d;
			if (ref $b eq 'ARRAY') {
				my $dd = substr($e->{ros}, $$b[0], 1+$$b[1]-$$b[0]);
				$d = 0;
				for my $c ( split(//, $dd)) {
					$d <<= 1;
					$d |= 1 if ($c == 1);
				}
			} else {
				$d = substr($e->{ros}, $b, 1);
			}
			my $rest = "";
			my $foo = $format2->{$k};
			if (!defined($foo)) {
			} elsif (@$foo[$d] eq "") {
				next;
			} else {
				$rest = sprintf "\t; %s", @$foo[$d];
			}
			printf qq/\t%s%d%s\n/, $k, $d, $rest;
		}
	}
}

@ARGV = process_opts(@ARGV);
my $data = read_in_data_bin(shift @ARGV);
print_io($data);
