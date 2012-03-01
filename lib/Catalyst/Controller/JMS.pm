package Catalyst::Controller::JMS;
use Moose;
use namespace::autoclean;
use Data::Printer;

# ABSTRACT: controller base class to simplify usage of Catalyst::ActionRole::JMS

BEGIN { extends 'Catalyst::Controller::ActionRole' }

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

=cut

__PACKAGE__->config(
    stash_key => 'message',
    default => 'application/json',
    map => {
        'application/json'   => 'JSON',
        'text/x-json'        => 'JSON',
    },
);

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

If you want to have a C<default> action to catch requests not matching
any other action, you have to declare it as:

  sub default :Default { }

otherwise dispatch may not work properly, see
http://lists.scsys.co.uk/pipermail/catalyst/2012-March/028261.html for
some attempts at an explanation

=cut

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

=head2 C<begin>

De-serialises the body of the request into C<< $ctx->req->data >>. See
L<Catalyst::Action::Deserialize> for details.

=cut

sub begin :ActionClass('Deserialize') { }

=head2 C<end>

Serialises C<< $ctx->stash->{message} >> into the response body. See
L<Catalyst::Action::Serialize> for details.

B<NOTE>: if C<< $ctx->stash->{message} >> is not a reference, it will
be wrapped in an arrayref. Some L<Catalyst::Action::Serialize> plugins
don't like serialising plain scalars.

=cut

sub end :ActionClass('Serialize') {
    my ($self,$c) = @_;

    $c->stash->{message} = [$c->stash->{message}]
        unless ref($c->stash->{message});
}

__PACKAGE__->meta->make_immutable;

1;
