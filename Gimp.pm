package Gimp;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD %EXPORT_TAGS @EXPORT_FAIL);
use vars qw(@_consts @_procs @_internals $interface_pkg $interface_type @_param);

# vars used in argument processing
use vars qw($help $verbose $host);

require DynaLoader;

@ISA = qw(DynaLoader);
$VERSION = '0.90';

@_param = qw(
	PARAM_BOUNDARY	PARAM_CHANNEL	PARAM_COLOR	PARAM_DISPLAY	PARAM_DRAWABLE
	PARAM_END	PARAM_FLOAT	PARAM_FLOATARRAY		PARAM_IMAGE
	PARAM_INT16	PARAM_INT16ARRAY		PARAM_INT32	PARAM_INT32ARRAY
	PARAM_INT8	PARAM_INT8ARRAY	PARAM_LAYER	PARAM_PATH	PARAM_REGION
	PARAM_SELECTION	PARAM_STATUS	PARAM_STRING	PARAM_STRINGARRAY
);

@_consts = (@_param,qw(
	ADDITION_MODE	ALPHA_MASK	APPLY		BEHIND_MODE	BG_BUCKET_FILL
	BG_IMAGE_FILL	BILINEAR	BLACK_MASK	BLUE_CHANNEL	BLUR
	CLIP_TO_BOTTOM_LAYER		CLIP_TO_IMAGE	COLOR_MODE	CONICAL_ASYMMETRIC
	CONICAL_SYMMETRIC	CUSTOM	DARKEN_ONLY_MODE		DIFFERENCE_MODE
	DISCARD		DISSOLVE_MODE	EXPAND_AS_NECESSARY		FG_BG_HSV
	FG_BG_RGB	FG_BUCKET_FILL	FG_TRANS	GRAY		GRAYA_IMAGE
	GRAY_CHANNEL	GRAY_IMAGE	GREEN_CHANNEL	HUE_MODE	IMAGE_CLONE
	INDEXED		INDEXEDA_IMAGE	INDEXED_CHANNEL	INDEXED_IMAGE	LIGHTEN_ONLY_MODE
	LINEAR		MULTIPLY_MODE	NORMAL_MODE	NO_IMAGE_FILL	OVERLAY_MODE
	PATTERN_BUCKET_FILL		PATTERN_CLONE	PIXELS		POINTS
	PROC_EXTENSION	PROC_PLUG_IN	PROC_TEMPORARY	RADIAL		RED_CHANNEL
	REPEAT_NONE	REPEAT_SAWTOOTH	REPEAT_TRIANGULAR		RGB
	RGBA_IMAGE	RGB_IMAGE	RUN_INTERACTIVE	RUN_NONINTERACTIVE
	RUN_WITH_LAST_VALS		SATURATION_MODE	SCREEN_MODE	SELECTION_ADD
	SELECTION_INTERSECT		SELECTION_REPLACE		SELECTION_SUB
	SHAPEBURST_ANGULAR		SHAPEBURST_DIMPLED		SHAPEBURST_SPHERICAL
	SHARPEN		SQUARE		STATUS_CALLING_ERROR		STATUS_EXECUTION_ERROR
	STATUS_PASS_THROUGH		STATUS_SUCCESS	SUBTRACT_MODE	TRANS_IMAGE_FILL
	VALUE_MODE	WHITE_IMAGE_FILL		WHITE_MASK
	
	ALL_HUES	RED_HUES	YELLOW_HUES	GREEN_HUES	CYAN_HUES
	BLUE_HUES	MAGENTA_HUES
	
	TRACE_NONE	TRACE_CALL	TRACE_TYPE	TRACE_NAME	TRACE_DESC
	TRACE_ALL
));

# procs an interface module must(!) implement somehow
@_procs = qw(
	gimp_main			gimp_install_procedure		gimp_call_procedure
	
	gimp_quit			gimp_progress_init		gimp_progress_update
	gimp_register_save_handler	gimp_register_magic_load_handler
	gimp_register_load_handler	gimp_gamma			gimp_install_cmap
	gimp_use_xshm			gimp_color_cube			gimp_gtkrc
	gimp_image_new			gimp_image_delete		gimp_image_width
	gimp_image_height		gimp_image_base_type		gimp_image_floating_selection
	gimp_image_add_channel		gimp_image_add_layer		gimp_image_add_layer_mask
	gimp_image_clean_all		gimp_image_disable_undo		gimp_image_enable_undo
	gimp_image_flatten		gimp_image_lower_channel	gimp_image_lower_layer
	gimp_image_merge_visible_layers	gimp_image_pick_correlate_layer	gimp_image_raise_channel
	gimp_image_raise_layer		gimp_image_remove_channel	gimp_image_remove_layer
	gimp_image_remove_layer_mask	gimp_image_resize		gimp_image_get_active_channel
	gimp_image_get_active_layer	gimp_image_get_channels		gimp_image_get_cmap
	gimp_image_get_component_active	gimp_image_get_filename		gimp_image_get_layers
	gimp_image_get_selection	gimp_image_set_active_channel	gimp_image_set_active_layer
	gimp_image_set_cmap		gimp_image_set_component_active	gimp_image_set_component_visible
	gimp_image_set_filename		gimp_display_new		gimp_display_delete
	gimp_displays_flush		gimp_layer_new			gimp_layer_copy
	gimp_layer_delete		gimp_layer_width		gimp_layer_height
	gimp_layer_bpp			gimp_layer_type			gimp_layer_add_alpha
	gimp_layer_create_mask		gimp_layer_resize		gimp_layer_scale
	gimp_layer_translate		gimp_layer_get_image_id		gimp_layer_is_floating_selection
	gimp_layer_get_mask_id		gimp_layer_get_apply_mask	gimp_layer_get_edit_mask
	gimp_layer_get_mode		gimp_layer_get_name		gimp_layer_get_opacity
	gimp_layer_get_show_mask	gimp_layer_get_visible		gimp_layer_get_preserve_transparency
	gimp_layer_set_apply_mask	gimp_layer_set_edit_mask	gimp_layer_set_mode
	gimp_layer_set_name		gimp_layer_set_offsets		gimp_layer_set_opacity
	gimp_layer_set_show_mask	gimp_layer_set_visible		gimp_layer_set_preserve_transparency
	gimp_channel_new		gimp_channel_copy		gimp_channel_delete
	gimp_channel_width		gimp_channel_height		gimp_channel_get_image_id
	gimp_channel_get_layer_id	gimp_channel_get_color		gimp_channel_get_name
	gimp_channel_get_opacity	gimp_channel_get_visible	gimp_channel_set_name
	gimp_channel_set_opacity	gimp_channel_set_visible	gimp_drawable_get
	gimp_drawable_detach		gimp_drawable_flush		gimp_drawable_delete
	gimp_drawable_update		gimp_drawable_merge_shadow	gimp_drawable_image_id
	gimp_drawable_name		gimp_drawable_width		gimp_drawable_height
	gimp_drawable_bpp		gimp_drawable_type		gimp_drawable_visible
	gimp_drawable_channel		gimp_drawable_color		gimp_drawable_gray
	gimp_drawable_has_alpha		gimp_drawable_indexed		gimp_drawable_layer
	gimp_drawable_layer_mask	gimp_drawable_fill		gimp_drawable_set_name
	gimp_drawable_set_visible
	
	gimp_tile_cache_size		gimp_tile_cache_ntiles		gimp_tile_width
	gimp_tile_height
	
	gimp_gradients_get_active	gimp_gradients_set_active
	
	gimp_set_data			gimp_get_data
);

# internal procedure not to be exported
@_internals = qw(
	_gimp_procedure_available	set_trace
);

use subs @_consts;
use subs @_procs;

sub ALL_HUES		{ 0 };
sub RED_HUES		{ 1 };
sub YELLOW_HUES		{ 2 };
sub GREEN_HUES		{ 3 };
sub CYAN_HUES		{ 4 };
sub BLUE_HUES		{ 5 };
sub MAGENTA_HUES	{ 6 };

# internal constants shared with Perl-Server

sub _PS_FLAG_QUIET	{ 0000000001 };	# do not output messages
sub _PS_FLAG_BATCH	{ 0000000002 }; # started via Gimp::Net, extra = filehandle

# we really abuse the import facility..
sub import($;@) {
   no strict 'refs';
   
   my $pkg = shift;
   my $up = caller();
   my @export;
   
   # make a quick but dirty guess ;)
   
   for(@_) {
      if ($_ eq ":auto") {
         push(@export,@_consts);
         push(@export,@_procs);
         push @{"${up}::ISA"},'Gimp';
      } elsif ($_ eq ":consts") {
         push(@export,@_consts);
      } elsif ($_ eq ":param") {
         push(@export,@_param);
      } elsif (/^interface=(\S+)$/) {
         $interface_type=$1;
      } else {
         croak "$_ is not a valid import tag for package $pkg";
      }
   }
   
   if ($interface_type=~/^lib$/i) {
      $interface_pkg="Gimp::Lib";
   } elsif ($interface_type=~/^net$/i) {
      $interface_pkg="Gimp::Net";
   } else {
      croak "interface '$interface_type' unsupported, use either 'lib' or 'net'";
   }
   
   # has to be done first. the "eval EXPR" form is necessary.
   use vars qw($interface_imported);
   if ($interface_imported ne $interface_pkg) {
      $interface_imported=$interface_pkg;
      eval "require $interface_pkg" or croak "$@";
      import $interface_pkg ();
      for((@_procs,@_internals)) {
         *$_ = \&{"${interface_pkg}::$_"};
      }
   }
   
   for(@export) {
      *{"${up}::$_"} = \&$_;
   }
}

sub AUTOLOAD {
   my $constname;
   ($constname = $AUTOLOAD) =~ s/.*:://;
   my $val = constant($constname, @_ ? $_[0] : 0);
   if ($! != 0) {
      if ($! =~ /Invalid/) {
         no strict 'refs';
         ${"${interface_pkg}::AUTOLOAD"}=$AUTOLOAD;
         goto &{"${interface_pkg}::AUTOLOAD"};
      } else {
         croak "Your vendor has not defined Gimp macro $constname";
      }
   }
   eval "sub $AUTOLOAD { $val }";
   goto &$AUTOLOAD;
}

# this is duplicated in Gimp/Lib.xs.. FIX!
sub canonicalize_colour {
   if (@_ == 3) {
      [@_];
   } elsif (ref $_[0]) {
      $_[0];
   } elsif ($_[0] =~ /^#([0-9a-f]{2,2})([0-9a-f]{2,2})([0-9a-f]{2,2})$/) {
      [map {eval "0x$_"} ($1,$2,$3)];
   } else {
      croak "Unable to grok ".join(",",@_)," as colour specifier";
   }
}

*canonicalize_color = \&canonicalize_colour;

$interface_type = "net";
if (@ARGV) {
   if ($ARGV[0] eq "-gimp") {
      $interface_type = "lib";
      # ignore other parameters completely
   } else {
      while(@ARGV) {
         $_=shift(@ARGV);
         if (/^-h$|^--?help$|^-\?$/) {
            $help=1;
            print <<EOF;
Usage: $0 [gimp-args..] [interface-args..] [script-args..]
       gimp-arguments are
           -gimp <anything>           used internally only
           -h | -help | --help | -?   print some help
           -v | --verbose             be more verbose in what you do
           --host|--tcp HOST[:PORT]   connect to HOST (optionally using PORT)
                                      (for more info, see Gimp::Net(3))
EOF
         } elsif (/^-v$|^--verbose$/) {
            $verbose++;
         } elsif (/^--host$|^--tcp$/) {
            $host=shift(@ARGV);
         } else {
            unshift(@ARGV,$_);
            last;
         }
      }
   }
}

bootstrap Gimp $VERSION;

__END__

=head1 NAME

Gimp - Perl extension for writing Gimp Extensions/Plug-ins/Load & Save-Handlers

This is mostly a reference manual. For a quick intro, look at the Gimp::Fu
manpage.

=head1 RATIONALE

Well, scheme (which is used by script-fu), is IMnsHO the crappiest language
ever (well, the crappiest language that one actually can use, so it's not
_that_ bad). Scheme has the worst of all languages, no data types, but still
using variables. Look at haskell to see how functional is done right.

I'd loved to write a haskell interface instead, but it was sooo much easier
in perl (at least for me..), so here's the Gimp <-> Perl interface, mostly a
direct libgimp interface. Needless to say, it was (is) very instructive,
too.

=head1 SYNOPSIS

  use Gimp;
  
  Other modules of interest:
  
  use Gimp::Util;
  use Gimp::OO;
  use Gimp::Fu;
  
  these have their own manpage.

=head2 IMPORT TAGS

If you don't give an interface= hint, we will guess a default which might be
wrong in future versions of the Gimp, so watch out!

=over 4

=item :auto

Import useful constants, like RGB, RUN_NONINTERACTIVE... as well as all
libgimp and pdb functions automagically into the caller's namespace. BEWARE!
This will overwrite your AUTOLOAD function, if you have one!

=item :param

Import PARAM_* constants (PARAM_INT32, PARAM_STRING etc.)

=item :consts

The constants from gimpenums.h (BG_IMAGE_FILL, RUN_NONINTERACTIVE etc.)

=item interface=lib

Use direct interface via libgimp.

=item interface=net

Use network interface using Net-Server and Gimp::Net.

=back
  
=head1 GETTING STARTED

Dov Grobgeld has written an excellent tutorial for Gimp-Perl. While not
finished, it's definitely better than this section currently. You can find
it at http://imagic.weizmann.ac.il/~dov/gimp/perl-tut.html

=head1 DESCRIPTION

Look at the sample plug-ins that come with
this module. If you write other plug-ins, send them to me! If you have
question on use, you might as well ask me (although I'm a busy man, so be
patient, or wait for the next version ;)

It might also prove useful to know how a plug-in is written in C, so
have a look at some existing plug-ins in C!

Anyway, feedback is appreciated, otherwise, I won't publish future version.

And have a look at the other modules, Gimp::Util and Gimp::OO, and maybe
the interface modules Gimp::Lib and Gimp::Net.

Some highlites:

=over 2

=item *
Networked plug-ins and plug-ins using the libgimp interfaces (i.e. to be
started by The Gimp) are written alsmot the same way, you can easily create
hybrid (network & libgimp) scripts as well.

=item *
Use either a plain pdb (scheme-like) interface or nice object-oriented
syntax, i.e. "gimp_layer_new(600,300,RGB)" is the same as "new Image(600,300,RGB)"

=back

noteworthy limitations (subject to be changed):

=over 2

=item *
callback procedures do not return anything to The Gimp, not even a status
argument, which seems to be mandatory by the gimp protocol (which is
nowhere standardized, though).

=item *
The tile and region functions are not yet supported.

=back

=head1 CALLBACKS

=over 4

=item init (), query (), quit (), <installed_procedure>()

the standard libgimp callback functions. run() is missing, because this
module will directly call the function you registered with
gimp_install_procedure.

=item net ()

this is called when the plug-in is not started from within Gimp, but is using
Net-Server (the perl network server extension you hopefully have installed
and started ;)

=back

=head1 FUNCTIONS

=over 4

=item set_trace (tracemask)

Tracking down bugs in gimp scripts is difficult: no sensible error messages.
If anything goes wrong, you only get an execution failure. Switch on
tracing to see which parameters are used to call pdb functions.

This function is never exported, so you have to qualify it when calling.
(not yet implemented for networked modules).

tracemask is any number of the following flags or'ed together.

=over 8

=item TRACE_NONE

nothing is printed.

=item TRACE_CALL

all pdb calls (and only pdb calls!) are printed
with arguments and return values.

=item TRACE_TYPE

the parameter types are printed additionally.

=item TRACE_NAME

the parameter names are printed.

=item TRACE_DESC

the parameter descriptions.

=item TRACE_ALL

all of the above.

=back

=item set_trace(\$tracevar)

write trace into $tracevar instead of printing it to STDERR. $tracevar only
contains the last command traces, i.e. it's cleared on every gimp_call_procedure
invocation.

=item set_trace(*FILEHANDLE)

write trace to FILEHANDLE instead of STDERR.

=item gimp_main()

Should be called immediately when perl is initialized. Arguments are not yet
supported. Initializations can later be done in the init function.

=item gimp_install_procedure(name, blurb, help, author, copyright, date, menu_path, image_types, type, [params], [return_vals])

Mostly same as gimp_install_procedure. The parameters and return values for
the functions are specified as an array ref containing either integers or
array-refs with three elements, [PARAM_TYPE, \"NAME\", \"DESCRIPTION\"].

=item gimp_progress_init(message)

Initializes a progress bar. In networked modules this is a no-op.

=item gimp_progress_update(percentage)

Updates the progress bar. No-op in networked modules.

=back

Some functions that have a different calling convention than pdb functions
but the same name are not visible in the perl module. (i.e. pdb functions
have priority on name clashes)

=head1 SUPPORTED GIMP DATA TYPES

Gimp supports different data types like colors, regions, strings. In
perl, these are represented as:

=over 4

=item INT32, INT16, INT8, FLOAT, STRING

normal perl scalars. Anything except STRING will be mapped
to a perl-double.

=item INT32ARRAY, INT16ARRAY, INT8ARRAY, FLOATARRAY, STRINGARRAY

array refs containing scalars of the same type, i.e. [1, 2, 3, 4].
(not yet supported).

=item COLOR

on input, either an array ref with 3 elements (i.e. [233,40,40])
or a X11-like string is accepted ("#rrggbb").

=item REGION

Not yet supported.

=item DISPLAY, IMAGE, LAYER, CHANNEL, DRAWABLE, SELECTION

These will be mapped to corresponding objects (IMAGE => Gimp::Image). In trace
output you will see small integers (the image/layer/etc..-ID)

=item BOUNDARY, PATH, STATUS

Not yet supported.

=back

=head1 PLEASE

if you get this far while reading the manpage, please consider helping
me with the documentation, or write scripts etc... ;) thanks!

=head1 AUTHOR

Marc Lehmann <pcg@goof.com>

=head1 SEE ALSO

perl(1), gimp(1), Gimp:OO(3), Gimp::Data(3), Gimp::Util(3).

=cut
