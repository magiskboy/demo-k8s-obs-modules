# Demo observibility modules for Kubernetes - WIP

## Pre-requisites

- [kind](https://kind.sigs.k8s.io)
- [helm](https://helm.sh)
- [helmfile](https://helmfile.readthedocs.io/en/latest/)

## Architecture

![Diagram](./screenshots/obs-module-k8s-diagram.png)

## Usage

Because we run k8s cluster locally so you should install local load balancer
Kind has a built-in cloud provider controller locally and it also supports a load balacer with [cloud-provider-kind](https://github.com/kubernetes-sigs/cloud-provider-kind)

```sh
$ docker run -dit --name cloud-provider-kind --network kind -v /var/run/docker.sock:/var/run/docker.sock registry.k8s.io/cloud-provider-kind/cloud-controller-manager:v0.5.0
```

If you are using MacOS or Windows, because kind run as non-root user (run on VM) so you must map ports to host, let's enable `-enable-lb-port-mapping` when starting cloud-provider-kind

```sh
$ docker run -dit --name cloud-provider-kind --network kind -v /var/run/docker.sock:/var/run/docker.sock registry.k8s.io/cloud-provider-kind/cloud-controller-manager:v0.5.0 -enable-lb-port-mapping
```

In below picture, you can see that port mapping is enabled and you can access frontend service via port 50322 from host

![Port mapping](./screenshots/local-lb-1.png)

Read more about it [Port mapping](https://github.com/kubernetes-sigs/cloud-provider-kind?tab=readme-ov-file#enabling-load-balancer-port-mapping)

Create a kind cluster, view more [kind config](./kind-cluster.yaml)

```sh
$ kind create cluster --name obs-modules --config ./kind-cluster.yaml
$ kind export kubeconfig
$ kubectl get nodes
```

You should see that
```
NAME                       STATUS   ROLES           AGE   VERSION
obs-module-control-plane   Ready    control-plane   77s   v1.31.0
obs-module-worker          Ready    <none>          66s   v1.31.0
obs-module-worker2         Ready    <none>          66s   v1.31.0
```


Install application namespace, this repo is using [demo-microservice](https://github.com/GoogleCloudPlatform/microservices-demo) repo of Google

```sh
$ helm upgrade onlineboutique oci://us-docker.pkg.dev/online-boutique-ci/charts/onlineboutique --install --namespace onlineboutique --create-namespace
$ bash ./onlineboutique-patch.sh
```

Prepare secret values before initializing observibility modules

```sh
MINIO_ROOT_USER=
MINIO_ROOT_PASSWORD=

CASSANDRA_USER=
CASSANDRA_PASSWORD=

LOKI_S3_CLIENT_ID=
LOKI_S3_CLIENT_SECRET=

CORTEX_S3_CLIENT_ID=
CORTEX_S3_CLIENT_SECRET=

GRAFANA_ADMIN_USER=
GRAFANA_ADMIN_PASSWORD=
```

Run observibility modules

```sh
$ helmfile apply
```

### Notice!!!

Have some configuration what I haven't set up yet. You can learn more about Kubernetes if you can find and set up them.

## Results

[Demo video](https://www.youtube.com/watch?v=9BQGGYWfSYQ&list=PL5Uk4IAzZ1pTELVIExV-8x7m2WWtXQOwF&index=5)

![Deployment metrics](./screenshots/obs-1.png)
![Cluster metrics](./screenshots/obs-2.png)
![Tracing](./screenshots/obs-3.png)
![Tracing with Jaeger UI](./screenshots/obs-4.png)


