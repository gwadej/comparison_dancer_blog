package DancerBlog;
use Dancer2;
use DancerBlog::Schema;
use DancerBlog::Controller::Blog;

our $VERSION = '0.1';

prefix '/blogs' => sub {
    get ''     => \&DancerBlog::Controller::Blog::index;
    get qr{/(?<id>[0-9a-f]{32})} => \&DancerBlog::Controller::Blog::show;
    get '/new'  => \&DancerBlog::Controller::Blog::make;
    post '/new' => \&DancerBlog::Controller::Blog::create;
};

get '/' => sub {
    template 'index' => { 'title' => 'dancer_blog' };
};

true;
