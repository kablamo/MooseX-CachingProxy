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

    has url => (is => 'ro', isa => 'Str', default => 'http://example.com');

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

This is a Moose role that allows you to easily cache responses from remote
servers.  For this to work, use either L<LWP> or a library that uses LWP (like
L<WWW::Mechanize>).

The implementation is a mashup of L<Plack::App::Proxy>,
L<Plack::Middleware::Cache>, and L<LWP::Protocol::PSGI>.  It intercepts any LWP
requests made and routes them to a PSGI app. The PSGI app will return a cached
response if available or send the request on to the intended server.

This role requires a 'url' attribute or method.

=cut

=head1 ATTRIBUTES

=head2 url

Required.  All requests are proxied to this server.  Example:
http://example.com.

=head2 caching_proxy_dir

Optional.  The directory on the local filesystem where responses are cached.
The default location is '/tmp/caching-proxy'.

=cut


requires 'url';

has _caching_proxy_dir => (
    is      => 'rw',
    isa     => 'Path::Class::Dir',
    lazy_build => 1,
    coerce  => 1,
);

sub _build__caching_proxy_dir {
    my $self = shift;
    eval { $self->caching_proxy_dir };
    $@ ? '/tmp/caching-proxy' : $self->caching_proxy_dir;
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
        Plack::App::Proxy->new( remote => $self->url )->to_app;
    };
}

=head1 METHODS

=head2 start_caching_proxy()

Start intercepting LWP requests with a caching proxy server

=cut

sub start_caching_proxy {
    LWP::Protocol::PSGI->register( $_[0]->_caching_proxy_app );
}

=head2 stop_caching_proxy()

Start intercepting LWP requests with a caching proxy server

=cut

sub stop_caching_proxy { LWP::Protocol::PSGI->unregister }

=head1 TODO

Add an option to remove the cache directory?

=head1 THANKS

Thanks to Foxtons Ltd for providing the opportunity to write and release the
original version of this module.

=head1 SEE ALSO

L<Plack::App::Proxy>, L<Plack::Middleware::Cache>, L<LWP::Protocol::PSGI>

=cut

1;
