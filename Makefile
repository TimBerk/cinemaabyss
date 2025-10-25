run:
	helm install cinemaabyss ./src/kubernetes/helm --namespace cinemaabyss --create-namespace
tun:
	minikube tunnel
del:
	kubectl delete all --all -n cinemaabyss
	kubectl delete  namespace cinemaabyss
rules:
	kubectl delete destinationrule --all -n cinemaabyss
	kubectl get destinationrule --all-namespaces
