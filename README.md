# Prometheus Demo

Minimal project with prometheus, grafana, mail and voting app running on k8s.

⚠️  This project is not suitable for production, best served for testing and try out new things from a simple baseline.

# Requirements

* [Setup AWS CLI](https://docs.aws.amazon.com/lambda/latest/dg/setup-awscli.html)
* [Kops installed](https://github.com/kubernetes/kops/blob/master/docs/aws.md)

# Deployment

Start the k8s cluster with kops
```bash
$ make create_k8s_cluster
```

Wait for things to be ready
```bash
$ make status_k8s_cluster
```

Ready? It's monitoring time :)
```bash
$ make deploy
```

Once you get bored or out of budget, delete everyhing!
```bash
$ make delete_k8s_cluster
```
