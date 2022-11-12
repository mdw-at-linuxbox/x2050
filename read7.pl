# read in data.json & s360.67, find rows w/ maximal diffs
use common::sense;
use JSON;
#use YAML::PP;

my $vflag;
my $aflag;
my @patterns;

my $dtype = '-';

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
				my @q = split(",", $f);
				$p = {};
				push @patterns, $p;
				$p->{bitoff} = $q[0];
				$p->{bitsize} = 1+$q[1]-$q[0];
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

sub read_in_data_json
{
	my ($f) = @_;
	open(my $fh, "<".$f) or die "Cannot read data.json from $f: $!\n";
	my $json = JSON->new;
	local $/;
	my $content = <$fh>;
	close $fh;
	my $h  = $content;
	return $json->decode($h);
}

sub read_uc2
{
	my ($f) = @_;
	my $r = {};
	open(my $fh, "<".$f) or die "Cannot read uc2 from $f: $!\n";
	while (my $l = <$fh>) {
		next if $l =~ /^#/;
		chomp $l;
		my @f = split("\t", $l);
		next if $#f < 3;
		my $e = {};
		$e->{address} = hex($f[0]);
		$e->{sheet} = $f[1];
		$e->{cld} = $f[2];
		$e->{type} = $f[3];
		$r->{$e->{address}} = $e;
	}
	close $fh;
	return $r;
}

sub make_amap
{
	my ($data) = @_;
	my $amap = {};
#	my $s = $ypp->dump_string($data);
	for my $k ( keys %$data ) {
		eval {
		$amap->{$k} = hex($k);
		};
		warn "bad data $k: $@\n" if $@;
	}
	return $amap;
}

sub print_it
{
	my ($data) = @_;
	my $amap = make_amap($data);
#	my $ypp = YAML::PP->new;
#	my $s = $ypp->dump_string($data);
	for my $k (sort {$amap->{$a} <=> $amap->{$b}} keys %$data) {
		my $element = $data->{$k};
		my $addr = $amap->{$k};
		my $sheet = $element->{'sheet'};
		my $ros = $element->{'ROS'};
		my $hb =make_hex_bytes_of($ros);
		printf "'h%04x: ros_out = 'h%s; // %s\n", $addr, $hb, $sheet;
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
	my ($data, $amap, $uc2, @patterns) = @_;
	my @r;
	for my $k (sort {$amap->{$a} <=> $amap->{$b}} keys %$data) {
		my $addr = $amap->{$k};
		next if $uc2->{$addr}->{type} ne $dtype;
		my $element = $data->{$k};
		my $sheet = $element->{'sheet'};
		my $ros = $element->{'ROS'};
		if (!is_a_match($addr, $ros, @patterns)) {
			next;
		}
		my $e = {};
		$e->{ros} = $ros;
		for my $ce (qw(address sheet cld type)) {
			$e->{$ce} = $uc2->{$addr}->{$ce};
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

@ARGV = process_opts(@ARGV);
die "need: -x bitstart,bitend\n" if $#patterns < 0;
#die "bad -x bitstart,bitend\n" if $bitsize <= 0;
#die "need -v value" if !defined($value);
print_patterns(@patterns);
my $data = read_in_data_json(shift @ARGV);
my $amap = make_amap($data);
my $uc2 = read_uc2(shift @ARGV);
my @candidates = find_candidates($data, $amap, $uc2, @patterns);
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
