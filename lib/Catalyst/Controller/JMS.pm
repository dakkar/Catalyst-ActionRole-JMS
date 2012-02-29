package Catalyst::Controller::JMS;
use Moose;
use namespace::autoclean;
use Data::Printer;

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
