
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'Module::Build' => '0.3601'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'simple bencher tool kit',
  'dist_author' => [
    'Ben Hengst <notbenh@cpan.org>'
  ],
  'dist_name' => 'Tool-Bench',
  'dist_version' => '0.001',
  'license' => 'perl',
  'module_name' => 'Tool::Bench',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'JSON' => '0',
    'List::Util' => '0',
    'Mouse' => '0',
    'MouseX::Getopt' => '0',
    'Test::Most' => '0'
  },
  'script_files' => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
