# -*- perl -*-

use strict;

use ExtUtils::MakeMaker;
use Config;

$| = 1;


my %prereq;
sub CheckModule ($;$$) {
    my($module, $version, $package) = @_;
    $package ||= $module;
    $prereq{$module} = $version || 0;
    if ($version) {
        print "Checking for $package, $version or later ... ";
        eval "use $module $version";
        if ($@) {
            print("\nYou don't have installed the $package package,",
                  " version $version or later.\n");
            return 0;
        }
    } else {
        print "Checking for $package ... ";
        eval "use $module";
        if ($@) {
            print("\nYou don't have installed the $package package.\n");
            return 0;
        }
    }
    print "ok\n";
    return 1;
}


my $ok = 1;
$ok = 0 unless CheckModule("Storable");
$ok = 0 unless CheckModule("Net::Daemon", 0.13);
if (!$ok) {
    print <<"MESSAGE";

Missing modules are available from any CPAN mirror, for example
        ftp://ftp.funet.fi/pub/languages/perl/CPAN/modules/by-module

MESSAGE
}


# Check, if fork() is available. If so, we assume that syslog should
# be available too. Thankfull for any better recommendations ...
if ($Config::Config{'d_fork'} eq 'define') {
    print "Checking for Sys::Syslog ... ";
    eval { require Sys::Syslog };
    if ($@) {
	my $errmsg = $@;
	$errmsg =~ s/^/  /mg;
	if ($@ =~ /h2ph/) {
	    print STDERR <<"MSG";

While loading the Sys::Syslog module, I received the following error message:

$errmsg

Most probably this means that you did not run the h2ph script after
installing Perl. You can do this now by executing the commands

    cd /usr/include
    h2ph *.h */*.h */*/*.h


MSG
            exit 10;
        }
	my $reply = prompt(qq{

Your system looks like Unix, as you seem to have fork() available. However
I cannot load the Sys::Syslog module which should be working on any Unix
machine. Please check out the following error message:

$@

In either case, please contact the package author, joe\@ispsoft.de and
let him know your machine configuration (try "perl -V") and the above
error message.

Do you want to continue? }, "y");
	if ($reply !~ /y/i) {
	    exit 1;
	}
    } else {
	print "ok\n";
    }
}


# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
my %opts = (
    'NAME'	=> 'RPC::PlServer',
    'DISTNAME'  => 'PlRPC',
    'dist'      => { SUFFIX   => '.gz', DIST_DEFAULT => 'all tardist',
                     COMPRESS => 'gzip -9vf' },
    'VERSION_FROM' => 'lib/RPC/PlServer.pm', # finds $VERSION
    'LIBS'	=> [''],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '',     # e.g., '-I/usr/include/other'
    'clean'     => { 'FILES' => 'ndtest.prt t/*.cfg' }
);

if ($ExtUtils::MakeMaker::VERSION >= 5.43) {
    $opts{'AUTHOR'} = 'Jochen Wiedmann (joe@ispsoft.de)';
    $opts{'PREREQ_PM'} = \%prereq;
    $opts{'ABSTRACT'} = 'Perl Remote Method Invocation';
}

WriteMakefile(%opts);

package MY;

sub libscan { my($self, $path) = @_; ($path =~ /\~$/) ? undef : $path }

sub postamble {
    <<"END_OF_POSTAMBLE";
pm_to_blib: README

README: lib/RPC/PlServer.pm
\tperldoc -t lib/RPC/PlServer.pm >README

END_OF_POSTAMBLE
}
