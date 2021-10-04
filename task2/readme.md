# second task
Migrate an application to Kubernetes

## steps followed
1. here i have created all yaml files for setting up the ingress , cert-issuer for ssl , kubernetes dashboard files

```bash
securrency-kubernetes/dashboard_nginx_ssl_setup:
I have created shellscript for this to install

command to run 
./deployer.sh
```

2. i have created a helm chart to deploy the kubernetes application 
with creation of database locally 
you can check all files here : /securrency-kubernetes/securrency/ 

i have declared all values in values.yml file of helm charts : /securrency-kubernetes/securrency/values.yml

i have created this files deployement.yml , ebs_creation.yml , hpa.yml , service.yml and ingress.yml file in  /securrency-kubernetes/securrency/templates

deploy the helm chart by following command
```python

helm install chartname applicationname

and if we want to upgrade and redeploy again 
helm upgrade chartname applicationname