package Gimp::Fu;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD @EXPORT_FAIL @PREFIXES);
use Gimp qw(:param);
use Gtk;

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter);
@EXPORT = ();
@EXPORT_OK = qw(interact);

sub interact($@) {
   my(@types)=@{shift()};
   my(@getres);
   my($w,$t,$button,$box,$bot);
   my $res=0;
   
   print "getting ",join(":",@_),"\n";#d#
   $t = new Gtk::Tooltips;
   
   $w = new Gtk::Dialog;
   set_title $w "main window";
   
   for(@types) {
      my($d,$e,$f);
      my($type,$name,$desc)=@$_;
      my($value)=shift;
      undef $e;
      if($type == PARAM_INT8
      || $type == PARAM_INT16
      || $type == PARAM_INT32
      || $type == PARAM_FLOAT
      || $type == PARAM_STRING) {
         $d=new Gtk::Label "$name: ";
         show $d;
         $f=new Gtk::Entry;
         show $f;
         set_usize $f 0,25;
         set_text $f $value;
         #select_region $f 0,1;
         $e=new Gtk::HBox(0,0);
         $e->pack_start($d,0,1,0);
         $e->pack_end($f,1,1,0);
         set_tip $t $f,$desc;
         push(@getres,,sub{get_text $f});
      } elsif($type == PARAM_COLOR) {
         $d=new Gtk::Label "$name: ";
         show $d;
         $f=new Gtk::ColorSelection;
         show $f;
         set_color $f @{$value};
         $e=new Gtk::HBox(0,0);
         $e->pack_start($d,0,1,0);
         $e->pack_end($f,1,1,0);
         push(@getres,sub{[get_color $f]});
      } else {
         $e=new Gtk::Label "Unsupported type $type";
         push(@getres,sub{$value});
      }
      
      $e && do {
         $w->vbox->pack_start($e,1,1,0);
         show $e;
      };
      $res++;
   }
   $res=0;
   
   signal_connect $w "destroy", sub {main_quit Gtk};
   signal_connect $w "delete_event", sub {main_quit Gtk};

   $button = new Gtk::Button "OK";
   signal_connect $button "clicked", sub {$res = 1; main_quit Gtk};
   $w->action_area->pack_start($button,1,1,0);
   can_default $button 1;
   grab_default $button;
   show $button;
   
   $button = new Gtk::Button "Cancel";
   signal_connect $button "clicked", sub {main_quit Gtk};
   $w->action_area->pack_start($button,1,1,0);
   show $button;
   
   show $w;
   main Gtk;
   print "gtk sucked, res = $res\n";
   @_=map {&$_} @getres;
   @_;
}

1;
__END__

=head1 NAME

Gimp::Fu - Query the user for parameters

=head1 SYNOPSIS

  use Gimp::Fu;

=head1 DESCRIPTION

This module uses Gtk. Nice description, isn't it?

=head1 STATUS

This module is experimental.

=head1 AUTHOR

Marc Lehmann, pcg@goof.com

=head1 SEE ALSO

perl(1), Gimp(1),

=cut
