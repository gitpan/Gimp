#!/usr/bin/perl

# example for the gimp-perl-server (also called Net-Server)

use Gimp qw( :auto );
use Gimp::OO;

sub net {
  # simple benchmark ;)
  
  $img=Gimp::Image::new(600,300,RGB);
  $bg=$img->layer_new(30,20,RGB_IMAGE,"Background",100,NORMAL_MODE);
  $img->add_layer($bg,1);
  Gimp::Display::new($img);
  
  for $i (0..255) {
     Gimp::Palette::set_background([$i,255-$i,$i]);
     gimp_edit_fill ($img,$bg);
     Gimp::Display::displays_flush ();
  }
  
#  Gimp::Net::server_quit;  # kill the gimp-perl-server-extension (ugly name)
}

exit gimp_main;




