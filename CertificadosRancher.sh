#!/bin/bash
# https://gist.github.com/superseb/175476a5a1ab82df74c7037162c64946
#curl -o 3-node-certificate.yml https://raw.githubusercontent.com/rancher/rancher/master/rke-templates/3-node-certificate.yml
###################################################################################
source ./vars

echo "###################################################"
echo " folderPath: [$folderPath] "
echo "###################################################"

rm -rf $folderPath/*

#Ayuda de Shell tagCreate
if [[ -z "$dominio" || -z "$varCN" ]]; # Si no se envia carpeta de repositorio de la aplicacion
then
      echo  '-------------------------------------------------------------------------'
      echo  ' >>> Falta variable 1. dominio aosintlabs.com >>>>           '
      echo  '-------------------------------------------------------------------------'
      exit 1
else

###################################################################################
# Root pair
###################################################################################
      mkdir -p $folderPath/ca
      cd $folderPath/ca

      mkdir -p $folderPath/certs $folderPath/crl $folderPath/newcerts $folderPath/private
      chmod 700 $folderPath/private
      touch index.txt

      echo 1000 > seria

      curl -Lo $folderPath/ca/intermediate/openssl.cnf https://raw.githubusercontent.com/giovanemere/CA/master/ca/openssl.cnf

      echo "##########"
      echo "CREATE root key"
      echo "##########"
            openssl genrsa -aes256 -out $folderPath/private/ca.key.pem 4096
            chmod 400 $folderPath/private/ca.key.pem

      echo "##########"
      echo "CREATE root certificate"
      echo "Fill in the Common Name!"
      echo "##########"
            openssl req -config $folderPath/openssl.cnf \
                  -key $folderPath/private/ca.key.pem \
                  -new -x509 -days 7300 -sha256 -extensions v3_ca \
                  -out $folderPath/certs/ca.cert.pem
            chmod 444 $folderPath/certs/ca.cert.pem

###################################################################################
# Intermediate
###################################################################################

      mkdir -p $folderPath/ca/intermediate
      cd $folderPath/ca/intermediate
      
      mkdir -p $folderPath/certs $folderPath/crl $folderPath/csr $folderPath/newcerts $folderPath/private
      chmod 700 private
      
      touch index.txt
      echo 1000 > serial
      echo 1000 > $folderPath/ca/intermediate/crlnumber

      curl -Lo $folderPath/ca/intermediate/openssl.cnf https://raw.githubusercontent.com/giovanemere/CA/master/ca/intermediate/openssl.cnf
      
      echo "##########"
      echo "KEY intermediate"
      echo "##########"

            cd $folderPath/ca
            openssl genrsa -aes256 \
                  -out $folderPath/intermediate/private/intermediate.key.pem 4096
            chmod 400 $folderPath/intermediate/private/intermediate.key.pem

      echo "##########"
      echo "CSR intermediate"
      echo "Fill in the Common Name!"
      echo "##########"
            openssl req -config $folderPath/intermediate/openssl.cnf -new -sha256 \
                  -key $folderPath/intermediate/private/intermediate.key.pem \
                  -out $folderPath/intermediate/csr/intermediate.csr.pem

      echo "##########"
      echo "SIGN intermediate"
      echo "##########"
            openssl ca -config $folderPath/openssl.cnf -extensions v3_intermediate_ca \
                  -days 3650 -notext -md sha256 \
                  -in $folderPath/intermediate/csr/intermediate.csr.pem \
                  -out $folderPath/intermediate/certs/intermediate.cert.pem
            
            chmod 444 $folderPath/intermediate/certs/intermediate.cert.pem
            cat $folderPath/intermediate/certs/intermediate.cert.pem \
                  $folderPath/certs/ca.cert.pem > $folderPath/intermediate/certs/ca-chain.cert.pem
            chmod 444 $folderPath/intermediate/certs/ca-chain.cert.pem

###################################################################################
# Create Certificate
###################################################################################
      echo "##########"
      echo "KEY certificate"
      echo "##########"
            openssl genrsa -aes256 \
                  -out $folderPath/intermediate/private/$dominio 2048
            chmod 400 $folderPath/intermediate/private/$dominio.key.pem

      echo "##########"
      echo "CSR certificate"
      echo "Use rancher.yourdomain.com as Common Name"
      echo "##########"
            openssl req -config $folderPath/intermediate/openssl.cnf \
                  -key $folderPath/intermediate/private/$dominio.key.pem \
                  -new -sha256 -out $folderPath/intermediate/csr/$dominio.csr.pem
      
      echo "##########"
      echo "SIGN certificate"
      echo "##########"
            openssl ca -config $folderPath/intermediate/openssl.cnf \
                  -extensions server_cert -days 375 -notext -md sha256 \
                  -in $folderPath/intermediate/csr/$dominio.csr.pem \
                  -out $folderPath/intermediate/certs/$dominio.cert.pem
            chmod 444 $folderPath/intermediate/certs/$dominio.cert.pem

      echo "##########"
      echo "Create files to be used for Rancher"
      echo "##########"
      
            mkdir -p $folderPath/ca/rancher/base64
            cp $folderPath/ca/certs/ca.cert.pem $folderPath/ca/rancher/cacerts.pem
            cat $folderPath/ca/intermediate/certs/$dominio.cert.pem $folderPath/ca/intermediate/certs/intermediate.cert.pem > $folderPath/ca/rancher/cert.pem
      
      echo "##########"
      echo "Removing passphrase from Rancher certificate key"
      echo "##########"
            openssl rsa -in $folderPath/ca/intermediate/private/$dominio.key.pem -out $folderPath/ca/rancher/key.pem
            cat $folderPath/ca/rancher/cacerts.pem | base64 -w0 > $folderPath/ca/rancher/base64/cacerts.base64
            cat $folderPath/ca/rancher/cert.pem | base64 -w0 > $folderPath/ca/rancher/base64/cert.base64
            cat $folderPath/ca/rancher/key.pem | base64 -w0 > $folderPath/ca/rancher/base64/key.base64

###################################################################################
# Paso Final
###################################################################################
      echo "##########"
      echo "Verify certificates"
      echo "##########"
            openssl verify -CAfile $folderPath/certs/ca.cert.pem \
                  $folderPath/intermediate/certs/intermediate.cert.pem
            openssl verify -CAfile $folderPath/intermediate/certs/ca-chain.cert.pem \
                  $folderPath/intermediate/certs/$dominio.cert.pem

fi