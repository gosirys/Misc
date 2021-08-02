#!/usr/bin/perl

# Giovanni - HackLabs

# This script extracts the MX and NS records of the domains passed as input.
# From the NS results, (if possible) collects company IP range

# dig +short domain.com MX
#	 Extracts MX domain name and convert it to IP.
	
# dig +short domain.com NS
#	 Extracts NSs.
#	 If one of the NS has the domain name as part of the stringt:
#	 dig +short NS A
#	 Gets the IP.
#	 	 whois IP
#			 extracts: inetnum,netname,descr,NetRange,CIDR

# ------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------

$input  = $ARGV[0];
$output = $ARGV[1];

if (!$input) {
	die "\nPlease provide an input file: perl $0 input.txt\n\n";
}

open(INPUT, '<', $input);
if ($output) {
	open(OUTPUT, '>', $output);
}

while ($a =<INPUT>) {
	$a =~ s/\s+$//g;
	$a =~ s/^www\.//;
	$a =~ s/(.+)/$1./;
	push(@domains,$a);
}

my @outsourced = ();

foreach my $d(@domains) {
	yprint("\n\n\n------------------=========\n##########Domain: ".$d."\n");

			my $ns_ip = `dig +short $d A`;
			#yprint(" $d\n");
			my $whois_res = `whois $d`;
			print "\n\n$whois_res\n\n";
			if ($whois_res =~ /caesarsdomains\@caesars\.com/) {
				#print "\tcaesars shit\n";
			}

			while ($whois_res =~ /inetnum:\s+(.+)/ig) {
				yprint("\tinetnum: $1\n");
			}
			while ($whois_res =~ /netname:\s+(.+)/ig) {
				yprint("\tnetname: $1\n");
			}
			while ($whois_res =~ /descr:\s+(.+)/ig) {
				yprint("\tdescr: $1\n");
			}
			while ($whois_res =~ /NetRange:\s+(.+)/ig) {
				yprint("\tNetRange: $1\n");
			}
			while ($whois_res =~ /CIDR:\s+(.+)/ig) {
				yprint("\tCIDR: $1\n");
			}
			yprint("\n");


}


close(INPUT);
if ($output) {
	close(OUTPUT);
}


sub conv() {
	my $h = $_[0];
	@octets = ();
	$raw_addr = (gethostbyname($h))[4];
	@octets = unpack("C4", $raw_addr);
	$host_name = join(".", @octets);
	return($host_name);
}

sub yprint() {
	my $m = $_[0];
	print $m;
	if ($output) {
		print OUTPUT $m;
	}
}

# HackLabs Pty Ltd.