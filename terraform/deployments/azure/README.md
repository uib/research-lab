# Azure Terraform #

- https://github.com/terraform-providers/terraform-provider-azurerm

## VM Extenstion ##

- http://www.anniehedgie.com/terraform-and-azure

## Azure Scale Set ##

- https://azure.microsoft.com/nb-no/blog/new-networking-features-in-azure-scale-sets/
- https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-networking

## Loadbalancer ##

- http://blog.superautomation.co.uk/2016/11/azure-resource-manager-load-balancer.html

## Know-how ##

### SSH ###

Connect: ssh -p 50000 username@ip
http://rabexc.org/posts/using-ssh-agent

    eval `ssh-agent`
    ssh-add ~/.ssh/id_rsa

### Ubuntu ###

https://stackoverflow.com/questions/35144550/how-to-install-cryptography-on-ubuntu
'sudo apt-get install build-essential libssl-dev libffi-dev python-dev'

### Kubernetes ###

- http://kubernetesbyexample.com/
- https://kubernetes.io/docs/tasks/run-application/run-stateless-application-deployment/

På lokal maskin kjørte vi videre:

    $ cd ../../../ansible
    $ cat kubeconfig
    $ kubectl --kubeconfig=kubeconfig get node
    $ kubectl --kubeconfig=kubeconfig get pod -n kube-system

Slik kjører man et shell på en kontainer i clusteret (usikker på hva "shell" er, men det kan være en tilfeldig streng. label)
`$ kubectl --kubeconfig=kubeconfig run --rm -ti --image=alpine shell sh`

Hvis man får problemer med at terraform ikke vil kjøre, så kan man slette noen tilstandsfiler:
`$ rm terraform.tfstate terraform.tfstate.backup`

Jobbing med nginx
`export KUBECONFIG=et-eller-annet`