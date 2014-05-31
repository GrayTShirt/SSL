#!/usr/bin/perl

use strict;
use warnings;

our $VERSION = 0.0.1;

sub generate
{
	my (%options) = @_;
	my $options{password}      ||= "default_password";
	my $options{cert_name}     ||= `hostname -f`;
	my $options{dir}           ||= "$ENV{PWD}";
	my $options{ca_expire}     ||= 365;
	my $options{server_expire} ||= 30;
	my $options{bits}          ||= 4096;

	die "Certs dir must be a full path" unless $options{dir} =~ m/^\//;
	if (!-e $options{dir}) {
		mkdir $options{dir} or die "Unable to make $options{dir} directory: $!";
	}



}

sub configure
{


	my $global = <<EOF
[ ca ]
default_ca = local_ca
[ local_ca ]
dir              = ssldir
certificate      = ssldir/cacert.pem
database         = ssldir/index.txt
new_certs_dir    = ssldir/signedcerts
private_key      = ssldir/private/cakey.pem
serial           = ssldir/serial
default_crl_days = 3000
default_days     =
default_md       = md5
policy           = local_ca_policy
x509_extensions  = local_ca_extensions
[ local_ca_policy ]
commonName             = supplied
localityName           = supplied
stateOrProvinceName    = supplied
countryName            = supplied
localityName           = supplied
emailAddress           = supplied
organizationName       = supplied
organizationalUnitName = supplied
[ local_ca_extensions ]
subjectAltName   = DNS:hhname
basicConstraints = CA:false
nsCertType       = server
[ req ]
default_bits       =
default_keyfile    = ssldir/private/cakey.pem
default_md         = md5
prompt             = no
distinguished_name = root_ca_distinguished_name
x509_extensions    = root_ca_extensions
[ root_ca_distinguished_name ]
commonName = hhname
localityName           =
stateOrProvinceName    =
countryName            =
emailAddress           =
organizationName       =
organizationalUnitName = IT
[ root_ca_extensions ]
basicConstraints = CA:true
EOF

	my $server_config = <<EOF
[ req ]
prompt             = no
distinguished_name = server_distinguished_name

[ server_distinguished_name ]
commonName             = hhname
localityName           =
stateOrProvinceName    =
countryName            =
emailAddress           =
organizationName       =
organizationalUnitName = IT
EOF
}

=pod

=head1 NAME

=cut

1;
