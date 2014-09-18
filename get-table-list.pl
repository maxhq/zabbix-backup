#!/usr/bin/env perl
# NAME
#     get-table-list.pl - List current and historic Zabbix database tables 
#
# SYNOPSIS
#     This is mainly a helper script for developing the backup script.
#
#     It connects to svn://svn.zabbix.com (using Subversion client "svn") and 
#     fetches the schema definitions of all tagged Zabbix versions beginning
#     from 1.3.1 (this takes a while).
#
#     It then prints out a list of all tables together with the first and last
#     Zabbix version where they were used.
#
# HISTORY
#     v0.1 - 2014-09-19 First version
#
# AUTHOR
#     Jens Berthold (maxhq), 2014

use File::Temp qw/ tempfile /;

my $tables = {}; # for each table, create a list of Zabbix versions that know it
my (undef, $tmpfile) = tempfile();

sub stop {
	my ($msg) = @_;
	print "ERROR: $msg\n";
	unlink $tmpfile;
	exit;
}

# sort version numbers correctly
sub cmpver {
	my ($a, $b) = @_;
	
	# split version parts: 1.2.3rc1 --> 1  2  3rc1
	my @a_parts = split /\./, $a;
	my @b_parts = split /\./, $b;
	
	for (my $i=0; $i<scalar(@a_parts); $i++) {
		return 1 if $i >= scalar(@b_parts);
		# split number parts: 3rc1 --> 3  rc  1
		my ($a_num, $a_type, $a_idx) = $a_parts[$i] =~ m/^(\d+)(\D+)?(\d+)?$/;
		my ($b_num, $b_type, $b_idx) = $b_parts[$i] =~ m/^(\d+)(\D+)?(\d+)?$/;
		my $cmp;
		# 3 before 4
		$cmp = $a_num <=> $b_num;   return $cmp unless $cmp == 0;
		# 3rc1 before 3
		return -1 if     $a_type and not $b_type;
		return  1 if not $a_type and     $b_type;
		# a1 before b1
		$cmp = $a_type cmp $b_type; return $cmp unless $cmp == 0;
		# rc1 before rc2
		$cmp = $a_idx <=> $b_idx;   return $cmp unless $cmp == 0;
	}
	# 1.2 before 1.2.1
	return -1 if scalar(@a_parts) < scalar(@b_parts);
	# equal
	return 0;
}

# Check for subversion client
my $svn = `which svn`;
stop("No subversion client found") unless $svn;

# List tags from subversion repo
my @tags = `svn ls 'svn://svn.zabbix.com/tags'`;
chomp @tags; # remove trailing newline
@tags = (map { $_ =~ s/\/$//; $_ } @tags); # remove trailing slash
@tags = sort { cmpver($a,$b) } @tags;

for my $tag (@tags) {
	next if cmpver($tag, "1.3.1") < 0; # before Zabbix 1.3.1, schema was stored as pure SQL

	my $schema;
	my $subdir;

	printf "%-10s %s", $tag, "Searching schema...";
	# search in subdir /schema (<= 1.9.8) and /src for schema.(sql|tmpl)
	for my $sub (qw(schema src)) {
		my @files = `svn ls 'svn://svn.zabbix.com/tags/$tag/create/$sub' 2>/dev/null`;
		next unless @files; # directory not found?
		chomp @files;
		($schema) = grep /^schema\.(sql|tmpl)/, @files;
		$subdir = $sub;
		last;
	}
	if (!$schema) {
		print "\nNo schema found in tag $tag\n";
		next;
	}
	print " ($schema) Download... ";
	system("svn --force export svn://svn.zabbix.com/tags/$tag/create/$subdir/$schema $tmpfile >/dev/null");
	open my $fh, '<', $tmpfile or stop("Couldn't open temp file: $!"); 
	while (<$fh>) {
		chomp;
		next unless m/^TABLE/;
		my (undef, $table) = split /\|/;
		$tables->{$table} //= [];
		push @{$tables->{$table}}, $tag;
	}
	print " Done\n";
}

unlink $tmpfile;

#
# Print out results
#
print "\n\n";
print "TABLE                     FIRST USE    LAST USE\n";
print "-------------------------------------------------\n";
for my $tab (sort keys %$tables) {
	printf "%-25s %-10s - %s\n", $tab, $tables->{$tab}->[0], $tables->{$tab}->[-1];
}
