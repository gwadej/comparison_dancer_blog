package DancerBlog;
use Dancer2;
use DancerBlog::Schema;
use DancerBlog::Controller::Blog;

our $VERSION = '0.1';

prefix '/blogs' => sub {
    get  ''     => \&DancerBlog::Controller::Blog::index;
    get  qr{/(?<id>[1-9][0-9]*)\z} => \&DancerBlog::Controller::Blog::show;
    get  '/new'  => \&DancerBlog::Controller::Blog::make;
    post '/new' => \&DancerBlog::Controller::Blog::create;
    get  qr{/(?<id>[1-9][0-9]*)/edit\z}  => \&DancerBlog::Controller::Blog::edit;
    post qr{/(?<id>[1-9][0-9]*)/edit\z} => \&DancerBlog::Controller::Blog::update;
};

get '/' => sub {
    template 'index' => { 'title' => 'dancer_blog' };
};

true;
