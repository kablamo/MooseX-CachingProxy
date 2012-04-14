package MooseX::CachingProxy;
use Moose::Role;
use MooseX::Types::Path::Class;

use Plack::Builder;
use Plack::App::Proxy;
use Plack::Middleware::Cache;
use LWP::Protocol::PSGI;

=head1 NAME

MooseX::CachingProxy;

=head1 SYNOPSIS

    package MyDownloader;
    use Moose;
    with 'MooseX::CachingProxy';

    sub _build__caching_proxy_url {'http://boringexample.com'};

    sub BUILD { $self->start_caching_proxy }

    sub get_files { # download files use the caching proxy }

    sub get_fresh_files {
        $self->stop_caching_proxy;
        # download files and dont use the caching proxy
        $self->start_caching_proxy;
    }

=head1 DESCRIPTION

A Moose role that overrides LWP's backend with a PSGI app that caches
responses.  

This role requires '_build__caching_proxy_url'.

You must either use L<LWP> or use a library that uses LWP (like
L<WWW::Mechanize>).

=cut

requires '_build__caching_proxy_url';

has _caching_proxy_url => (
    is         => 'ro',
    isa        => 'Str',
    lazy_build => 1,
);

has _caching_proxy_dir => (
    is      => 'rw',
    isa     => 'Path::Class::Dir',
    lazy    => 1,
    builder => '_build__caching_proxy_dir_or_default',
    coerce  => 1,
);

sub _build__caching_proxy_dir_or_default {
    my $self = shift;
    eval { $self->_build__caching_proxy_dir };
    $@
        ? '/tmp/plack-cache'
        : $self->_build__caching_proxy_dir;
}

has _caching_proxy_app => (
    is         => 'ro',
    isa        => 'CodeRef',
    lazy_build => 1,
);

sub _build__caching_proxy_app {
    my $self = shift;
    $self->_caching_proxy_dir->mkpath;
    return builder {
        enable "Cache",    #
            match_url => '^/.*',
            cache_dir => $self->_caching_proxy_dir;
        Plack::App::Proxy->new( remote => $self->_caching_proxy_url )->to_app;
    };
}

=head2 start_caching_proxy()

Start up the caching proxy

=cut

sub start_caching_proxy {
    LWP::Protocol::PSGI->register( $_[0]->_caching_proxy_app );
}

=head2 stop_caching_proxy()

Stop the caching proxy

=cut

sub stop_caching_proxy { LWP::Protocol::PSGI->unregister }

=head1 TODO

- Add an option to clean up the cache directory.

- Better default for caching_proxy_cache_dir attr.

=head1 SEE ALSO

L<Plack::App::Proxy>, L<Plack::Middleware::Cache>, L<LWP::Protocol::PSGI>

=head1 AUTHOR

Eric Johnson

=cut

1;
