[master]
${master_hosts}

[etcd]
${etcd_hosts}

[worker]
${worker_hosts}

[coreos:children]
master
etcd
worker

[coreos:vars]
ansible_ssh_user=core
ansible_python_interpreter="/home/core/bin/python"
ansible_ssh_private_key_file="${ssh_key}"
