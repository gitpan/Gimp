use ExtUtils::MakeMaker;

if ($ARGV[0] eq "---called-after-configure") {
   shift(@ARGV);
} elsif (!(system("./etc/configure",@ARGV)>>8) && -f "./pcfg") {
   do './pcfg';
   exec $PERL,$0,"---called-after-configure",@ARGV;
} else {
   exit(1);
}

do './pcfg';

@ARGV=();
unshift(@ARGV,"prefix=$prefix") if $prefix;

eval "use Gtk;"; $GTK = $@ eq "";
eval "use PDL;"; $PDL = $@ eq "";

$GTK or print <<EOF;

WARNING: unable to use the Perl-Gtk interface.  Some features (like
         Gimp::Fu) rely on this extension.  You can try to build without it,
         but it's better to install it (version 0.2_03 or higher is
         required, you can get it from ftp://ftp.gimp.org/pub/gtk/perl/ or
         any CPAN mirror).

EOF

$PDL or print <<EOF;

WARNING: unable to use PDL (the perl data language).  This means that
         Gimp::PDL is non-functional.  Unless you plan to use Tile/PixelRgn
         functions together with PDL, this is harmless.  Gimp::PDL will be
         installed, just in case you later install PDL.  You can get PDL
         from any CPAN mirror).

EOF

!$PDL or $PDL::Version::VERSION > 1.99 or print <<EOF;

WARNING: PDL version $PDL::Version::VERSION is installed. Gimp::PDL was only tested with
         1.9905.  In case of problems its advisable to upgrade PDL.

EOF

($major,$minor,$patch)=split /[._]/,$Gtk::VERSION;
print "using gtk version $Gtk::VERSION\n";

unless ($major > 0
        || ($major == 0 && $minor > 2)
        || ($major == 0 && $minor == 2 && $patch > 1)) {
   print <<EOF;

WARNING: version 0.2.3 of Gtk is _required_ for this module to build
         properly.  You can get the newest version from
         ftp://ftp.gimp.org/pub/gtk/perl/ or any CPAN mirror.  Older
         versions may work, but I have warned you!

EOF
}

sub MY::postamble {
   <<"EOF";

#install :: install-plugins

install-plugins:
	$GIMPTOOL --install-admin-bin Perl-Server
	cd examples && $GIMPTOOL --install-admin-bin windy.pl
	cd examples && $GIMPTOOL --install-admin-bin example-oo.pl
	cd examples && $GIMPTOOL --install-admin-bin example-net.pl
	cd examples && $GIMPTOOL --install-admin-bin example-fu.pl
EOF
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'dist'	=> {
                    'PREOP'     => 'chmod -R u=rwX,go= . ;'.
                    		   '[ -x ./cphp ] && ./cphp',
#                                   '&& pod2man Gimp.pm | groff -man -P-buo -Tascii > README',
                    'COMPRESS'	=> 'gzip -9v',
                    'SUFFIX'	=> '.gz',
                   },
#    'PREREQ_PM'	=> {
#    		    "Gtk"	=> 0.0203,
#		   },
    'DIR'	=> ['Gimp'],
    'NAME'	=> 'Gimp',
    'VERSION_FROM' => 'Gimp.pm',
    'PM'	=> {
    		    'Gimp.pm'		=> '$(INST_LIBDIR)/Gimp.pm',
    		    'Gimp/Data.pm'	=> '$(INST_LIBDIR)/Gimp/Data.pm',
    		    'Gimp/Fu.pm'	=> '$(INST_LIBDIR)/Gimp/Fu.pm',
    		    'Gimp/Lib.pm'	=> '$(INST_LIBDIR)/Gimp/Lib.pm',
    		    'Gimp/UI.pm'	=> '$(INST_LIBDIR)/Gimp/UI.pm',
    		    'Gimp/Net.pm'	=> '$(INST_LIBDIR)/Gimp/Net.pm',
    		    'Gimp/PDL.pm'	=> '$(INST_LIBDIR)/Gimp/PDL.pm',
#    		    'Gtk/ColorSelectButton.pm'=> '$(INST_LIBDIR)/Gimp/ColorSelectButton.pm',
    		   },
    'LIBS'	=> [''],
    'INC'	=> "$CPPFLAGS $CFLAGS $DEFS",
    'DEFINE'	=> '',
    'clean'	=> { FILES => "config.log config.h pcfg config.status config.cache" },
);

print <<EOF;


Hopefully, Gimp is now correctly configured. you can now enter "make", "make
test" and "make install" and, to install the Perl-Server and various
other plugins, "make install-plugins".

EOF



