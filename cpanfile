requires "LWP::Protocol::PSGI", ">= 0";
requires "Moose::Role", ">= 0";
requires "MooseX::Types::Path::Class", ">= 0";
requires "Plack::App::Proxy", ">= 0";
requires "Plack::Builder", ">= 0";
requires "Plack::Middleware::Cache", ">= 0";
requires "perl", "5.006";

on 'test' => sub {
    requires "LWP::UserAgent", ">= 0";
    requires "MooseX::Test::Role", "0.02";
    requires "Test::HTTP::Server", ">= 0";
    requires "Test::Most", ">= 0";
    requires "Test::Pod", ">= 1.14";
};
