use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'dist'	=> {
                    'PREOP'     => 'pod2man Gimp.pm | groff -man -P-buo -Tascii > README',
                    'COMPRESS'	=> 'gzip -9v',
                    'SUFFIX'	=> '.gz',
                   },
    'DIR'	=> ['Gimp'],
    'NAME'	=> 'Gimp',
    'VERSION_FROM' => 'Gimp.pm', # finds $VERSION
    'LIBS'	=> [''],   # e.g., '-lm' 
    'INC'	=> '',     # e.g., '-I/usr/include/other' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
);
