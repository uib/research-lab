Research Lab Platform
==========================

This repository contains scripts and ansible playbooks for managing the Research lab platform.

## Bringing up a test cluster in Safespring (IPnett)

In the `terraform/deployments/safespring` directory, make a `local.tfvars` based on the
example, check your setup with `terraform plan --var-file=local.tfvars`, then bring up the bare machines with
`terraform apply --var-file=local.tfvars`. The job prints out an ansible inventory at
the end.

One can also use the `./run_dev.sh safespring` command from the top level directory to do everything.
