#!/bin/bash
# https://gist.github.com/superseb/175476a5a1ab82df74c7037162c64946
#curl -o 3-node-certificate.yml https://raw.githubusercontent.com/rancher/rancher/master/rke-templates/3-node-certificate.yml

clear

      ###################################################################################
      # Variables Dinamicas
      ###################################################################################
            source envvars/vars.sh

            echo "###################################################"
            echo " dominio: [$dominio] | folderPath: [$folderPath] | CN: [$varCN] "
            echo "###################################################"

      ###################################################################################
      # Seccion 2: Ayuda
      ###################################################################################
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
                  echo 1000 > serial
                  
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
            chmod 700 private
            
            touch index.txt
            echo 1000 > serial
            echo 1000 > $folderInter/crlnumber
            
            interOpenssl="$folderInter/openssl.cnf"
            curl  https://raw.githubusercontent.com/giovanemere/CA/master/ca/intermediate/openssl.cnf --output $interOpenssl
            
            echo "##########"
            echo "KEY intermediate"
            echo "##########"
                  cd $folderCA

                  interKey="private/intermediate.key.pem"
                  
                  openssl genrsa -aes256 \
                        -out $folderInter/$interKey 4096
                  chmod 700 $folderInter/$interKey

                  cat $folderInter/$interKey

            echo "##########"
            echo "CSR intermediate"
            echo "Fill in the Common Name!"
            echo "##########"
                  
                  interCSR="csr/intermediate.csr.pem"

                  openssl req -config $interOpenssl -new -sha256 \
                        -key $folderInter/$interKey \
                        -out $folderInter/$interCSR

                  cat $folderInter/$interCSR

            echo "##########"
            echo "SIGN intermediate"
            echo "##########"
                  
                  interCER="certs/intermediate.cert.pem"

                  openssl ca -config $caOpenssl -extensions v3_intermediate_ca \
                        -days 3650 -notext -md sha256 \
                        -in $folderInter/$interCSR \
                        -out $folderInter/$interCER
                  
                  chmod 700 $folderInter/$interCER

                  interCHAIN="certs/ca-chain.cert.pem"

                  cat $folderInter/$interCER \
                        $fileCA > $folderInter/$interCHAIN
                  chmod 700 $folderInter/$interCHAIN

            echo  '-------------------------------------------------------------------------'
            read -p "Press [Enter] key to continue  >> Proceso Limpieza... o CTRL + C para salir" readEnterKey
            echo  '-------------------------------------------------------------------------'

            
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
                  
                  domainKey="$folderInter/private/$dominio.key.pem"
                  
                  openssl genrsa -aes256 \
                        -out $domainKey 2048
                  chmod 700 $domainKey

                  cat $domainKey

            echo  '-------------------------------------------------------------------------'
            read -p "Press [Enter] key to continue  >> Proceso Limpieza... o CTRL + C para salir" readEnterKey
            echo  '-------------------------------------------------------------------------'

            echo "##########"
            echo "CSR certificate"
            echo "Use rancher.yourdomain.com as Common Name"
            echo "##########"
                  
                  domainCSR="$folderInter/csr/$dominio.csr.pem"
                  
                  openssl req -config $interOpenssl \
                        -key $domainKey \
                        -new -sha256 -out $domainCSR

                  cat $domainCSR
            echo  '-------------------------------------------------------------------------'
            read -p "Press [Enter] key to continue  >> Proceso Limpieza... o CTRL + C para salir" readEnterKey
            echo  '-------------------------------------------------------------------------'
            
            echo "##########"
            echo "SIGN certificate"
            echo "##########"
                  
                  domainCert="$folderInter/certs/$dominio.cert.pem"
                  openssl ca -config $interOpenssl \
                        -extensions server_cert -days 375 -notext -md sha256 \
                        -in $domainCSR \
                        -out $domainCert
                  chmod 700 $domainCert

                  cat $domainCert
            
            echo  '-------------------------------------------------------------------------'
            read -p "Press [Enter] key to continue  >> Proceso Limpieza... o CTRL + C para salir" readEnterKey
            echo  '-------------------------------------------------------------------------'

            echo "##########"
            echo "Create files to be used for Rancher"
            echo "##########"
            
                  mkdir -p $folderCA/rancher/base64
                  cp $fileCA $folderCA/rancher/cacerts.pem
                  cat $domainCert $folderInter/$interCER > $folderCA/rancher/cert.pem

            echo  '-------------------------------------------------------------------------'
            read -p "Press [Enter] key to continue  >> Proceso Limpieza... o CTRL + C para salir" readEnterKey
            echo  '-------------------------------------------------------------------------'
            
            echo "##########"
            echo "Removing passphrase from Rancher certificate key"
            echo "##########"
                  openssl rsa -in $domainKey -out $folderCA/rancher/key.pem

                  cat $folderCA/rancher/cacerts.pem | base64 -w0 > $folderCA/rancher/base64/cacerts.base64
                  cat $folderCA/rancher/cert.pem | base64 -w0 > $folderCA/rancher/base64/cert.base64
                  cat $folderCA/rancher/key.pem | base64 -w0 > $folderCA/rancher/base64/key.base64

            echo  '-------------------------------------------------------------------------'
            read -p "Press [Enter] key to continue  >> Proceso Limpieza... o CTRL + C para salir" readEnterKey
            echo  '-------------------------------------------------------------------------'

###################################################################################
# Paso Final
###################################################################################
      echo "##########"
      echo "Verify certificates"
      echo "##########"
            openssl verify -CAfile $fileCA \
                  $interCER
            openssl verify -CAfile $interCHAIN \
                  $domainCert

fi