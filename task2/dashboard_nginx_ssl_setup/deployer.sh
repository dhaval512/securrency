#!/bin/bash

echo "---------creating namespaces-----------"
kubectl create namespace cert-manager
kubectl create namespace nginx-ingress
kubectl create namespace kubernetes-dashboard
echo "-----------adding helm repos-----------"
helm repo add jetstack https://charts.jetstack.io
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
echo "---------applying namespace resources------"
helm install --namespace cert-manager --set installCRDs=true cert-manager jetstack/cert-manager --version 1.1.0
kubectl apply -f cluster-issuer.yml -n cert-manager
echo "----------deploying nginx-ingress controller------------"
kubens nginx-ingress
helm install nginx-ingress ingress-nginx/ingress-nginx -f nginx.yaml --version 3.35.0
echo "----------deploying dashboard-----------------"
kubectl apply -f dashboard.yaml -n kubernetes-dashboard
kubectl apply -f dashboard-ingress.yaml -n kubernetes-dashboard
echo "-----------creating service account for dashboard admin role------------"
kubens default
kubectl create serviceaccount dashboard-admin-sa
kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
kubectl get secrets
echo -e "important: \033[31;7m to access dashboard print the secret example : kubectl describe secret dashboard-admin-sa-token-kw7vn \e[0m";
