package Gtk::ColorSelectButton;

=head1 NAME

Gtk::ColorSelectButton - A clickable colour preview label

=head1 SYNOPSIS

    use Gtk::ColorSelectButton;

    $color_button = Gtk::ColorSelectButton->new();
    $hbox->pack_start($color_button, 1,1,0);
    $color_button->show();

    ...
    print join(" ",$color_button->color);
    ...

=head1 DESCRIPTION

Gtk::ColorSelectButton shows a button with a uniform color. Pressing
this buton pops up the color_selection dialog in which a new color
may be chosen. When the color selection dialog is closed, the chosen
color is reflected in the color of the button.

The member function C<color> provides a way to access the chosen color.

=head1 AUTHOR

Dov Grobgeld <dov@imagic.weizmann.ac.il>

=head1 COPYRIGHT

Copyright (c) 1998 Dov Grobgeld. All rights reserved. This program may
be redistributed and copied under the same licence as Perl itself.

=cut

use strict;
use vars qw($VERSION @ISA);
use Gtk;

$VERSION = "0.10";
@ISA = qw(Gtk::Button);

# Class defaults data
my $class_preview_width = 50;
my $class_preview_height = 15;
my @class_def_color = (255,175,0);

sub new {
    # Defaults
    my $pkg = shift;
    my (@color) = @class_def_color;
    my ($preview_width, $preview_height) = ($class_preview_width,
					    $class_preview_height);
    local($_); # Can't use my on $_
    
    # Parse options
    while($_ = $_[0], /^-/) {
	shift;
	/^-color/ and do { @color = @{shift()}; next; };
	/^-width/ and do { $preview_width = shift; next; };
	/^-height/ and do { $preview_height = shift; next; };
	die "Gtk::ColorSelectButton: Unknown option $_ in new()!\n";
    }
	  
    my $color_button = bless Gtk::Button->new(), $pkg;
    my $preview = new Gtk::Preview("color");
    $preview->size($preview_width,$preview_height);
    $color_button->{preview} = $preview;
    $color_button->{preview_width} = $preview_width;
    $color_button->{preview_height} = $preview_height;
    $color_button->{color} = [@color];
    
    $color_button->add($preview);
    $color_button->signal_connect("clicked",
				  \&cb_color_button);

    $color_button->paint_preview();
    $preview->show();
    return $color_button;
}

sub paint_preview($) {
    my($this) = shift;
    my($preview, $color) = ($this->{preview}, $this->{color});
    my($width, $height) = ($this->{preview_width}, $this->{preview_height});

    my($buf) = pack("C3", @$color) x $width;

    for(my $i=0;$i<$height;$i++) {
	$preview->draw_row($buf, 0, $i, $width);
    }
    $preview->draw(undef);
}

sub color_selection_ok {
    my($widget, $dialog, $color_button) = @_;
	
    my(@color) = $dialog->colorsel->get_color;
    @{$color_button->{color}} = map(int(255.99*$_),@color);

    $color_button->paint_preview();
    $dialog->destroy();
}

sub cb_color_button {
    my($color_button) = @_;

    my $cs_window=new Gtk::ColorSelectionDialog("Color");
    $cs_window->show();
    $cs_window->colorsel->set_color(map($_*1/255,@{$color_button->color}));
    $cs_window->ok_button->signal_connect("clicked",
					  \&color_selection_ok,
					  $cs_window,
					  $color_button);
    $cs_window->cancel_button->signal_connect("clicked",
					      sub { $cs_window->destroy });
}

sub set_color {
    my $this = shift;

    $this->{color} = shift;
    $this->paint_preview();
}

sub color { return shift->{color} }
sub width { return shift->{preview_width} };
sub height { return shift->{preview_height} };

1;
