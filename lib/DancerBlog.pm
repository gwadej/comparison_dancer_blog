package DancerBlog;
use Dancer2;
use DancerBlog::Schema;
use DancerBlog::Controller::Blog;
use DancerBlog::Controller::Post;
use DancerBlog::Paths qw(:blogs);
use Dancer2::Plugin::Auth::Extensible;

our $VERSION = '0.1';

my $show_path = qr{/(?<id>[1-9][0-9]*)\z};
my $new_path  = '/new';
my $edit_path = qr{/(?<id>[1-9][0-9]*)/edit\z};
my $new_post_path = qr{/(?<id>[1-9][0-9]*)/posts/new\z};

my $alert;

prefix '/blogs' => sub {
    get  ''         => \&DancerBlog::Controller::Blog::index;
    get  $show_path => \&DancerBlog::Controller::Blog::show;
    get  $new_path  => require_login sub { DancerBlog::Controller::Blog::make() };
    post $new_path  => require_login sub { DancerBlog::Controller::Blog::create() };
    get  $edit_path => require_login sub { DancerBlog::Controller::Blog::edit() };
    post $edit_path => require_login sub { DancerBlog::Controller::Blog::update() };

    get  $new_post_path => require_login sub { DancerBlog::Controller::Post::make() };
    post $new_post_path => require_login sub { DancerBlog::Controller::Post::create() };
};

prefix '/posts' => sub {
    get  $show_path => \&DancerBlog::Controller::Post::show;
    get  $edit_path => require_login sub { DancerBlog::Controller::Post::edit() };
    post $edit_path => require_login sub { DancerBlog::Controller::Post::update() };
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

sub alert
{
    my ($msg) = @_;
    if($msg)
    {
        $alert = $msg;
        return;
    }
    else
    {
        $msg = $alert;
        $alert = undef;
        return $msg;
    }
}

sub default_vars
{
    my $alert = alert();
    return (
        ($alert ? (alert => $alert) : ()),
        blogs_url      => blogs_url,
        (defined(logged_in_user)
            ? (user_logged_in => defined( logged_in_user ), user_name => logged_in_user->{name})
            : ())
    );
}

true;
