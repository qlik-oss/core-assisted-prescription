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

while [[ $# -gt 1 ]]
do
  arg="$1"

  case $arg in
    -a)
    ADDRESS="$2"
    shift # past arg
    ;;
    -r)
    FORCE="1"
    shift
    ;;
  esac
  shift # past arg
done

echo "\n========================================================================"
echo "  Setting up deployment certificates"
echo "========================================================================"

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

SUBJECT="/O=Global Security/CN=$ADDRESS"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $CERT_KEY -out $CERT_FILE -subj "$SUBJECT"
