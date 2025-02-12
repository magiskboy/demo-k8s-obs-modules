#!/bin/bash

namespace=onlineboutique
deployments=$(kubectl get deployments -o name -n ${namespace})

for deployment in $deployments; do
    echo "patching ${deployment}"

    service_name=$(echo $deployment | cut -d '/' -f 2)
    env="ENABLE_TRACING=1 COLLECTOR_SERVICE_ADDR=jaegertracing-collector.obs-modules.svc.cluster.local:4317 OTEL_SERVICE_NAME=${service_name}"

    kubectl set env ${deployment} ${env} -n ${namespace}
done
