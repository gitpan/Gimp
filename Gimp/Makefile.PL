use ExtUtils::MakeMaker;

do '../config.pl';

WriteMakefile(
    'NAME'	=> 'Gimp::Lib',
    'VERSION_FROM' => '../Gimp.pm',
    'LIBS'	=> "$LDFLAGS $LIBS $GIMP_LIBS",
    'INC'	=> "$CPPFLAGS -I.. $GIMP_INC $CFLAGS $DEFS",
    'DEFINE'	=> '',
);
