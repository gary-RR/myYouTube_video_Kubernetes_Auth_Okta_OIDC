#Linux client
k8s_oidc_client_id = 
k8s_oidc_issuer_url = 

#Windows (Powershell) client
$k8s_oidc_client_id = 
$k8s_oidc_issuer_url = 

#Install kubelogin (oidc-login)
kubectl krew install oidc-login

kubectl oidc-login setup --oidc-issuer-url=$k8s_oidc_issuer_url --oidc-client-id=$k8s_oidc_client_id


#Windows ***********************************
kubectl config set-credentials oidc `
          --exec-api-version=client.authentication.k8s.io/v1beta1 `
          --exec-command=kubectl `
          --exec-arg=oidc-login `
          --exec-arg=get-token `
          --exec-arg=--oidc-issuer-url=$k8s_oidc_issuer_url  `
          --exec-arg=--oidc-client-id=$k8s_oidc_client_id
#Edit the config file and add the following to "args" section:
          - --oidc-extra-scope=email 
          - --oidc-extra-scope=offline_access 
          - --oidc-extra-scope=profile 
          - --oidc-extra-scope=openid
#**********************************************************************

#Linux ****************************************************************
kubectl config set-credentials oidc \
          --exec-api-version=client.authentication.k8s.io/v1beta1 \
          --exec-command=kubectl \
          --exec-arg=oidc-login \
          --exec-arg=get-token \
          --exec-arg=--oidc-issuer-url=$k8s_oidc_issuer_url \
          --exec-arg=--oidc-client-id=$k8s_oidc_client_id 
#Edit the config file and add the following to "args" section:
          - --oidc-extra-scope=email 
          - --oidc-extra-scope=offline_access 
          - --oidc-extra-scope=profile 
          - --oidc-extra-scope=openid 
#***********************************************************************

kubectl --user=oidc get nodes


