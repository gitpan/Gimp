#!/usr/bin/perl

# example for the gimp-perl-server (also called Server)

use Gimp qw(:consts);
use Gimp::Net qw(:procs);

sub net {
  # simple benchmark ;)
  
  $img=gimp_image_new(600,300,RGB);
  print "$img\n";
  $bg=gimp_layer_new($img,30,20,RGB_IMAGE,"Background",100,NORMAL_MODE);
  gimp_image_add_layer($img,$bg,1);
  gimp_display_new($img);
  
  for $i (0..255) {
     gimp_palette_set_background([$i,255-$i,$i]);
     gimp_edit_fill ($img,$bg);
     gimp_displays_flush ();
  }
  
#  Gimp::Net::server_quit;  # kill the gimp-perl-server-extension (ugly name)
}

exit(gimp_main());




