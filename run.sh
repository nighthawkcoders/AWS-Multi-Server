terraform init
terraform plan -var-file secrets.tfvars
terraform apply -var-file secrets.tfvars