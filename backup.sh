#!/bin/bash

basedir=${0%/*}
list_file=$basedir/list.conf
data=$basedir/data/
decr=$basedir/decrypted
salt=$basedir/data/salt
password=$basedir/.secret

function notify {
    echo -e "-- $1"
}

if ! [ -e "$list_file" ]
then
    notify "list.conf should exist in basedir: $basedir"
    exit -1
fi

# salt is pushed in the backup repository
function passwd_salt {
    if ! [ -e $salt ]
    then
	rm -f "$password"
	openssl rand -base64 6 > $salt && \
	    notify "Salt generated"
    fi
}

# password is MD5 encrypted with salt and not pushed into repository
function passwd {
    ! [ -e $salt ] && notify "no salt file" && exit -1
    if ! [ -e $password ]
    then
	openssl passwd -1 -salt `cat $salt` > "$password" && \
	    chmod 400 $password && \
	    notify "Password generated"
    fi
}

function encrypt {
    notify "Encrypt: $1 -> $2"
    if openssl aes-256-cbc -a -salt -in "$1" -out "$2" -pass file:$password
    then notify "Encrypted!"
    else notify "Echec!"
    fi
}

function compress {
    notify "Compressing: $1"
    tar cvfz "$1" -T "$2" || ( notify "compression error!" && rm -f "$1" && exit -1 )
}

function extract {
    notify "Extract: $1 -> $2"
    tar xvfz "$1" -C "$2"
}

function encryption {
    if ! [ -e $data ]
    then
	mkdir -vp $data && \
	    notify "Created backup directory"
    fi
    passwd_salt
    passwd
    notify "Start compress and encrypt"
    tar="snapshot-`date +%Y.%m.%d-%H:%m:%S`.tar.gz"
    tmp="/tmp/$tar"
    compress $tmp $list_file
    encrypt $tmp $data$tar.enc
    rm $tmp
    notify "Done"
}

function decrypt {
    if openssl aes-256-cbc -a -d -in "$1" -out "$2" -pass file:"$password"
    then notify "Decrypted: $1"
    else notify "Error: $1"
    fi
}


function decryption {
    ! [ -e "$salt" ] && notify "Cannot decrypt without the password salt" && exit -1
    ! [ -e "$data" ] && notify "No data have been encrypted" && exit -1
    passwd
    ! [ -e "$decr" ] && mkdir -p "$decr"
    for compressed_encrypted in $data*
    do
	compressed=/tmp/compressed.tar.gz
	decrypt $compressed_encrypted $compressed
	extract $compressed $decr
	rm $compressed
    done
}

if [[ $1 == "-d" ]]
then
    decryption
else
    encryption
fi
