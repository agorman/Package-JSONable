# ABSTRACT: Add TO_JSON to your packages without the boilerplate

package Package::JSONable;

use strict;
use warnings;
use Scalar::Util qw(reftype);
use Carp qw(croak);
use List::MoreUtils qw(none);
use JSON;

sub import {
    my ( $class, %opts ) = @_;

    my ( $target ) = caller;

    my $glob;
    {
        no strict 'refs';
        $glob = \*{"${target}::TO_JSON"}
    }
    
    $$glob = sub {
        my $self = shift;

        $self = $target unless $self;
        
        my @types = qw/Str Int Num Bool ArrayRef HashRef/;

        my %hash;
        foreach my $method ( keys %opts ) {
            my $type      = $opts{$method};
            my @value     = $self->$method;
            my ( $value ) = @value;
            my $reftype   = reftype $value;
            my $typetype  = reftype $type;

            if ($typetype) {                
                croak sprintf('Invalid type: "%s"', $typetype)
                        if $typetype ne 'CODE';
                
                $hash{$method} = $type->($self, @value );
                next;
            }

            croak sprintf('Invalid type: "%s"', $type)
                    if none { /^$type$/ } @types;
            
            if (!defined $value && $type ne 'Bool') {
                $hash{$method} = $value;
                next;
            }

            if ( $type eq 'Str' ) {
                $hash{$method} = $value . "";
            }
            elsif ( $type eq 'Int' ) {
                $hash{$method} = int $value;
            }
            elsif ( $type eq 'Num' ) {
                $hash{$method} = $value += 0;
            }
            elsif ( $type eq 'ArrayRef' ) {                
                if ($reftype && $reftype eq 'ARRAY') {
                    $hash{$method} = $value;
                }
                else {
                    $hash{$method} = [ @value ];
                }
            }
            elsif ( $type eq 'HashRef' ) {                
                if ($reftype && $reftype eq 'HASH') {
                    $hash{$method} = $value;
                }
                else {
                    $hash{$method} = { @value };
                }
            }
            elsif ( $type eq 'Bool' ) {
                if ( $self->$method() ) {
                    $hash{$method} = JSON::true;
                }
                else {
                    $hash{$method} = JSON::false;
                }
            }
        }

        return \%hash;
    };
}

1;

__END__

=head1 EXPERIMENTAL

For now this module should be considered experimental. I'm also not huge fan of
the namespace so that may change too.

=head1 SYNOPSIS

    package MyModule;
    use Moo;
    
    use Package::JSONable (
        foo => 'Str',
        bar => 'Int',
        baz => 'Bool',
    );
    
    has foo => (
        is      => 'ro',
        default => sub { 'encode me!' },
    );
    
    sub bar {
        return 12345;
    }
    
    sub baz {
        return 1;
    }
    
    sub skipped {
        return 'I wish I could be encoded too :(';
    }
    
later...

    print encode_json(MyModule->new);
    
prints...

    {
        "foo":"encode me!",
        "bar":12345,
        "baz":true
    }

=head1 DESCRIPTION

This module removes the boilderplate of writing TO_JSON functions and methods
for your packages and classes. This module is designed to work with packages
or classes including object systems like Moose.

=head1 Types

The types are designed to be familiar to Moose users. They are designed to cast
method return values to proper JSON.

=head2 Str

    Appends "" to the return value of the given method.
    
=head2 Int

    Calls int() on the return value of the given method.

=head2 Num

    Adds 0 to the return value of the given method.

=head2 Bool

    Returns JSON::true if the given method returns a true value, JSON::false
    otherwise.

=head2 ArrayRef

    If the given method returns an ARRAY ref then it is passed straight though.
    Otherwise [ $return_value ] is returned.

=head2 HashRef

    If the given method returns an HASH ref then it is passed straight though.
    Otherwise { $return_value } is returned.
    
=head2 CODE

    Passes the invocant to the sub along with the given method's return value. 
    