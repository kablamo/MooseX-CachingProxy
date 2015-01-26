on 'configure' => sub {
    requires "ExtUtils::MakeMaker", ">= 6.30";
}

on 'test' => sub {
    requires "File::Find", "";
    requires "File::Temp", "";
    requires "LWP::UserAgent", "";
    requires "MooseX::Test::Role", "";
    requires "Test::HTTP::Server", "";
    requires "Test::More", "";
    requires "Test::Most", "";
    requires "base", "";
    requires "strict", "";
    requires "warnings", "";
};

on 'runtime' => sub {
    requires "LWP::Protocol::PSGI", "";
    requires "Moose::Role", "";
    requires "MooseX::Types::Path::Class", "";
    requires "Plack::App::Proxy", "";
    requires "Plack::Builder", "";
    requires "Plack::Middleware::Cache", "";
    requires "perl", "5.006";
}

on 'provides' => sub {
    requires "MooseX::CachingProxy", "";
}



