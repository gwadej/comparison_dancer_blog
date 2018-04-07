#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';
use DateTime;
use DancerBlog::Schema;
use YAML;

my $config = YAML::LoadFile( 'config.yml' );

my $dbconfig = $config->{plugins}->{DBIC}->{default};
die "Cannot find connection information\n" unless defined $dbconfig;

my $dsn  = $dbconfig->{dsn};
my $user = $dbconfig->{user};
my $pass = $dbconfig->{password};

my $schema = DancerBlog::Schema->connect( $dsn, $user, $pass );

$schema->resultset( 'User' )->create(
    {
        userid       => 'gwadej',
        name         => 'G. Wade Johnson',
        passwordhash => DancerBlog::Schema::Result::User->hash_password( 'my_secret_password' ),
    }
);
