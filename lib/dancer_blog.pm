package dancer_blog;
use Dancer2;

our $VERSION = '0.1';

get '/' => sub {
    template 'index' => { 'title' => 'dancer_blog' };
};

true;
