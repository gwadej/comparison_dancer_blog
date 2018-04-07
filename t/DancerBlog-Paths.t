#!/usr/bin/env perl

use Test::More tests => 8;
use Test::Exception;

use strict;
use warnings;

use DancerBlog::Paths qw(:all);

is( blogs_url(), '/blogs', 'blogs index url' );

subtest 'blog show url' => sub {
    is( blog_url( 1 ), '/blogs/1', 'real id' );
    throws_ok { blog_url() } qr/Missing/, 'missing id';
    throws_ok { blog_url( 'abcd' ) } qr/Not a valid/, 'Invalid id';
};

is( new_blog_url(), '/blogs/new', 'blogs new url' );

subtest 'blog edit url' => sub {
    is( edit_blog_url( 1 ), '/blogs/1/edit', 'real id' );
    throws_ok { edit_blog_url() } qr/Missing/, 'missing id';
    throws_ok { edit_blog_url( 'abcd' ) } qr/Not a valid/, 'Invalid id';
};

subtest 'blog posts index' => sub {
    is( blog_posts_url( 1 ), '/blogs/1/posts', 'real id' );
    throws_ok { blog_posts_url() } qr/Missing/, 'missing blog id';
    throws_ok { blog_posts_url( 'abcd') } qr/Not a valid/, 'Invalid blog id';
};

subtest 'post show url' => sub {
    is( post_url( 2 ), '/posts/2', 'real id' );
    throws_ok { post_url() } qr/Missing/, 'missing post id';
    throws_ok { post_url( 'abcd') } qr/Not a valid/, 'Invalid post id';
};

subtest 'new blog post url' => sub {
    is( new_blog_post_url( 1 ), '/blogs/1/posts/new', 'real id' );
    throws_ok { new_blog_post_url() } qr/Missing/, 'missing id';
    throws_ok { new_blog_post_url( 'abcd' ) } qr/Not a valid/, 'Invalid id';
};

subtest 'post edit url' => sub {
    is( edit_post_url( 2 ), '/posts/2/edit', 'real id' );
    throws_ok { edit_post_url() } qr/Missing/, 'missing id';
    throws_ok { edit_post_url( 'abcd' ) } qr/Not a valid/, 'Invalid id';
};
