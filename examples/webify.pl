#!/usr/bin/perl -w

use Gimp qw(:consts);
use Gimp::Fu;

Gimp::set_trace(TRACE_ALL);

register "webify",
         "Make an image suitable for the web",
         "This plug-in converts the image to indexed, with some extra options",
         "Marc Lehmann",
         "Marc Lehmann",
         "19980911",
         "<Image>/Filters/Misc/Webify",
         "RGB*, GRAY*",
         [
          [PF_BOOL,	"new",		"create a new image?", 1],
          [PF_BOOL,	"transparent",	"make transparent?", 1],
          [PF_COLOUR,	"bg colour",	"the background colour to use for transparency", "white"],
          [PF_INT32,	"threshold",	"the threshold to use for background detection", 3],
          [PF_INT32,	"colours",	"how many colours to use (0 = don't convert to indexed)", 32],
          [PF_BOOL,	"autocrop",	"autocrop at end?", 1],
         ],
         sub {					# es folgt das eigentliche Skript...
   my($img,$drawable,$new,$alpha,$bg,$thresh,$colours,$autocrop)=@_;
   
   print "$img,$drawable,$new,$alpha,$bg,$thresh,$colours,$autocrop\n";
   
   $img = $img->channel_ops_duplicate if $new;
   $drawable = $img->flatten;
   
   if ($alpha) {
      $drawable->add_alpha;
      $drawable->by_color_select($bg,$thresh,SELECTION_REPLACE,1,0,0,0);
      $drawable->edit_cut if $img->selection_bounds;
   }
   Plugin->autocrop(RUN_NONINTERACTIVE,$img,$drawable) if $autocrop;
   $img->convert_indexed (1, $colours) if $colours;
   
   $new ? ($img->clean_all, $img) : undef;
};

exit main;










