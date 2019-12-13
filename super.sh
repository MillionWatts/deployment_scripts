#!/bin/sh
printf "Deploying MillionWatts\n"

BASEDIR=$(dirname "$0")

printf "Installing Server Prerequisites..."
helm install nginx-ingress stable/nginx-ingress --set controller.publishService.enabled=true >/dev/null
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml >/dev/null
kubectl create namespace cert-manager >/dev/null
helm repo add jetstack https://charts.jetstack.io >/dev/null
helm install cert-manager --version v0.11.0 --namespace cert-manager jetstack/cert-manager >/dev/null
printf "Done!\n"

printf "Installing mw-mongodb..."
chmod +x $BASEDIR/db/dbinstall.sh
$BASEDIR/db/dbinstall.sh

printf "Applying Secrets...\n"
find $BASEDIR/secrets -type f -name \*.yaml | xargs -n1 kubectl apply -f 
printf "Done!\n"

printf "Applying Apps and respective Services...\n"
find $BASEDIR/apps -type f -name \*.yaml | xargs -n1 kubectl apply -f 
printf "Done!\n"

printf "Applying Certification Manager...\n"
find $BASEDIR/certification -type f -name \*.yaml | xargs -n1 kubectl apply -f 
printf "Done!\n"

printf "Applying Services...\n"
find $BASEDIR/services -type f -name \*.yaml | xargs -n1 kubectl apply -f 
printf "Done!\n"
