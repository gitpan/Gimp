#
# This package is loaded by the Gimp, and is !private!, so don't
# use it standalone, it won't work.
#
package Gimp::Net;

use strict;
use Carp;
use vars qw(
   $VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD @EXPORT_FAIL %EXPORT_TAGS
   $default_tcp_port $default_unix_dir $default_unix_sock
   $server_fh $trace_level $trace_res
);

use IO::Socket;

@ISA = ();

$default_tcp_port  = 10009;
$default_unix_dir  = "/tmp/gimp-perl-serv/";
$default_unix_sock = "gimp-perl-serv";

$trace_res = *STDERR;
$trace_level = 0;

sub AUTOLOAD {
  my $constname;
  ($constname = $AUTOLOAD) =~ s/.*:://;
  eval "sub $AUTOLOAD { gimp_call_procedure '$constname',\@_ }";
  goto &$AUTOLOAD;
}

# network to array
sub net2args($) {
  no strict 'subs';
  eval "sub b(\$\$) { bless \\(my \$x = \$_[0]),\$_[1] }; ($_[0])";
}

sub args2net {
  my($res,$v);
  for $v (@_) {
    if(ref($v) eq "ARRAY") {
      $res.="[".join(",",map { "qq[".quotemeta($_)."]" } @$v)."],";
    } elsif(ref($v)) {
      $res.="b(".${$v}.",".ref($v)."),";
    } else {
      $res.="qq[".quotemeta($v)."],";
    }
  }
  $res;
}

sub _gimp_procedure_available {
  my $req="TEST".$_[0];
  print $server_fh pack("N",length($req)).$req;
  $server_fh->read($req,1);
  return $req;
}

sub gimp_call_procedure {
  my($len,@args,$trace,$req);
  if ($trace_level) {
    $req="TRCE".args2net($trace_level,@_);
    print $server_fh pack("N",length($req)).$req;
    $server_fh->read($len,4) == 4 or croak "protocol error";
    $len=unpack("N",$len);
    $server_fh->read($req,$len) == $len or croak "protocol error";
    ($trace,$req,@args)=net2args($req);
    if (ref $trace_res eq "SCALAR") {
      $$trace_res = $trace;
    } else {
      print $trace_res $trace;
    }
  } else {
    $req="EXEC".args2net(@_);
    print $server_fh pack("N",length($req)).$req;
    $server_fh->read($len,4) == 4 or croak "protocol error";
    $len=unpack("N",$len);
    $server_fh->read($req,$len) == $len or croak "protocol error";
    ($req,@args)=net2args($req);
  }
  croak $req if $req;
  wantarray ? @args : $args[0];
}

sub server_quit {
  print "sending quit\n";
  print $server_fh pack("N",4)."QUIT";
  exit(0);
}

# progress bar would never go away, since Net-Server isn't
# stopped... to avoid confusion. just disable the progress bar.
sub gimp_progress_init {};
sub gimp_progress_update {};

sub set_trace {
  my($trace)=@_;
  if(ref $trace) {
    $trace_res=$trace;
  } else {
    $trace_level=$trace;
  }
}

sub gimp_main {
  $server_fh = new IO::Socket::UNIX (Peer => $default_unix_dir.$default_unix_sock);
  unless($server_fh) {
    my($host,$port);
    $host = $ARGV[0] ? $ARGV[0] : "localhost";
    $port = $ARGV[1] ? $ARGV[1] : $default_tcp_port;
    $server_fh = new IO::Socket::INET (PeerAddr => $host, PeerPort => $port);
    unless($server_fh) {
      croak "unable to contact server (make sure Net-Server is running)";
    }
  }
  $server_fh or croak "could not connect to the gimp server server (make sure Net-Server is running)";
  $server_fh->autoflush(1); # for compatibility with very old perls..
  no strict 'refs';
  &{caller()."::net"};
}

1;
__END__

=head1 NAME

Gimp::Net - Communication module for the gimp-perl server.

=head1 SYNOPSIS

  use Gimp qw( interface=net );

=head1 DESCRIPTION

WARNING: the Net-Server may open a listening socket at port 10009, reachable for
everybody. In this version, no provisions for security have been made!

You first have to install the "Server" extension somewhere where Gimp can
find it. Then have a look at example-net.pl (and run it!), or homepage-logo.pl
(which is a hybrid: works as plug-in and as

=head1 CALLBACKS

net

is called after we succesfully connected to the server. Do your dirty work
in this function.

=head1 FUNCTIONS

server_quit

sends the perl server a quit command.

=head1 BUGS

(Ver 0.04..) This module is much faster than it ought to be... Silly that I wondered
wether I should implement it in perl or C, since perl is soo fast.

=head1 AUTHOR

Marc Lehmann, pcg@goof.com

=head1 SEE ALSO

perl(1), Gimp(1),

=cut
