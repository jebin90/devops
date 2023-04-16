# Network Policy
They are used to control the traffic flow between different pods in a cluster.
Network policies define a set of rules that determine which pods are allowed to communicate with each other and how they can communicate. It is part of security practices employed while managing Kubernetes, and is deployed at network layer.

They are typically used in multi-tenant Kubernetes clusters where multiple teams or applications are running on the same cluster. In such scenarios, it is important to have fine-grained control over the network traffic to ensure that each application or team has access only to the resources it needs and is not able to interfere with other applications.

## Implementation

Network policies in Kubernetes are implemented using the Kubernetes Network Policy API, which allows you to create and manage network policies using YAML files. A network policy typically consists of a set of ingress and egress rules that define how traffic is allowed to flow to and from a pod.

Ingress rules define the traffic that is allowed to flow into a pod, while egress rules define the traffic that is allowed to flow out of a pod. In addition to specifying the source and destination pods, network policies can also specify other properties such as the protocol (TCP, UDP, etc.), the port number, and the traffic direction (ingress or egress).

By using network policies, we can implement a wide range of security and compliance policies to protect the cluster from malicious attacks and unauthorized access. For eg., isolating sensitive workloads, restricting access to specific ports, or blocking traffic from specific IP addresses.

To actually enforce the network policy, make sure a 3rd party CNI is installed alongside like Calico, Weave, Flannel, etc.
