#!perl

use warnings;
use strict;
use Test::More tests => 32;

use lib 't/';
use TestServer;


BEGIN {
    delete @ENV{ grep { lc eq 'http_proxy' } keys %ENV };
    delete @ENV{ qw( IFS CDPATH ENV BASH_ENV ) };
    use_ok( 'WWW::Mechanize' );
}

eval "use Test::Memory::Cycle";
my $canTMC = !$@;

my $server      = TestServer->new;
my $pid         = $server->background;
my $server_root = $server->root;

my $agent = WWW::Mechanize->new;
isa_ok( $agent, 'WWW::Mechanize', 'Created object' );

my $response = $agent->get( "$server_root/" );
isa_ok( $response, 'HTTP::Response' );
isa_ok( $agent->response, 'HTTP::Response' );
ok( $response->is_success, 'Page read OK' );
ok( $agent->success, "Get webpage" );
is( $agent->ct, "text/html", "Got the content-type..." );
ok( $agent->is_html, "... and the is_html wrapper" );
is( $agent->title, 'WWW::Mechanize::Shell test page', 'Titles match' );

$agent->get( '/foo/' );
ok( $agent->success, 'Got the /foo' );
is( $agent->uri, "$server_root/foo/", 'Got relative OK' );
ok( $agent->is_html,'Got HTML back' );
is( $agent->title, 'WWW::Mechanize::Shell test page', 'Got the right page' );

$agent->get( '../bar/' );
ok( $agent->success, 'Got the /bar page' );
is( $agent->uri, "$server_root/bar/", 'Got relative OK' );
ok( $agent->is_html, 'is HTML' );
is( $agent->title, 'WWW::Mechanize::Shell test page', 'Got the right page' );

$agent->get( 'basics.html' );
ok( $agent->success, 'Got the basics page' );
is( $agent->uri, "$server_root/bar/basics.html", 'Got relative OK' );
ok( $agent->is_html, 'is HTML' );
is( $agent->title, 'WWW::Mechanize::Shell test page', 'Title matches' );
like( $agent->content, qr/WWW::Mechanize::Shell test page/, 'Got the right page' );

$agent->get( './refinesearch.html' );
ok( $agent->success, 'Got the "refine search" page' );
is( $agent->uri, "$server_root/bar/refinesearch.html", 'Got relative OK' );
ok( $agent->is_html, 'is HTML' );
is( $agent->title, 'WWW::Mechanize::Shell test page', 'Title matches' );
like( $agent->content, qr/WWW::Mechanize::Shell test page/, 'Got the right page' );
my $rslength = do {use bytes; length $agent->content};

my $tempfile = './temp';
unlink $tempfile;
ok( !-e $tempfile, 'tempfile not there right now' );
$agent->get( './refinesearch.html', ':content_file'=>$tempfile );
ok( -e $tempfile, 'File exists' );
is( -s $tempfile, $rslength, 'Did all the bytes get saved?' );
unlink $tempfile;

SKIP: {
    skip 'Test::Memory::Cycle not installed', 1 unless $canTMC;

    memory_cycle_ok( $agent, 'Mech: no cycles' );
}
