#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use dancer_blog;

dancer_blog->to_app;

use Plack::Builder;

builder {
    enable 'Deflater';
    dancer_blog->to_app;
}



=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use dancer_blog;
use Plack::Builder;

builder {
    enable 'Deflater';
    dancer_blog->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use dancer_blog;
use dancer_blog_admin;

builder {
    mount '/'      => dancer_blog->to_app;
    mount '/admin'      => dancer_blog_admin->to_app;
}

=end comment

=cut

