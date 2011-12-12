package Catalyst::ActionRole::JMS;
use strict;
use warnings;
use Moose::Role;
use List::Util 'first';
use namespace::autoclean;

requires 'attributes';

has jmstype => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    builder => '_build_jmstype',
);

sub _build_jmstype {
    my ($self) = @_;

    return $self->attributes->{JMSType}[0] // $self->name;
}

sub _extract_jmstype {
    my ($self,$ctx) = @_;

    my $ret = $ctx->request->headers->header('JMSType');
    return $ret if defined $ret;
    my $env = $ctx->engine->env;
    my $key = first { /\.jmstype$/ } keys %{$env};
    return $env->{$key};
}

sub _match_jmstype {
    my ($self,$req_jmstype) = @_;

    return $self->jmstype eq $req_jmstype;
}

around match => sub {
    my ($orig,$self,$ctx) = @_;

    my $req_jmstype = $self->_extract_jmstype($ctx);
    if ($self->_match_jmstype($req_jmstype)) {
        return $self->$orig($ctx);
    }
    return 0;
};

1;
