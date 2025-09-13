dev-init:
	git pull
	rm -rf .terraform/terraform.tfstate
	terraform init -backend-config=./environments/dev/state.tfvars

dev-plan:
	terraform plan -var-file=./environments/dev/main.tfvars

dev-apply: dev-init
	terraform apply -var-file=./environments/dev/main.tfvars -auto-approve

dev-destroy: dev-init
	terraform destroy -var-file=./environments/dev/main.tfvars -auto-approve

prod-init:
	git pull
	rm -rf .terraform/terraform.tfstate
	terraform init -backend-config=./environments/dev/state.tfvars

prod-plan:
	terraform plan -var-file=./environments/prod/main.tfvars

prod-apply: prod-init
	terraform apply -var-file=./environments/prod/main.tfvars -auto-approve

prod-destroy: prod-init
	terraform destroy -var-file=./environments/prod/main.tfvars -auto-approve