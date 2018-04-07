use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on it.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME                => 'DancerBlog',
    AUTHOR              => q{YOUR NAME <youremail@example.com>},
    VERSION_FROM        => 'lib/DancerBlog.pm',
    ABSTRACT_FROM       => 'lib/DancerBlog.pm',
    LICENSE             => 'perl_5',
    PL_FILES            => {},
    MIN_PERL_VERSION    => 5.010000,
    TEST_REQUIRES => {
        'Test::More'                        => 0,
    },
    PREREQ_PM => {
        'YAML'                                  => 0,
        'Crypt::SaltedHash'                     => 0,
        'Dancer2'                               => 0.205001,
        'Dancer2::Plugin::Auth::Extensible'     => 0,
        'Dancer2::Plugin::CSRF'                 => 0,
        'Dancer2::Plugin::DBIC'                 => 0,
        'DateTime'                              => 0,
        'DBD::SQLite'                           => 0,
        'DBIx::Class'                           => 0,
        'DBIx::Class::InflateColumn::DateTime'  => 0,
        'Exporter::Easy'                        => 0,
        'Plack'                                 => 0,
        'Plack::Middleware::Deflater'           => 0,
        'Scalar::Util'                          => 0,
        'Template'                              => 0,
        'Text::MultiMarkdown'                   => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'dancer_blog-*' },
    realclean           => { FILES => 'db/dancer_log.db' },
    META_MERGE => {
        'meta-spec' => {
            version => 2,
            url     => 'https://metacpan.org/pod/CPAN::Meta::Spec',
        },
        resources => {
            type => 'git',
            url => 'git://',
        },
    },
);

sub MY::postamble {
    return <<"MAKE_FRAG";
db:
\tmkdir db

database: db db/dancer_blog.db

db/dancer_blog.db:
\tbin/create_tables.pl

init_db: database
\tbin/populate_test.pl
MAKE_FRAG
}
