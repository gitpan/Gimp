#!/usr/bin/perl

use Gimp qw(:consts);
use Gimp::Fu;

register "my_first_gimp_fu",				# fill in name
         "My very first Gimp::Fu script",		# and a small description,
         "Just a starting point to derive new scripts",	# a help text
         "My name",					# don't forget your name (author)
         "My name (my copyright)",			# and your copyright!
         "19980506",					# the date this script was written
         "<Toolbox>/Xtns/MY Very First",		# the menu path
         "*",						# which image types do I accept (all)
         [
          [PF_STRING	, "text"	, "The Message"			, "example text"],
          [PF_FONT	, "font"	, "The Font Family"		, "helvetica"],
          [PF_INT32	, "size"	, "Font Size"			, 20],
          [PF_COLOR	, "text colour"	, "The (foreground) text colour", [10,10,10]],
          [PF_COLOR	, "bg colour"	, "The background colour"	, "#ff8000"],
          [PF_TOGGLE	, "ignore cols" , "Ignore colours"		, 0],
         ],
         sub {
   
   # now do sth. useful with the garbage we got ;)
   my($text,$font,$size,$fg,$bg,$ignore)=@_;
   
   my $img=new Image(300,200,RGB);
   
   my $l=new Layer($img,300,200,RGB_IMAGE,"Background",100,NORMAL_MODE);
   $img->add_layer($l,0);
   
   Palette->set_foreground($fg) unless $ignore;
   Palette->set_background($bg) unless $ignore;
   
   fill $l BG_IMAGE_FILL;
   $t=$img->text(-1,10,10,$text,5,1,$size,PIXELS,"*",$font,"*","*","*","*");
   
   $img;	# return the image, or undef
};

exit main;










