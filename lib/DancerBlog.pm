package DancerBlog;
use Dancer2;
use DancerBlog::Schema;
use DancerBlog::Controller::Blog;
use DancerBlog::Paths qw(:blogs);
use Dancer2::Plugin::Auth::Extensible;

our $VERSION = '0.1';

my $show_path = qr{/(?<id>[1-9][0-9]*)\z};
my $new_path  = '/new';
my $edit_path = qr{/(?<id>[1-9][0-9]*)/edit\z};

prefix '/blogs' => sub {
    get  ''         => \&DancerBlog::Controller::Blog::index;
    get  $show_path => \&DancerBlog::Controller::Blog::show;
    get  $new_path  => require_login sub { DancerBlog::Controller::Blog::make() };
    post $new_path  => require_login sub { DancerBlog::Controller::Blog::create() };
    get  $edit_path => require_login sub { DancerBlog::Controller::Blog::edit() };
    post $edit_path => require_login sub { DancerBlog::Controller::Blog::update() };
};

get '/' => sub {
    template 'index' => { 'title' => 'dancer_blog' };
};

sub login_page
{
    info( 'login_page' );
    return template 'login' => {
        return_url => param('return_url'), # Need to validate this
        message => param('message'), # Need to validate this as well
    };
}

sub default_vars
{
    return (
        blogs_url      => blogs_url,
        user_logged_in => defined( logged_in_user ),
    );
}

true;
