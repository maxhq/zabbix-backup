#!/usr/bin/env perl
use File::Temp qw/ tempfile /;

my $tables = {}; # for each table, create a list of Zabbix versions that know it
my (undef, $tmpfile) = tempfile();

sub stop {
	my ($msg) = @_;
	print "ERROR: $msg\n";
	unlink $tmpfile;
	exit;
}

# Check for subversion client
my $svn = `which svn`;
stop("No subversion client found") unless $svn;

# List tags from subversion repo
my @tags = `svn ls 'svn://svn.zabbix.com/tags'`;
chomp @tags; # remove trailing newline
@tags = (map { $_ =~ s/\/$//; $_ } @tags); # remove trailing slash

# Sort tags as version numbers (http://www.perlmonks.org/?node_id=814026)
@tags = map {$_->[0]}
  sort {$a->[1] cmp $b->[1]}
  map {[$_, pack "C*", split /\./]} @tags;

for my $tag (@tags) {
	next if $tag < 1.4; # before Zabbix 1.4, schema was stored as pure SQL

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

print "----------------------------------------\n";
for my $tab (sort keys %$tables) {
	printf "%-25s %s - %s\n", $tab, $tables->{$tab}->[0], $tables->{$tab}->[-1];
}
