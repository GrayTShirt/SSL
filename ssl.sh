#!/bin/bash

ssl ()
{
	cd certs

	# Generate the certificates
	export OPENSSL_CONF=./caconfig.cnf
	echo "Generating cacert.pem"
	openssl req -x509 -newkey rsa:$bits -out cacert.pem -outform PEM -days $catime -passout pass:$password
	echo "Generating cacert.crt"
	openssl x509 -in cacert.pem -out $filename\_cacert.crt
	export OPENSSL_CONF=./$hname.cnf
	echo "Generating server_key.pem"
	openssl req -newkey rsa:$bits -keyout tempkey.pem -keyform PEM -out tempreq.pem -outform PEM -passout pass:$password
	openssl rsa < tempkey.pem > $filename\_key.pem -passin pass:$password
	export OPENSSL_CONF=./caconfig.cnf

	# echo "Generating server_crt.pem"
	# This is the 01 in signedcerts, preformed diff file is absoluetly the same
	# Will need devise generating plan

	< response.txt openssl ca -in tempreq.pem -out $filename\_crt.pem -passin pass:$password
	rm -f tempkey.pem && rm -f tempreq.pem
	cd ../../
}
