package Catalyst::Controller::JMS;
{
  $Catalyst::Controller::JMS::VERSION = '0.0.1';
}
{
  $Catalyst::Controller::JMS::DIST = 'Catalyst-ActionRole-JMS';
}
use Moose;
use namespace::autoclean;
use Data::Printer;

# ABSTRACT: controller base class to simplify usage of Catalyst::ActionRole::JMS

BEGIN { extends 'Catalyst::Controller::ActionRole' }

__PACKAGE__->config(
    stash_key => 'message',
    default => 'application/json',
    map => {
        'application/json'   => 'JSON',
        'text/x-json'        => 'JSON',
    },
);

around create_action => sub {
    my ($orig, $self, %args) = @_;

    return $self->$orig(%args)
        if $args{name} =~ /^_(DISPATCH|BEGIN|AUTO|ACTION|END)$/;

    my $type = delete $args{attributes}->{MessageTarget};
    if ($type) {
        $args{attributes}->{Path} = [$self->path_prefix()];
        $args{attributes}->{JMSType} = [$type->[0] // $args{name}];
        $args{attributes}->{Does} = [ 'Catalyst::ActionRole::JMS' ];
    }

    return $self->$orig(%args);
};

sub begin :ActionClass('Deserialize') { }

sub end :ActionClass('Serialize') {
    my ($self,$c) = @_;
    return unless $c->req->data;
    $c->res->header('X-Reply-Address' => $c->req->data->{reply_to});
}

__PACKAGE__->meta->make_immutable;

1;

__END__
=pod

=encoding utf-8

=head1 NAME

Catalyst::Controller::JMS - controller base class to simplify usage of Catalyst::ActionRole::JMS

=head1 VERSION

version 0.0.1

=head1 AUTHOR

Gianni Ceccarelli <gianni.ceccarelli@net-a-porter.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

