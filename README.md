# NAME

Package::JSONable - Add TO\_JSON to your packages without the boilerplate

# VERSION

version 0.001

# SYNOPSIS

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

# DESCRIPTION

This module removes the boilderplate of writing TO\_JSON functions and methods
for your packages and classes. This module is designed to work with packages
or classes including object systems like Moose.

# EXPERIMENTAL

For now this module should be considered experimental. I'm also not huge fan of
the namespace so that may change too.

# Types

The types are designed to be familiar to Moose users. They are designed to cast
method return values to proper JSON.

## Str

    Appends "" to the return value of the given method.

## Int

    Calls int() on the return value of the given method.

## Num

    Adds 0 to the return value of the given method.

## Bool

    Returns JSON::true if the given method returns a true value, JSON::false
    otherwise.

## ArrayRef

    If the given method returns an ARRAY ref then it is passed straight though.
    Otherwise [ $return_value ] is returned.

## HashRef

    If the given method returns an HASH ref then it is passed straight though.
    Otherwise { $return_value } is returned.

## CODE

    Passes the invocant to the sub along with the given method's return value. 

# AUTHOR

Andy Gorman <agorman@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Andy Gorman.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
