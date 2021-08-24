# Terraform

## Initialize

1. Navigate into a specific regions root directory.

```shell
cd terraform
```

2. Initialize the terraform backend.

```shell
terraform init -backend-config=environments/dev/backend-config.properties
```

## Plan

1. Use the `environments/dev/dev.tfvars` file for development environment variables.

```shell
terraform plan -var-file=environments/dev/dev.tfvars
```

## Apply

```shell
terraform apply -var-file=environments/dev/dev.tfvars
```

## Cloud Scheduler
The Scheduler start Notebooks instance with a specific label and does the automatic shutdown of that VM at 18:00 CET and automatic start at 8:00 CET.