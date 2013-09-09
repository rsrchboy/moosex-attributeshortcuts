requires "Moose" => "0";
requires "Moose::Exporter" => "0";
requires "Moose::Util::MetaRole" => "0";
requires "Moose::Util::TypeConstraints" => "0";
requires "MooseX::Role::Parameterized" => "0";
requires "MooseX::Types::Common::String" => "0";
requires "MooseX::Types::Moose" => "0";
requires "namespace::autoclean" => "0";
requires "perl" => "5.006";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Moose::Role" => "0";
  requires "Moose::Util" => "0";
  requires "MooseX::Types::Path::Class" => "0";
  requires "Path::Class" => "0";
  requires "Test::CheckDeps" => "0.006";
  requires "Test::Fatal" => "0";
  requires "Test::Moose" => "0";
  requires "Test::Moose::More" => "0.018";
  requires "Test::More" => "0.94";
  requires "constant" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
  requires "version" => "0.9901";
};
