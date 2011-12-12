package TestApp::Controller::Queue;
use Moose;
use namespace::autoclean;
use Data::Printer;

BEGIN { extends 'Catalyst::Controller::ActionRole' }

__PACKAGE__->config(
    namespace => 'queue/myq',
    action_roles => ['JMS'],
    stash_key => 'message',
    default => 'application/json',
    map => {
        'application/json'   => 'JSON',
        'text/x-json'        => 'JSON',
    },
);

sub begin :ActionClass('Deserialize') {
    my ($self,$c) = @_;
}
sub end :ActionClass('Serialize') {
    my ($self,$c) = @_;
    $c->res->header('X-Reply-Address' => $c->req->data->{reply_to});
}

sub foo :Path JMSType('foo') {
    my ($self,$c) = @_;

    $c->log->debug('Message received "foo"'.p($c->req->data));

    $c->stash->{message} = $c->req->data;

    return;
}

sub bar :Path :JMSType {
    my ($self,$c) = @_;

    $c->log->debug('Message received "bar"'.p($c->req->data));

    $c->stash->{message} = {my=>'return'};

    return;
}

1;
