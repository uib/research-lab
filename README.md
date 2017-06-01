Research Lab Platform
==========================

This repository contains scripts and ansible playbooks for managing the Research lab platform.

## Bringing up a test cluster in Safespring (IPnett)

In the `terraform/deployments/safespring` directory, make a `local.tfvars` based on the
example, check your setup with `terraform plan --var-file=local.tfvars`, then bring up the bare machines with
`terraform apply --var-file=local.tfvars`. The job prints out an ansible inventory at
the end.

One can also use the `./run_dev.sh safespring` command from the top level directory to do everything.

## Bringing up a test cluster in uh-iaas

### Prerequisites

- A personal project at uh-iaas, see: http://docs.uh-iaas.no/en/latest/login.html#first-time-login
  (After you have created your personal project, you can for access to the shared project)
- The API-password for uh-iaas. You can test it with: http://docs.uh-iaas.no/en/latest/api.html
- Terraform: https://www.terraform.io/
- Access to the project 

### local.tfvars

In the `terraform/deployments/uh-iaas` directory, make a `local.tfvars` based on the
example.

### Download modules 

With `terraform get`, the necessary modules are downloaded to a subfolder
`.terraform` of the working directory.  We have used
`terraform/deployments/uh-iaas` as a working directory.

### Test and run

Check your setup with `terraform plan --var-file=local.tfvars`, then bring up
the bare machines with `terraform apply --var-file=local.tfvars`. The job
prints out an ansible inventory at the end.

The run_dev.sh script (under development) will in addition create securitygroups
and apply the ansible setup.

### Debugging / verbose output

For debugging, use the environment variables TF_LOG=DEBUG and OS_DEBUG:

    TF_LOG=DEBUG OS_DEBUG=1 terraform apply --var-file=local.tfvars


