package Gimp::Data;

sub freeze($) {
   my $data = shift;
   if (ref $data
       or $data =~ /^\$VAR1 = \[/) {
      if ( eval { require Data::Dumper } ) {
         $data = new Data::Dumper [$data];
         $data->Purity(1)->Terse(0);
         return $data->Dump;
      } else {
         return;
      }
   }
   $data;
}

sub thaw {
   my $data = shift;
   if ($data =~ /^\$VAR1 = \[/) {
      if (eval { require Data::Dumper }) {
         my $VAR1; # Data::Dumper is braindamaged
         local $^W=0; # perl -w is braindamaged
         return eval $data;
      } else {
         return;
      }
   }
   $data;
}

sub TIEHASH {
   my $pkg = shift;
   my $self;

   bless \$self, $pkg;
}

sub FETCH {
   thaw eval { Gimp->parasite_find ($_[1])->data }
        || ($@ ? Gimp->get_data ($_[1]) : ());
}

sub STORE {
   my $data = freeze $_[2];
   eval { Gimp->parasite_attach ([$_[1], Gimp::PARASITE_PERSISTENT, $data]) };
   Gimp->set_data ($_[1], $data) if $@;
}

sub EXISTS {
   $_[0]->FETCH ? 1 : ();
}

tie (%Gimp::Data, 'Gimp::Data');

1;
__END__

=head1 NAME

Gimp::Data - Set and get state data.

=head1 SYNOPSIS

  use Gimp::Data;

  $Gimp::Data{'value1'} = "Hello";
  print $Gimp::Data{'value1'},", World!!\n";

=head1 DESCRIPTION

With this module, you can access plugin-specific (or global) data in Gimp,
i.e. you can store and retrieve values that are stored in the main Gimp
application.

An example would be to save parameter values in Gimp, so that on subsequent
invocations of your plug-in, the user does not have to set all parameter
values again (L<Gimp::Fu> does this already).

=head1 %Gimp::Data

You can store and retrieve anything you like in this hash. It's contents
will automatically be stored in Gimp, and can be accessed in later
invocations of your plug-in. Be aware that other plug-ins store data
in the same "hash", so better prefix your key with something unique,
like your plug-in's name. As an example, the Gimp::Fu module uses
"function_name/_fu_data" to store its data.

This module might use a persistant implementation, i.e. your data might
survive a restart of the Gimp application, but you cannot count on this.

C<Gimp::Data> will try to freeze your data when you pass in a reference. On
retrieval, the data is thawed again. See L<Storable> for more info. This
might be implemented through either Storable or Data::Dumper, or not
implemented at all (i.e. silently fail) ;)

=head1 PERSISTANCE

C<Gimp::Data> contains the following functions to ease applications where
persistence for perl data structures is required:

=over 4

=item Gimp::Data::freeze(reference)

Freeze (serialize) the reference.

=item Gimp::Data::thaw(data)

Thaw (unserialize) the dsata and return the original reference.

=back

=head1 LIMITATIONS

You cannot store references, and you cannot (yet) iterate through the keys
(with C<keys>, C<values> or C<each>).

=head1 AUTHOR

Marc Lehmann <pcg@goof.com>

=head1 SEE ALSO

perl(1), L<Gimp>.

=cut
