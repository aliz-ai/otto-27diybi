This is the repository for the Aliz/Otto 27diyBI project
# Pre-requisites

Your system must have [terraform installed](https://learn.hashicorp.com/tutorials/terraform/install-cli).

You'll also need the Google Cloud SDK installed and its authentication configured.
# Terraform
## Initialize
You need to initialize terraform before executing any other commands with it. You also have to do this each time you switch environments.

1. Navigate into a specific environment root directory.

```shell
cd environments/dev
```

2. Initialize the terraform backend.

```shell
terraform init 
```

## Plan

```shell
terraform plan
```
## Apply

```shell
terraform apply
```

# Create a new team and member
open config.tf in specific environment root directory and add new group email to "groups" variable also with member email
in this case terraform will add new service account, AI Notebook Instance and GCS bucket for each team members in the group
example:
```shell
  groups = {
    "ml@aliz.ai" = {
      members = [
        "norbert.liki@aliz.ai",
        "tamas.moricz@aliz.ai"
      ],
    },
    "infra@aliz.ai" = {
      members = [
        "taufik.romdony@aliz.ai",
      ],
    },
    "new-email-group@aliz.ai" = {
      members = [
        "new-email-members@aliz.ai",
      ],
    }
  }
```
# Add Dataprep role 
open config.tf in specific environment root directory and add new prefix for dataprep with true or false
and you need to define dataprep custom role has created in dataprep module ```dataprep_roles = "roles/CHANGE-TO-DATAPREP-CUSTOM-ROLE"```

example:
```shell
  groups = {
    "ml@aliz.ai" = {
      members = [
        "norbert.liki@aliz.ai",
        "tamas.moricz@aliz.ai"
      ],
      prefix   = "p"
      dataprep = true
    },
    "infra@aliz.ai" = {
      members = [
        "taufik.romdony@aliz.ai",
      ],
      prefix   = "h"
      dataprep = false
    },
    "new-email-group@aliz.ai" = {
      members = [
        "new-email-members@aliz.ai",
      ],
      prefix   = "h"
      dataprep = false
    }
  }
```