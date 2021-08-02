#!/usr/bin/perl

# Google Safe Browsing Lookup Tool
# Use this tool to chech if domains are infected by malware or phishing crap

# 18/04/2012


#use lib 'lib';
use IO::Socket::SSL;
use Getopt::Long;
use Switch;
use Net::SMTP;

my($urls_total_count,$abs_counter_sites,$abs_counter_retrieved,$urls_count,$urls,$log,
   $phish_mal,$phishing,$malware,$safe) = (0,0,0,0,'',0,0,0,0,0);
my @sites = ();
my @temp = ();

my %conf = (
	'api_key' => '<apikey>', 
	'appver' 	=> '1.5.2',
	'pver' 	=> '3.0'
);

my %email_conf = (smtp_host	  => "<smtp host>",
			host		  => "<host>",
			smtp_username => "<smtp user>",
			smtp_password => "<smtp pass>",
			from		  => "<from>",
			to			  => "<to>"
			);

my @customer_to_scan = qw(google);


foreach my $c(@customer_to_scan) {
	my $input_file = "customers/".$c."/domains.txt";
	
	my $hour = (localtime)[2];
	my $day = (localtime)[3];
	my $month = (localtime)[4];
	my $year = 1900+(localtime)[5];
	$day = "0".$day if ($day < 10);
	$month = "0".$month if ($month < 10);
	my $time = $hour."-".$day."-".$month."-".$year;
	#print "ff: $time\n";exit;
	my $output_file = "customers/".$c."/reports/".$c."-report-".$time.".txt";


	open(INPUT, '<', $input_file) || die "\n[-] Can't open $input_file: ".$!."\n";
	open(OUTPUT, '>', $output_file) || die "\n[-] Can't create $output_file: ".$!."\n";
	
	while (my $a = <INPUT>) {
		$a =~ s/\s+$//;#print $a."\n";
		push(@sites,$a);
	}
	
	$urls_total_count = scalar(@sites);
	
	my $cc = 0;
	foreach my $s(@sites) {
		$cc++;
		$abs_counter_sites++;
		if (($cc <= 500)||($urls_total_count <= 500)) {
			push(@temp,$s."\r\n");
			if (($cc == 500)||($abs_counter_sites == $urls_total_count)) {
				request();
				splice(@temp,0);
				$cc = 0;
			}
		}		
	}

	yprint("\n\n[+] Stats:\n\tMalware+Pishing:\t$phish_mal\n\tMalware:\t\t$malware\n\tPishing:\t\t$phishing\n\tSafe:\t\t\t$safe\n\n");
	
	my $good = $safe;
	my $bad = $phish_mal+$malware+$phishing;
	my $mess_title = "Customer: ".$c." - Daily Report[".$time."] - Stats: $good Safe, $bad Unsafe";
	send_email($output_file,$mess_title);

}


sub send_email() {
	my ($data_file,$obj) = @_;
	my $boundary = 'frontier';
	my @attachment = ();

	open(DATA, '<', $data_file);
	while (<DATA>) { push (@attachment, $_); }
	close(DATA);

	$smtp = Net::SMTP->new($email_conf{'smtp_host'},
	                    Hello => $email_conf{'host'},
						Debug => 0,
	                    Timeout => 10) or die "pddd: $!\n";

	$smtp->auth($email_conf{'smtp_username'}, $email_conf{'smtp_password'}) or die "Can't authenticate: $!\n";

	$smtp->mail($email_conf{'from'});
	$smtp->recipient($email_conf{'to'});

	$smtp->data;

	$smtp->datasend("From: ".$email_conf{'from'}."\n");
	$smtp->datasend("To: ".$email_conf{'to'}."\n");
	$smtp->datasend("Subject: ".$obj."\n");
	$smtp->datasend("MIME-Version: 1.0\n");
	$smtp->datasend("Content-type: multipart/mixed;\n\tboundary=".$boundary."\n");
	$smtp->datasend("\n");
	$smtp->datasend("--$boundary\n");
	$smtp->datasend("Content-type: text/plain\n");
	$smtp->datasend("Content-Disposition: quoted-printable\n");
	$smtp->datasend("\nDaily generated report for Malware and Phishing\n$obj\n");
	$smtp->datasend("--$boundary\n");
	$smtp->datasend("Content-Type: application/text; name=".$data_file."\n");
	$smtp->datasend("Content-Disposition: attachment; filename=".$data_file."\n");
	$smtp->datasend("\n");
	$smtp->datasend("@attachment\n");
	$smtp->datasend("--$boundary--\n");
	$smtp->dataend;
	$smtp->quit;	
}





sub request() {
	my $urls;
	$urls_count = scalar(@temp);
	my $rt = 0;
	foreach my $t(@temp) {
		$urls .= $t;		
	}
	
	$urls =~ s/\r\n$//;
	$urls = $urls_count."\r\n".$urls;
	
	my $data = "POST /safebrowsing/api/lookup?client=firefox&apikey=".$conf{'api_key'}."&appver=".$conf{'appver'}."&pver=".$conf{'pver'}." HTTP/1.1\r\n".
	            "Host: sb-ssl.google.com\r\n".
			 		"Content-length: ".length($urls)."\r\n".
	            "User-Agent: tet\r\n".
	            "Connection: close\r\n\r\n".
			 $urls."\r\n\r\n";
			#print "\n\n$data\n\n";
	my $socket = IO::Socket::SSL->new("sb-ssl.google.com:443") || die "aaaaa: ".$!;
	print $socket $data;
	
	my($stop,$ccc,$none,$counter2) = (0,0,0,-1);
	
	while ((my $e = <$socket>)&&($stop != 1)) {#print "\t$e\n";
		$ccc++;
		if ($e =~ /HTTP\/1\.1 204 No Content|HTTP\/1\.1 400 Bad Request/) {
			$stop = 1;
			if ($e =~ /204 No Content/) {
				$none = 1;
			}
		}
		if ($ccc > 10) {
			if ($e =~ /phishing|malware|ok/) {
				$counter2++;
				$abs_counter_retrieved++;
				my $t = $temp[$counter2];
				$t =~ s/\r\n$//;
				yprint("[".$abs_counter_retrieved."/".$urls_total_count."] ".$t."\t".$e);
				
				switch ($e)  {
					case /phishing,malware/ 	{ $phish_mal++; }
					case /phishing/ 		{ $phishing++;}
					case /malware/ 		{ $malware++;}
					case /ok/ 			{ $safe++;}
					
				}	
			}
		}
	}
	
	if ($none == 1) {
		yprint("[!] All hosts passed do not contain threats!\n\n");
		foreach my $t(@temp) {
			$t =~ s/\s+$//;
			$abs_counter_retrieved++;
			yprint("[".$abs_counter_retrieved."/".$urls_total_count."] ".$t."\tok\n");
			$safe++;
		}
	}

	yprint("\n");
	splice(@temp,0);	
}

sub yprint() {
	my $text = $_[0];
	#if ($log == 1) {
		print OUTPUT $text;
	#}
	print $text;
}
