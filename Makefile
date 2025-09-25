dev-init: ## Initialize dev environment
	git pull
	rm -rf .terraform/terraform.tfstate
	terraform init -backend-config=./environments/dev/state.tfvars

dev-plan: ## Plan changes for dev
	terraform plan -var-file=./environments/dev/main.tfvars

dev-apply: dev-init ## Apply changes to dev
	terraform apply -var-file=./environments/dev/main.tfvars -auto-approve

dev-destroy: dev-init ## Destroy dev environment
	terraform destroy -var-file=./environments/dev/main.tfvars -auto-approve

prod-init: ## Initialize prod environment
	git pull
	rm -rf .terraform/terraform.tfstate
	terraform init -backend-config=./environments/prod/state.tfvars

prod-plan: ## Plan changes for prod
	terraform plan -var-file=./environments/prod/main.tfvars

prod-apply: prod-init ## Apply changes to prod
	terraform apply -var-file=./environments/prod/main.tfvars -auto-approve

prod-destroy: prod-init ## Destroy prod environment
	terraform destroy -var-file=./environments/prod/main.tfvars -auto-approve

tools-infra: ## Apply tools infrastructure
	git pull
	rm -rf .terraform/terraform.tfstate
	cd tools ; terraform init ; terraform plan
