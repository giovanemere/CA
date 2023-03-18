#/bin/bash

#cat -b /home/giovanemere/.profile
#
#24  token="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"
#25  username="giovanemere"
#26  rama="master"
#27  repo="giovanemere/Aprovisionamiento_Linux.git"
#
#git config --global user.name "Edisson Zuniga"
#git config --global user.email "giovanemere@gmail.com"
#git config --list

git config --global core.autocrlf false

clear

# set variables
username="Edisson Zuniga"
comment="${1}"
rama="${2}"

#Ayuda de Shell tagCreate
if [[ -z "$comment" || -z "$rama" ]]; # Si no se envia carpeta de repositorio de la aplicacion
    then
        echo  '-------------------------------------------------------------------------'
        echo  ' >>> Falta variable 1. commentario o nombre de la 2. rama >>>>           '
        echo  '-------------------------------------------------------------------------'
        exit 1
    else

        # Ejecucion

        #cd /home/giovanemere/Aprovisionamiento_Linux
        #git clone https://$username:$token@github.com/$repo
        #git clone https://@github.com/$repo

        git status
        read -p "Press [Enter] key to continue..." readEnterKey

        echo "----------------------------------------------------"
        echo "git add ."
        echo "----------------------------------------------------"
        git add .

        read -p "Press [Enter] key to continue..." readEnterKey

        echo "----------------------------------------------------"
        echo "git commit -m \"$comment\""
        echo "----------------------------------------------------"
        git commit -m "$comment"

        read -p "Press [Enter] key to continue..." readEnterKey

        echo "----------------------------------------------------"
        echo "git push origin $rama"
        echo "----------------------------------------------------"
        git push origin $rama

        read -p "Press [Enter] key to continue..." readEnterKey

fi