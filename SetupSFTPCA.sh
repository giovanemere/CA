#!/bin/bash
# set an infinite loop
while :
do
	clear

    # display menu
    echo " SERVER NAME: $(hostname)               "
	echo "----------------------------------------"
	echo " MENU: Administracion                  -"
	echo "----------------------------------------"
	echo " Administración CA                     -"
	echo "----------------------------------------"
    echo " 1. Crear Request                      -"
	echo " 2. Importar/Firmar Certificados       -"
	echo " 3. Solo Firmar Certificados           -"
	echo " 4. Revocar un certificado             -"
	echo " 5. Listar certificados Revocados      -"
	echo "----------------------------------------"
	echo " Administración Cliene                 -"
	echo "----------------------------------------"
	echo " 6. Crear pfx o p12                    -"
	echo " 7. Crear PKCS#7                       -"
	echo " 8. Copiar ca,crt a Server Remotos     -"
	echo " 9. Export pem certificado crt         -"
	echo "----------------------------------------"
	echo " General                               -"
	echo " ------------------------------------- -"
	echo " 14. Apagar Servidor                   -"
	echo " 15. Reiniciar Servidor                -"
	echo " 16. Cambiar password Usuarios         -"
	echo "----------------------------------------"
	echo " E. Exit                               -"
    echo "----------------------------------------"
	# get input from the user
	read -p "Enter your choice [1-100] " choice
	
	# get input from the user
	case $choice in
    1)
  			echo ---------------------------------------------------------------
  			echo Modulo Creacion Request
  			echo ---------------------------------------------------------------
  			read -p "Digite el nombre del Certificado    [easy.com]     : " NameDNS
  			read -p "Digite el nombre CN del certificado [*.easy.com]   : " CNNameDNS
  			echo ---------------------------------------------------------------
  			
  			echo Listado de certificados
  			mkdir -p ~/certificates/$NameDNS
  			cd ~/certificates/$NameDNS
  
  			echo -------------------------------------------
  			echo Creación llave Privada
  			echo "Clave por defecto key pass : [Banco123*] "
  			openssl genrsa -out $NameDNS.key
  			ls -d ~/certificates/$NameDNS/$NameDNS.key
  			echo -------------------------------------------
  			echo Fin creación llave Privada
  			echo -------------------------------------------
  
  			echo ---------------------------------------------------------------------------------------
  			echo Modulo Creacion Request
  			echo ---------------------------------------------------------------------------------------
  			#read -p "Country Name (2 letter code) [CO]                   : " vCountry
  			#read -p "State or Province Name (full name) [Colombia]       : " vState
  			#read -p "Locality Name (eg, city) [Bogota]                   : " vLocality
  			#read -p "Organization Name (eg, company) [galeav]	          : " vOrganization
  			#read -p "Organizational Unit Name (eg, section) [Tecnologia] : " vUnitOrganization
  			#read -p "Email Address [admin@$NameDNS.com]                  : " vemail
  			echo ----------------------------------------------------------------------------------------
  
  			vCountry=CO
  			vState=Colombia
  			vLocality=Bogota
  			vOrganization=Easy-DC.local
  			vUnitOrganization=Tecnologia
  			vemail=admin@$NameDNS.com
  		
  			echo -------------------------------------------
  			echo Generar Automatico el request
  			echo -------------------------------------------
  
  			#openssl req -new -key ~/certificates/$NameDNS/$NameDNS.key -out ~/certificates/$NameDNS/$NameDNS.req -subj \
  			#/C=$vCountry/ST=$vState/L=$vLocality/O=$vOrganization/OU=$vUnitOrganization/CN=$NameDNS/emailAddress=$vemail

			openssl genrsa -out ~/certificates/$NameDNS/$NameDNS.key 2048
			
			openssl req -key ~/certificates/$NameDNS/$NameDNS.key -out ~/certificates/$NameDNS/$NameDNS.csr -subj \
  			/C=$vCountry/ST=$vState/L=$vLocality/O=$vOrganization/OU=$vUnitOrganization/CN=$CNNameDNS/emailAddress=$vemail -new -sha256
  
  			ls -d ~/certificates/$NameDNS/$NameDNS.csr
  
  			echo -------------------------------------------
  			echo Verificación de request
  			echo -------------------------------------------
  			
  			openssl req -in ~/certificates/$NameDNS/$NameDNS.csr -noout -subject
  			openssl req -in ~/certificates/$NameDNS/$NameDNS.csr -noout -text
  
  			cp -r ~/certificates/$NameDNS/$NameDNS.csr /tmp/
  
  		echo ---------- Fin del Script ----------------------------
  		read -p "Press [Enter] key to continue..." readEnterKey
  		;;

		2)
			echo -------------------------------------------
			echo Listado de Request posibles a importar
			echo -------------------------------------------
			ls -d /tmp/*.csr
			echo ---------------------------------------------------------------
			echo Modulo Firmar Certificados
			echo ---------------------------------------------------------------
			read -p "Digite el pat del request /tmp/sammy-server.csr   : " ReqDir
			read -p "Digite el nombre del DNS sammy-server             : " NameDNS
			echo ---------------------------------------------------------------
			
			echo " Importar Certificado"
			cd ~/easy-rsa
			./easyrsa import-req $ReqDir $NameDNS

			echo ---------------------------------------------------------------
			echo Modulo Firmar Certificados
			echo ---------------------------------------------------------------
			read -p "Digite el tipo de certificado client, server o ca : " TypeCert
			echo ---------------------------------------------------------------
			
			echo " Firmar Certificado"
			echo " Clave es ::::::: $oport3M$"
			./easyrsa sign-req $TypeCert $NameDNS

			echo " Copiar Certificados Certificados Firmados Certificado"
			cp -r /home/sammy/easy-rsa/pki/issued/$NameDNS.crt ~/certificates/$NameDNS/

			echo " Listado de Certificados Firmados Certificado"
			ls -ld /home/sammy/easy-rsa/pki/issued/*

			echo ---------- Fin del Script ----------------------------
			read -p "Press [Enter] key to continue..." readEnterKey
			;;

		3) 
			echo -------------------------------------------
			echo Listado de Request posibles a importar
			echo -------------------------------------------
			ls /tmp/ | sed -n 's/\.csr$//p'
			echo ---------------------------------------------------------------
			echo Modulo Firmar Certificados
			echo ---------------------------------------------------------------
			read -p "Digite el nombre del DNS sammy-server             : " NameDNS
			read -p "Digite el tipo de certificado client, server o ca : " TypeCert
			echo ---------------------------------------------------------------

			echo " Firmar Certificado"
			echo " Clave es ::::::: $oport3M$"
			cd ~/easy-rsa
			./easyrsa sign-req $TypeCert $NameDNS

			echo " Copiar Certificados Certificados Firmados Certificado"
			cp -r /home/sammy/easy-rsa/pki/issued/$NameDNS.crt ~/certificates/$NameDNS/

			echo " Listado de Certificados Firmados Certificado"
			ls -ld /home/sammy/easy-rsa/pki/issued/*

			echo ---------- Fin del Script ----------------------------
			read -p "Press [Enter] key to continue..." readEnterKey
			;;
			
		4)		
			echo -------------------------------------------
			echo Listado de certificados
			echo -------------------------------------------
				ls /home/sammy/easy-rsa/pki/issued/ | sed -n 's/\.crt$//p'
			echo ---------------------------------------------------------------
			echo Modulo Revocar Certificados
			echo ---------------------------------------------------------------
			read -p "Digite el nombre del DNS sammy-server        : " NameDNS
			echo ---------------------------------------------------------------

			echo Generar una lista de revocación de certificados
			echo -------------------------------------------
			cd ~/easy-rsa
			./easyrsa revoke $NameDNS

			echo Listado de certificados
			echo -------------------------------------------
			./easyrsa gen-crl
			openssl crl -in /home/sammy/easy-rsa/pki/crl.pem -noout -text

		echo ---------- Fin del Script ----------------------------
		read -p "Press [Enter] key to continue..." readEnterKey
		;;

		5)		
			echo ---------------------------------------------------------------
			echo Modulo Listado de Certificados Revocados
			echo ---------------------------------------------------------------

			echo Generar una lista de revocación de certificados
			echo -------------------------------------------
			./easyrsa gen-crl

			echo Listado de certificados
			echo -------------------------------------------
			openssl crl -in /home/sammy/easy-rsa/pki/crl.pem -noout -text

		echo ---------- Fin del Script ----------------------------
		read -p "Press [Enter] key to continue..." readEnterKey
		;;
		
		6)
			#!/bin/bash
			# set an infinite loop
			while :
			do
			clear
			# display menu
			echo " SERVER NAME: $(hostname)               "
			echo "----------------------------------------"
			echo " MENU: Administracion                  -"
			echo "----------------------------------------"
			echo " Administración CA                     -"
			echo "----------------------------------------"
			echo " A. Crear pfx o p12                    -"
			echo " B. Crear pfx o p12 cert adiconales    -"
			echo " C. Crear Keystore                     -"
			echo "----------------------------------------"
			echo " V. Volver Menu Anterio                -"
			echo " E. Exit                               -"
			echo "----------------------------------------"
			# get input from the user 
			read -p "Enter your choice [1-100] " choice

			# get input from the user
			case $choice in
					A)
						echo -------------------------------------------
						echo Listado de certificados
						echo -------------------------------------------
							ls ~/certificates/
						echo ---------------------------------------------------------------
						echo Modulo Creacion pfx o p12
						echo ---------------------------------------------------------------
						read -p "Digite el nombre del Certificado            : " NameDNS
						echo ---------------------------------------------------------------
						echo "Creación de PEM (.pem, .crt, .cer) a PFX  pass : [Banco123*]"
						echo -------------------------------------------

						cd ~/certificates/$NameDNS
						openssl pkcs12 -export -out ~/certificates/$NameDNS/$NameDNS.pfx -inkey ~/certificates/$NameDNS/$NameDNS.key -in ~/certificates/$NameDNS/$NameDNS.crt

						ls -d ~/certificates/$NameDNS/*.p*
						
						echo ---------- Fin del Script ----------------------------
						read -p "Press [Enter] key to continue..." readEnterKey
						;;
				
					B)
						
						ls ~/certificates/
						echo ---------------------------------------------------------------
						echo Modulo Creacion pfx o p12 con certificados adicionales
						echo ---------------------------------------------------------------
						read -p "Digite el nombre del CErtificado            : " NameDNS
						echo ---------------------------------------------------------------
						echo "Creación de PEM (.pem, .crt, .cer) a PFX  pass : [Banco123*]"
						echo -------------------------------------------

						cd ~/certificates/$NameDNS
						openssl pkcs12 -export -out $NameDNS.pfx -inkey $NameDNS.key -in $NameDNS.crt -certfile more.crt

						ls -d ~/certificates/$NameDNS/*.p*

						echo ---------- Fin del Script ----------------------------
						read -p "Press [Enter] key to continue..." readEnterKey
						;;
					C)
						echo -------------------------------------------
						echo Listado de Request posibles a importar
						echo -------------------------------------------
						ls ~/certificates/
						echo ---------------------------------------------------------------
						echo Modulo Create Keystore
						echo ---------------------------------------------------------------
						read -p "Digite el nombre del Certificado               : " NameDNS
						read -p "Digite el nombre CN del Certificado            : " CNNameDNS
						echo ---------------------------------------------------------------
						
						cd ~/certificates/$NameDNS
           				keytool -importkeystore -srckeystore ~/certificates/$NameDNS/$NameDNS.pfx -srcstoretype pkcs12 -srcalias 1 -destkeystore ~/certificates/$NameDNS/$NameDNS.jks -deststoretype jks -deststorepass Banco123* -destalias $CNNameDNS

						ls -d ~/certificates/$NameDNS/*.jks

						echo ---------- Fin del Script ----------------------------
						read -p "Press [Enter] key to continue..." readEnterKey
						;;

					V)
						sh /home/sammy/SetupSFTPCA.sh
						;;
					E)
						echo "Gracias!"
						exit 0
						;;
					*)
						echo "Error: Invalid option..."
						read -p "Press [Enter] key to continue..." readEnterKey
						;;
				esac
			done
			echo ---------- Fin del Script ----------------------------
			read -p "Press [Enter] key to continue..." readEnterKey
			;;
		7)

			echo ---------- Fin del Script ----------------------------
			read -p "Press [Enter] key to continue..." readEnterKey
			;;
		8)
			echo ---------------------------------------------------------------
			echo Modulo Creacion pfx o p12 con certificados adicionales
			echo ---------------------------------------------------------------
			read -p "Digite la ip del servidor remoto          : " ipremoto
			read -p "Digite el usuario de conexion             : " user
			echo ---------------------------------------------------------------
			
			sudo scp /home/sammy/easy-rsa/pki/ca.crt $user@$ipremoto:/usr/local/share/ca-certificates/

			echo ---------------------------------------------------------------
			echo Actualizar llavero certificados
			echo ---------------------------------------------------------------
			
			ssh $user@$ipremoto sudo update-ca-certificates
			
			echo ---------- Fin del Script ----------------------------
			read -p "Press [Enter] key to continue..." readEnterKey
			;;
		9)

			echo -------------------------------------------
			echo Exportar formato PEM certificado crt o cer
			echo -------------------------------------------
			ls /tmp/ | sed -n 's/\.csr$//p'
			echo ---------------------------------------------------------------
			read -p "Digite el nombre del DNS sammy-server             : " NameDNS
			echo ---------------------------------------------------------------
			
			cd ~/certificates/$NameDNS
			openssl x509 -in ~/certificates/$NameDNS/$NameDNS.crt -out ~/certificates/$NameDNS/$NameDNS.pem -outform PEM

			ls -d ~/certificates/$NameDNS/*.pem
			cat ~/certificates/$NameDNS/$NameDNS.pem
			
			echo ---------- Fin del Script ----------------------------
			read -p "Press [Enter] key to continue..." readEnterKey
			;;
					
		14)
			echo --- Apagar Servidor
				sudo shutdown now
				sleep 10
			echo ---------- Fin del Script ----------------------------
			read -p "Press [Enter] key to continue..." readEnterKey
			;;
			
			15)
			echo --- Reinciar Servidor
				sudo reboot
				sleep 10
			echo ---------- Fin del Script ----------------------------
			read -p "Press [Enter] key to continue..." readEnterKey
			;;
		
		16)
			read -p "Digite el usuario a cambiar password: " Usuario
				sudo passwd $Usuario
				sleep 5
			echo ---------- Fin del Script ----------------------------
			read -p "Press [Enter] key to continue..." readEnterKey
			;;
		
		E)
			echo "Gracias!"
			exit 0
			;;
		*)
			echo "Error: Invalid option..."	
			read -p "Press [Enter] key to continue..." readEnterKey
			;;
		esac
	done