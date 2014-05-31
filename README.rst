=============
SSL GENERATOR
=============

:keywords: ssl, openssl, perl
:description:
    Auto Generate ssl certs for security automation


:author: Daniel Molik
:contact: dan@runedrive.com
:copyright: GPL-2
:language: English

Progress
========

The perl modulariztiion is going well, I've opted for a simpler tranliteration of the shell script as opposed to a full code rewrite. This allows the conversion to happen quicker, additions and fixes can happen to code base in perl, instead of both perl and bash.

TODO
====

# Add support for signing multiple server certs off the same ca. Add support for signing multiple client certs off a choosen server cert, but if there is only one server cert it won't prompt, additionally support cding to a given server directory and sign new client certs (no prompt necessary).
# Documentation.
# Functions should be generic enough to use in a Dancer App.
# Object Oriented.
