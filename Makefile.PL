use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'dist'	=> {
                    'PREOP'     => 'pod2text Gimp.pm > README',
                    'COMPRESS'	=> 'gzip -9v',
                    'SUFFIX'	=> '.gz',
                   },
    'NAME'	=> 'Gimp',
    'VERSION_FROM' => 'Gimp.pm', # finds $VERSION
    'LIBS'	=> ['-lgimp'],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '',     # e.g., '-I/usr/include/other' 
);
