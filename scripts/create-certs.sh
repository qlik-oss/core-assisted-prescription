#!/bin/bash

set -e

ADDRESS=
FORCE="0"
CERT_FILE=./secrets/cert-gateway.crt
CERT_KEY=./secrets/cert-gateway.key

# base our path from root independent from cwd:
cd "$(dirname "$0")"
cd ..

mkdir -p ./secrets/

while [[ $# -gt 0 ]]
do
  arg="$1"

  case $arg in
    -a)
    ADDRESS="$2"
    shift # past arg
    ;;
    -r)
    FORCE="1"
    ;;
  esac
  shift # past arg
done

echo -e "\n========================================================================"
echo -e "  Setting up deployment certificates"
echo -e "========================================================================"

if [[ -z "$ADDRESS" ]]; then
  echo "-> Failure: you need to pass in the hostname/ip of the deployment using -a"
  exit 1
fi

if [ $FORCE == "1" ]; then
  echo "-> Replace argument found, removing old certificates..."
  rm $CERT_FILE
  rm $CERT_KEY
elif [ -f $CERT_FILE ]; then
  echo "-> Warning: skipping certificate creation since they already exist, use -r 1 to replace"
  exit 0
fi

echo "-> Creating new certificates..."

if [[ $(uname -o) == "Msys" ]]; then
  # https://stackoverflow.com/questions/31506158/running-openssl-from-a-bash-script-on-windows-subject-does-not-start-with
  SUBJECT="//O=Global Security\CN=$ADDRESS"
else
  SUBJECT="/O=Global Security/CN=$ADDRESS"
fi
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $CERT_KEY -out $CERT_FILE -subj "$SUBJECT"
