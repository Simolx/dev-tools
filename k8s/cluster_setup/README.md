# Setup kubernetes cluster

1. setup vm

```bash
cd ${PROJECT_HOME}/k8s/cluster_setup
vagrant up
```

2. install python

```bash
# vagrant ssh master1
bash /vagrant/k8s-playbooks/templates/preinstall.sh control

# vagrant ssh master2 or master3
# bash /vagrant/k8s-playbooks/templates/preinstall.sh
```

3. copy public key from master1 `${HOME}/.ssh/authorized_keys` to master2, master3 and master1

```bash
ssh-copy-id vagrant@master1 # or ip
ssh-copy-id vagrant@master2 # or ip
ssh-copy-id vagrant@master3 # or ip
# re login master1
ansible-playbook -i inventory.ini py-prepare.yaml
```

4. check ansible

```bash
# vagrant ssh master1
ansible -i /vagrant/k8s-playbooks/inventory.ini all -m raw -a "uname -a"
```

5. enable cgroupv2

```bash
# vagrant ssh master1
ansible-playbook -i inventory.ini enable-cgroupv2.yaml
```

6. install kubernetes packages

```bash
# logout and vagrant ssh master1
ansible-playbook -i inventory.ini k8s-deploy.yaml
```

7. (Option) config hosts, already config in kubeadm-install task

```bash
# add to /etc/hosts
10.98.66.30 controlplane
```

8. setup kubernetes cluster, pull image already config in kubeadm-install task, only need to init kubernetes

```bash
# vagrant ssh master1
# check and pull container images
kubeadm config images list --image-repository=registry.aliyuncs.com/google_containers
# or kubeadm config images list --cri-socket=unix:///var/run/cri-dockerd.sock  --image-repository=registry.aliyuncs.com/google_containers

kubeadm config images pull --image-repository=registry.aliyuncs.com/google_containers

# copy pause image tag, or config /etc/containerd/config.toml
docker tag registry.aliyuncs.com/google_containers/pause:3.10.1 registry.k8s.io/pause:3.10

sudo kubeadm init --control-plane-endpoint  controlplane --pod-network-cidr=10.96.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock --image-repository=registry.aliyuncs.com/google_containers --service-cidr=10.97.0.0/16 --apiserver-advertise-address=10.98.66.30
# vagrant ssh master2
# vagrant ssh master3
```

9. config calico

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.4/manifests/operator-crds.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.4/manifests/tigera-operator.yaml

# eBPF
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.31.4/manifests/custom-resources-bpf.yaml
kubectl create -f custom-resources-bpf.yaml

# iptables
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.31.4/manifests/custom-resources.yaml
kubectl create -f custom-resources.yaml

# Monitor
watch kubectl get tigerastatus

```

10. worker join use the command from init result

11. remove the taints on the control plane so that you can schedule pods on it

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```
