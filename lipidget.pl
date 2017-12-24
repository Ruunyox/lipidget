#! /usr/bin/perl -w
#use strict;
#use warnings;

if (not @ARGV  or grep(/-h/,@ARGV))
{
	print "\n << LIPIDGET >>\n";
	print "\n Usage:\n";
	print "\n\t-s [keyword]\tsearch the LipidMaps database";
	print "\n\t-csv\tsave fetch to csv format";
	print "\n\t-mol\tsave fetch to mol format";
	print "\n\t-sdf\tsave fetch to sdf format";
	print "\n\t-tsv\tsave fetch to tsv format\n";
	exit;
}

my $id = "$ARGV[$#ARGV]";
our $database = "http://www.lipidmaps.org/data/LMSDRecord.php?Mode=File&LMID=";
our $datasearch = "http://www.lipidmaps.org/data/structure/LMSDSearch.php?Mode=ProcessTextSearch&OutputMode=File&OutputType=TSV&OutputQuote=Yes&Name=";

if ( grep(/\-csv/, @ARGV))
{
	our $ext = "csv";
	my $filename = join("","$id",".","$ext");
	my $url = join("","$database","$id","&OutputType=CSV&OutputQuote=Yes");
	my $dl = `wget -O "$filename" "$url"`;
	print $url;
}
if ( grep(/\-mol/, @ARGV))
{
	our $ext = "mol";
	my $filename = join("","$id",".","$ext");
	my $url = join("","$database","$id");
	my $dl = `wget -O $filename $url`;
}
if ( grep(/\-sdf/, @ARGV))
{
	our $ext = "sdf";
	my $filename = join("","$id",".","$ext");
	my $url = join("","$database","$id");
	my $dl = `wget -O $filename $url`;
}
if ( grep(/\-tsv/, @ARGV))
{
	our $ext = "tsv";
	my $filename = join("","$id",".","$ext");
	my $url = join("","$database","$id");
	my $dl = `wget -O $filename $url`;
	print $url;
}

if (grep(/\-s/, @ARGV))
{
	print "\n=> Searching for $id...\n\n";
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
	print "\n=> @{[$cnt-1]} line(s) read.\n";
	close $input;	
}


