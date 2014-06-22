#!/usr/bin/perl

use strict;
use warnings;

our $VERSION = 0.0.1;

my $OPTION = {};

sub generate
{


}

sub configure
{
	my (%options) = @_;
	$OPTION->{password}      ||= "default_password";
	$OPTION->{cert_name}     ||= `hostname -f`;
	$OPTION->{dir}           ||= "$ENV{PWD}";
	$OPTION->{ca_expire}     ||= 365;
	$OPTION->{server_expire} ||= 30;
	$OPTION->{bits}          ||= 4096;
	$OPTION->{state}         ||= "NY";
	$OPTION->{contry}        ||= "US";
	$OPTION->{locality}      ||= 'BUFFALO';
	$OPTION->{unit}          ||= 'IT';
	$OPTION->{email}         ||= 'ADMIN@'.uc $OPTION->{cert_name};
	if(!$OPTION->{org}) {
		$OPTION->{org} ||=  $OPTION->{cert_name};
		$OPTION->{org}   =~ s/\.[A-Za-z0-9]+$//;
		$OPTION->{org}   =  uc $OPTION->{org};
		$OPTION->{org}   =~ s/\./_/g;
	}

	die "Certs dir must be a full path" unless $OPTION->{dir} =~ m/^\//;
	if (!-e $OPTION->{dir}) {
		mkdir $OPTION->{dir}
			or die "Unable to make $OPTION->{dir} directory: $!";
	}
	for (qw/signedcerts private/) {
		mkdir "$OPTION->{dir}/$_"
			or die "Unable to make $OPTION->{dir}/$_ directory: $!";
	}

	open my $fh, ">", "$OPTION->{dir}/serial"
		or die "Unable to open $OPTION->{dir}/serial file: $!";
	print $fh "01\n";
	close $fh
		or die "Unable to close $OPTION->{dir}/serial file: $!";

	open $fh, ">", "$OPTION->{dir}/index.txt"
		or die "Unable to open $OPTION->{dir}/index.txt file: $!";
	close $fh
		or die "Unable to close $OPTION->{dir}/index.txt file: $!";

	my $global = <<EOF;
[ ca ]
default_ca = local_ca
[ local_ca ]
dir              = $OPTION->{dir}
certificate      = $OPTION->{dir}/cacert.pem
database         = $OPTION->{dir}/index.txt
new_certs_dir    = $OPTION->{dir}/signedcerts
private_key      = $OPTION->{dir}/private/cakey.pem
serial           = $OPTION->{dir}/serial
default_crl_days = $OPTION->{server_expire}
default_days     = $OPTION->{ca_expire}
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
default_bits       = $OPTION->{bits}
default_keyfile    = $OPTION->{dir}/private/cakey.pem
default_md         = md5
prompt             = no
distinguished_name = root_ca_distinguished_name
x509_extensions    = root_ca_extensions
[ root_ca_distinguished_name ]
commonName             = $OPTION->{cert_name}
localityName           = $OPTION->{locality}
stateOrProvinceName    = $OPTION->{state}
countryName            = $OPTION->{contry}
emailAddress           = $OPTION->{email}
organizationName       = $OPTION->{org}
organizationalUnitName = $OPTION->{unit}
[ root_ca_extensions ]
basicConstraints = CA:true
EOF

	open $fh, ">", "$OPTION->{dir}/ca_config.cnf"
		or die "Unable to open $OPTION->{dir}/ca_config.cnf file: $!";
	print $fh $global;
	close $fh
		or die "Unable to close $OPTION->{dir}/ca_config.cnf file: $!";

	my $server_config = <<EOF;
[ req ]
prompt             = no
distinguished_name = server_distinguished_name

[ server_distinguished_name ]
commonName             = $OPTION->{cert_name}
localityName           = $OPTION->{locality}
stateOrProvinceName    = $OPTION->{state}
countryName            = $OPTION->{contry}
emailAddress           = $OPTION->{email}
organizationName       = $OPTION->{org}
organizationalUnitName = $OPTION->{unit}
EOF

	open $fh, ">", "$OPTION->{dir}/$OPTION->{cert_name}_config.cnf"
		or die "Unable to open $OPTION->{dir}/$OPTION->{cert_name}_config.cnf file: $!";
	print $fh $server_config;
	close $fh
		or die "Unable to close $OPTION->{dir}/$OPTION->{cert_name}_config.cnf file: $!";
}

sub generate
{
	$ENV{OPENSSL_CONF} = "./caconfig.cnf";
	openssl req -x509 -newkey rsa:$bits -out cacert.pem -outform PEM -days $catime -passout pass:$password

	openssl x509 -in cacert.pem -out $filename\_cacert.crt
	$ENV{OPENSSL_CONF} = "./$hname.cnf";

	openssl req -newkey rsa:$bits -keyout tempkey.pem -keyform PEM -out tempreq.pem -outform PEM -passout pass:$password
	openssl rsa < tempkey.pem > $filename\_key.pem -passin pass:$password
	$ENV{OPENSSL_CONF} = "./caconfig.cnf";

	< response.txt openssl ca -in tempreq.pem -out $filename\_crt.pem -passin pass:$password

}

=pod

=head1 NAME

D3fy::SSL

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

1;
