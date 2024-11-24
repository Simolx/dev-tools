# Setup kubernetes cluster

1. setup vm

```bash
vagrant up
```

2. install python

```bash
# vagrant ssh master1
bash $PATH/cluster_setup/k8s-playbooks/templates/preinstall.sh control

# vagrant ssh master2 or master3
bash $PATH/cluster_setup/k8s-playbooks/templates/preinstall.sh
```

3. copy public key from master1 `${HOME}/.ssh/authorized_keys` to master2 and master3

4. check ansible

```bash
# vagrant ssh master1
ansible -i inventory.ini all -m raw -a "uname -a"
```

5. install kubernetes packages

```bash
# logout and vagrant ssh master1
ansible-playbook -i inventory.ini k8s-deploy.yaml
```

6. (Option) config hosts, already config in kubeadm-install task

```bash
# add to /etc/hosts
10.98.66.30 controlplane
```

7. setup kubernetes cluster, pull image already config in kubeadm-install task, only need to init kubernetes

```bash
# vagrant ssh master1
# check and pull container images
kubeadm config images list --image-repository=registry.aliyuncs.com/google_containers
# or kubeadm config images list --cri-socket=unix:///var/run/cri-dockerd.sock  --image-repository=registry.aliyuncs.com/google_containers

kubeadm config images pull --image-repository=registry.aliyuncs.com/google_containers

# copy pause image tag, or config /etc/containerd/config.toml
docker tag registry.aliyuncs.com/google_containers/pause:3.10 registry.k8s.io/pause:3.9

sudo kubeadm init --control-plane-endpoint  controlplane --pod-network-cidr=10.96.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock --image-repository=registry.aliyuncs.com/google_containers --service-cidr=10.97.0.0/16 --apiserver-advertise-address=10.98.66.30
# vagrant ssh master2
# vagrant ssh master3

```

8. config calico

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.0/manifests/custom-resources.yaml
```

9. worker join use the command from init result

10. remove the taints on the control plane so that you can schedule pods on it

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```
