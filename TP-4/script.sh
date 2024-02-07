#!/bin/bash

#take input for client public key

#rpm -q chrony | grep -q 'package chrony is not installed' && echo 'oh no'

chrony () {
  rpm -q chrony | grep -q 'package chrony is not installed' && dnf install chrony
}



main () {
    chrony

}


while true; do
    read -p "Is this machine the server? (y/n) " yn
    case $yn in
        [Yy]* ) read -p "Please enter your clients public key, then press enter: " pub; main;;
        [Nn]* ) echo "Sorry, this script only works if the machine is your server"; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
