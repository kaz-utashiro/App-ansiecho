package App::ansiecho;

our $VERSION = "0.01";

use v5.14;
use warnings;

use utf8;
use Encode;
use Data::Dumper;
{
    no warnings 'redefine';
    *Data::Dumper::qquote = sub { qq["${\(shift)}"] };
    $Data::Dumper::Useperl = 1;
}
use open IO => 'utf8', ':std';
use Pod::Usage;

use Moo;

has debug     => ( is => 'ro' );
has verbose   => ( is => 'ro', default => 1 );
has no_newline => ( is => 'ro' );

no Moo;

use App::ansiecho::Util;
use Text::ANSI::Printf qw(ansi_sprintf);

sub run {
    my $app = shift;
    local @ARGV = map { utf8::is_utf8($_) ? $_ : decode('utf8', $_) } @_;

    use Getopt::EX::Long qw(GetOptions Configure ExConfigure);
    ExConfigure BASECLASS => [ __PACKAGE__, "Getopt::EX" ];
    Configure qw(bundling no_getopt_compat pass_through);
    GetOptions($app, make_options "
	debug
	verbose    | v !
	no_newline | n !
	") || pod2usage();
    $app->initialize();
    print $app->param(@ARGV);
    print "\n" unless $app->no_newline;
}

sub initialize {
    my $app = shift;
}

use Getopt::EX::Colormap qw(ansi_pair ansi_code);

sub param {
    my $app = shift;
    my @in = @_;
    my @out;
    while (@in) {
	my $arg = shift @in;
	#
	# -r : raw code
	#
	if ($arg =~ /^-r(.+)?$/) {
	    my $spec = $1 || shift @in;
	    push @out, ansi_code($spec);
	    next;
	}
	#
	# -c : color
	#
	if ($arg =~ /^-c(\pP)?+(.+)?$/) {
	    my($delim, $param) = ($1, $2);
	    my($color, $string) = sub {
		if ($delim and $param and $param =~ $delim) {
		    return split $delim, $param, 2;
		}
		if ($param) {
		    @in >= 1 or die "$arg : format error.\n";
		    return ($param, shift @in);
		}
		@in >= 2 or die "$arg : parameter error.";
		splice @in, 0, 2;
	    }->();
	    my($s, $e) = ansi_pair($color);
	    push @out, $s . $string . $e;
	}
	#
	# -f : format
	#
	elsif ($arg =~ /^-f(.+)?$/) {
	    my $format = defined $1 ? $1 : shift @in;
	    $format = safe_interpolate($format);
	    @in = $app->param(@in);
	    my $n = $format =~ tr'%'%';
	    @in >= $n or die "$arg : not enough arguments.\n";
	    push @out, ansi_sprintf($format, splice @in, 0, $n);
	}
	#
	# string
	#
	else {
	    push @out, $arg;
	}
    }
    return @out;
}

sub safe_interpolate {
    $_[0] =~ s{
	( \\ x{[0-9a-f]+}
	| \\ x[0-9a-f]{2}
	| \\ N{.+?}
	| \\ c.
	| \\ o{\d+}
	| \\ \d\d\d
	| \\ .
        )
    }{ eval qq["$1"] or die }xger;
}

1;

__END__

=encoding utf-8

=head1 NAME

App::ansiecho - Command to produce ANSI terminal code

=head1 SYNOPSIS

    ansiecho [ options ] color-spec

=head1 DESCRIPTION

B<ansiecho> is a small command interface to produce ANSI terminal
code using L<Getopt::EX::Colormap> module.

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright 2021 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

