Security policy for UH-Kubernetes
===================================

This policy document covers production use of kubernetes and «kubified»
applications used in the Norwegian «UH-sector». Production means that the clusters 
are hosting applications that contain end user data. 


## Protection of administrative entrypoints 

All administrative entrypoints that enables control over cluster behavior, such
as the kubernetes api, etcd and ssh to nodes, must be secured using strong
encryption and authentication mechanisms. The implementation must employ secure
initial generation and exchange of secrets/tokens and authorization of users
should be implemented using role-based access control (RBAC) to give access
only to resources needed based on role of people. Revocation of privileges 
should be done when the need for such cease, for example when people leave
projects.

The different administrative components of the cluster should be separated as
much as practiacally feasible using kubernets network policies, accounts,
namespaces, roles and role bindings.

Admin entrypoints must also be secured using IP based access control lists, for
example by using Openstack security groups and rules, such that only the
IP-ranges of hosts that need access has the necessary access. 

Risk assessments should always be considered  to ensure a practical balance
between granularity of access control and the effort made to implement it. 

## Resources quotas 

To prevent «Denial of Service» due to abnormal resources consumption Kubernetes
quotas should be applied to cluster components (namespaces and pods) with a
known normal resources usage. 

##  Security Context 

All kubernetes deployments should apply security contexts to strip running
components of all capabilities except those needed for the component to work

For containers running in privileged mode, use the «DenyEscalatingExec»
admission control if possible.  

## Logging and monitoring.

All security related container, component and application output must be logged to a central location. Procedures for
analysis, forensics and alerting must be established to detect anomalous behavior. 

## End user applications 


## Containers, registries and images 

All end user applications must be sources from an internal container image
repository. Running container images from registries not in the list of
accepted sources is not allowed. 

Running application must regularly be scanned for security vulnerabilities and
alerted to the application owners which is responsible for risk assessment and
mitigation: normally an image update and a rolling upgrade.  

Base images and applications should be built with a minimum of unnecessary
dependencies to reduce the volume of false positive alarms from security
scanning. 

Container images in registries that is built by UH-users must be tagged with
VCS revision that points back to the Dockerfile the image was built from.
Images built by UH-users from Docker files not available in a UH-accessible VCS
is not allowed. 

## Component secrets 

Component secrets, such as database and API passwords/tokens must be managed
properly, preferably using kubernetes own secret storage. Secrets must be
changed at least once a year. 



