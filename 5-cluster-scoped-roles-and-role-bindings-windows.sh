@'
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: oidc-cluster-admin-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: Group
  name: k8s-admin
'@ | kubectl.exe apply -f -


@'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: developer
rules:
- apiGroups: [""] 
  resources: ["pods/logs","endpoints","services","deployments"]
  verbs: ["get", "watch", "list"]
- apiGroups: [""] 
  resources: ["pods"]
  verbs: ["get", "watch", "list","delete"]
'@ | kubectl apply -f - 

@'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: dev-op
rules:
- apiGroups: [""] 
  resources: ["pods","pods/logs","endpoints","services","secrets","configmaps"]
  verbs: ["get", "create", "watch", "list", "delete", "deletecollection"]
- apiGroups: ["apps"] 
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
'@ | kubectl apply -f - 


#Cleanup
kubectl delete ClusterRoleBinding oidc-cluster-admin-role-binding
kubectl delete ClusterRole developer
kubectl delete ClusterRole dev-op
