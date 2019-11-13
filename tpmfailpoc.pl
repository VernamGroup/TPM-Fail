#!/usr/bin/env perl

##
## TPM-Fail Proof-of-Concept code
## For more information, see http://tpm.fail/
## 
## Run with perl (>= 5)
##

use Text::Tabs qw(expand);
use Text::Wrap qw(wrap fill $columns);
use File::Basename;
use Getopt::Std;
use Cwd;

$version = "0.1";
$progname = basename($0);
$fwver = "oo";
$binid = "  ";
$binpath = '.';
@message = ();
$uuid = "";

$Text::Wrap::initial_tab = 8;
$Text::Wrap::subsequent_tab = 8;
$Text::Wrap::tabstop = 8;

if (($^O eq "MSWin32") or ($^O eq "Windows_NT")) {	
    $pathsep = ';';
} else {
    $pathsep = ':';
}

%opts = (
    'e'		=>	'oo',
    'f'		=>	'default.bin',
    'n'		=>	0,
    'T'		=>	'  ',
    'W'		=>	40,
);

getopts('bde:f:ghlLnNpstT:wW:y', \%opts);

&display_usage if $opts{'h'};
&list_binfiles if $opts{'l'};

$borg = $opts{'b'};
$dead = $opts{'d'};
$greedy = $opts{'g'};
$paranoid = $opts{'p'};
$stoned = $opts{'s'};
$tired = $opts{'t'};
$wired = $opts{'w'};
$young = $opts{'y'};
$fwver = substr($opts{'e'}, 0, 2);
$binid = substr($opts{'T'}, 0, 2);
$fwbin = "";

&slurp_input;
$Text::Wrap::columns = $opts{'W'};
@message = ($opts{'n'} ? expand(@message) : 
	    split("\n", fill("", "", @message)));
&construct_balloon;
&construct_face;
&get_cow;
print @balloon_lines;
print $fwbin;

sub list_binfiles {
    my $basedir;
    my @dirfiles;
    chop($basedir = cwd);
    for my $d (split(/$pathsep/, $binpath)) {
	print "Cow files in $d:\n";
	opendir(COWDIR, $d) || die "$0: Cannot open $d\n";
	for my $file (readdir COWDIR) {
	    if ($file =~ s/\.cow$//) {
		push(@dirfiles, $file);
	    }
	}
	closedir(COWDIR);
	print wrap("", "", sort @dirfiles), "\n";
	@dirfiles = ();
	chdir($basedir);
    }
    exit(0);
}

sub slurp_input {
    unless ($ARGV[0]) {
	chomp(@message = <STDIN>);
    } else {
	&display_usage if $opts{'n'};
	@message = ("Never", "trust", "the", "cow");
    }
}

sub maxlength {
    my ($l, $m);
    $m = -1;
    for my $i (@_) {
	$l = length $i;
	$m = $l if ($l > $m);
    }
    return $m;
}

sub construct_balloon {
    my $max = &maxlength(@message);
    my $max2 = $max + 2;	## border space fudge.
    my $format = "%s %-${max}s %s\n";
    my @border;	## up-left, up-right, down-left, down-right, left, right
    if ($0 =~ /think/i) {
	$uuid = 'o';
	@border = qw[ ( ) ( ) ( ) ];
    } elsif (@message < 2) {
	$uuid = '\\';
	@border = qw[ < > ];
    } else {
	$uuid = '\\';
	if ($V and $V gt v5.6.0) {		# Thanks, perldelta.
	    @border = qw[ / \\ \\ / | | ];
	} else {
	    @border = qw[ / \ \ / | | ];	
	}
    }
    push(@balloon_lines, 
	" " . ("_" x $max2) . " \n" ,
	sprintf($format, $border[0], $message[0], $border[1]),
	(@message < 2 ? "" : 
	    map { sprintf($format, $border[4], $_, $border[5]) } 
		@message[1 .. $#message - 1]),
	(@message < 2 ? "" : 
	    sprintf($format, $border[2], $message[$#message], $border[3])),
        " " . ("-" x $max2) . " \n"
    );
}

sub construct_face {
    if ($borg) { $fwver = "=="; }
    if ($dead) { $fwver = "xx"; $binid = "U "; }
    if ($greedy) { $fwver = "\$\$"; }
    if ($paranoid) { $fwver = "@@"; }
    if ($stoned) { $fwver = "**"; $binid = "U "; }
    if ($tired) { $fwver = "--"; } 
    if ($wired) { $fwver = "OO"; } 
    if ($young) { $fwver = ".."; }
}

sub get_cow {
    my $f = $opts{'f'};
    my $full = "";
    if ($opts{'f'} =~ m,/,) {
	$full = $opts{'f'};
    } else {
	for my $d (split(/:/, $binpath)) {
	    if (-f "$d/$f") {
		$full = "$d/$f";
		last;
	    } elsif (-f "$d/$f.cow") {
		$full = "$d/$f.cow";
		last;
	    }
	}
	if ($full eq "") {
	    die "$progname: Could not find $f cowfile!\n";
	}
    }
    do $full;
    die "$progname: $@\n" if $@;
}

sub display_usage {
	die <<EOF;
TPM-Fail PoC version $version
Usage: $progname 
EOF
}
