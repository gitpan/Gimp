#
# This package is loaded by the Gimp, and is !private!, so don't
# use it standalone, it won't work.
#
package Gimp::Net;

use strict;
use Carp;
use vars qw(
   $VERSION @ISA
   $default_tcp_port $default_unix_dir $default_unix_sock
   $server_fh $trace_level $trace_res $auth $gimp_pid
);
use subs qw(gimp_call_procedure);

use IO::Socket;

@ISA = ();
 
$default_tcp_port  = 10009;
$default_unix_dir  = "/tmp/gimp-perl-serv/";
$default_unix_sock = "gimp-perl-serv";

$trace_res = *STDERR;
$trace_level = 0;

sub import {
   return if @_;
   *Gimp::Tile::DESTROY=
   *Gimp::PixelRgn::DESTROY=
   *Gimp::GDrawable::DESTROY=sub {
      my $req="DTRY".args2net(@_);
      print $server_fh pack("N",length($req)).$req;
   };
}

# network to array
sub net2args($) {
   no strict 'subs';
   sub b($$) { bless \(my $x=$_[0]),$_[1] }
   eval "($_[0])";
}

sub args2net {
   my($res,$v);
   for $v (@_) {
      if(ref($v) eq "ARRAY" or ref($v) eq "Gimp::Color") {
         $res.="[".join(",",map { "qq[".quotemeta($_)."]" } @$v)."],";
      } elsif(ref($v)) {
         $res.="b(".$$v.",".ref($v)."),";
      } elsif(defined $v) {
         $res.="qq[".quotemeta($v)."],";
      } else {
         $res.="undef,";
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

# this is hardcoded into gimp_call_procedure!
sub response {
   my($len,$req);
   $server_fh->read($len,4) == 4 or die "protocol error";
   $len=unpack("N",$len);
   $server_fh->read($req,$len) == $len or die "protocol error";
   net2args($req);
}

# this is hardcoded into gimp_call_procedure!
sub command {
   my $req=shift;
   $req.=args2net(@_);
   print $server_fh pack("N",length($req)).$req;
}

sub gimp_call_procedure {
   my($len,@args,$trace,$req);
   
   if ($trace_level) {
      $req="TRCE".args2net($trace_level,@_);
      print $server_fh pack("N",length($req)).$req;
      $server_fh->read($len,4) == 4 or die "protocol error";
      $len=unpack("N",$len);
      $server_fh->read($req,$len) == $len or die "protocol error";
      ($trace,$req,@args)=net2args($req);
      if (ref $trace_res eq "SCALAR") {
         $$trace_res = $trace;
      } else {
         print $trace_res $trace;
      }
   } else {
      $req="EXEC".args2net(@_);
      print $server_fh pack("N",length($req)).$req;
      $server_fh->read($len,4) == 4 or die "protocol error";
      $len=unpack("N",$len);
      $server_fh->read($req,$len) == $len or die "protocol error";
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

sub set_trace {
   my($trace)=@_;
   if(ref $trace) {
      $trace_res=$trace;
   } else {
      $trace_level=$trace;
   }
}

sub start_server {
   print "trying to start gimp\n" if $Gimp::verbose;
   $server_fh=*SERVER_SOCKET;
   socketpair $server_fh,GIMP_FH,AF_UNIX,SOCK_STREAM,PF_UNIX
      or croak "unable to create socketpair for gimp communications: $!";
   $gimp_pid = fork;
   if ($gimp_pid > 0) {
      Gimp::ignore_functions(@Gimp::gimp_gui_functions);
      return $server_fh;
   } elsif ($gimp_pid == 0) {
      close $server_fh;
      unless ($Gimp::verbose) {
         open STDOUT,">/dev/null";
         open STDERR,">&1";
         close STDIN;
      }
      my $args = &Gimp::RUN_NONINTERACTIVE." ".
                 (&Gimp::_PS_FLAG_BATCH | &Gimp::_PS_FLAG_QUIET)." ".
                 fileno(GIMP_FH);
      exec "gimp","-n","-b","(extension-perl-server $args)",
                            "(extension_perl_server $args)";
   } else {
      croak "unable to fork: $!";
   }
}

sub try_connect {
   $_=$_[0];
   my $fh;
   $auth = s/^(.*)\@// ? $1 : "";	# get authorization
   if ($_ ne "") {
      if (s{^spawn/}{}) {
         return start_server;
      } elsif (s{^unix/}{/}) {
         return new IO::Socket::UNIX (Peer => $_);
      } else {
         s{^tcp/}{};
         my($host,$port)=split /:/,$_;
         $port=$default_tcp_port unless $port;
         return new IO::Socket::INET (PeerAddr => $host, PeerPort => $port);
      };
   } else {
      return $fh if $fh = try_connect ("$auth\@unix$default_unix_dir$default_unix_sock");
      return $fh if $fh = try_connect ("$auth\@tcp/localhost:$default_tcp_port");
      return $fh if $fh = try_connect ("$auth\@spawn/");
   }
   undef $auth;
}

sub gimp_main {
   if (defined($Gimp::host)) {
      $server_fh = try_connect ($Gimp::host);
   } elsif (defined($ENV{GIMP_HOST})) {
      $server_fh = try_connect ($ENV{GIMP_HOST});
   } else {
      $server_fh = try_connect ("");
   }
   defined $server_fh or croak "could not connect to the gimp server server (make sure Net-Server is running)";
   $server_fh->autoflush(1); # for compatibility with very old perls..
   
   my @r = response;
   
   die "expected perl-server at other end of socket, got @r\n"
      unless $r[0] eq "PERL-SERVER";
   shift @r;
   die "expected protocol version $Gimp::_PROT_VERSION, but server uses $r[0]\n"
      unless $r[0] eq $Gimp::_PROT_VERSION;
   shift @r;
   
   for(@r) {
      if($_ eq "AUTH") {
         die "server requests authorization, but no authorization available\n"
            unless $auth;
         command "AUTH",$auth;
         my @r = response;
         die "authorization failed: $r[1]\n" unless $r[0];
         print "authorization ok, but: $r[1]\n" if $Gimp::verbose and $r[1];
      }
   }
   
   no strict 'refs';
   &{caller()."::net"};
   return 0;
}

END {
   kill 'KILL',$gimp_pid if $gimp_pid;
}

1;
__END__

=head1 NAME

Gimp::Net - Communication module for the gimp-perl server.

=head1 SYNOPSIS

  use Gimp;

=head1 DESCRIPTION

For Gimp::Net (and thus commandline and remote scripts) to work, you first have to
install the "Perl-Server" extension somewhere where Gimp can find it (e.g in
your .gimp/plug-ins/ directory). Usually this is done automatically while installing
the Gimp extension. If you have a menu entry C<<Xtns>/Perl-Server>
then it is probably installed.

The Perl-Server can either be started from the C<<Xtns>> menu in Gimp, or automatically
when a perl script can't find a running Perl-Server.

When started from within The Gimp, the Perl-Server will create a
unix domain socket to which local clients can connect. If an authorization
password is given to the Perl-Server (by defining the environment variable
C<GIMP_HOST> before starting The Gimp), it will also listen on a tcp port
(default 10009).

=head1 ENVIRONMENT

The environment variable C<GIMP_HOST> specifies the default server to
contact and/or the password to use. The syntax is
[auth@][tcp/]hostname[:port] for tcp, [auth@]unix/local/socket/path for unix
and spawn/ for a private gimp instance. Examples are:

 www.yahoo.com               # just kidding ;)
 yahoo.com:11100             # non-standard port
 tcp/yahoo.com               # make sure it uses tcp
 authorize@tcp/yahoo.com:123 # full-fledged specification
 
 unix/tmp/unx                # use unix domain socket
 password@unix/tmp/test      # additionally use a password
 
 authorize@                  # specify authorization only
 
 spawn/                      # use a private gimp instance

=head1 CALLBACKS

 net()

is called after we have succesfully connected to the server. Do your dirty
work in this function, or see L<Gimp::Fu> for a better solution.

=head1 FUNCTIONS

 server_quit()

sends the perl server a quit command.

=head1 BUGS

(Ver 0.04..) This module is much faster than it ought to be... Silly that I wondered
wether I should implement it in perl or C, since perl is soo fast.

=head1 AUTHOR

Marc Lehmann <pcg@goof.com>

=head1 SEE ALSO

perl(1), L<Gimp>,

=cut
