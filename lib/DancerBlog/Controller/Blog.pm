package DancerBlog::Controller::Blog;

use warnings;
use strict;
use 5.010;

use Dancer2 appname => 'DancerBlog';
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::Auth::Extensible;
use DancerBlog::Paths qw(:blog_form);
use DancerBlog::CSRF;

our $VERSION = '0.10';

sub current_user
{
    my $user = logged_in_user;
    return unless $user;

    return schema->resultset( 'User' )->find( { id => $user->{id} } );
}

sub default_vars
{
    my ($blog) = @_;
    return (
        DancerBlog::default_vars(),
        is_owner  => is_owner( $blog ),
    );
}

sub is_owner
{
    my ($blog) = @_;
    return 0 unless $blog;

    my $user = current_user;
    return 0 unless $user;
    return ($user->id == $blog->user_id) ? 1 : 0;
}

sub index
{
    my @blogs = map { $_->to_hash } resultset( 'Blog' )->all();
    return template 'blogs/index.tt', {
        default_vars(),
        return_url   => blogs_url(),
        blogs        => \@blogs,
        new_blog_url => new_blog_url(),
    };
}

sub show
{
    my $blogid = captures->{'id'}; # Validate
    my $blog = resultset( 'Blog' )->find( {id => $blogid} );

    if(!$blog)
    {
        DancerBlog::alert( 'Blog not found' );
        redirect blogs_url();
    }

    return template 'blogs/show.tt', {
        default_vars( $blog ),
        return_url   => blog_url( $blogid ),
        blogs_url    => blogs_url(),
        blog         => $blog->to_hash_with_posts,
        new_post_url => new_blog_post_url( $blogid ),
    };
}

sub make
{
    return template 'blogs/new.tt', {
        default_vars(),
        csrf_token      => DancerBlog::CSRF::get_token(),
        return_url      => new_blog_url(),
        title_len       => $DancerBlog::Schema::Result::Blog::TITLE_LEN,
        description_len => $DancerBlog::Schema::Result::Blog::DESCRIPTION_LEN,
        new_blog_url    => new_blog_url(),
        blogs_url       => blogs_url(),
    };
}

sub create
{
    my $title = body_parameters->get( 'title' ); # Validate
    my $description = body_parameters->get( 'description' ); # Validate
    my $blog = resultset( 'Blog' )->create(
        {
            user_id     => current_user->id,
            title       => $title,
            description => $description,
        }
    );

    if(!validate_csrf_protection())
    {
        DancerBlog::alert( 'CSRF token is invalid, try again' );
        error 'CSRF protection error';
    }
    elsif($blog)
    {
        redirect blog_url( $blog->id );
    }
    else
    {
        error "Unable to create blog: $DBI::errstr";

        DancerBlog::alert( 'Failed to create blog' );
    }

    return template 'blogs/new.tt', {
        default_vars(),
        csrf_token      => DancerBlog::CSRF::get_token(),
        return_url      => new_blog_url(),
        title_len       => $DancerBlog::Schema::Result::Blog::TITLE_LEN,
        description_len => $DancerBlog::Schema::Result::Blog::DESCRIPTION_LEN,
        title           => $title,
        description     => $description,
        new_blog_url    => new_blog_url(),
        blogs_url       => blogs_url(),
    };

    return;
}

sub edit
{
    my $blogid = captures->{'id'}; # Validate
    my $blog = resultset( 'Blog' )->find( {id => $blogid, user => current_user} );

    if(!$blog)
    {
        DancerBlog::alert( 'Blog not found' );
        redirect blogs_url();
    }

    return template 'blogs/edit.tt', {
        default_vars( $blog ),
        csrf_token      => DancerBlog::CSRF::get_token(),
        return_url      => edit_blog_url( $blogid ),
        title_len       => $DancerBlog::Schema::Result::Blog::TITLE_LEN,
        description_len => $DancerBlog::Schema::Result::Blog::DESCRIPTION_LEN,
        blog            => $blog->to_hash,
    };
}

sub update
{
    my $blogid = captures->{'id'}; # Validate
    my $blog = resultset( 'Blog' )->find( {id => $blogid, user => current_user} );

    if(!$blog)
    {
        DancerBlog::alert( 'Blog not found' );
        redirect blogs_url();
    }

    my $title = body_parameters->get( 'title' ); # Validate
    my $description = body_parameters->get( 'description' ); # Validate

    if(!validate_csrf_protection())
    {
        DancerBlog::alert( 'CSRF token is invalid, try again' );
        error 'CSRF protection error';
    }
    elsif($blog->update( { title => $title, description => $description } ))
    {
        redirect blog_url( $blogid );
    }
    else
    {
        error "Unable to create blog: $DBI::errstr";
        # need to report the error
        return template 'blogs/edit.tt', {
            default_vars( $blog ),
            csrf_token      => DancerBlog::CSRF::get_token(),
            return_url      => edit_blog_url( $blogid ),
            title_len       => $DancerBlog::Schema::Result::Blog::TITLE_LEN,
            description_len => $DancerBlog::Schema::Result::Blog::DESCRIPTION_LEN,
            blog            => {
                title        => $title,
                description  => $description,
                url          => blog_url( $blogid ),
                edit_url     => edit_blog_url( $blogid ),
            },
        };
    }
    return;
}

# -------- Utilities

sub validate_csrf_protection
{
    my $csrf_token = param( 'csrf_token' );
    return( $csrf_token && DancerBlog::CSRF::validate_token( $csrf_token ) )
}

1;
__END__

=head1 NAME

DancerBlog::Controller::Blog - [One line description of module's purpose here]


=head1 VERSION

This document describes DancerBlog::Controller::Blog version 0.10

=head1 SYNOPSIS

    use DancerBlog::Controller::Blog;

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

DancerBlog::Controller::Blog requires no configuration files or environment variables.

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

