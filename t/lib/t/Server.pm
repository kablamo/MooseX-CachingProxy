package t::Server;
use base 'Test::HTTP::Server';

sub Test::HTTP::Server::Request::boop {
    return "hey world";
}

1;
