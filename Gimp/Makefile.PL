use ExtUtils::MakeMaker;

do '../pcfg';

WriteMakefile(
    'NAME'	=> 'Gimp::Lib',
    'VERSION_FROM' => '../Gimp.pm',
    'LIBS'	=> "$LDFLAGS $LIBS $GIMP_LIBS",
    'INC'	=> "$CPPFLAGS -I.. $GIMP_CFLAGS $CFLAGS $DEFS",
    'DEFINE'	=> '',
);
