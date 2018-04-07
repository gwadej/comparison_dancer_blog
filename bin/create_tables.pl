#!/usr/bin/env perl

use strict;
use warnings;
use lib 'lib';
use DancerBlog::Schema;
use YAML;

my $config = YAML::LoadFile( 'config.yml' );

my $dbconfig = $config->{plugins}->{DBIC}->{default};
die "Cannot find connection information\n" unless defined $dbconfig;

my $dsn = $dbconfig->{dsn};
my $user = $dbconfig->{user};
my $pass = $dbconfig->{password};
my $options = $dbconfig->{options};

my $schema = DancerBlog::Schema->connect(
    $dsn,
    $user,
    $pass,
    $options
);

$schema->deploy( { add_drop_table => 1 } );
