# read data.json, write out data.bin, to be read in verilog w/ $readmemb
# with -uc2 file - read in extra data "s360.67") to get sheet coords.
# format of uc2: hexaddr sheet box mode
use common::sense;
use JSON;

my $uflag;

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
		if ($j eq "-u") {
			$f = sub {
				my ($f) = @_;
				my @q = split(",", $f);
				$uflag = $f;
			};
			next;
		}
#		if ($j eq "-n") {
#			++$nflag;
#			next;
#		}
		push @r, $j;
	}
	return @r;
}

sub read_it_in
{
	local $/;
	my $data = <>;
	my $json = JSON->new;
	my $r = $json->decode($data);
	return $r;
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

sub cpu_bits_to_memb_format
{
	my ($ros) = @_;
	substr($ros, 84, 0) = '_';	# SS
	substr($ros, 83, 0) = '_';	# spare?
	substr($ros, 78, 0) = '_';	# BB
	substr($ros, 72, 0) = '_';	# AB
	substr($ros, 68, 0) = '_';	# AD
	substr($ros, 65, 0) = '_';	# RY
	substr($ros, 64, 0) = '_';	# TC
	substr($ros, 61, 0) = '_';	# LX
	substr($ros, 57, 0) = '_';	# CE
	substr($ros, 56, 0) = '_';	# parity 56-89
	substr($ros, 54, 0) = '_';	# UR
	substr($ros, 52, 0) = '_';	# UL
	substr($ros, 49, 0) = '_';	# DG
	substr($ros, 48, 0) = '_';	# MB
	substr($ros, 47, 0) = '_';	# LB
	substr($ros, 46, 0) = '_';	# MD
	substr($ros, 44, 0) = '_';	# UP
	substr($ros, 40, 0) = '_';	# WM
	substr($ros, 35, 0) = '_';	# AL
	substr($ros, 32, 0) = '_';	# IV
	substr($ros, 31, 0) = '_';	# parity 31-55
	substr($ros, 28, 0) = '_';	# SF
	substr($ros, 25, 0) = '_';	# WS
	substr($ros, 24, 0) = '_';	# spare
	substr($ros, 19, 0) = '_';	# TR
	substr($ros, 16, 0) = '_';	# ZN
	substr($ros, 12, 0) = '_';	# ZF
	substr($ros, 6, 0) = '_';	# ZP
	substr($ros, 4, 0) = '_';	# MV
	substr($ros, 1, 0) = '_';	# LU
					# parity bits 0-30
	return $ros;
}

sub ones_bits_to_memb_format
{
	my ($ros) = @_;
	substr($ros, 57, 0) = '_';	# B3
	substr($ros, 56, 0) = '_';	# parity 56-89
	substr($ros, 32, 0) = '_';	# B2
	substr($ros, 31, 0) = '_';	# parity 31-55
	substr($ros, 1, 0) = '_';	# B1
					# parity bits 0-30
	return $ros;
}

sub io_bits_to_memb_format
{
	my ($ros) = @_;
	substr($ros, 84, 0) = '_';	# SS
	substr($ros, 83, 0) = '_';	# spare?
	substr($ros, 78, 0) = '_';	# BB
	substr($ros, 72, 0) = '_';	# AB
	substr($ros, 71, 0) = '_';	# unused
	substr($ros, 68, 0) = '_';	# CL
	substr($ros, 65, 0) = '_';	# RY
	substr($ros, 64, 0) = '_';	# TC
	substr($ros, 61, 0) = '_';	# LX
	substr($ros, 57, 0) = '_';	# CE
	substr($ros, 56, 0) = '_';	# parity 56-89
	substr($ros, 54, 0) = '_';	# UR
	substr($ros, 52, 0) = '_';	# UL
	substr($ros, 49, 0) = '_';	# MG
	substr($ros, 47, 0) = '_';	# CG
	substr($ros, 44, 0) = '_';	# MS
	substr($ros, 43, 0) = '_';	# HC
	substr($ros, 40, 0) = '_';	# WL
	substr($ros, 35, 0) = '_';	# AL
	substr($ros, 32, 0) = '_';	# CT
	substr($ros, 31, 0) = '_';	# parity 31-55
	substr($ros, 28, 0) = '_';	# SF
	substr($ros, 26, 0) = '_';	# SA
	substr($ros, 25, 0) = '_';	# CS
	substr($ros, 24, 0) = '_';	# spare
	substr($ros, 19, 0) = '_';	# TR
	substr($ros, 16, 0) = '_';	# ZN
	substr($ros, 12, 0) = '_';	# ZF
	substr($ros, 6, 0) = '_';	# ZP
	substr($ros, 4, 0) = '_';	# MV
	substr($ros, 1, 0) = '_';	# LU
					# parity bits 0-30
	return $ros;
}

sub print_it_out
{
	my ($data, $uc2) = @_;
	my $amap;
	for my $k ( keys %$data) {
		$amap->{$k} = hex($k);
	}
	for my $k (sort {$amap->{$a} <=> $amap->{$b}} keys %$data) {
		my $line = sprintf "@%03x", $amap->{$k};
		if (defined($data->{$k}->{CT})) {
		$line .= "  ".io_bits_to_memb_format($data->{$k}->{ROS});
		} elsif (defined($data->{$k}->{B1})) {
		$line .= "  ".ones_bits_to_memb_format($data->{$k}->{ROS});
		} else {
		$line .= "  ".cpu_bits_to_memb_format($data->{$k}->{ROS});
		}
		my $ue = $uc2->{hex($k)};
		if (defined($ue) && defined($ue->{cld}) && $ue->{cld} =~ m%\S%) {
			$line .= sprintf "    // %s %s",
				$ue->{sheet},
				$ue->{cld};
		} elsif (defined($data->{$k}->{sheet}) && $data->{$k}->{sheet} =~ m%\S%) {
			$line .= sprintf "    // %s", $data->{$k}->{sheet};
		}
		print "$line\n";
	}
}

@ARGV = process_opts(@ARGV);
my $data = read_it_in();
my $uc2 = read_uc2($uflag) if $uflag;
print_it_out($data, $uc2);
