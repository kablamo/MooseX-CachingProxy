# ABSTRACT: Send LWP requests through a caching proxy server
package MooseX::CachingProxy;
use Moose::Role;
use MooseX::Types::Path::Class;

use Plack::Builder;
use Plack::App::Proxy;
use Plack::Middleware::Cache;
use LWP::Protocol::PSGI;

=head1 SYNOPSIS

    package MyDownloader;
    use Moose;
    use WWW::Mechanize;
    with 'MooseX::CachingProxy';

    # required
    sub _build__caching_proxy_url {'http://boringexample.com'};

    # optional
    sub _build__caching_proxy_dir {'/tmp/plack-cache'};

    sub BUILD {$self->start_caching_proxy}

    # this method retrieves web pages via the caching proxy
    sub get_files { 
        my $response = WWW::Mechanize->new()->get('http://example.com');
    }

    # this method retrieves web pages directly from example.com
    sub get_fresh_files {
        $self->stop_caching_proxy;
        my $response = WWW::Mechanize->new()->get('http://example.com');
        $self->start_caching_proxy;
    }

=head1 DESCRIPTION

This is a Moose role that sends LWP requests through a PSGI app that either
sends the request on to the web server or returns a cached response.  

For this to work, use either L<LWP> or a library that uses LWP (like
L<WWW::Mechanize>).

This role requires '_build__caching_proxy_url'.

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

=cut

1;
