#! /usr/bin/perl -w
use strict;
use warnings;
use autodie;

sub load_dat {
	my($input, $delim) = @_;
	my $cnt = 0;
	my @headers = ();
	my @values  = ();
	while(<$input>)
	{
		if ($cnt eq 0)
		{
			$_=~s/\"$delim\"/\"!!\"/g;
			$_=~s/\"//g;
			@headers=split("!!",$_);
		}
		if ($cnt eq 1)
		{
			$_=~s/\"$delim\"/\"!!\"/g;
			$_=~s/\"//g;
			@values=split("!!",$_);
		}
		$cnt = $cnt +1;		
	}
	return (\@headers, \@values);
}

sub show_dat {
	my($first, $second) = @_;
	my @headers = @{ $first };
	my @values = @{ $second };
	for (my $i=0;$i<$#headers;$i++)
	{
		print "\e[31m";
		printf("\n%-20s\e[32m%-20s","$headers[$i]","$values[$i]");
		print "\e[31m";
	}
}

if (not @ARGV  or grep(/-h/,@ARGV))
{
	print "\n << LIPIDGET >>\n";
	print "\n Usage: lipidget [opts] [str or LMID]\n";
	print "\n\t-s [str]         search the LipidMaps database";
	print "\n\t--csv [LMID]\t save fetch to csv format";
	print "\n\t--mol [LMID]\t save fetch to mol format";
	print "\n\t--sdf [LMID]\t save fetch to sdf format";
	print "\n\t--tsv [LMID]\t save fetch to tsv format\n";
	exit;
}

my $id = "$ARGV[$#ARGV]";
our $database = "http://www.lipidmaps.org/data/LMSDRecord.php?Mode=File&LMID=";
our $datasearch = "http://www.lipidmaps.org/data/structure/LMSDSearch.php?Mode=ProcessTextSearch&OutputMode=File&OutputType=TSV&OutputQuote=Yes&Name=";

if ( grep(/\-\-csv/, @ARGV))
{
	print ">>> Grabbing csv ... ";
	our $ext = "csv";
	my $filename = join("","$id",".","$ext");
	my $url = join("","$database","$id","&OutputType=CSV&OutputQuote=Yes");
	my $delim = ",";
	open my $input, "-|", "wget -q -O - \"$url\"";
	my ($first, $second) = load_dat($input,$delim);	
	show_dat($first,$second);
	close $input;
	print "Done.\n";
}
if ( grep(/\-\-tsv/, @ARGV))
{
	print ">>> Grabbing tsv ... ";
	our $ext = "tsv";
	my $filename = join("","$id",".","$ext");
	my $url = join("","$database","$id");
	my $delim = "\t";
	open my $input, "-|", "wget -q -O - \"$url\"";
	my ($first, $second) = load_dat($input,$delim);	
	show_dat($first,$second);
	close $input;
	print "Done.\n";
}
if ( grep(/\-\-sdf/, @ARGV))
{
	print ">>> Grabbing sdf ... ";
	our $ext = "sdf";
	my $filename = join("","$id",".","$ext");
	my $url = join("","$database","$id");
	my $dl = `wget -O \"$filename\" \"$url\"`;
	print "Done.\n";
}
if ( grep(/\-\-mol/, @ARGV))
{
	print ">>> Grabbing mol ... ";
	our $ext = "mol";
	my $filename = join("","$id",".","$ext");
	my $url = join("","$database","$id");
	my $dl = `wget -O \"$filename\" \"$url\"`;
	print "Done.\n";
}

if (grep(/\-s/, @ARGV) and not grep(/\-\-sdf/, @ARGV))
{
	print "\e[36m";
	print "\n>>> Searching for $id...\n\n";
	my $url = join("","$datasearch","$id");
	my $filename = join("","$id","_search.txt");
	my @headers = ();
	my $cnt = 0;
	open my $input, "-|", "wget -q -O - \"$url\"";
	while (<$input>)
	{
		if ( $cnt eq 0)
		{
			my @line=split(/\t/,"$_");
			push(@headers, $line[0]);
			push(@headers, $line[1]);
			$headers[0]=~s/\"//g;
			$headers[1]=~s/\"//g;
			print "\e[31m";
			print "$headers[0]\t\t";
			print "\e[32m";
			print "$headers[1]\n\n";
			print "\e[31m";
		}
		else
		{
			my @line=split(/\t/,"$_");
			my @res =($line[0],$line[1]);
			$res[0]=~s/\"//g;
			$res[1]=~s/\"//g;
			print "\e[31m";
			print "$res[0]\t";
			print "\e[32m";
			print "$res[1]\n";
			print "\e[31m";
		}	
		$cnt = $cnt + 1;
	}
	print "\e[36m";
	print "\n>>> @{[$cnt-1]} Entries Found\n";
	close $input;	
}
