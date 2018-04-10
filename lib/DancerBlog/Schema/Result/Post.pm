package DancerBlog::Schema::Result::Post;

use warnings;
use strict;
use 5.010;

our $VERSION = '0.10';

use base qw/DancerBlog::Model::Core/;
use DateTime;
use DancerBlog::Paths qw(:posts);
use Text::MultiMarkdown;
use HTML::Scrubber; # Need to replace this

our $TITLE_LEN = 250;

__PACKAGE__->load_components( 'InflateColumn::DateTime');

__PACKAGE__->table('posts');
__PACKAGE__->add_columns(
    id => {
        data_type => 'integer',
        is_nullable => 0,
        is_auto_increment => 1,
        is_numeric => 1,
    },
    title => {
        data_type => 'varchar',
        size => $TITLE_LEN,
        is_nullable => 0,
    },
    content => {
        data_type => 'varchar',
        is_nullable => 0,
    },
    blog_id => {
        data_type => 'integer',
        is_foreign_key => 1,
        is_numeric => 1,
        is_nullable => 0,
    },
    created_at => {
        data_type => 'datetime',
        is_nullable => 0,
    },
    updated_at => {
        data_type => 'datetime',
        is_nullable => 0,
    },
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_one( blog => 'DancerBlog::Schema::Result::Blog', {'foreign.id' => 'self.blog_id'}, { cascade_delete => 0 } );

sub to_hash
{
    my ($self) = @_;

    return {
        title        => $self->title,
        content      => $self->safe_content,
        html_content => $self->html_content,
        url          => post_url( $self->id ),
        edit_url     => edit_post_url( $self->id ),
    };
}

sub to_hash_with_blog
{
    my ($self) = @_;
    my $post = $self->to_hash;
    $post->{'blog'} = $self->blog->to_hash;

    return $post;
}

sub clean_markdown
{
    my ($unsafe) = @_;
    my $scrubber = HTML::Scrubber->new( allow => [ qw[ abbr b i super sub ] ] );
    return $scrubber->scrub( $unsafe );
}

sub safe_content
{
    my ($self) = @_;

    return clean_markdown( $self->content );
}

sub html_content
{
    my ($self) = @_;

    my $m = Text::MultiMarkdown->new(
        empty_element_suffix => '>',
        tab_width => 2,
        disable_bibliography => 0,
    );
    return $m->markdown( $self->safe_content );
}

1;
__END__

=head1 NAME

DancerBlog::Schema::Result::Post - [One line description of module's purpose here]


=head1 VERSION

This document describes DancerBlog::Schema::Result::Post version 0.10

=head1 SYNOPSIS

    use DancerBlog::Schema::Result::Post;

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

DancerBlog::Schema::Result::Post requires no configuration files or environment variables.

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


