package Gimp::Lib;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD @_consts @_procs %EXPORT_TAGS @EXPORT_FAIL);
use Gimp;

require DynaLoader;

@ISA = qw(DynaLoader);
$VERSION = $Gimp::VERSION;

use subs @Gimp::_procs;
use subs @Gimp::_internals;

# Preloaded methods go here.

sub AUTOLOAD {
  my $constname;
  ($constname = $AUTOLOAD) =~ s/.*:://;
  if (_gimp_procedure_available ($constname)) {
     no strict "refs";
     *{$AUTOLOAD} = sub { gimp_call_procedure $constname,@_ };
     goto &$AUTOLOAD;
  } else {
     croak "$constname not defined in Gimp";
  }
}

bootstrap Gimp::Lib $VERSION;

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Gimp::Lib - Interface to libgimp (as opposed to Gimp::Net)

=head1 SYNOPSIS

  use Gimp qw( interface=lib );

=head1 DESCRIPTION

This is package that uses libgimp to interface with the Gimp, i.e. the
normal interface to use with the Gimp. You don't normally use this module
directly, look at the documentation for the package "Gimp".

=head1 AUTHOR

Marc Lehmann <pcg@goof.com>

=head1 SEE ALSO

perl(1), L<Gimp>.

=cut
