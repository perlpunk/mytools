#!/usr/bin/perl
use strict;
use warnings;
use Term::ANSIColor;
use Getopt::Long;
use JSON::Any;
use IO::All;
GetOptions(
    "type=s" => \my @types,
);
my @re2 = @ARGV;
if (not @types and not @re2) {
    print <<"EOM";
Usage:
tail log | $0 --type /path/to/type.yaml
tail log | $0 --type type.yaml # \$ENV{HOME}/.loghighlight/type.yaml
tail log | $0 --type foo.yaml --type bar.yaml
tail log | $0 "foo\\d" red
tail log | $0 --type foo.yaml --type bar.yaml "foo\\d" red
EOM
    exit;
}
my $j = JSON::Any->new;
my %re;
my @re;
my %re_compiled;
for my $type (@types) {
    unless (File::Spec->file_name_is_absolute($type)) {
        $type = "$ENV{HOME}/.loghighlight/$type";
    }
    my $json = io($type)->slurp;
    my $data = $j->Load($json);
    for my $item (@{ $data->{colors} }) {
        my $re = $item->{regex};
        my $name = $item->{name};
        my $qr = eval { qr/$re/ };
        next unless $qr;
        $re{ $name } = $item->{color};
        $re_compiled{ $name } = $qr;
        push @re, $name;
    }
}
for (my $i = 0; $i < @ARGV; $i += 2) {
    my $name = "cmdline $i";
    my $re = $re2[ $i ];
    my $qr = eval { qr/$re/ };
    next unless $qr;
    my $color = $re2[ $i + 1 ];
    $re_compiled{ $name } = $qr;
    $re{ $name } = $color;
}
while (<STDIN>) {
    for my $name (@re) {
        my $val = $re{ $name };
        my $qr = $re_compiled{ $name };
        eval {
            s/($qr)/colored("$1", $val)/eg;
        };
    }
    print;
}

__END__

=pod

=head1 NAME

loghighlight.pl

=head1 DESCRIPTION

Highlight parts of log lines with ansi colors.

=head1 EXAMPLE

    type.yaml:
    {
        "colors": [
            { "name": "post request", "regex": "\\bPOST\\b", "color": "bold" },
            { "name": "ipv4 address", "regex": "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}", "color": "magenta" }
        ]
    }

=head1 USAGE

    tail log | loghighlight.pl --type /path/to/type.yaml
    tail log | loghighlight.pl --type type.yaml # \$ENV{HOME}/.loghighlight/type.yaml
    tail log | loghighlight.pl --type foo.yaml --type bar.yaml
    tail log | loghighlight.pl "foo\\d" red
    tail log | loghighlight.pl --type foo.yaml --type bar.yaml "foo\\d" red

