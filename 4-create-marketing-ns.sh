#****************Marketing NS
kubectl create ns marketing 
kubectl create deployment -n marketing hello-world --image=gcr.io/google-samples/hello-app:1.0
#Scale up the replica set to 2
kubectl scale --replicas=2 deployment/hello-world -n marketing
#View all Kubernetes deployments
kubectl get deployments -n marketing
kubectl expose deployment -n marketing hello-world --port=8080 --target-port=8080 --type=NodePort


#Cleanup
kubectl delete ns marketing