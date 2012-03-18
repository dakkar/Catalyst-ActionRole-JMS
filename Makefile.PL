
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "role for actions to dispatch based on JMSType",
  "AUTHOR" => "Gianni Ceccarelli <gianni.ceccarelli\@net-a-porter.com>",
  "BUILD_REQUIRES" => {
    "Catalyst" => 0,
    "Catalyst::Controller" => 0,
    "Catalyst::Runtime" => "5.80",
    "Catalyst::ScriptRunner" => 0,
    "Catalyst::Test" => 0,
    "Data::Printer" => 0,
    "FindBin::libs" => 0,
    "HTTP::Request" => 0,
    "JSON::XS" => 0,
    "Net::Stomp" => 0,
    "Test::More" => 0,
    "Test::Most" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Catalyst-ActionRole-JMS",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Catalyst::ActionRole::JMS",
  "PREREQ_PM" => {
    "Catalyst::Action::REST" => 0,
    "Catalyst::Controller::ActionRole" => 0,
    "List::Util" => 0,
    "Moose" => 0,
    "Moose::Role" => 0,
    "namespace::autoclean" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.1_02",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



