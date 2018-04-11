package DancerBlog::Controller::Post;

use warnings;
use strict;
use 5.010;

use Dancer2 appname => 'DancerBlog';
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::CSRF;
use Dancer2::Plugin::Auth::Extensible;
use DancerBlog::Paths qw(:post_form);

our $VERSION = '0.10';

my $alert;

sub current_user
{
    my $user = logged_in_user;
    return unless $user;

    return resultset( 'User' )->find( { id => $user->{id} } );
}

sub default_vars
{
    my ($post) = @_;
    return (
        DancerBlog::default_vars(),
        is_owner  => is_owner( $post && $post->blog ),
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

sub show
{
    my $postid = captures->{'id'}; # Validate
    my $post = resultset('Post')->find( {id => $postid} );

    if(!$post)
    {
        DancerBlog::alert( 'Post not found' );
        redirect blogs_url();
    }

    return template 'posts/show.tt', {
        default_vars( $post ),
        return_url   => post_url( $postid ),
        post         => $post->to_hash_with_blog,
    };
}

sub make
{
    my $blogid = captures->{'id'}; # Validate
    my $blog = resultset('Blog')->find( {id => $blogid, owner_id => current_user->id} );

    if(!$blog)
    {
        DancerBlog::alert( 'You are not authorized to create a post' );
        redirect blogs_url();
    }

    return template 'posts/new.tt', {
        default_vars(),
#        csrf_token      => get_csrf_token(),  ## After session
        return_url        => new_blog_post_url( $blogid ),
        title_len         => $DancerBlog::Schema::Result::Post::TITLE_LEN,
        new_blog_post_url => new_blog_post_url( $blog->id ),
        blog_url          => blog_url( $blog->id ),
    };
}

sub create
{
#    _ensure_csrf_protection();  ## After session

    my $blogid = captures->{'id'}; # Validate
    my $blog = resultset('Blog')->find( {id => $blogid, owner_id => current_user->id} );

    if(!$blog)
    {
        DancerBlog::alert( 'You are not authorized to create a post' );
        redirect blogs_url();
    }

    my $title = body_parameters->get( 'title' ); # Validate
    my $unsafe = body_parameters->get( 'content' ); # Validate
    my $content = DancerBlog::Schema::Result::Post::clean_markdown( $unsafe );
    if($content ne $unsafe)
    {
        # A little conservative
        warning 'Unsafe content';
        DancerBlog::alert( 'The content you entered contained unsafe HTML' );

        return template 'posts/new.tt', {
            default_vars(),
#            csrf_token        => get_csrf_token(),  ## After session
            return_url        => new_blog_post_url( $blogid ),
            title_len         => $DancerBlog::Schema::Result::Post::TITLE_LEN,
            title             => $title,
            content           => $unsafe,
            new_blog_post_url => new_blog_post_url( $blog->id ),
            blog_url          => blog_url( $blog->id ),
        };
    }

    my $post = resultset( 'Post' )->create(
        {
            blog_id => $blog->id,
            title   => $title,
            content => $content,
        }
    );

    if($post)
    {
        redirect post_url( $post->id );
    }
    else
    {
        error "Unable to create post $DBI::errstr";
        DancerBlog::alert( 'Failed to create the post' );

        return template 'posts/new.tt', {
            default_vars(),
#            csrf_token        => get_csrf_token(),  ## After session
            return_url        => new_blog_post_url( $blogid ),
            title_len         => $DancerBlog::Schema::Result::Post::TITLE_LEN,
            title             => $title,
            content           => $content,
            new_blog_post_url => new_blog_post_url( $blog->id ),
            blog_url          => blog_url( $blog->id ),
        };
    }
    return;
}

sub edit
{
    my $postid = captures->{'id'}; # Validate
    my $post = resultset( 'Post' )->find( {id => $postid} );
    if(!$post || $post->blog->user_id != current_user->id)
    {
        DancerBlog::alert( 'Post not found' );
        redirect blogs_url();
    }

    return template 'posts/edit.tt', {
        default_vars( $post ),
#        csrf_token      => get_csrf_token(),  ## After session
        return_url      => edit_post_url( $postid ),
        title_len       => $DancerBlog::Schema::Result::Post::TITLE_LEN,
        post            => $post->to_hash_with_blog,
    };
}

sub update
{
#    _ensure_csrf_protection();  ## After session

    my $postid = captures->{'id'}; # Validate
    my $post = resultset( 'Post' )->find( {id => $postid} );
    if(!$post || $post->blog->user_id != current_user->id)
    {
        DancerBlog::alert( 'Post not found' );
        redirect blogs_url();
    }

    my $title = body_parameters->get( 'title' ); # Validate
    my $unsafe = body_parameters->get( 'content' ); # Validate
    my $content = DancerBlog::Schema::Result::Post::clean_markdown( $unsafe );
    if($content ne $unsafe)
    {
        # A little conservative
        warning 'Unsafe content';
        DancerBlog::alert( 'The content you entered contained unsafe HTML' );

        # Fall thru to template
    }
    elsif($post->update( { title => $title, content => $content } ))
    {
        redirect post_url( $postid );
    }
    else
    {
        error "Unable to create post $DBI::errstr";
        # need to report the error
        alert( 'Failure to save the post' );
    }

    return template 'posts/edit.tt', {
        default_vars( $post ),
#            csrf_token      => get_csrf_token(),  ## After session
        return_url      => edit_post_url( $postid ),
        title_len       => $DancerBlog::Schema::Result::Post::TITLE_LEN,
        post            => {
            title    => $title,
            content  => $unsafe,
            url      => post_url( $postid ),
            edit_url => edit_post_url( $postid ),
        },
    };
}

# -------- Utilities

sub _ensure_csrf_protection
{
    my $csrf_token = param( 'csrf_token' );
    if( !$csrf_token || !validate_csrf_token( $csrf_token ) )
    {
        error 'CSRF protection error';
        DancerBlog::alert( 'CSRF token is invalid, try again' );
        my $postid = captures->{'id'}; # Validate
        redirect post_url( $postid );
    }
    return;
}

1;
__END__

=head1 NAME

DancerBlog::Controller::Post - [One line description of module's purpose here]


=head1 VERSION

This document describes DancerBlog::Controller::Post version 0.10

=head1 SYNOPSIS

    use DancerBlog::Controller::Post;

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

DancerBlog::Controller::Post requires no configuration files or environment variables.

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

