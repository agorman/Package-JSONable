# ABSTRACT: Add TO_JSON to your packages without the boilerplate

package Package::JSONable;

use strict;
use warnings;
use Scalar::Util qw(reftype);
use JSON;

sub _getglob { \*{$_[0]} }

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

        my %hash;
        foreach my $method ( keys %opts ) {
            my $type  = $opts{$method};
            my $value = $self->$method;
            
            if (!defined $value && $type ne 'Bool') {
                $hash{$method} = $value;
                next;
            }

            if ( $type eq 'Str' ) {
                $hash{$method} = $self->$method() . "";
            }
            elsif ( $type eq 'Int' ) {
                $hash{$method} = int $self->$method();
            }
            elsif ( $type eq 'Num' ) {
                my $num = $self->$method();
                $hash{$method} = $num += 0;
            }
            elsif ( $type eq 'ArrayRef' ) {
                my $rtype = reftype $self->$method();
                
                if ($rtype && $rtype eq 'ARRAY') {
                    $hash{$method} = $self->$method();
                }
                else {
                    $hash{$method} = [ $self->$method() ];
                }
            }
            elsif ( $type eq 'HashRef' ) {
                my $rtype = reftype $self->$method();
                
                if ($rtype && $rtype eq 'HASH') {
                    $hash{$method} = $self->$method();
                }
                else {
                    $hash{$method} = { $self->$method() };
                }
            }
            elsif ( reftype($type) && reftype($type) eq 'CODE' ) {
                $hash{$method} = $type->($self, $self->$method() );
            }
            elsif ( $type eq 'Bool' ) {
                if ( $self->$method() ) {
                    $hash{$method} = JSON::true;
                }
                else {
                    $hash{$method} = JSON::false;
                }
            }
            else {
                die "Invalid type: $type";
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

The types are designed to be familiar to Moose users. They 

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
    