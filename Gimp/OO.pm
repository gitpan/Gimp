1;
__END__

=head1 NAME

Gimp::OO - Pseudo-OO for Gimp functions.

=head1 SYNOPSIS

  use Gimp;
  
  [yes, the functionality has been moved into the Gimp module]

=head1 DESCRIPTION

The following classes are available to the user (you can drop the Gimp::
prefix from all packages):

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

=item Progress

gimp_progress_*

=item Tile

gimp_tile_*

=item Region

gimp_region_*

=back

=head1 AUTHOR

Marc Lehmann <pcg@goof.com>

=head1 SEE ALSO

perl(1), L<Gimp>,

=cut
