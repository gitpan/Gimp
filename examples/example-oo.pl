#!/usr/bin/perl

# this extension shows some oo-like calls

# it's really easy

use Gimp qw( :auto );
use Gimp::Util;
use Gimp::OO;

# the extension that's called.
sub extension_perl_experimental {
  
  my $img=new Image(300,200,RGB);
  
  my $bg=new Layer($img,300,200,RGB_IMAGE,"Background",100,NORMAL_MODE);
  
  Palette::set_background([200,100,200]);
  
  $bg->fill(BG_IMAGE_FILL);
  $img->add_layer($bg,1);
  
  new Display($img);
}

sub net {
  extension_perl_experimental;
}

sub query {
  gimp_install_extension("extension_perl_experimental", "a test extension in perl",
                         "try it out", "Marc Lehmann", "Marc Lehmann", "1997-02-06",
                         "<Toolbox>/Xtns/Perl-Experimental-OO", "*");
}

exit gimp_main;

