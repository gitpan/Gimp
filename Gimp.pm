package Gimp;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD %EXPORT_TAGS @EXPORT_FAIL);
use vars qw(@_consts @_procs @_internals $interface_pkg $interface_type @_param);

# vars used in argument processing
use vars qw($help $verbose $host);

require DynaLoader;

@ISA = qw(DynaLoader);
$VERSION = '0.97';

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
	
	MESSAGE_BOX	CONSOLE
	
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
	gimp_drawable_set_visible	gimp_drawable_get_tile		gimp_drawable_get_tile2
	
	gimp_tile_cache_size		gimp_tile_cache_ntiles		gimp_tile_width
	gimp_tile_height		gimp_tile_flush
	
	gimp_gradients_get_active	gimp_gradients_set_active
	
	gimp_set_data			gimp_get_data

	gimp_pixel_rgn_init		gimp_pixel_rgn_resize		gimp_pixel_rgn_get_pixel
	gimp_pixel_rgn_get_row		gimp_pixel_rgn_get_col		gimp_pixel_rgn_get_rect
	gimp_pixel_rgn_set_pixel	gimp_pixel_rgn_set_row		gimp_pixel_rgn_set_col
	gimp_pixel_rgn_set_rect
	
	gimp_list_images

	gimp_gdrawable_width		gimp_gdrawable_height		gimp_gdrawable_ntile_rows
	gimp_gdrawable_ntile_cols	gimp_gdrawable_bpp		gimp_gdrawable_id

	gimp_pixel_rgn_x		gimp_pixel_rgn_y		gimp_pixel_rgn_w
	gimp_pixel_rgn_h		gimp_pixel_rgn_rowstride	gimp_pixel_rgn_bpp
	gimp_pixel_rgn_dirty		gimp_pixel_rgn_shadow		gimp_pixel_rgn_drawable

	gimp_tile_ewidth		gimp_tile_eheight		gimp_tile_bpp
	gimp_tile_shadow		gimp_tile_gdrawable

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

sub MESSAGE_BOX		{ 0 };
sub CONSOLE		{ 1 };

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
         push(@export,@_consts,@_procs,"AUTOLOAD");
#         push @{"${up}::ISA"},'Gimp';
      } elsif ($_ eq ":consts") {
         push(@export,@_consts);
      } elsif ($_ eq ":param") {
         push(@export,@_param);
      } elsif (/^interface=(\S+)$/) {
         croak "interface=... tag is no longer supported\n";
      } else {
         croak "$_ is not a valid import tag for package $pkg";
      }
   }
   
   for(@export) {
      *{"${up}::$_"} = \&$_;
   }
}

sub AUTOLOAD {
   my $constname;
   ($constname = $AUTOLOAD) =~ s/.*:://;
   my $val = constant($constname);
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

if ($interface_type=~/^lib$/i) {
   $interface_pkg="Gimp::Lib";
} elsif ($interface_type=~/^net$/i) {
   $interface_pkg="Gimp::Net";
} else {
   croak "interface '$interface_type' unsupported.";
}

eval "require $interface_pkg" or croak "$@";
$interface_pkg->import();
for(@_procs,@_internals) {
   no strict 'refs';
   *$_ = \&{"${interface_pkg}::$_"};
}

bootstrap Gimp $VERSION;

package Gimp::OO;

use vars qw($AUTOLOAD);
use Carp;

sub AUTOLOAD {
   no strict 'refs';
   my ($class,$subname) = $AUTOLOAD =~ /^(.*)::(.*?)$/;
   for(@{"${class}::PREFIXES"}) {
      my $sub = $_.$subname;
      if (defined($Gimp::{$sub})) {
         my $ref = \&{"Gimp::$sub"};
         *{$AUTOLOAD} = sub {
            shift if $_[0] eq $class;
            return &$ref;	# simulate goto until repaired
            goto &$ref;		#d##fixme#
         };
         goto &$AUTOLOAD;
      } elsif (Gimp::_gimp_procedure_available ($_.$subname)) {
         *{$AUTOLOAD} = sub {
            shift if $_[0] eq $class;
            Gimp::gimp_call_procedure($sub,@_);
         };
         goto &$AUTOLOAD;
      }
   }
   croak "function $subname not found in $class";
}

sub DESTROY {};

sub _pseudoclass {
  no strict 'refs';
  my ($class, @prefixes)= @_;
  unshift(@prefixes,"");
  @{"Gimp::${class}::ISA"}	= @{"${class}::ISA"}		= ('Gimp::OO');
  @{"Gimp::${class}::PREFIXES"}	= @{"${class}::PREFIXES"}	= @prefixes;
}

_pseudoclass qw(Layer		gimp_layer_ gimp_drawable_ gimp_);
_pseudoclass qw(Image		gimp_image_ gimp_drawable_ gimp_);
_pseudoclass qw(Drawable	gimp_drawable_ gimp_);
_pseudoclass qw(Selection 	gimp_selection_);
_pseudoclass qw(Channel		gimp_channel_ gimp_drawable_ gimp_);
_pseudoclass qw(Display		gimp_display_ gimp_);
_pseudoclass qw(Palette		gimp_palette_);
_pseudoclass qw(Plugin		plug_in_);
_pseudoclass qw(Gradients	gimp_gradients_);
_pseudoclass qw(Edit		gimp_edit_);
_pseudoclass qw(Progress	gimp_progress_);
_pseudoclass qw(Region		);

_pseudoclass qw(GDrawable	gimp_drawable_);
_pseudoclass qw(PixelRgn	gimp_pixel_rgn_);
_pseudoclass qw(Tile		gimp_tile_);

package Gimp::Tile;

*Tile:: = *Gimp::Tile::;

sub data {
   my $self = shift;
   $self->set_data(@_) if @_;
   defined(wantarray) ? $self->get_data : undef;
}

package Gimp::GDrawable;

sub pixel_rgn($$$$$$) {
   Gimp::gimp_pixel_rgn_init(@_);
}

package Gimp::PixelRgn;

*PixelRgn:: =  *Gimp::PixelRgn::;

sub new($$$$$$$$) {
   shift;
   goto &Gimp::gimp_pixel_rgn_init;
}

#sub DESTROY {
#   my $self = shift;
## does not work as advertised (by me):
##   $self->{drawable}->{id}->update($self->{x},$self->{y},$self->{w},$self->{h})
##     if $self->{dirty};
#}

1;

__END__

=head1 NAME

Gimp - Perl extension for writing Gimp Extensions/Plug-ins/Load & Save-Handlers

This is mostly a reference manual. For a quick intro, look at L<Gimp::Fu>.

=head1 RATIONALE

Well, scheme (which is used by script-fu), is IMnsHO the crappiest language
ever (well, the crappiest language that one actually can use, so it's not
_that_ bad). Scheme has the worst of all languages, no data types, but still
using variables. Look at haskell (http://www.haskell.org) to see how
functional is done right.

Since I was unable to write a haskell interface (and perl is the traditional
scripting language), I wrote a Perl interface instead. Not too bad a
decision I believe...

=head1 SYNOPSIS

  use Gimp;
  
  Other modules of interest:
  
  use Gimp::Fu;		# easy scripting environment
  use Gimp::PDL;	# interface to the Perl Data Language
  
  these have their own manpage (or will have)

=head2 IMPORT TAGS

=over 4

=item :auto

Import useful constants, like RGB, RUN_NONINTERACTIVE... as well as all
libgimp and pdb functions automagically into the caller's namespace. BEWARE!
This will overwrite your AUTOLOAD function, if you have one!

=item :param

Import PARAM_* constants (PARAM_INT32, PARAM_STRING etc.)

=item :consts

The constants from gimpenums.h (BG_IMAGE_FILL, RUN_NONINTERACTIVE etc.)

=back

=head1 GETTING STARTED

You should first read the Gimp::Fu manpage and then come back. This manpage is mainly
intended for reference purposes.

Also, Dov Grobgeld has written an excellent tutorial for Gimp-Perl. You can
find it at http://imagic.weizmann.ac.il/~dov/gimp/perl-tut.html

=head1 DESCRIPTION

I think you already know what this is about: writing Gimp
plug-ins/extensions/scripts/file-handlers/standalone-scripts, just about
everything you can imagine in perl. If you are missing functionality (look
into TODO first), please feel free contact the author...

Some hilites:

=over 2

=item *
Networked plug-ins and plug-ins using the libgimp interfaces (i.e. to be
started by The Gimp) are written almost the same way (if you use Gimp::Fu,
there will be no differences at all), you can easily create hybrid (network
& libgimp) scripts as well.

=item *
Use either a plain pdb (scheme-like) interface or nice object-oriented
syntax, i.e. "gimp_layer_new(600,300,RGB)" is the same as "new Image(600,300,RGB)"

=item *
Gimp::Fu will start the gimp for you, if it cannot connect to an existing
gimp process.

=item *
You can optionally overwrite the pixel-data functions by versions using piddles
(see L<PDL>)

=back

noteworthy limitations (subject to be changed):

=over 2

=item *
callback procedures do not return anything to The Gimp, not even a status
argument, which seems to be mandatory by the gimp protocol (which is
nowhere standardized, though).

=back

=head1 OUTLINE OF A GIMP PLUG-IN

All plug-ins (and extensions etc.) _must_ contain a call to C<gimp_main>.
The return code should be immediately handed out to exit:

C<exit gimp_main;>

In a Gimp::Fu-script, you should call C<main> instead:

C<exit main;>

This is similar to Gtk, Tk or similar modules, where you have to call the
main eventloop.

=head1 CALLBACKS

If you use the plain Gimp module (as opposed to Gimp::Fu), your
program should only call one function: C<gimp_main>. Everything
else is being B<called> from the Gimp. For this to work, you
should define certain call-backs in the same module you called
C<gimp_main>:

=over 4

=item init (), query (), quit (), <installed_procedure>()

the standard libgimp callback functions. C<run>() is missing, because this
module will directly call the function you registered with
C<gimp_install_procedure>. Some only make sense for extensions, some
only for normal plug-ins.

=item net ()

this is called when the plug-in is not started directly from within the
Gimp, but instead from the I<Net-Server> (the perl network server extension you
hopefully have installed and started ;)

=back

=head1 CALLING GIMP FUNCTIONS

There are two different flavours of gimp-functions. Functions from the
B<PDB> (the Procedural DataBase), and functions from B<libgimp> (the
C-language interface library).

You can get a listing and description of every PDB function by starting the
B<DB Browser> extension in the Gimp-B<Xtns> menu (but remember that B<DB
Browser> is buggy and displays "_" (underscores) as "-" (dashes), so you
can't see the difference between gimp_quit and gimp-quit. As a rule of
thumb, B<Script-Fu> registers scripts with dashes, and everything else uses
underscores).

B<libgimp> functions can't be traced (and won't be traceable in the
foreseeable future). Many B<libgimp> functions are merely convinience
functions for C programmers that just call equivalent PDB functions.

At the moment, Gimp favours B<libgimp> functions where possible, i.e. the
calling sequence is the same, or implementing an interface is too much work
when there is an equivalent PDB function anyway. The libgimp functions are
also slightly faster, but the real benefit is that users (B<YOU>) will hit
bugs in libgimp very effectively ;) Once libgimp is sufficiently debugged,
I'll remove the libgimp functions that only shadow PDB functions (thus
reducing object size as well).

To call pdb functions (or equivalent libgimp functions), just
treat them as normal perl:

 gimp_palette_set_foreground_color([20,5,7]);

"But how do I call functions containing dashes?". Well, get your favourite
perl book and learn perl! Anyway, newer perls understand a nice syntax (see
also the description for C<gimp_call_procedure>):

 "plug-in-the-egg"->(RUN_INTERACTIVE,$image,$drawable);

Older perls need:

 &{"plug-in-the-egg"}(RUN_INTERACTIVE,$image,$drawable);

(unfortunately. the plug-in in this example is actually called
"plug_in_the_egg" *sigh*)

=head1 SPECIAL FUNCTIONS

In this section, you can find descriptions of special functions, functions
having different calling conventions/semantics than I would expect (I cannot
speak for you), or just plain interesting functions.

=over 4

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

=item gimp_tile_*, gimp_pixel_rgn_*, gimp_drawable_get

With these functions you can access the raw pixel data of drawables. They
are documented in L<Gimp::Pixel>, to keep this manual page short.

=item gimp_call_procedure(procname, arguments...)

This function is actually used to implement the fancy stuff. Its your basic
interface to the PDB. Every function call is eventually done through his
function, i.e.:

 gimp_image_new(args...);

is replaced by

 gimp_call_procedure "gimp_image_new",args...;

at runtime.

=item gimp_list_images, gimp_image_get_layers, gimp_image_get_channels

These functions return what you would expect: an array of images, layers or
channels. The reason why this is documented is that the usual way to return
C<PARAM_INT32ARRAY>'s would be to return a B<reference> to an B<array of
integers>, rather than blessed objects.

=back

=head1 OBJECT ORIENTED SYNTAX

In this manual, only the plain syntax (that lesser languages like C use) is
described. Actually, the recommended way to write gimp scripts is to use the
fancy OO-like syntax you are used to in perl (version 5 at least ;). As a
fact, OO-syntax saves soooo much typing as well. See L<Gimp::OO> for
details.

=head1 DEBUGGING AIDS

No, I can't tell you how to cure immune deficiencies, but I I<can> tell
you how Gimp can help you debugging your scripts:

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

=head1 SUPPORTED GIMP DATA TYPES

Gimp supports different data types like colors, regions, strings. In
perl, these are represented as:

=over 4

=item INT32, INT16, INT8, FLOAT, STRING

normal perl scalars. Anything except STRING will be mapped
to a perl-double.

=item INT32ARRAY, INT16ARRAY, INT8ARRAY, FLOATARRAY, STRINGARRAY

array refs containing scalars of the same type, i.e. [1, 2, 3, 4]. Gimp
implicitly swallows or generates a preceeding integer argument because the
preceding argument usually (this is a de-facto standard) contains the number
of elements.

=item COLOR

on input, either an array ref with 3 elements (i.e. [233,40,40])
or a X11-like string is accepted ("#rrggbb").

=item DISPLAY, IMAGE, LAYER, CHANNEL, DRAWABLE, SELECTION

These will be mapped to corresponding objects (IMAGE => Gimp::Image). In trace
output you will see small integers (the image/layer/etc..-ID)

=item REGION, BOUNDARY, PATH, STATUS

Not yet supported.

=back

=head1 AUTHOR

Marc Lehmann <pcg@goof.com>

=head1 SEE ALSO

perl(1), gimp(1), L<Gimp::OO>, L<Gimp::Data> and L<Gimp::Util>.

=cut
