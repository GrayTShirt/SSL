#!/usr/bin/perl

use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'D3fy::SSL',
	VERSION_FROM => 'lib/D3fy/SSL.pm',
	ABSTRACT     => "Easy and extenaible generation of ssl certs",
	LICENSE      => 'GPLv2',
);
