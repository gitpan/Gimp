package Gimp::Fu;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD @EXPORT_FAIL
            %EXPORT_TAGS @PREFIXES @scripts @_params $run_mode %pf_type2string);
use Gimp qw(:param);
use Gimp::UI;
use File::Basename;
use Gtk;
use Gtk::ColorSelectButton;

require Exporter;
require DynaLoader;
require AutoLoader;

=cut

=head1 NAME

Gimp::Fu - easy to use framework for Gimp scripts

=head1 SYNOPSIS

  use Gimp;
  use Gimp::Fu;
  
  (this module uses Gtk, so make sure it's correctly installed)

=head1 DESCRIPTION

Currently, there are only three functions in this module. This
fully suffices to provide a professional interface and the
ability to run this script from within the Gimp and standalone
from the commandline.

Dov Grobgeld has written an excellent tutorial for Gimp-Perl. While not
finished, it's definitely worth a look! You can find it at
C<http://imagic.weizmann.ac.il/~dov/gimp/perl-tut.html>.

=head1 INTRODUCTION

In general, a Gimp::Fu script looks like this:

   #!/path/to/your/perl
   
   use Gimp;
   use Gimp::Fu;
   
   register <many arguments>, sub {
      your code;
   }
   
   exit main;

(This distribution comes with example scripts. One is
C<examples/example-fu.pl>, which is small Gimp::Fu-script you can take as
starting point for your experiments)

=cut

sub PF_INT8	() { PARAM_INT8		};
sub PF_INT16	() { PARAM_INT16	};
sub PF_INT32	() { PARAM_INT32	};
sub PF_FLOAT	() { PARAM_FLOAT	};
sub PF_VALUE	() { PARAM_FLOAT	};
sub PF_STRING	() { PARAM_STRING	};
sub PF_COLOR	() { PARAM_COLOR	};
sub PF_COLOUR	() { PARAM_COLOR	};
sub PF_IMAGE	() { PARAM_IMAGE	};
sub PF_LAYER	() { PARAM_LAYER	};
sub PF_CHANNEL	() { PARAM_CHANNEL	};
sub PF_DRAWABLE	() { PARAM_DRAWABLE};

sub PF_FONT	() { PARAM_STRING	};	# at the moment!
sub PF_TOGGLE	() { PARAM_END+1	};

%pf_type2string = (
         &PF_INT8	=> 'small integer',
         &PF_INT16	=> 'integer',
         &PF_INT32	=> 'integer',
         &PF_FLOAT	=> 'value',
         &PF_STRING	=> 'string',
         &PF_COLOR	=> 'colour',
#         &PF_FONT	=> 'fontspec',
         &PF_TOGGLE	=> 'boolean',
         &PF_IMAGE	=> 'NYI',
         &PF_LAYER	=> 'NYI',
         &PF_CHANNEL	=> 'NYI',
         &PF_DRAWABLE	=> 'NYI',
);

@_params=qw(PF_INT8 PF_INT16 PF_INT32 PF_FLOAT PF_VALUE
            PF_STRING PF_COLOR PF_COLOUR PF_TOGGLE PF_IMAGE
            PF_DRAWABLE PF_FONT PF_LAYER PF_CHANNEL);

@ISA = qw(Exporter);
@EXPORT = (qw(register main),@_params);
@EXPORT_OK = qw(interact $run_mode);
%EXPORT_TAGS = (params => [@_params]);

sub interact($@) {
   my(@types)=@{shift()};
   my(@getres);
   my($w,$t,$button,$box,$bot,$g);
   my $res=0;
   
   parse Gtk::Rc Gimp::gimp_gtkrc;
   
   $t = new Gtk::Tooltips;
   
   $w = new Gtk::Dialog;
   set_title $w "$0";
   
   $g = new Gtk::Table scalar@types,2,0;
   $g->border_width(4);
   show $g;
   $w->vbox->pack_start($g,1,1,0);
   
   for(@types) {
      my($label,$a);
      my($type,$name,$desc,$default)=@$_;
      my($value)=shift;
      $value=$default unless defined($value);
      $label="$name: ";
      if($type == PF_INT8	# perl just maps
      || $type == PF_INT16	# all this crap
      || $type == PF_INT32	# into the scalar
      || $type == PF_FLOAT	# domain.
      || $type == PF_STRING) {	# I love it
         $a=new Gtk::Entry;
         set_usize $a 0,25;
         set_text $a $value;
         #select_region $a 0,1;
         push(@getres,,sub{get_text $a});
      } elsif($type == PF_COLOR) {
         my $res;
         $a=new Gtk::ColorSelectButton (-width => 60, -height => 15);
         $a->color(join " ",@{Gimp::canonicalize_color $value});
         push(@getres,sub{[split ' ',$a->color]});
      } elsif($type == PF_TOGGLE) {
         $a=new Gtk::CheckButton $desc;
         set_state $a ($value ? 1 : 0);
         push(@getres,sub{state $a eq "active"});
      } elsif($type == PF_IMAGE) {
         my $res;
         $a=new Gtk::OptionMenu;
         $a->set_menu(new Gimp::UI::ImageMenu(sub {1},-1,$res));
         push(@getres,sub{$res});
      } elsif($type == PF_LAYER) {
         my $res;
         $a=new Gtk::OptionMenu;
         $a->set_menu(new Gimp::UI::LayerMenu(sub {1},-1,$res));
         push(@getres,sub{$res});
      } elsif($type == PF_CHANNEL) {
         my $res;
         $a=new Gtk::OptionMenu;
         $a->set_menu(new Gimp::UI::ChannelMenu(sub {1},-1,$res));
         push(@getres,sub{$res});
      } elsif($type == PF_DRAWABLE) {
         my $res;
         $a=new Gtk::OptionMenu;
         $a->set_menu(new Gimp::UI::DrawableMenu(sub {1},-1,$res));
         push(@getres,sub{$res});
      } else {
         $label="Unsupported argumenttype $type";
         push(@getres,sub{$value});
      }
      
      $label=new Gtk::Label $label;
      $label->set_alignment(0,0.5);
      show $label;
      $g->attach($label,0,1,$res,$res+1,{},{},4,2);
      $a && do {
         set_tip $t $a,$desc;
         show $a;
         $g->attach($a,1,2,$res,$res+1,{},{},4,2);
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
   
   return map {&$_} @getres if $res;
   ();
}

sub this_script {
   return $scripts[0] unless $#scripts;
   # well, not-so-easy-day today
   my $exe = basename($0);
   my @names;
   for my $this (@scripts) {
      my $fun = (split /\//,$this->[0])[-1];
      return $this if lc($exe) eq lc($fun);
      push(@names,$fun);
   }
   die "function '$exe' not found in this script (must be one of ".join(", ",@names).")\n";
}

sub string2pf($$) {
   my($s,$type,$name,$desc)=($_[0],@{$_[1]});
   print "convertin $s to $type $name $desc\n";
   if($type==PF_STRING) {
      $s;
   } elsif($type==PF_INT8 || $type==PF_INT16 || $type==PF_INT32) {
      die "$s: not an integer\n" unless $s==int($s);
      $s*1;
   } elsif($type==PF_FLOAT) {
      $s*1;
   } elsif($type==PF_COLOUR) {
      die "only #rrggbb allowed as colour argument\n" unless $s=~/^#[0-9a-f]{6,6}$/i;
      $s;
   } elsif($type==PF_TOGGLE) {
      $s?1:0;
   } else {
      die "conversion to type $pf_type2string{$type} is not yet implemented\n";
   }
}

sub net {
   no strict 'refs';
   my $this = this_script;
   my(%map,@args);
   @map{map $_->[1],@{$this->[8]}} = (0..$#{$this->[8]});
   while(defined($_=shift @ARGV)) {
      if (/^-+(.*)$/) {
         my $arg=shift @ARGV;
         my $idx=$map{$1};
         die "$1: illegal switch, try $0 --help\n" unless defined($idx);
         $args[$idx]=string2pf($arg,$this->[8][@args]);
      } else {
         push(@args,string2pf($_,$this->[8][@args]));
      }
   }
   $this->[0]->(&Gimp::RUN_INTERACTIVE,@args);
}

sub query {
   my($type);
   for(@scripts) {
      my($function,$blurb,$help,$author,$copyright,$date,
         $menupath,$imagetypes,$params,$code)=@$_;
      
      if ($menupath=~/^<Image>\//) {
         $type=&Gimp::PROC_PLUG_IN;
         unshift(@$params,
                 [&Gimp::PARAM_IMAGE	, "image",	"The image to work on"],
                 [&Gimp::PARAM_DRAWABLE	, "drawable",	"The drawable to work on"]);
      } elsif ($menupath=~/^<Toolbox>\//) {
         $type=&Gimp::PROC_EXTENSION;
      } else {
         die "menupath _must_ start with <Image> or <Toolbox>!";
      }
      unshift(@$params,
              [&Gimp::PARAM_INT32,"run_mode","Interactive, [non-interactive]"]);
      Gimp::gimp_install_procedure($function,$blurb,$help,$author,$copyright,$date,
                                   $menupath,$imagetypes,$type,
                                   [map {
                                      $_->[0]=PARAM_INT32	if $_->[0] == PF_TOGGLE;
                                      $_->[0]=PARAM_STRING	if $_->[0] == PF_FONT;
                                      $_;
                                   } @$params],[]);
   }
}

=cut

=head2 THE REGISTER FUNCTION

   register
     "function_name",
     "blurb", "help",
     "author", "copyright",
     "date",
     "menu path",
     "image types",
     [
       [PF_TYPE,name,desc,default],
       [PF_TYPE,name,desc,default],
       etc...
     ],
     sub { code };

=over 2

=item function name

The pdb name of the function, i.e. the name under which is will be
registered in the Gimp database. If it doesn't start with "perl_fu_", it
will be prepended (so all function names registered via Gimp::Fu begin
with "perl_fu_")

=item blurb

A small description of this script/plug-in.

=item help

A help text describing this script. Should be longer and more verbose than
C<blurb>.

=item copyright

The copyright designation for this script. Important! Safe your intellectual
rights!

=item date

The "last modified" time of this script. There is no strict syntax here, but
I recommend ISO format (yyyymmdd or yyyy-mm-dd).

=item menu path

The menu entry Gimp should create. It should start either with <Image>, meaning
this script is an image-plug-in, or <Xtns>, for scripts creating new images.

=item image types

The types of images your script will accept. Examples are "RGB", "RGB*",
"GRAY, RGB" etc... Most scripts will want to use "*", meaning "any type".

=item the parameter array

An array ref containing parameter definitions. These are similar to the
parameter definitions used for C<gimp_install_procedure>, but include an
additional B<default> value used when the caller doesn't supply one.

Each array element has the form [type, name, description, default_value].

<Image>-type plugins get two additional parameters, image (C<PF_IMAGE>) and
drawable (C<PF_DRAWABLE>). Do not specify these yourself. Also, the
C<run_mode> argument is never given to the script, but its value canm be
accessed in the package-global C<$run_mode>. The B<name> is used in the
dialog box as a hint, the B<description> will be used as a tooltip.

See the section PARAMETER TYPES for the supported types.

=item the code

This is either a anonymous sub declaration (C<sub { your code here; }>, or a
coderef, which is called when the script is run. Arguments (including the
image and drawable for <Image> plug-ins) are supplied automatically.

It is good practise to return an image, if the script creates one, or
C<undef>, since the return value is interpreted by Gimp::Fu (like displaying
the image or writing it to disk). If your script creates multiple pictures,
return an array.

=back

=head2 PARAMETER TYPES

=over 2

=item PF_INT8, PF_INT16, PF_INT32, PF_FLOAT, PF_STRING, PF_VALUE

Are all mapped to a string entry, since perl doesn't really distinguish
between all these datatypes. The reason they exist is to help other scripts
(possibly written in other languages! really!). It's nice to be able to
specify a float as 13.45 instead of "13.45" in C! C<PF_VALUE> is synonymous
to C<PF_STRING>.

=item PF_COLOR, PF_COLOUR

Will accept a colour argument. In dialogs, a colour preview will be created
which will open a colour selection box when clicked.

=item PF_IMAGE

A gimp image. Not yet supported in dialogs :(

=item PF_DRAWABLE

A gimp drawable (image, channel or layer). Not yet supported in dialogs :(

=item PF_FONT

An experimental value used to denote fonts. At the moment, this is just
a C<PF_STRING>. It might be replaced by a font selection dialog in the future.

Please note that the Gimp has no value describing a font, so the format of
this string is undefined (and will usually contain only the family name of
the selected font).

=item PF_TOGGLE

A boolean value (anything perl would accept as true or false). The description
will be used for the toggle-button label!

=back

=cut

sub register($$$$$$$$$&) {
   no strict 'refs';
   my($function,$blurb,$help,$author,$copyright,$date,
      $menupath,$imagetypes,$params,$code)=@_;
   $function=~s/^perl_fu_|/perl_fu_/;
   *$function = sub {
      $run_mode=shift;	# global!
      my(@pre);
      if ($menupath=~/^<Image>\//) {
         @_ >= 2 or die "<Image> plug-in called without an image and drawable!\n";
         @pre = (shift,shift);
      } elsif ($menupath=~/^<Toolbox>\//) {
         # valid ;)
      } else {
         die "menupath _must_ start with <Image> or <Toolbox>!";
      }
      
      # supplement default arguments
      for my $i (0..$#{$params}) {
         $_[$i]=$params->[$i]->[3] unless defined($_[$i]);
      }
      
      if ($run_mode == &Gimp::RUN_WITH_LAST_VALS) {
         die "RUN_WITH_LAST_VALS not yet implemented\n";
      }
      
      if ($run_mode == &Gimp::RUN_INTERACTIVE) {
         if (@_) {
            undef @_;	# gimp doesn't deliver useful values!! #D# #FIXME#
            @_=interact($params,@_);
            return unless defined(@_);
         }
      } elsif ($run_mode = &Gimp::RUN_NONINTERACTIVE) {
      } else {
         die "run_mode must be INTERACTIVE, NONINTERACTIVE or WITH_LAST_VALS\n";
      }
      
      print $function,"(",join(",",(@pre,@_)),")\n" if $Gimp::verbose;
      
      for my $img (&$code(@pre,@_)) {
         Gimp::gimp_display_new($img) if defined $img;
      }
      Gimp::gimp_displays_flush();
   };
   push(@scripts,[$function,$blurb,$help,$author,$copyright,$date,
                  $menupath,$imagetypes,$params,$code]);
}

# provide some clues ;)
sub print_switches {
   my($this)=@_;
   for(@{$this->[8]}) {
      my $type=$pf_type2string{$_->[0]};
      printf "           -%-25s %s\n","$_->[1] $type",$_->[2];
   }
}

sub main {
   if (!@scripts) {
      die "well, there are no scripts registered.. what do you expect?";
   } elsif ($Gimp::help) {
      my $this=this_script;
      print <<EOF;
       interface-arguments are
           -o | --output <filespec>   write image to disk, then delete (NYI)
           --info                     provide some info about this script(NYI)
           -i | --interact            let the user edit the values first (NYI)
       script-arguments are
EOF
      print_switches ($this);
   } else {
      Gimp::gimp_main;
   }
}

1;
__END__

=head1 STATUS

This module is experimental and unfinished.

=head1 AUTHOR

Marc Lehmann <pcg@goof.com>

=head1 SEE ALSO

perl(1), L<Gimp>,

=cut
