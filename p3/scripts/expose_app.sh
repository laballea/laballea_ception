kill $(ps | grep -v 'grep' | grep 'kubectl port-forward svc/will-app-service' | cut -d ' ' -f1) 2>/dev/null
kubectl port-forward svc/will-app-service -n dev 8888:8888 &>/dev/null &
