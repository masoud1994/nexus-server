#!/usr/bin/env bash
#To allow full file access to the volume in case docker is running as root...
chmod 777 volume


#Generate certificate for Nginx
cd configs/secrets/
openssl genrsa -out ca.key 2048
openssl req -new -x509 -key ca.key -out ca.crt -config openssl.conf
openssl genrsa -out server.key 2048

openssl req -new -sha256 -key server.key -out nexus.csr -config openssl.conf
openssl x509 -req -in nexus.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -extensions v3_req -extfile openssl.conf

cp ca.crt /etc/pki/trust/anchors/
update-ca-certificates

cd ../../
#Bring up the server
docker-compose up -d
