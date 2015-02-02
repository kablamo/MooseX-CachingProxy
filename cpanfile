on 'configure' => sub {
    requires "ExtUtils::MakeMaker", ">= 6.30";
};

on 'test' => sub {
    requires "File::Find", ">= 0";
    requires "File::Temp", ">= 0";
    requires "LWP::UserAgent", ">= 0";
    requires "MooseX::Test::Role", "0.02";
    requires "Test::HTTP::Server", ">= 0";
    requires "Test::More", ">= 0";
    requires "Test::Most", ">= 0";
    requires "base", ">= 0";
    requires "strict", ">= 0";
    requires "warnings", ">= 0";
};

on 'runtime' => sub {
    requires "LWP::Protocol::PSGI", ">= 0";
    requires "Moose::Role", ">= 0";
    requires "MooseX::Types::Path::Class", ">= 0";
    requires "Plack::App::Proxy", ">= 0";
    requires "Plack::Builder", ">= 0";
    requires "Plack::Middleware::Cache", ">= 0";
    requires "perl", "5.006";
};

on 'provides' => sub {
    requires "MooseX::CachingProxy", ">= 0";
};
