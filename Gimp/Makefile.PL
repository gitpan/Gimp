use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'dist'	=> {
                    'COMPRESS'	=> 'gzip -9v',
                    'SUFFIX'	=> '.gz',
                   },
    'NAME'	=> 'Gimp::Lib',
    'VERSION_FROM' => '../Gimp.pm', # finds $VERSION
    'LIBS'	=> ['-lgimp -lglib'],   # e.g., '-lm' 
    'INC'	=> '-I.. ',     # e.g., '-I/usr/include/other' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
);
