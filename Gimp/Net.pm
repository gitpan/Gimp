package Gimp::Net;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD @EXPORT_FAIL %EXPORT_TAGS);
use vars qw(
   $default_tcp_port $default_unix_dir $default_unix_sock
   $server_fh
);

use IO::Socket;

use Gimp;

require Exporter;

@ISA = qw(Exporter);
@EXPORT = ();
@EXPORT_OK = ();

%EXPORT_TAGS = (
    'procs'	=> [@Gimp::_procs,"procs"],
);
@EXPORT_FAIL = qw( procs );

use subs @Gimp::_procs;

Exporter::export_ok_tags('consts','procs');

$default_tcp_port  = 10009;
$default_unix_dir  = "/tmp/gimp-perl-serv/";
$default_unix_sock = "gimp-perl-serv";

# dirty trick to export AUTOLOAD when :procs is specified.
sub export_fail {
  eval '*'.caller(2).'::AUTOLOAD = *AUTOLOAD;';
  ();
}

sub AUTOLOAD {
  my $constname;
  ($constname = $AUTOLOAD) =~ s/.*:://;
  eval "sub $AUTOLOAD { gimp_call_procedure '$constname',\@_ }";
  goto &$AUTOLOAD;
}

# network to array
sub net2args($) {
  my($arg)=@_;
  my(@res,$offset,$len,$class,$value);
  while($offset<length($arg)) {
    $len=unpack("N",substr($arg,$offset,4));
    $offset+=4;
    $value=substr($arg,$offset,$len);
    $offset+=$len;
    if(substr($value,0,1) eq "S") {
      push(@res,substr($value,1));
    } elsif(substr($value,0,1) eq "A") {
      push(@res,[split("\0",substr($value,1))]);
    } elsif(substr($value,0,1) eq "R") {
      ($class,$value)=split("\0",substr($value,1),2);
      push(@res,bless(\"$value",$class));
    }
  }
  @res;
}

sub args2net {
  my($res,$v);
  for(@_) {
    if(ref($_) eq "ARRAY") {
      $v="A".join("\0",@$_);
    } elsif(ref($_)) {
      $v="R".ref($_)."\0${$_}";
    } else {
      $v="S$_";
    }
    $res.=pack("N",length($v)).$v;
  }
  $res;
}

sub server_quit {
  print "sending quit\n";
  print $server_fh pack("N",4)."QUIT";
  exit(0);
}

sub gimp_main {
  $server_fh = new IO::Socket::UNIX (Peer => $default_unix_dir.$default_unix_sock);
  unless($server_fh) {
    croak "tcp connections not yet supported in client (make sure the Server is running)";
  }
  $server_fh or croak "could not connect to gimp-perl server (make sure the Server is running)";
  $server_fh->autoflush(1);
  eval caller()."::net()";
}

sub fatal {
  print STDERR "FATAL: @_\n";
  exit(1);
}

sub gimp_call_procedure {
  my($len,@args);
  my($req)="EXEC".args2net(@_);
  print $server_fh pack("N",length($req)).$req;
  $server_fh->read($len,4) == 4 or fatal "protocol error";
  $len=unpack("N",$len);
  $server_fh->read($req,$len) == $len or fatal "protocol error";
  ($req,@args)=net2args($req);
  fatal $req if $req;
  wantarray ? @args : $args[0];
}

1;
__END__

=head1 NAME

Gimp::Net - Communication module for the gimp-perl server.

=head1 SYNOPSIS

  use Gimp::Net;
  
  recommended is:
  
  use Gimp ':consts';
  use Gimp::Net ':procs';

=head1 DESCRIPTION

WARNING: the Server may open a listening socket at port 10009, reachable for
everybody. In this version, no provisions for security have been made!

This is early alpha.

You first have to install the "Server" extension somewhere where Gimp can
find it. Then have a look at example-net.pl (and run it!).

=head1 FUNCTIONS

server_quit

sends the perl server a quit command.

=head1 BUGS

Does not work with Gimp:OO (yet).

This module is much faster than it ought to be... Silly that I wondered
wether I should implement it in perl or C, since perl is soo fast.

=head1 AUTHOR

Marc Lehmann, pcg@goof.com

=head1 SEE ALSO

perl(1), Gimp(1),

=cut
