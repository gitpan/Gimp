package Gimp::UI;

use Carp;
use Gimp;
use Gtk;

$VERSION = $Gimp::VERSION;

=head1 NAME

Gimp::UI - "simulation of libgimpui"

=head1 SYNOPSIS

  use Gimp::UI;

=head1 DESCRIPTION

Due to the braindamaged (read: "unusable") libgimpui API, I had to
reimplement it in perl.

=cut

@Gimp::UI::ImageMenu::ISA   =qw(Gimp::UI);
@Gimp::UI::LayerMenu::ISA   =qw(Gimp::UI);
@Gimp::UI::ChannelMenu::ISA =qw(Gimp::UI);
@Gimp::UI::DrawableMenu::ISA=qw(Gimp::UI);

sub Gimp::UI::ImageMenu::_items {
  map [[$_],$_,$_->get_filename],
      Gimp->list_images ();
}
sub Gimp::UI::LayerMenu::_items {
  map { my $i = $_; map [[$i,$_],$_,$i->get_filename."/".$_->get_name],$i->get_layers }
      Gimp->list_images ();
}

sub Gimp::UI::ChannelMenu::_items {
  map { my $i = $_; map [[$i,$_],$_,$i->get_filename."/".$_->get_name],$i->get_channels }
      Gimp->list_images ();
}

sub Gimp::UI::DrawableMenu::_items {
  map { my $i = $_; map [[$i,$_],$_,$i->get_filename."/".$_->get_name],($i->get_layers, $i->get_channels) }
      Gimp->list_images ();
}

sub new($$$$) {
   my($class,$constraint,$active)=@_;
   my(@items)=$class->_items;
   my $menu = new Gtk::Menu;
   for(@items) {
      my($constraints,$result,$name)=@$_;
      next unless &$constraint(@{$constraints});
      my $item = new Gtk::MenuItem $name;
      $item->show;
      $item->signal_connect(activate => sub { $_[3]=$result });
      $menu->append($item);
   }
   if (@items) {
      $_[3]=$items[0]->[1];
   } else {
      my $item = new Gtk::MenuItem "(none)";
      $item->show;
      $menu->append($item);
   }
   $menu;
}

=head1 AUTHOR

Marc Lehmann <pcg@goof.com>

=head1 SEE ALSO

perl(1), L<Gimp>.

=cut
