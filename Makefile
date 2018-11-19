.PHONY: all
.DEFAULT_GOAL := help

KOPS_CLUSTER_NAME := test.k8s.local
KOPS_STATE_STORE := s3://test-state-store
K8S_NAMESPACE := monitoring
K8S_CURRENT_CONTEXT := $(shell kubectl config current-context)
DEMO_APP_IMAGE := carlos4ndre/prometheus-demo:dev

export

help:
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

create_k8s_cluster: ## Create k8s cluster
	@kops create cluster \
		--node-count 1 \
		--zones us-east-1a \
		--node-size t2.medium \
		--master-size t2.medium \
		--topology private \
		--networking kopeio-vxlan \
		--api-loadbalancer-type public
	@kops update cluster --yes

status_k8s_cluster: ## Show k8s cluster status
	@kubectl get nodes --show-labels
	@kops validate cluster

delete_k8s_cluster: ## Delete k8s cluster
	@kops delete cluster --yes

deploy-namespace:
	@echo "======================="
	@echo "Deploying namespace    "
	@echo "======================="
	@kubectl apply -f k8s/namespace.yml
	@kubectl config set-context $(K8S_CURRENT_CONTEXT) --namespace=$(K8S_NAMESPACE)

deploy-cluster-role:
	@echo "======================="
	@echo "Deploying cluster role "
	@echo "======================="
	@kubectl apply -f k8s/clusterRole.yml

deploy-node-exporter:
	@echo "======================="
	@echo "Deploying node exporter"
	@echo "======================="
	@kubectl apply -f k8s/node-exporter.yml

deploy-kube-state-metrics:
	@echo "================================="
	@echo "Deploying kube state metrics     "
	@echo "================================="
	@kubectl apply -f k8s/kube-state-metrics.yml

deploy-prometheus-server-config:
	@echo "=================================="
	@echo "Deploying prometheus server config"
	@echo "=================================="
	@kubectl apply -f k8s/prometheus-server-config.yml

deploy-prometheus-rules-config:
	@echo "================================="
	@echo "Deploying prometheus rules config"
	@echo "================================="
	@kubectl apply -f k8s/prometheus-rules-config.yml

deploy-prometheus:
	@echo "======================="
	@echo "Deploying prometheus   "
	@echo "======================="
	@kubectl apply -f k8s/prometheus.yml

deploy-grafana: deploy-grafana-dashboards
	@echo "======================="
	@echo "Deploying Grafana      "
	@echo "======================="
	@kubectl apply -f k8s/grafana.yml

deploy-grafana-dashboards:
	@echo "============================="
	@echo "Deploying Grafana Dashboards "
	@echo "============================="
	@kubectl apply -f k8s/grafana-config.yml
	@kubectl apply -f k8s/grafana-import-dashboards.yml

deploy-alertmanager:
	@echo "======================="
	@echo "Deploying Alert Manager"
	@echo "======================="
	@kubectl apply -f k8s/alertmanager.yml

deploy-alertmanager-config:
	@echo "=============================="
	@echo "Deploying Alert Manager Config"
	@echo "=============================="
	@kubectl apply -f k8s/alertmanager-config.yml

deploy-k8s-dashboard:
	@echo "=============================="
	@echo "Deploying k8s Dashboard       "
	@echo "=============================="
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

deploy-redis:
	@echo "=================="
	@echo "Deploying redis   "
	@echo "=================="
	@kubectl apply -f k8s/redis.yml

deploy-mail:
	@echo "======================="
	@echo "Deploying mail server  "
	@echo "======================="
	@kubectl apply -f k8s/mail.yml

deploy-demo-app:
	@echo "===================="
	@echo "Deploying demo app  "
	@echo "===================="
	@kubectl apply -f k8s/demo-app.yml

deploy: deploy-namespace \
				deploy-cluster-role \
				deploy-node-exporter \
				deploy-kube-state-metrics \
				deploy-prometheus-server-config \
				deploy-prometheus-rules-config \
				deploy-prometheus \
				deploy-grafana \
				deploy-alertmanager-config \
				deploy-alertmanager \
				deploy-k8s-dashboard \
				deploy-redis \
				deploy-mail \
				deploy-demo-app
deploy: ## Deploy stack

undeploy: ## Undeploy stack
	@kubectl delete namespace monitoring

port_forwarding_prometheus: ## local access to prometheus
	@kubectl port-forward deployment/prometheus-core 9090:9090

port_forwarding_grafana: ## local access to grafana
	@kubectl port-forward deployment/grafana-core 3000:3000

port_forwarding_kube_state_metrics: ## local access to kube state metrics
	@kubectl port-forward deployment/kube-state-metrics 8080:8080

k8s_dashboard: ## local access to k8s dashboard
	@kubectl proxy

build-demo-app: ## build web app
	@echo "==================="
	@echo "Building demo app  "
	@echo "==================="
	@docker-compose -f app/docker-compose.yml build --force

run-demo-app: ## run demo web app
	@echo "==================="
	@echo "Running demo app   "
	@echo "==================="
	@docker-compose -f app/docker-compose.yml up

push-demo-app: ## push demo web app to docker registry
	@echo "================================="
	@echo "Push demo app to docker registry "
	@echo "================================="
	@docker push $(DEMO_APP_IMAGE)
