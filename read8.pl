# read in data.bin, find rows w/ maximal diffs
use common::sense;

my $vflag;
my $aflag;
my @patterns;

my $dtype = 'cpu';

my @patterns;

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
		if ($j eq "-v") {
			$f = sub {
				my ($f) = @_;
				my @q = split(",", $f);
if (!$p) {
die "Need -x before -v\n";
}
				$p->{value} = $f;
			};
			next;
		}
		if ($j eq "-x") {
			$f = sub {
				my ($f) = @_;
				$p = {};
				push @patterns, $p;
				if (got_range($p, $f)) {
				} else {
					my @q = split(",", $f);
					$p->{bitoff} = $q[0];
					$p->{bitsize} = 1+$q[1]-$q[0];
				}
			};
			next;
		}
		if ($j eq "-t") {
			$f = sub {
				my ($f) = @_;
				my @q = split(",", $f);
				$dtype = $f;
			};
			next;
		}
		if ($j eq "-a") {
			++$aflag;
			next;
		}
#		if ($j eq "-n") {
#			++$nflag;
#			next;
#		}
		if ($j eq "-v") {
			++$vflag;
			next;
		}
		if ($j eq "-i") {
			$dtype = 'io';
			next;
		}
#		if (!$prefix) {
#			$prefix = $j;
#			next;
#		}
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

sub print_it
{
	my ($data) = @_;
	for my $addr (sort {$a <=> $b} keys %$data) {
		my $element = $data->{$addr};
		my $sheet = $element->{'sheet'};
		my $cld = $element->{'cld'};
		my $ros = $element->{'ros'};
		my $hb =make_hex_bytes_of($ros);
		printf "'h%04x: ros_out = 'h%s; // %s\n", $addr, $hb, $sheet, $cld;
	}
}

sub is_a_match
{
	my ($addr, $ros, @patterns) = @_;
	for my $p ( @patterns) {
		my $dd = substr($ros, $p->{bitoff}, $p->{bitsize});
		my $d = 0;
		for my $c ( split(//, $dd)) {
			$d <<= 1;
			$d |= 1 if $c == 1;
		}
#	printf "addr=%04x d=%s value=%s\n", $addr, $d, $p->{value};
		return 0 if $d != $p->{value};
#	print "Extracted $dd from $ros at ".$p->{bitoff}." size ".$p->{bitsize}."\n";
	}
	return 1;
}

sub find_candidates
{
	my ($data, @patterns) = @_;
	my @r;
	for my $addr (sort {$a <=> $b} keys %$data) {
		my $element = $data->{$addr};
		next if $element->{type} ne $dtype;
		my $ros = $element->{'ros'};
		if (!is_a_match($addr, $ros, @patterns)) {
			next;
		}
		my $e = {};
		$e->{ros} = $ros;
		for my $ce (qw(address sheet cld type)) {
			$e->{$ce} = $data->{$addr}->{$ce};
		}
		push @r, $e;
	}
	return @r;
}

sub count_distance
{
	my ($x, $y, $mask) = @_;
	my $r = 0;
	my $q = ($x->{ros} ^ ~$y->{ros}) & $mask;
	for my $i ( 0..length($q)-1) {
		$r += (ord(substr($q,$i,1)) & 1);
	}
#print "   x=<".length($x->{ros}).">".unpack('H*', $x->{ros})."\n";
#print "   y=<".length($y->{ros}).">".unpack('H*', $y->{ros})."\n";
#print "mask=<".length($mask).">".unpack('H*', $mask)."\n";
#print "   q=<".length($q).">".unpack('H*', $q)."\n";
#print "r=$r\n\n";
	return $r;
}

sub filter_candidates
{
	my (@candidates) = @_;
	my @best;
	my $mask = "1" x 90;
	for my $p ( @patterns ) {
		for my $i ( $p->{bitoff} .. $p->{bitoff}+$p->{bitsize}-1 ) {
			substr($mask, $i, 1) = "0";
		}
	}
	substr($mask,0,1) = "0";
	substr($mask,31,1) = "0";
	substr($mask,56,1) = "0";
	my ($n) = 1+$#candidates;
	my $bestness = 0;
	for my $i (0..$n-2) {
my $x = $candidates[$i];
		for my $j ( $i+1..$n-1) {
#print "I=$i J=$j N=$n\n";
my $y = $candidates[$j];
my $distance = count_distance($x, $y, $mask);
$bestness += !$distance;
push @best, {"x" =>$x, "y" => $y, "distance" => $distance};
last if ($bestness >= 4);
		}
last if ($bestness >= 32);
	}
	return sort {$a->{distance} <=> $b->{distance}} @best;
}

sub print_candidates
{
	my @candidates = @_;
	for my $e ( @candidates ) {
		printf "%04x %s %s %s\n",
			$e->{address}, $e->{ros}, $e->{sheet}, $e->{cld};
	}
	print 1+$#candidates, " candidates\n";
}

sub print_patterns
{
	my (@patterns) = @_;
	for my $p ( @patterns) {
	my $mask = "0" x 90;
	for my $i ($p->{bitoff}..$p->{bitoff}+$p->{bitsize}-1) {
	substr($mask,$i,1) = "1";
	}
	printf "%04x %s\n", $p->{bitoff}, $mask;
	my $v = (0+$p->{value});
	my $j = $p->{bitoff} + $p->{bitsize};
	for my $i ( 0..$p->{bitsize}) {
		--$j;
		substr($mask,$j,1) = "0" if !($v & 1);
		$v >>= 1;
	}
	printf "%04x %s\n", $p->{bitoff}+$p->{bitsize}-1, $mask;
	}
}


my $fieldnames = {
"?" => 71,
"AB" => [72,77],
"AD" => [68,71],
"AL" => [35,39],
"BB" => [78,82],
"CE" => [57,60],
"CG" => [47,48],
"CL" => [68,70],
"CS" => 25,
"CT" => [32,34],
"DG" => [49,51],
"HC" => 43,
"IV" => [32,34],
"LB" => 47,
"LU" => [1,3],
"LX" => [61,63],
"MB" => 48,
"MD" => 46,
"MG" => [49,51],
"MS" => [44,46],
"MV" => [4,5],
"P" => 56,
"RY" => [65,67],
"SA" => [26,27],
"SF" => [28,30],
"SS" => [84,89],
"TC" => 64,
"TR" => [19,23],
"UL" => [52,53],
"UP" => [44,45],
"UR" => [54,55],
"UX" => 83,
"WL" => [40,42],
"WM" => [40,43],
"WS" => [25,27],
"ZF" => [12,15],
"ZN" => [16,18],
"ZP" => [6,11],
"ZR" => 24,
};

sub got_range
{
	my ($p, $f) = @_;
	my $value = undef;
	if ($f =~ m%[a-zA-Z]*([0-9]+)$%) {
		$value = substr($f, $-[1], $+[1]-$-[1], "");
	}
	my $x = $fieldnames->{uc($f)};
	return 0 if !$x;
	if (ref $x eq "ARRAY") {
		$p->{bitoff} = $$x[0];
		$p->{bitsize} = 1+$$x[1]-$$x[0];
		$p->{value} = $value if defined($value);
	} else {
		$p->{bitoff} = $x;
		$p->{bitsize} = 1;
	}
	return 1;
}


@ARGV = process_opts(@ARGV);
die "need: -x bitstart,bitend\n" if $#patterns < 0;
#die "bad -x bitstart,bitend\n" if $bitsize <= 0;
#die "need -v value" if !defined($value);
print_patterns(@patterns);
my $data = read_in_data_bin(shift @ARGV);
my @candidates = find_candidates($data, @patterns);
#print_candidates(@candidates);
if (!$#candidates) {
print "this value is only used once\n";
print_candidates(@candidates);
exit(0);
}
if ($aflag) {
	print "\n";
	print_candidates(@candidates);
	exit(1);
}
my @best = filter_candidates(@candidates);
print 1+$#candidates." from filter\n";
print 1+$#best." best matches\n";
my @best_5 = @best;
if ($#best_5 >= 5) {
	@best_5 = @best_5[0..4];
}
print 1+$#best_5." at most 5\n";
for my $b ( @best_5 ) {
	print "\ndistance=".$b->{distance}."\n";
	print_candidates($b->{x}, $b->{y});
}
