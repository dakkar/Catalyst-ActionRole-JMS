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


sub end :ActionClass('Serialize') { }

__PACKAGE__->meta->make_immutable;

1;

__END__
=pod

=encoding utf-8

=head1 NAME

Catalyst::Controller::JMS - controller base class to simplify usage of Catalyst::ActionRole::JMS

=head1 VERSION

version 0.0.1

=head1 SYNOPSIS

  package MyApp::Controller::Something;
  use Moose;

  BEGIN { extends 'Catalyst::Controller::JMS' }

  __PACKAGE__->config(
    namespace => 'queue/my_queue',
  );

  sub my_message_type :MessageTarget {
    my ($self,$c) = @_;

    my $body = $c->req->data;
    my $headers = $c->req->headers;

    # do something

    $c->res->header('X-Reply-Address' => 'temporary-queue-name');
    $c->stash->{message} = { some => [ 'reply', 'message' ] };

    return;
  }

=head1 DESCRIPTION

This controller base class makes it easy to handle messages in your
Catalyst application. It handles deserialisation and serialisation
transparently (thanks to L<Catalyst::Action::Deserialize> and
L<Catalyst::Action::Serialize>) and sets up the attributes needed
by L<Catalyst::ActionRole::JMS>. It also sets up some sensible default
configuration.

=head1 CONFIGURATION

  __PACKAGE__->config(
    stash_key => 'message',
    default => 'application/json',
    map => {
      'application/json'   => 'JSON',
      'text/x-json'        => 'JSON',
    },
  );

See L<Catalyst::Action::Deserialize> and
L<Catalyst::Action::Serialize> for what this means.

=head1 ACTIONS

=head2 Your actions

If you set the C<MessageTarget> attribute on an action, it will be
marked for dispatch based on the JMSType of incoming messages. More
precisely:

  sub my_message_type :MessageTarget { }

is equivalent to:

  sub my_message_type : Does('Catalyst::ActionRole::JMS')
                        JMSType('my_message_type')
   { }

And:

  sub my_action :MessageTarget('my_type') { }

is equivalent to:

  sub my_action : Does('Catalyst::ActionRole::JMS')
                  JMSType('my_type')
   { }

=head2 C<begin>

De-serialises the body of the request into C<< $ctx->req->data >>. See
L<Catalyst::Action::Deserialize> for details.

=head2 C<end>

Serialises C<< $ctx->stash->{message} >> into the response body. See
L<Catalyst::Action::Serialize> for details.

=head1 AUTHOR

Gianni Ceccarelli <gianni.ceccarelli@net-a-porter.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

