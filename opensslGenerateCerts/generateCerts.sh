#!/bin/bash

set -e

function usage {
    echo ""
    echo "Usage: $0 [-h|--help] [--ip ServerIP] [--host ServerHostName]"
    echo ""
    echo "generate CA, server or client certificates."
    echo ""
    echo "Options:"
    echo "  --cacert caFielNamePrefix            ca cert filename prefix, default is 'ca', create new if not exists"
    echo "  --capass caKeyPassword               ca key password"
    echo "  --client clientCertFileNamePrefix    client cert filename prefix, default is 'client', generate client certificate if not exists"
    echo "  --clientpass clientKeyPassword       client key password"
    echo "  --server serverCertFileNamePrefix    server cert filename prefix, default is 'server', generate server certificate if not exists"
    echo "  --serverpass serverKeyPassword       server key password"
    echo "  --ip serverCertIP                    server cert ip, default is empty"
    echo "  --host serverCertDomain              server cert domain, default is empty"
    exit 0
}


function encryptKey {
    keyFileName=$1
    password=$2
    openssl rsa -des3 -in ${keyFileName} -out encrypted_${keyFileName} -passout pass:${password}
    mv encrypted_${keyFileName} $keyFileName
}


function showStepInfo {
    echo "========== $1 =========="
}

CAFILE="ca"
CLIENTFILE="client"
SERVERFILE="server"
IP="127.0.0.1"
DOMAIN="localhost"
NEWFILES=""
SIGNPASS=""
CAPASS=""
CAPASSIN=""
CLIENTPASS=""
CLIENTPASSIN=""
SERVERPASS=""
SERVERPASSIN=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      usage
      ;;
    --cacert)
      [ -n "$2" ] && CAFILE="$2"
      shift
      shift
      ;;
    --capass)
      [ -n "$2" ] && CAPASS="$2"
      shift
      shift
      ;;
    --client)
      [ -n "$2" ] && CLIENTFILE="$2"
      shift
      shift
      ;;
    --clientpass)
      [ -n "$2" ] && CLIENTPASS="$2"
      shift
      shift
      ;;
    --server)
      [ -n "$2" ] && SERVERFILE="$2"
      shift
      shift
      ;;
    --serverpass)
      [ -n "$2" ] && SERVERPASS="$2"
      shift
      shift
      ;;
    --ip)
      [ -n "$2" ] && IP="$2"
      shift
      shift
      ;;
    --host)
      [ -n "$2" ] && DOMAIN="$2"
      shift
      shift
      ;;
    *)
      echo "Invalid option: $1"
      usage
      ;;
  esac
done

[ -n "$CAPASS" ] && CAPASSIN="-passin pass:$CAPASS"
[ -n "$CLIENTPASS" ] && CLIENTPASSIN="-passin pass:$CLIENTPASS"
[ -n "$SERVERPASS" ] && SERVERPASSIN="-passin pass:$SERVERPASS"

if [ ! -f "${CAFILE}.key" ]; then
  showStepInfo "generate ca key and cert file: ${CAFILE}.key, ${CAFILE}.crt"
  openssl req -x509 -newkey rsa:3072 -nodes -keyout "${CAFILE}.key" -out "${CAFILE}.crt" -days 3650 -subj "/C=CN/ST=Beijing/L=Haidian/O=devCompany/OU=testing/CN=testCA"
  [ -n "$CAPASS" ] && encryptKey ${CAFILE}.key $CAPASS
  NEWFILES="\n${CAFILE}.key\n${CAFILE}.crt"
elif [ ! -f "${CAFILE}.crt" ]; then
  showStepInfo "ca key file ${CAFILE}.key exists, generate ca cert file: ${CAFILE}.crt"
  openssl req -x509 -new -key "${CAFILE}.key" -out "${CAFILE}.crt"  -days 3650 -subj "/C=CN/ST=Beijing/L=Haidian/O=devCompany/OU=testing/CN=testCA" $CAPASSIN
  NEWFILES="\n${CAFILE}.crt"
else
  showStepInfo "use exists ca key and cert file: ${CAFILE}.key, ${CAFILE}.crt"
fi

if [ ! -f "${CLIENTFILE}.key" ]; then
  showStepInfo "generate client key and cert file: ${CLIENTFILE}.key, ${CLIENTFILE}.crt"
  openssl req -new -newkey rsa:3072 -nodes -keyout ${CLIENTFILE}.key -out ${CLIENTFILE}.csr -subj "/C=CN/ST=Beijing/L=Haidian/O=devCompany/OU=testing/CN=testClient"
  openssl x509 -req -in ${CLIENTFILE}.csr -CA ${CAFILE}.crt -CAkey ${CAFILE}.key -CAcreateserial -out ${CLIENTFILE}.crt -days 3650 $CAPASSIN
  rm -f ${CLIENTFILE}.csr
  [ -n "$CLIENTPASS" ] && encryptKey ${CLIENTFILE}.key $CLIENTPASS
  NEWFILES="${NEWFILES}\n${CLIENTFILE}.key\n${CLIENTFILE}.crt"
elif [ ! -f "${CLIENTFILE}.crt" ]; then
  showStepInfo "client key file ${CLIENTFILE}.key exists, generate client cert file: ${CLIENTFILE}.crt"
  openssl req -new -key ${CLIENTFILE}.key -out ${CLIENTFILE}.csr -subj "/C=CN/ST=Beijing/L=Haidian/O=devCompany/OU=testing/CN=testClient" $CLIENTPASSIN
  openssl x509 -req -in ${CLIENTFILE}.csr -CA ${CAFILE}.crt -CAkey ${CAFILE}.key -CAcreateserial -out ${CLIENTFILE}.crt -days 3650 $CAPASSIN
  rm -f ${CLIENTFILE}.csr
  NEWFILES="${NEWFILES}\n${CLIENTFILE}.key\n${CLIENTFILE}.crt"
else
  showStepInfo "use exists client key and cert file: ${CLIENTFILE}.key, ${CLIENTFILE}.crt"
fi
  
if [ ! -f "${SERVERFILE}.key" ]; then
  showStepInfo "generate server key and cert file: ${SERVERFILE}.key, ${SERVERFILE}.crt"
  openssl req -new -newkey rsa:3072 -nodes -keyout ${SERVERFILE}.key -out ${SERVERFILE}.csr -subj "/C=CN/ST=Beijing/L=Haidian/O=devCompany/OU=testing/CN=testServer"
  openssl x509 -req -in ${SERVERFILE}.csr -CA ${CAFILE}.crt -CAkey ${CAFILE}.key -CAcreateserial -out ${SERVERFILE}.crt -days 3650 -extfile <(printf "subjectAltName=DNS:${DOMAIN},IP:${IP}") $CAPASSIN
  rm -f ${SERVERFILE}.csr
  [ -n "$SERVERPASS" ] && encryptKey ${SERVERFILE}.key $SERVERPASS
  NEWFILES="${NEWFILES}\n${SERVERFILE}.key\n${SERVERFILE}.crt"
elif [ ! -f "${SERVERFILE}.crt" ]; then
  showStepInfo "server key file ${SERVERFILE}.key exists, generate server cert file: ${SERVERFILE}.crt"
  openssl req -new -key ${SERVERFILE}.key -out ${SERVERFILE}.csr -subj "/C=CN/ST=Beijing/L=Haidian/O=devCompany/OU=testing/CN=testServer" $SERVERPASSIN
  openssl x509 -req -in ${SERVERFILE}.csr -CA ${CAFILE}.crt -CAkey ${CAFILE}.key -CAcreateserial -out ${SERVERFILE}.crt -days 3650 -extfile <(printf "subjectAltName=DNS:${DOMAIN},IP:${IP}") $CAPASSIN
  rm -f ${SERVERFILE}.csr
  NEWFILES="${NEWFILES}\n${SERVERFILE}.crt"
else
  showStepInfo "use exists server key and cert file: ${SERVERFILE}.key, ${SERVERFILE}.crt"
fi

rm -f ${CAFILE}.srl

showStepInfo "new files"
echo -e ${NEWFILES}
