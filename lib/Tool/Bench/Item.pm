package Tool::Bench::Item;
BEGIN {
  $Tool::Bench::Item::VERSION = '0.001';
}
use Mouse;
use List::Util qw{min max sum};
use Time::HiRes qw{time};

# ABSTRACT: A single item to be benchmarked

=head1 SYNOPSIS 

Here you are, looking at the object for one specific item. At this level things
start to look much more like the unix 'time' command as this is a clock wrapped
around a single 'item'. 

As a matter of comparison, lets look at a simple example:

  time perl -e 'for(1..3){print $_}'

As a Tool::Bench::Item things would look something like:

  my $item = Tool::Bench::Item->new(
                  name => 'Example',
                  code => sub{qx{perl -e 'for(1..3){print $_}'}},
                  # to be fair we call perl again to include compile time
             );
  $item->run;
  printf qq{%0.3f\n} $item->times->[0];

This is a very simple example, with very simular outcomes. But there's more 
that an item provides, speciflcy the startup and teardown events. These are 
untimed CodeRefs that get run before and after the core 'code'. 

Here is another set of examples comparing to 'time':

  echo 'hello' > /tmp/example && time cat /tmp/example && rm /tmp/example

  Tool::Bench::Item->new(
      name     => 'Example with startup and teardown',
      startup  => sub{qx{echo 'hello' > /tmp/example}},
      code     => sub{qx{cat /tmp/example}},
      teardown => sub{qx{rm /tmp/example}},
  )->run;

In both cases we only timed 'cat' not 'echo' or 'rm'. 

=attr name

REQUIRED.

Stores a string name for this item.

=cut

has name => 
   is => 'ro',
   isa => 'Str',
   required => 1,
;

=attr code

REQUIRED.

A CodeRef that is to be run.

=cut

has code => 
   is => 'ro',
   isa => 'CodeRef',
   required => 1,
;

has [qw{buildup teardown}] => 
   is => 'ro',
   isa => 'CodeRef',
   default => sub{sub{}},
;

has note => 
   is => 'ro',
   isa => 'Str',
   default => '',
;

=attr buildup

An untimed CodeRef that is executed everytime before 'run' is called.

=attr teardown

Ain untimed CodeRef that is executed everytime after 'run' is called.

=attr note

An optional string to better explain the item.

=attr results

An ArrayRef that contains all the results.

=attr times

An ArrayRef that contains all the times that a specific run took.

=attr errors

An ArrayRef that contains all any errors that were captured.

=cut

has [qw{results times errors}]  =>
   is => 'rw',
   isa => 'ArrayRef',
   default => sub{[]},
;

=method run

  $item->run;    # a single run
  $item->run(3); # run the code 3 times

Execute code and capture results, errors, and the time for each run.

=cut

before run => sub{ shift->buildup->()  };
after  run => sub{ shift->teardown->() };

sub run {
   my $self = shift;
   my $loop = shift || 1;
   for (1..$loop) {
      local $@;
      my $result;
      my $start = time();
      eval { $result = $self->code->(); };
      my $stop = time();
      push @{ $self->times  }, $stop - $start;
      push @{ $self->results }, $result;
      push @{ $self->errors }, $@;
   }
   return $self->total_runs;
}


#---------------------------------------------------------------------------
#  REPORTING HOOKS
#---------------------------------------------------------------------------
=method total_time

The total time that all runs took to execute.

=method min_time

The fastest execute time.

=method max_time 

The slowest execute time.

=method avg_time

The averge execute time, total_time / total_runs.

= method total_runs

The number of runs that we've captured thus far.

=cut

sub total_time { sum @{shift->times} }
sub min_time   { min @{shift->times} }
sub max_time   { max @{shift->times} }

sub avg_time   { 
   my $self = shift;
   $self->total_time / $self->total_runs
}

sub total_runs { scalar(@{ shift->results }) }

1;
