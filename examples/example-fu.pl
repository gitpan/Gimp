#!/usr/bin/perl

# this extension shows some oo-like calls

# it's really easy

use Gimp qw( :auto );
use Gimp::Util;
use Gimp::OO;

# the extension that's called.
sub plug_in_example_fu {
  
  my $img=new Image(300,200,RGB);
  
  my $bg=new Layer($img,300,200,RGB_IMAGE,"Background",100,NORMAL_MODE);
  
  Palette::set_background([200,100,200]);
  
  $bg->fill(BG_IMAGE_FILL);
  $img->add_layer($bg,1);
  
  new Display($img);
}

sub net {
  plug_in_example_fu;
}

sub query {
  gimp_install_procedure("plug_in_example_fu", "an example perl-fu script",
                         "try it out", "Marc Lehmann", "Marc Lehmann", "1998-04-21",
                         "<Toolbox>/Xtns/Perl-Fu/Example Plug-in", "*", PROC_PLUGIN,
                         [[PARAM_INT32, "run_mode", "Interactive, [non-interactive]"]], []);
}

exit gimp_main;

