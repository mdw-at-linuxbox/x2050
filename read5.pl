# read data.json, print address of ros words w/ "extra" data (bits 90+)
use common::sense;
use JSON;

sub read_it_in
{
	local $/;
	my $data = <>;
	my $json = JSON->new;
	my $r = $json->decode($data);
	return $r;
}

sub print_it_out
{
	my ($data) = @_;
	my $amap;
	for my $k ( keys %$data) {
		$amap->{$k} = hex($k);
	}
	for my $k (sort {$amap->{$a} <=> $amap->{$b}} keys %$data) {
		if (defined($data->{$k}->{"?1"}) || defined($data->{$k}->{"?1"}
)) {
printf " %03x", $amap->{$k};
}
	}
print "\n";
}

my $data = read_it_in();
print_it_out($data);
