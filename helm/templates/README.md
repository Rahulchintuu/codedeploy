How this works

deployment.yaml → Creates the pods for your app.

service.yaml → Exposes the pods. Type LoadBalancer gives a public IP.

ingress.yaml → Optional, routes HTTP traffic to your service.

hpa.yaml → Automatically scales pods based on CPU usage.

_helpers.tpl → Keeps naming consistent across files.

values.yaml → User-defined values; you can override them during helm install or helm upgrade.
