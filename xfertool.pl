#!/usr/bin/perl

use strict;
use warnings;
use Net::SCP;
use File::Find;
use File::Rsync;
use Data::Dumper;
use Config::Simple;

my @clusters = ('');

my $config = shift;
my $user = shift;
my @files = ();
my @destinations = ();
my $cfg = new Config::Simple($config);
my $rsync = File::Rsync->new( recursive => 1);

# Exit if user root runs the script.
if ($> == 0) {
    die 'Do not run as root';
}

# Exit if config or destination are not provided.
if (!defined($config) || !defined($user)) {
    die 'Usage: ./xfertool.pl $config $user';
}

# Parse the config file
my $sources = $cfg->param(-block => 'move');

# Compile a list of files from the given directories in the config.
foreach my $key (keys %{ $sources }) {
    find(\&wanted, $key);
    push @destinations, $sources->{$key};
}

sub wanted {
    push @files, $File::Find::name;
    return;
}

# Upload files to each destination
foreach my $d (@destinations) {
    foreach my $c (@clusters) {
        # Generate hostname for SCP based on given clusters
        my $host = "$c-host.com";

        # Do SCP stuff: login, cwd to given destination, and upload
        # files from list previously compiled
        my $scp = Net::SCP->new($host);
        $scp->login($user);
        $scp->cwd($d);
        foreach my $f (@files) {
            #$scp->put($_);
            #print "Uploaded $f => $d on $host\n";
        }
    }
}
