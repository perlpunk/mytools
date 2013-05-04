#!/usr/bin/perl
use strict;
use warnings;
use Storable;
use Data::Dumper;
use Getopt::Long;
no warnings 'once';
local $Storable::Deparse = 1;
local $Data::Dumper::Deparse = 1;
local $Data::Dumper::Indent = 1;
if ($ENV{STORABLE_EVAL}){
    $Storable::Eval=1;
}
GetOptions(
    "size" => \my $size,
);
if ($size) {
    require Devel::Size
}
unless (@ARGV) {
    print <<"EOM";
Usage:
$0 file.storable
$0 file.storable --size # calculates memory usage of the data structure
STORABLE_EVAL=1 $0 file # to activate eval
EOM
    exit;
}
my ($file) = @ARGV;
if (!defined $file or !-r $file) {
    die "File '$file' does not exist";
}
unless ($ENV{STORABLE_EVAL}) {
    print "eval deactivated, use `STORABLE_EVAL=1 $0` to activate ist\n";
}
my $data = retrieve $file;
print __PACKAGE__.':'.__LINE__.$".Data::Dumper->Dump([\$data], ['data']);
if ($size) {
    my $total_size = Devel::Size::total_size($data);
    print "Size: $total_size\n";
}

__END__

=pod

=head1 NAME

storable_retrieve

=head1 DESCRIPTION

Retrieves data from a Storable file and dumps out with Data::Dumper.

=head1 USAGE

    storable_retrieve.pl file.storable
    storable_retrieve.pl file.storable --size # calculates memory usage of the data structure

If the data contains code, set environment variable STORABLE_EVAL to 1

    STORABLE_EVAL=1 storable_retrieve.pl file.storable
