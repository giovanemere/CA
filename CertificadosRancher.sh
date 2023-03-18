#!/bin/bash
# https://gist.github.com/superseb/175476a5a1ab82df74c7037162c64946
#curl -o 3-node-certificate.yml https://raw.githubusercontent.com/rancher/rancher/master/rke-templates/3-node-certificate.yml
###################################################################################
source ./vars

echo "###################################################"
echo "folderPath: [$folderPath]"
echo "###################################################"

###################################################################################
# Root pair
###################################################################################
      mkdir -p $folderPath/ca
      cd $folderPath/ca

      mkdir -p certs crl newcerts private
      chmod 700 private
      touch index.txt

      echo 1000 > seria

      curl -o $folderPath/ca/intermediate/openssl.cnf https://jamielinux.com/docs/openssl-certificate-authority/_downloads/root-config.txt

      echo "##########"
      echo "CREATE root key"
      echo "##########"
            openssl genrsa -aes256 -out private/ca.key.pem 4096
            chmod 400 private/ca.key.pem

      echo "##########"
      echo "CREATE root certificate"
      echo "Fill in the Common Name!"
      echo "##########"
            openssl req -config openssl.cnf \
                  -key private/ca.key.pem \
                  -new -x509 -days 7300 -sha256 -extensions v3_ca \
                  -out certs/ca.cert.pem
            chmod 444 certs/ca.cert.pem

###################################################################################
# Intermediate
###################################################################################

      mkdir -p $folderPath/ca/intermediate
      cd $folderPath/ca/intermediate
      
      mkdir -p certs crl csr newcerts private
      chmod 700 private
      
      touch index.txt
      echo 1000 > serial
      echo 1000 > $folderPath/ca/intermediate/crlnumber

      curl -o $folderPath/ca/intermediate/openssl.cnf https://jamielinux.com/docs/openssl-certificate-authority/_downloads/root-config.txt

      
      echo "##########"
      echo "KEY intermediate"
      echo "##########"

            cd $folderPath/ca
            openssl genrsa -aes256 \
                  -out intermediate/private/intermediate.key.pem 4096
            chmod 400 intermediate/private/intermediate.key.pem

      echo "##########"
      echo "CSR intermediate"
      echo "Fill in the Common Name!"
      echo "##########"
            openssl req -config intermediate/openssl.cnf -new -sha256 \
                  -key intermediate/private/intermediate.key.pem \
                  -out intermediate/csr/intermediate.csr.pem

      echo "##########"
      echo "SIGN intermediate"
      echo "##########"
            openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
                  -days 3650 -notext -md sha256 \
                  -in intermediate/csr/intermediate.csr.pem \
                  -out intermediate/certs/intermediate.cert.pem
            
            chmod 444 intermediate/certs/intermediate.cert.pem
            cat intermediate/certs/intermediate.cert.pem \
                  certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
            chmod 444 intermediate/certs/ca-chain.cert.pem

###################################################################################
# Create Certificate
###################################################################################
      echo "##########"
      echo "KEY certificate"
      echo "##########"
            openssl genrsa -aes256 \
                  -out intermediate/private/$dominio 2048
            chmod 400 intermediate/private/$dominio.key.pem

      echo "##########"
      echo "CSR certificate"
      echo "Use rancher.yourdomain.com as Common Name"
      echo "##########"
            openssl req -config intermediate/openssl.cnf \
                  -key intermediate/private/$dominio.key.pem \
                  -new -sha256 -out intermediate/csr/$dominio.csr.pem
      
      echo "##########"
      echo "SIGN certificate"
      echo "##########"
            openssl ca -config intermediate/openssl.cnf \
                  -extensions server_cert -days 375 -notext -md sha256 \
                  -in intermediate/csr/$dominio.csr.pem \
                  -out intermediate/certs/$dominio.cert.pem
            chmod 444 intermediate/certs/$dominio.cert.pem

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
            openssl verify -CAfile certs/ca.cert.pem \
                  intermediate/certs/intermediate.cert.pem
            openssl verify -CAfile intermediate/certs/ca-chain.cert.pem \
                  intermediate/certs/$dominio.cert.pem