package DancerBlog::Paths;

use warnings;
use strict;
use 5.010;
use Scalar::Util qw/looks_like_number/;
use Exporter::Easy (
    TAGS => [
        blogs     => [qw(blogs_url blog_url new_blog_url edit_blog_url)],
        blog_form => [qw(:blogs new_blog_post_url)],
        posts     => [qw(blog_posts_url post_url new_blog_post_url edit_post_url)],
        all       => [qw(:blogs :posts)],
    ],
);

our $VERSION = '0.10';

sub _ensure_blogid
{
    my ($blogid) = @_;
    die "Missing blog id\n" unless defined $blogid;
    die "Not a valid blog id format\n" unless looks_like_number $blogid;
    return;
}

sub _ensure_postid
{
    my ($postid) = @_;
    die "Missing post id\n" unless defined $postid;
    die "Not a valid post id format\n" unless looks_like_number $postid;
    return;
}

sub blogs_url
{
    return '/blogs';
}

sub blog_url
{
    my ($id) = @_;
    _ensure_blogid( $id );
    return "/blogs/$id";
}

sub new_blog_url
{
    return '/blogs/new';
}

sub edit_blog_url
{
    my ($id) = @_;
    _ensure_blogid( $id );
    return "/blogs/$id/edit";
}

sub blog_posts_url
{
    my ($blogid) = @_;
    _ensure_blogid( $blogid );
    return "/blogs/$blogid/posts";
}

sub post_url
{
    my ($id) = @_;
    _ensure_postid( $id );
    return "/posts/$id";
}

sub new_blog_post_url
{
    my ($blogid) = @_;
    _ensure_blogid( $blogid );
    return "/blogs/$blogid/posts/new";
}

sub edit_post_url
{
    my ($id) = @_;
    _ensure_postid( $id );
    return "/posts/$id/edit";
}

1;
__END__

=head1 NAME

DancerBlog::Paths - [One line description of module's purpose here]


=head1 VERSION

This document describes DancerBlog::Paths version 0.10

=head1 SYNOPSIS

    use DancerBlog::Paths;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.

=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.

=head1 INTERFACE

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.

=head1 CONFIGURATION AND ENVIRONMENT

DancerBlog::Paths requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-<RT NAME>@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

G. Wade Johnson  C<< gwadej@cpan.org >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) <YEAR>, G. Wade Johnson C<< gwadej@cpan.org >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

