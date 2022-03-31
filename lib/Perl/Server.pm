package Perl::Server;

use strict;
use warnings;
use Cwd;
use Plack::Runner;

our $VERSION = '0.02';

sub new {
    my $class = shift;
    my $path  = shift;
    
    return bless {
        path => $path ? $path : getcwd
    }, $class;
}

sub run {
    my $self = shift;
    my @argv = @_;

    my $type = $self->_type;   

    if (exists $type->{module}) {
        push(@argv, '-M');
        push(@argv, $type->{module});
        
        push(@argv, '-e');
        push(@argv, $type->{eval});          
    } else {
        push(@argv, '-a');
        push(@argv, $type->{app});        
    }
    
    unless (grep(/^(-p|--port)$/, @argv)) {
        push(@argv, '-p');
        push(@argv, 3000);      
    }
    
    $ENV{PLACK_ENV} = 'perl-server';       
    
    my $runner = Plack::Runner->new;    
    $runner->parse_options(@argv);   
    $self->_message($runner);
    $runner->run;
}

sub _type {
    my $path = shift->{path};
    
    my $type = {};
        
    if (-d $path) {
        $type->{module} = 'Plack::App::WWW';
        $type->{eval}   = "Plack::App::WWW->new(root => '$path')->to_app";        
    } elsif (-e $path && $path =~ /\.(pl|cgi)$/i) {
        $type->{module} = 'Plack::App::WrapCGI';
        $type->{eval}   = "Plack::App::WrapCGI->new(script => '$path')->to_app";         
    } else {
        $type->{app} = $path;
    }
    
    return $type;
}

sub _message {
    my ($self, $runner) = @_;
    
    push @{$runner->{options}}, server_ready => sub {
        my $args = shift;
        my $host  = $args->{host}  || 0;
        my $proto = $args->{proto} || 'http';
        print STDERR "Perl::Server: Accepting connections at $proto://$host:$args->{port}/\n";
    };     
}

1;

__END__

=encoding utf8
 
=head1 NAME
 
Perl::Server - A simple Perl server.

=head1 SYNOPSIS

    # run path current
    $ perl-server 
    
    # run path 
    $ perl-server /home/foo/www
    
    # run file Perl
    $ perl-server foo.pl
    
    # run file psgi
    $ perl-server app.psgi    

=head1 DESCRIPTION

Perl::Server is a simple, zero-configuration command-line Perl server. 
It is to be used for testing, local development, and learning.

Using Perl::Server:

    $ perl-server [path] [options]
    
    # or
    
    $ perl-server [options]
    
These options are the same as L<Plackup Options|plackup#OPTIONS>.

=head1 SEE ALSO
 
L<Plack>, L<Plack::App::WWW>, L<Plack::App::WrapCGI>, L<Plack::App::CGIBin>, L<plackup>.
 
=head1 AUTHOR
 
Lucas Tiago de Moraes, C<lucastiagodemoraes@gmail.com>.
 
=head1 COPYRIGHT AND LICENSE
 
This software is copyright (c) 2022 by Lucas Tiago de Moraes.
 
This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.
 
=cut
