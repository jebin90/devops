# Notes on Kubernetes Usage

## Best practices for Security

### 1. Image scanning for vulnerabilities.
It starts with securing the layers themselves (OS, libraries, packages, etc.). Use leaner base images as much as possible (eg. alpine).
Eliminate dependencies that are unnecessary. Use tools like Snyk, Sysdig, etc. for image scanning (vulnerabilities, misconfiguration).
It is recommended to be run regularly before being pushed to the registry.
This can be implemented during build process in the CI/CD pipeline.

### 2. Avoid running containers as root user
Create and switch to non-root user before running. USER directive can be used, but can be overrridden by securityContext in spec. Hence, avoid running privileged containers.

### 3. Use RBAC (Role Based Access Control)
This is to keep user privileges as restrictive as possible. Once created, they have to be attached to users.
This is usually done by importing list of users into cluster or by generating Client Certificates individually for the API Server, since API server manages authentication requests.
For cluser-wide use instead of just namespaces, there is ClusterRole. For non-human users (3rd party apps) like Istio, Prometheus, etc., ServiceAccount resource is used.
To authenticate them, tokens are used instead of Client Certificates.

### 4. Use Network Policies
This is to limit inter-pod communications, since by default each pod can communicate to every other pod inside the cluster.
It is best to define each and every communication rule between all pods.
This is usually implemented using network plugins like Calico, Weave, etc. To implement this on a service level instead of network level, use Service Mesh like Istio.

### 5. Encrypt communication
Enable mTLS for inter-pod communications.

### 6. Secure Secret data
By default, secrets are unencrypted, only base-64 encoded at best.
In Kubernetes, you can enable EncryptionConfiguration service, but encryption key has to be stored securely elsewhere.
3rd party services like Vault, AWS KMS, etc. can be used as well.

### 7. Secure etcd
Access to etcd practically gives unilimited powers to control the cluster components. Hence it is important to secure etcd key-value store.
Putting etcd behind firewall as well as encrypting the data is recommended.

### 8. Setup data backup and restore
Automating backup and restore is recommended. Built-in tools like etcdctl can be used, which creates a snapshot and is stored in a PVC (make sure accessModes is ReadWriteMany).
3rd party tools like Velero can also be used to backup and restore.

### 9. Configure Security Policies
Make sure all users avoid misconfigurations by using Security Policies (eg., disallow container run as root, enforce network policy definition for each pod, etc.).
This can be implemented using 3rd party policy engines like Open Policy Agent, Kyverno, etc, which can also be automated.

### 10. Disaster Recovery
Have proper strategy and mechanism for disaster recovery (back to the same state). TrilioVault, Portworx, etc are some examples.

