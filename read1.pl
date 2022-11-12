# read in data.json write out prospective verilog code (big-big-endian)
use common::sense;
use JSON;
use YAML::PP;

sub read_it_in
{
	my $json = JSON->new;
	local $/;
	my $content = <>;
	my $h  = $content;
	return $json->decode($h);
}

sub make_hex_bytes_of
{
	my ($ros) = @_;
	my $ros2 = $ros;
	my $final_length = ((length($ros)) + 3)>>2;
	while (length($ros2) % 8) {
		$ros2 .= "0";
	}
	$ros2 = join("", reverse (split //, $ros2));
	my $row_data = pack ('B*', $ros2);
	my $r = unpack('H*', $row_data);
	$r = substr($r, -$final_length);
	return $r;
}

sub print_it
{
	my ($data) = @_;
	my $amap = {};
	my $ypp = YAML::PP->new;
#	my $s = $ypp->dump_string($data);
	for my $k ( keys %$data ) {
		eval {
		$amap->{$k} = hex($k);
		};
		warn "bad data $k: $@\n" if $@;
	}
	for my $k (sort {$amap->{$a} <=> $amap->{$b}} keys %$data) {
		my $element = $data->{$k};
		my $addr = $amap->{$k};
		my $sheet = $element->{'sheet'};
		my $ros = $element->{'ROS'};
		my $hb =make_hex_bytes_of($ros);
		printf "'h%04x: ros_out = 'h%s; // %s\n", $addr, $hb, $sheet;
	}
}

my $data = read_it_in();
print_it($data);
