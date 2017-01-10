#!/bin/bash

read -p 'Enter SERVICE_IP_RANGE : ' SERVICE_IP_RANGE
echo $SERVICE_IP_RANGE
if [ ! -z "$SERVICE_IP_RANGE" ]
then
   echo $SERVICE_IP_RANGE
   sed -i "" "s~SERVICE_IP_RANGE:.*~SERVICE_IP_RANGE: ${SERVICE_IP_RANGE}~" defaults/main.yaml
fi

read -p 'Enter POD_NETWORK : ' POD_NETWORK
echo $POD_NETWORK
if [ ! -z "$POD_NETWORK" ]
then
   echo $POD_NETWORK
   sed -i "" "s~POD_NETWORK:.*~POD_NETWORK: ${POD_NETWORK}~" defaults/main.yaml
fi

read -p 'Enter DNS_SERVICE_IP : ' DNS_SERVICE_IP
echo $DNS_SERVICE_IP
if [ ! -z "$DNS_SERVICE_IP" ]
then
   echo $DNS_SERVICE_IP
   sed -i "" "s~DNS_SERVICE_IP:.*~DNS_SERVICE_IP: ${DNS_SERVICE_IP}~" defaults/main.yaml
fi

read -p 'Enter K8S_SERVICE_IP : ' K8S_SERVICE_IP
echo $K8S_SERVICE_IP
if [ ! -z "$K8S_SERVICE_IP" ]
then
   echo $K8S_SERVICE_IP
   sed -i "" "s~K8S_SERVICE_IP:.*~K8S_SERVICE_IP: ${K8S_SERVICE_IP}~" defaults/main.yaml
fi

read -p 'Enter K8S_VER : ' K8S_VER
echo $K8S_VER
if [ ! -z "$K8S_VER" ]
then
   echo $K8S_VER 
   sed -i "" "s~K8S_VER:.*~K8S_VER: ${K8S_VER}~" defaults/main.yaml
fi

read -p 'Enter MASTER_HOST : ' MASTER_HOST
echo $MASTER_HOST
if [ ! -z "$MASTER_HOST" ]
then
   echo $MASTER_HOST
   sed -i "" "s~MASTER_HOST:.*~MASTER_HOST: ${MASTER_HOST}~" defaults/main.yaml
fi

read -p 'Enter ETCD_ENDPOINTS : ' ETCD_ENDPOINTS
echo $ETCD_ENDPOINTS
if [ ! -z "$ETCD_ENDPOINTS" ]
then
   echo $ETCD_ENDPOINTS
   sed -i "" "s~ETCD_ENDPOINTS:.*~ETCD_ENDPOINTS: ${ETCD_ENDPOINTS}~" defaults/main.yaml
fi

mkdir certs
cd certs
echo "[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = ${K8S_SERVICE_IP}
IP.2 = ${MASTER_HOST}" >> openssl.cnf
openssl genrsa -out ca-key.pem 2048
openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"
openssl genrsa -out apiserver-key.pem 2048
openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=kube-apiserver" -config openssl.cnf
openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 365 -extensions v3_req -extfile openssl.cnf
openssl genrsa -out worker-key.pem 2048
openssl req -new -key worker-key.pem -out worker.csr -subj "/CN=kube-worker"
openssl x509 -req -in worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out worker.pem -days 365
openssl genrsa -out admin-key.pem 2048
openssl req -new -key admin-key.pem -out admin.csr -subj "/CN=kube-admin"
openssl x509 -req -in admin.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out admin.pem -days 365

cd ..
ansible-playbook site.yaml 
