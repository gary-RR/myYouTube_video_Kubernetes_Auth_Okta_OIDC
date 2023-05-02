#***********************************************************Marketing admin role********************************************
kubectl --user=oidc get pods
kubectl --user=oidc get pods -n marketing

@'
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: marketing-admin-binding
  namespace: marketing
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
- kind: Group
  name: k8s-marketing-admins
'@ | kubectl.exe apply -f -

kubectl --user=oidc get pods
kubectl --user=oidc get pods -n marketing

kubectl config set-context --current --user=oidc
kubectl auth can-i delete pods -n marketing 
kubectl auth can-i create secrets -n marketing
kubectl auth can-i create roles -n marketing
kubectl auth can-i create ClusterRoles 
kubectl auth can-i create namespace 

#Set the default back to me (kubernetes-admin)
kubectl config set-context --current --user=kubernetes-admin

#***********************************************************Developer role********************************************
kubectl --user=oidc get pods
kubectl --user=oidc get pods -n marketing

@'
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: marketing-develper-role-binding
  namespace: marketing
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: developer
subjects:
- kind: Group
  name: k8s-marketing-devs
'@ | kubectl.exe apply -f -

kubectl --user=oidc get pods
kubectl --user=oidc get pods -n marketing

kubectl config set-context --current --user=oidc
kubectl auth can-i delete pods -n marketing 
kubectl auth can-i list services -n marketing
kubectl auth can-i list endpoints -n marketing
kubectl auth can-i create secrets -n marketing
kubectl auth can-i create roles -n marketing
kubectl auth can-i create ClusterRoles 
kubectl auth can-i create namespace 

#Set the default back to me (kubernetes-admin)
kubectl config set-context --current --user=kubernetes-admin

#***********************************************************Dev-op role********************************************
kubectl --user=oidc get pods
kubectl --user=oidc get pods -n marketing

@'
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: marketing-dev-op-role-binding
  namespace: marketing
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: dev-op
subjects:
- kind: Group
  name: k8s-marketing-dev-ops
'@ | kubectl.exe apply -f -

kubectl --user=oidc get pods
kubectl --user=oidc get pods -n marketing

kubectl config set-context --current --user=oidc
kubectl auth can-i delete pods -n marketing 
kubectl auth can-i list services -n marketing
kubectl auth can-i delete services -n marketing
kubectl auth can-i list endpoints -n marketing
kubectl auth can-i create secrets -n marketing
kubectl auth can-i create configmaps -n marketing
kubectl auth can-i create roles -n marketing
kubectl auth can-i create ClusterRoles 
kubectl auth can-i create namespace 

#Set the default back to me (kubernetes-admin)
kubectl config set-context --current --user=kubernetes-admin

#Cleanup
kubectl delete RoleBinding marketing-admin-binding -n marketing
kubectl delete RoleBinding marketing-developer-binding -n marketing
kubectl delete RoleBinding marketing-dev-op-role-binding -n marketing

