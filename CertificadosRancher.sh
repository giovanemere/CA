#!/bin/bash
# z<
#curl -o 3-node-certificate.yml https://raw.githubusercontent.com/rancher/rancher/master/rke-templates/3-node-certificate.yml
###################################################################################
# Variables Dinamicas
###################################################################################
clear

source envvars/vars.sh

echo "###################################################"
echo " dominio: [$dominio] | folderPath: [$folderPath] | CN: [$varCN] "
echo "###################################################"

      #####################################################################################################
      # Seccion 2: Ayuda
      #####################################################################################################
            if [[ -z $dominio ]]; # Si no se envia carpeta de repositorio de la aplicacion
                  then
                  echo  '-------------------------------------------------------------------------'
                  echo  ' Faltan paramentros para la ejecución de la shell dominio [aosintlabs.com]'
                  read -p "Press [Enter] key to continue  >> Proceso Limpieza... o CTRL + C para salir" readEnterKey
                  echo  '-------------------------------------------------------------------------'
                  exit 1
            else
      
      ###################################################################################
      # Root pair
      ###################################################################################
            
            #Limpieza Ambientes
            #rm -rf $folderPath/*
            
            ################
            # Variables
            ################
                  fileVars="$folderPath/envvars/folderCA.sh"
                  folderCA="$folderPath/ca"

                  mkdir -p $folderCA
                  cd $folderCA

                  mkdir -p $folderCA/certs $folderCA/crl $folderCA/newcerts $folderCA/private $folderPath/envvars
                  chmod 700 $folderCA/private

                  >$fileVars
                  echo  '-------------------------------------------------------------------------'

                  touch index.txt
                  echo 1000 > seria
                  
                  caOpenssl="$folderCA/openssl.cnf"
                  curl  https://raw.githubusercontent.com/giovanemere/CA/master/ca/openssl.cnf --output $caOpenssl

            echo "##########"
            echo "CREATE root key"
            echo "##########"

                  fileKeyCA="$folderCA/private/ca.key.pem"

                  openssl genrsa -aes256 -out $fileKeyCA 4096
                  chmod 700 $fileKeyCA

                  ls -ltr $fileKeyCA
                  cat $fileKeyCA

            echo "##########"
            echo "CREATE root certificate"
            echo "Fill in the Common Name!"
            echo "##########"

                  fileCA="$folderCA/certs/ca.cert.pem"

                  openssl req -config $caOpenssl \
                        -key $fileKeyCA \
                        -new -x509 -days 7300 -sha256 -extensions v3_ca \
                        -out $fileCA
                  chmod 700 $fileCA

                  ls -ltr $fileCA
                  cat $fileCA

            # Almacenar Variables
                  #echo "folderCA=$folderCA" >>$fileVars
                  #echo "fileKeyCA=$fileKeyCA" >>$fileVars
                  #echo "fileCA=$fileCA" >>$fileVars

                  #echo  '-------------------------------------------------------------------------'
                  #echo  ' Lectura Archivo Variables '
                  #echo  '-------------------------------------------------------------------------'
                  #cat -b $fileVars

            echo  '-------------------------------------------------------------------------'
            read -p "Press [Enter] key to continue  >> Proceso Limpieza... o CTRL + C para salir" readEnterKey
            echo  '-------------------------------------------------------------------------'

      ###################################################################################
      # Intermediate
      ###################################################################################

            folderInter="$folderPath/ca/intermediate"

            mkdir -p $folderInter
            cd $folderInter
            
            mkdir -p $folderInter/certs $folderInter/crl $folderInter/csr $folderInter/newcerts $folderInter/private $folderPath/envvars
            echo "folderInter=$folderInter" >>$fileVars

            chmod 700 private
            
            touch index.txt
            echo 1000 > serial
            echo 1000 > $folderInter/crlnumber
            
            interOpenssl="$folderInter/openssl.cnf"
            curl  https://raw.githubusercontent.com/giovanemere/CA/master/ca/intermediate/openssl.cnf --output $interOpenssl
            
            echo "##########"
            echo "KEY intermediate"
            echo "##########"

                  interKey="$folderInter/private/intermediate.key.pem"

                  cd $folderPath/ca
                  openssl genrsa -aes256 \
                        -out $folderInter/$interKey 4096
                  chmod 700 $folderInter/$interKey

            echo "##########"
            echo "CSR intermediate"
            echo "Fill in the Common Name!"
            echo "##########"
                  
                  interCSR="$folderInter/csr/intermediate.csr.pem"

                  openssl req -config $interOpenssl -new -sha256 \
                        -key $folderInter/$interKey \
                        -out $folderInter/$interCSR

            echo "##########"
            echo "SIGN intermediate"
            echo "##########"
                  
                  interCER="$folderInter/certs/intermediate.cert.pem"

                  openssl ca -config $interOpenssl -extensions v3_intermediate_ca \
                        -days 3650 -notext -md sha256 \
                        -in $folderInter/$interCSR\
                        -out $folderInter/$interCER
                  
                  chmod 700 $folderInter/$interCER

                  interCHAIN="$folderInter/certs/ca-chain.cert.pem"

                  cat $ffolderInter/$interCER \
                        $fileCA > $folderInter/$interCHAIN
                  chmod 700 $folderInter/$interCHAIN

            
            #Almacenar Variables
                  #echo "interCER=$interCER" >>$fileVars
                  #echo "interKey=$interKey" >>$fileVars
                  #echo "interCSR=$interCSR" >>$fileVars

      ###################################################################################
      # Create Certificate
      ###################################################################################
            echo "##########"
            echo "KEY certificate"
            echo "##########"
                  openssl genrsa -aes256 \
                        -out $folderInter/private/$dominio 2048
                  chmod 700 $folderInter/private/$dominio.key.pem

            echo "##########"
            echo "CSR certificate"
            echo "Use rancher.yourdomain.com as Common Name"
            echo "##########"
                  openssl req -config $interOpenssl \
                        -key $folderInter/private/$dominio.key.pem \
                        -new -sha256 -out $folderInter/csr/$dominio.csr.pem
            
            echo "##########"
            echo "SIGN certificate"
            echo "##########"
                  openssl ca -config $interOpenssl \
                        -extensions server_cert -days 375 -notext -md sha256 \
                        -in $folderInter/csr/$dominio.csr.pem \
                        -out $folderInter/certs/$dominio.cert.pem
                  chmod 700 $folderInter/certs/$dominio.cert.pem

            echo "##########"
            echo "Create files to be used for Rancher"
            echo "##########"
            
                  mkdir -p $folderCA/rancher/base64
                  cp $folderCA/certs/ca.cert.pem $folderCA/rancher/cacerts.pem
                  cat $folderInter/certs/$dominio.cert.pem $folderInter/certs/intermediate.cert.pem > $folderCA/rancher/cert.pem
            
            echo "##########"
            echo "Removing passphrase from Rancher certificate key"
            echo "##########"
                  openssl rsa -in $folderInter/private/$dominio.key.pem -out $folderCA/rancher/key.pem
                  cat $folderCA/rancher/cacerts.pem | base64 -w0 > $folderCA/rancher/base64/cacerts.base64
                  cat $folderCA/rancher/cert.pem | base64 -w0 > $folderCA/rancher/base64/cert.base64
                  cat $folderCA/rancher/key.pem | base64 -w0 > $folderCA/rancher/base64/key.base64

###################################################################################
# Paso Final
###################################################################################
      echo "##########"
      echo "Verify certificates"
      echo "##########"
            openssl verify -CAfile $folderPath/certs/ca.cert.pem \
                  $folderInter/certs/intermediate.cert.pem
            openssl verify -CAfile $interCHAIN \
                  $folderInter/certs/$dominio.cert.pem

fi