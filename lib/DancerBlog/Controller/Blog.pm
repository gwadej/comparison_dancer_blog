package DancerBlog::Controller::Blog;

use warnings;
use strict;
use 5.010;

use Dancer2 appname => 'DancerBlog';
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::CSRF;
use DancerBlog::Paths qw(:blogs new_blog_post_url);

our $VERSION = '0.10';

sub model
{
    return schema->resultset('Blog');
}

sub current_user
{
    return schema->resultset('User')->find({ userid => 'gwadej' });
}

sub index
{
    my @blogs = map { _blog_hash( $_ ) } model->all();
    return template 'blogs/index.tt', {
        blogs        => \@blogs,
        new_blog_url => new_blog_url(),
    };
}

sub show
{
    my $blogid = captures->{'id'}; # Validate
    my $blog = model->find({id => $blogid});

    return template 'blogs/show.tt', {
        blogs_url    => blogs_url(),
        blog         => $blog->to_hash,
        new_post_url => new_blog_post_url( $blogid ),
    };
}

sub make
{
    return template 'blogs/new.tt', {
#        csrf_token      => get_csrf_token(),  ## After session
        title_len       => $DancerBlog::Schema::Result::Blog::TITLE_LEN,
        description_len => $DancerBlog::Schema::Result::Blog::DESCRIPTION_LEN,
        new_blog_url    => new_blog_url(),
    };
}

sub create
{
#    _ensure_csrf_protection();  ## After session
#
    my $title = body_parameters->get( 'title' ); # Validate
    my $description = body_parameters->get( 'description' ); # Validate
    my $blog = model->create({
            user_id => current_user->id,
            title => $title,
            description => $description,
        });

    if($blog)
    {
        redirect blog_url( $blog->id );
    }
    else
    {
        error "Unable to create blog: $DBI::errstr";
        # need to report the error
        return template 'blogs/new.tt', {
#           csrf_token      => get_csrf_token(),  ## After session
            title_len       => $DancerBlog::Schema::Result::Blog::TITLE_LEN,
            description_len => $DancerBlog::Schema::Result::Blog::DESCRIPTION_LEN,
            title           => $title,
            description     => $description,
            new_blog_url    => new_blog_url(),
        };
    }
    return;
}

# -------- Utilities

sub _ensure_csrf_protection
{
    my $csrf_token = param( 'csrf_token' );
    if( !$csrf_token || !validate_csrf_token( $csrf_token ) )
    {
        redirect '/?error=invalid_csrf_token';
    }
    return;
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

