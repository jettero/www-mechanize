package main;

require 5.008000;

use strict;
use warnings;
use ExtUtils::MakeMaker qw( WriteMakefile );
use File::Spec;
use Getopt::Long;

my $live = 1;
my $local = 1;
GetOptions(
    'live!'         => \$live,
    'local!'        => \$local,
    'all'           => sub { print "All tests are on by default.  This option is deprecated.\n" },
    'mech-dump!'    => sub { print "mech-dump is always installed now.  This option is deprecated.\n" },
) or exit 1;

my @tests = glob File::Spec->catfile( 't', '*.t' );
push( @tests, glob File::Spec->catfile( 't', 'local', '*.t' ) ) if $local;
push( @tests, glob File::Spec->catfile( 't', 'live', '*.t' ) ) if $live;
push( @tests, glob File::Spec->catfile( 't', 'mech-dump', '*.t' ) );

my $parms = {
    NAME            => 'WWW::Mechanize',
    VERSION_FROM    => 'lib/WWW/Mechanize.pm', # finds $VERSION
    ABSTRACT_FROM   => 'lib/WWW/Mechanize.pm', # retrieve abstract from module
    AUTHOR          => 'Andy Lester <andy@petdance.com>',
    EXE_FILES       => [ 'bin/mech-dump' ],
    PREREQ_PM       => {
        'Carp'                      => 0,
        'File::Temp'                => 0,
        'FindBin'                   => 0,
        'Getopt::Long'              => 0,
        'HTML::Form'                => 1.038,
        'HTML::HeadParser'          => 0,
        'HTML::Parser'              => 3.33,
        'HTML::TokeParser'          => 2.28,
        'HTML::TreeBuilder'         => 0,
        'HTTP::Daemon'              => 0,
        'HTTP::Request'             => 1.30,
        'HTTP::Server::Simple'      => 0.35,
        'HTTP::Server::Simple::CGI' => 0,
        'HTTP::Status'              => 0,
        'LWP'                       => 5.829,
        'LWP::UserAgent'            => 5.829,
        'Pod::Usage'                => 0,
        'Test::More'                => 0.34,
        'Test::Warn'                => 0.11,
        'URI'                       => 1.36,
        'URI::URL'                  => 0,
        'URI::file'                 => 0,
    },
    test            => { TESTS => join( ' ', @tests ) },
    clean           => { FILES => 'WWW-Mechanize-*' },
};

if ( $^O !~ /Win32/ ) {
}

if ( $ExtUtils::MakeMaker::VERSION ge '6.45_01' ) {
    $parms->{META_MERGE} = {
        resources => {
            license     => 'http://dev.perl.org/licenses/',
            homepage    => 'http://code.google.com/p/www-mechanize/',
            bugtracker  => 'http://code.google.com/p/www-mechanize/issues/list',
            Repository  => 'http://code.google.com/p/www-mechanize/source',
            MailingList => 'http://groups.google.com/group/www-mechanize-users',
        }
    };
    $parms->{LICENSE} = 'perl';
}
if ( $ExtUtils::MakeMaker::VERSION ge '6.47_02' ) {
    $parms->{MIN_PERL_VERSION} = 5.008;
}


eval { require LWP; };
if (!$@) {
    if ( ! LWP::Protocol::implementor('https') ) {
        print <<EOT;

It looks like you don't have SSL capability (like IO::Socket::SSL) installed. 
You will not be able to process https:// URLs correctly.

EOT
    }
}

my @missing;
my @nice = qw( Test::Pod Test::Memory::Cycle Test::Warn Test::Taint );
for my $nice ( @nice ) {
    eval "require $nice";
    push( @missing, $nice ) if $@;
}

if ( @missing ) {
    @missing = map { "\t$_\n" } @missing;
    print <<EOT;

WWW::Mechanize likes to have a lot of test modules for some of its tests.
The following are modules that would be nice to have, but not required.

@missing

EOT
}

WriteMakefile( %$parms );

sub MY::postamble {
    return <<'MAKE_FRAG';
.PHONY: tags critic

tags:
	ctags -f tags --recurse --totals \
		--exclude=blib \
		--exclude=.svn \
		--exclude='*~' \
		--languages=Perl --langmap=Perl:+.t \

critic:
	perlcritic -1 -q -profile perlcriticrc bin/ lib/ t/

MAKE_FRAG
}

1;
