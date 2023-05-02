
terraform init
terraform  plan -out=okta_plan
terraform apply "okta_plan"

#Note the values for:
  #k8s_oidc_client_id  
  #and
  #k8s_oidc_issuer_url 


#********* You need to perform this on the master!
#Modify API server's config file and add oidc client id and issuer url:
# "ctl+shift+v" to paste into nano
sudo nano /etc/kubernetes/manifests/kube-apiserver.yaml
    - --oidc-issuer-url=
    - --oidc-client-id=
    - --oidc-username-claim=email 
    - --oidc-groups-claim=groups


#Cleanup, delete Okta auth servers and users
#Linux
  echo -e "yes" | terraform destroy
#Windows
  echo "yes" | terraform destroy



































