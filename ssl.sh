#!/bin/bash

ssl ()
{
	hname="0"
	filename="0"
	catime="365"
	stime="30"
	bits="4096"
	while [ "$1" != "" ]; do
		case $1 in
			-p | --password ) shift
                              password=$1
                              ;;
			-h | --hostname ) shift
				hname=$1
				;;
			-f | --file ) shift
				filename=$1
				;;
			-t | --catime ) shift
				catime=$1
				;;
			-s | --stime ) shift
				stime=$1
				;;
			-b | --bits ) shift
				bits=$1
				;;
		esac
		shift
	done

	if [[ "$hname" == "0" ]] ; then 
    hname=`hostname -f`
  fi
  if [[ "$filename" == "0" ]] ; then 
    filename="server"
  fi
   
   if [[ ! -e certs ]]; then
     mkdir certs
   fi 
   
   pwd 
   # set up the configuration files
   . ./config
   config $hname

   # Set the static file path in the script
   sdir=`pwd -P`/certs
   echo "sdir: $sdir"
   sdir=`echo $sdir | sed -e 's/\//\\\\\//g'`
   sed -i "s/ssldir/$sdir/g" certs/* 


   # Change default days
   sed -i "s/default\_days\ \=/default\_days\ \=\ $catime/" certs/caconfig.cnf
   sed -i "s/default\_days\ \=/default\_days\ \=\ $stime/" certs/$hname.cnf
   
   # Chage default bits (probably not necessary to have different bit encryption)
   sed -i "s/default\_bits\ \=/default\_bits\ \=\ $bits/" certs/*
   # Set the common name of the cert to the fully qualifed domain name
  
   
   hnamen=`echo $hname | sed -e 's/\./\\\\./g'`
   domain=`echo $hnamen | sed "s/^[A-Za-z0-9\/]*[A-Za-z0-9\/]\.//" `
   # echo $hnamen   
   # echo $domain
   sed -i "s/hhname/$hnamen/g" certs/*

   # Set the organization name to the domain name without the tld
   orgname=`echo $domain | sed 's/\(^.*\)\\\.*$/\U\1/'`
   # echo $orgname
   sed -i "s/\(^organizationName.*\=\)$/\1\ $orgname/" certs/*

   # Set the email to admin plus the domian name
   email=admin\@$domain
   
   email=`echo $email | sed -e 's/\@/\\\\@/g'`
   echo $email
   sed -i "s/\(^emailAddress.*\=\)$/\1\ $email/" certs/*
   # if [ ! -f ip_info ] ; then 
   #   wget -q -t 3 http://www.liveipmap.com/ -O ip_info
   # fi
   # Callout to get the country and parse
   # . ./country
   #getcountry
   country='US'
   sed -i "s/\(countryName.*\=\)$/\1\ $country/" certs/*

   # Callout to get the state and parse
   #. ./state
   # getstate
   state='NY'
   sed -i "s/\(stateOrProvinceName.*\=\)$/\1\ $state/" certs/*

   # Callout to get the city, don't bother parsing
   city='BUFFALO'
   sed -i "s/\(localityName.*\=\)$/\1\ $city/" certs/*

   mkdir certs/signedcerts
   mkdir certs/private
   touch certs/index.txt
   echo "01" > certs/serial
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
   echo "Generating server_crt.pem"
   # This is the 01 in signedcerts, preformed diff file is absoluetly the same
   # Will need devise generating plan
   < response.txt openssl ca -in tempreq.pem -out $filename\_crt.pem -passin pass:$password 
   rm -f tempkey.pem && rm -f tempreq.pem
   cd ../../
}

# Testing out the generator
# ssl -t 365 -s 31 -b 1024 -p youaregoingtodie -h door.d3fy.net
ssl -h git.d3fy.net -p secretpassword
