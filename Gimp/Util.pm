package Gimp::Util;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD @EXPORT_FAIL);
use Gimp;

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter);
@EXPORT = qw(gimp_install_extension gimp_install_plug_in);
@EXPORT_OK = ();

sub gimp_install_extension($$$$$$$$;$) {
  my $params = [[&Gimp::PARAM_INT32, "run_mode", "Interactive, [non-interactive]"]];
  push(@$params, @$_[8]) if $_[8];
  Gimp::gimp_install_procedure($_[0],$_[1],$_[2],$_[3],$_[4],$_[5],$_[6],$_[7],
                               &Gimp::PROC_EXTENSION, $params, []);
}

sub gimp_install_plug_in($$$$$$$$;$) {
  my $params = [[&Gimp::PARAM_INT32, "run_mode", "Interactive, [non-interactive]"],
                [&Gimp::PARAM_IMAGE, "image", "Input image"],
                [&Gimp::PARAM_DRAWABLE, "drawable", "Input drawable"]];
  push(@$params, @$_[8]) if $_[8];
  Gimp::gimp_install_procedure($_[0],$_[1],$_[2],$_[3],$_[4],$_[5],$_[6],$_[7],
                               &Gimp::PROC_PLUG_IN, $params, []);
}

1;
__END__

=head1 NAME

Gimp::Util - Convinience functions for Gimp.pm

=head1 SYNOPSIS

  use Gimp::Util;

=head1 DESCRIPTION

=over 4

=item gimp_install_extension name,blurb,help,author,copyright,date,menu_path,image_types,[additional params]

install a plug-in, with the standard arguments.

=item gimp_install_plug_in name,blurb,help,author,copyright,date,menu_path,image_types,[additional params]

install an extension, with the standard arguments.

=back

=head1 AUTHOR

Marc Lehmann, pcg@goof.com

=head1 SEE ALSO

perl(1), Gimp(1),

=cut
