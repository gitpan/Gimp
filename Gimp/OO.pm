package Gimp::OO;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD @EXPORT_FAIL);
use Gimp;

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter);
@EXPORT = ();

sub pseudoclass {
  my ($class, @prep)= @_;
  my ($prep);
  for(@prep) {
     $prep .= "\"${_}_\",";
  };
  $prep .= '""';
  eval <<EOF;

sub Gimp::${class}::AUTOLOAD {
  my \$subname;
  (\$subname = \$Gimp::${class}::AUTOLOAD) =~ s/.*:://;
  for($prep) {
    if (Gimp::_gimp_procedure_available (\$_.\$subname)) {
      eval \"sub \$Gimp::${class}::AUTOLOAD { Gimp::gimp_call_procedure '\$_\$subname',\\\@_ }\";
      goto &\$Gimp::${class}::AUTOLOAD;
    }
  }
  Carp::croak \"function \$subname not found in Gimp::$class\";
}

sub ${class}::AUTOLOAD {
   \$Gimp::${class}::AUTOLOAD = \$${class}::AUTOLOAD;
   goto &Gimp::${class}::AUTOLOAD;
};

EOF
   die $@ if $@;
}

pseudoclass qw(Layer	gimp_layer gimp_drawable gimp);
pseudoclass qw(Image	gimp_image gimp);
pseudoclass qw(Drawable	gimp_drawable gimp);
pseudoclass qw(Selection gimp_selection);
pseudoclass qw(Channel	gimp_channel gimp_drawable gimp);
pseudoclass qw(Display	gimp_display gimp);
pseudoclass qw(Palette	gimp_palette);
pseudoclass qw(Plugin	plug_in);
pseudoclass qw(Gradients gimp_gradients);
pseudoclass qw(Edit	gimp_edit);

1;
__END__

=head1 NAME

Gimp::OO - Pseudo-OO for Gimp functions.

=head1 SYNOPSIS

  use Gimp::OO;

=head1 DESCRIPTION

After use'ing this module, the following classes are available to the user. 
You can drop the Gimp:: prefix from all packages, too.

All gimp functions can be called through these modules, there is some simple
rewriting going on, for example Gimp::Edit::gimp_quit is the same as
Gimp::gimp_quit. Further examples:

    $img=Gimp::Image::new(60,300,RGB) get's translated to $img=gimp_image_new(60,300,RGB).

    $img->delete get's translated to gimp_image_delete ($img).

    Palette::set_foreground get's translated to gimp_palette_set_foreground

    See example-oo.pl for a working extension using these techniques.

The following modules (with and without Gimp::) are available, with
the indicated rewritings:

=over 4

=item Layer

gimp_layer_*

gimp_drawable_*

gimp_*

=item Image

gimp_image_*

gimp_*

=item Drawable

gimp_drawable_*

gimp_*

=item Selection

gimp_selection_*

=item Channel

gimp_channel_*

gimp_drawable_*

gimp_*

=item Display

gimp_display_*

gimp_*

=item Palette

gimp_palette_*

=item Plugin

plug_in_*

=item Gradients

gimp_gradients_*

=item Edit

gimp_edit_*

=back

=head1 STATUS

This module is experimental, the API is subjedt to change.

=head1 AUTHOR

Marc Lehmann, pcg@goof.com

=head1 SEE ALSO

perl(1), Gimp(1),

=cut
