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
   $server_fh $trace_level $trace_res $auth $gimp_pid
);
use subs qw(gimp_call_procedure);
use Gimp;

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
  no strict "refs";
  *{$AUTOLOAD} = sub { Gimp::Net::gimp_call_procedure $constname,@_ };
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

sub try_connect {
   $_=$_[0];
   $auth = s/^(.*)\@// ? $1 : undef;	# get authorization
   if ($_ ne "") {
      if (s{^unix/}{/}) {
         return new IO::Socket::UNIX (Peer => $_);
      } else {
         s{^tcp/}{};
         my($host,$port)=split /:/,$_;
         $port=$default_tcp_port unless $port;
         return new IO::Socket::INET (PeerAddr => $host, PeerPort => $port);
      }
   };
   undef $auth;
}

sub gimp_main {
   return if $Gimp::help;
   if (defined($Gimp::host)) {
      $server_fh = try_connect ($Gimp::host);
   } elsif (defined($ENV{GIMP_HOST})) {
      $server_fh = try_connect ($ENV{GIMP_HOST});
   } else {
      $server_fh = new IO::Socket::UNIX (Peer => $default_unix_dir.$default_unix_sock);
      unless(defined($server_fh)) {
         $server_fh = new IO::Socket::INET (PeerAddr => "localhost", PeerPort => $default_tcp_port);
         unless (defined($server_fh)) {
            print "trying to start gimp\n" if $Gimp::verbose;
            $server_fh=*SERVER_SOCKET;
            socketpair $server_fh,GIMP_FH,AF_UNIX,SOCK_STREAM,PF_UNIX
               or croak "unable to create socketpair for gimp communications: $!";
            $gimp_pid = fork;
            if ($gimp_pid > 0) {
               *gimp_display_new=sub {};
               # well, we now have out perl-server listening, don't we?
            } elsif ($gimp_pid == 0) {
               close $server_fh;
               unless ($Gimp::verbose) {
                  open STDOUT,">/dev/null";
                  open STDERR,">&1";
                  close STDIN;
               }
               exec "gimp","-n","-b","(extension_perl_server ".&Gimp::RUN_NONINTERACTIVE." ".
                                     (&Gimp::_PS_FLAG_BATCH | &Gimp::_PS_FLAG_QUIET)." ".
                                     fileno(GIMP_FH).")";
            } else {
               croak "unable to fork: $!";
            }
         }
      }
   }
   defined($server_fh)
      or croak "could not connect to the gimp server server (make sure Net-Server is running)";
   $server_fh->autoflush(1); # for compatibility with very old perls..
   no strict 'refs';
   &{caller()."::net"};
   return 0;
}

END {
   kill -TERM,$gimp_pid if $gimp_pid;
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

You first have to install the "Perl-Server" extension somewhere where Gimp
can find it (e.g in your .gimp/plug-ins/ directory). Then have a look at
example-fu.pl (and run it!), or example-net.pl (and run it!).

=head1 ENVIRONMENT

The environment variable C<GIMP_HOST> specifies the default server to contact. The syntax
is [auth@][tcp/]hostname[:port] for tcp or [auth@]unix/local/socket/path. Examples are:

www.yahoo.com               # just kidding ;)
yahoo.com:11100             # non-standard port
tcp/yahoo.com               # make sure it uses tcp
authorize@tcp/yahoo.com:123 # full-fledged specification

unix/tmp/unx                # use unix domain socket
password@unix/tmp/test      # additionally use a password

authorize@                  # specify authorization only

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

Marc Lehmann <pcg@goof.com>

=head1 SEE ALSO

perl(1), L<Gimp>,

=cut
