#!/usr/bin/perl

# example for the gimp-perl-server (also called Net-Server)

use Gimp qw( :auto );
use Gimp::OO;

sub net {
  # simple benchmark ;)
  
  $img=new Gimp::Image(600,300,RGB);
  # the is the same as $img = new Image(600,300,RGB)
  
  $bg=$img->layer_new(30,20,RGB_IMAGE,"Background",100,NORMAL_MODE);
  
  $img->add_layer($bg,1);
  
  new Gimp::Display($img);
  
  for $i (0..255) {
     Palette::set_background([$i,255-$i,$i]);
     $img->edit_fill ($bg);
     Display::displays_flush ();
  }
  
#  Gimp::Net::server_quit;  # kill the gimp-perl-server-extension (ugly name)
}

exit gimp_main;



