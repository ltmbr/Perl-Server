requires 'Cwd'             => '0';
requires 'Plack'           => '0';
requires 'Plack::App::WWW' => '0.03';
requires 'Term::ANSIColor' => '0';
requires 'Net::EmptyPort'  => '0';

on 'test' => sub {
    requires 'Test::More'     => '0';
    requires 'Test::Requires' => '0';
    requires 'LWP::UserAgent' => '0';
};
