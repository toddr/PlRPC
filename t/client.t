# -*- perl -*-
#

require 5.004;
use strict;
use File::Spec; # File::Spec was first released with perl 5.00405

require "t/lib.pl";


my $numTests = 10;
my $numTest = 0;




my($handle, $port);
if (@ARGV) {
    $port = $ARGV[0];
} else {
    ($handle, $port) = Net::Daemon::Test->Child($numTests,
						$^X, '-Iblib/lib',
						'-Iblib/arch',
						't/server', '--mode=single',
						'--debug', '--timeout', 60);
}

my @opts = ('peeraddr' => '127.0.0.1', 'peerport' => $port, 'debug' => 1,
	    'application' => 'CalcServer', 'version' => 0.01,
	    'timeout' => 20);
my $client;

# Making a first connection and closing it immediately
open(my $log_fh, '>>', File::Spec->devnull());
Test(eval { RPC::PlClient->new(@opts, 'logfile' => $log_fh) })
    or print "Failed to make first connection: $@\n";

RunTests(@opts);
eval { $handle->Terminate() } if $handle;
