package DancerBlog::Schema::Result::User;

use warnings;
use strict;
use 5.010;

our $VERSION = '0.10';

use base qw/DancerBlog::Model::Core/;
use DateTime;
use Crypt::SaltedHash;

our $USERID_LEN = 100;
our $NAME_LEN   = 200;

__PACKAGE__->load_components( 'InflateColumn::DateTime');

__PACKAGE__->table('users');
__PACKAGE__->add_columns(
    id => {
        data_type => 'integer',
        is_nullable => 0,
        is_auto_increment => 1,
        is_numeric => 1,
    },
    userid => {
        data_type => 'varchar',
        size => $USERID_LEN,
        is_nullable => 0,
    },
    name => {
        data_type => 'varchar',
        size => $NAME_LEN,
        is_nullable => 0,
    },
    passwordhash => {
        data_type => 'varchar',
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
__PACKAGE__->has_many(blogs => 'DancerBlog::Schema::Result::Blog', 'user_id');

sub to_hash
{
    my ($self) = @_;

    return {
        userid => $self->userid,
        name   => $self->name,
    };
}

sub to_hash_with_blogs
{
    my ($self) = @_;

    my $user = $self->to_hash;
    $user->{blogs} = [ map { $_->to_hash } $self->blogs ];

    return $user;
}

sub check_password
{
    my ($self, $password) = @_;
    return Crypt::SaltedHash->validate( $self->passwordhash, $password );
}

sub hash_password
{
    my ($class, $password) = @_;
    die "Password cannot be empty\n" unless $password;
    return Crypt::SaltedHash->new()->add( $password )->generate()
}

sub change_password
{
    my ($self, $password) = @_;
    return $self->update( {
        passwordhash => __PACKAGE__->hash_password( $password ),
    } )->discard_changes();
}

1;
__END__

=head1 NAME

DancerBlog::Schema::Result::User - [One line description of module's purpose here]


=head1 VERSION

This document describes DancerBlog::Schema::Result::User version 0.10

=head1 SYNOPSIS

    use DancerBlog::Schema::Result::User;

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

DancerBlog::Schema::Result::User requires no configuration files or environment variables.

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

