#!/bin/bash

set -e
set -x
mkdir -p ~/miniconda3
curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh -o ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

# eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
~/miniconda3/bin/conda init
~/miniconda3/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
~/miniconda3/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
~/miniconda3/bin/conda update --all -y
if [ "$1" = "control" ]; then
  echo "install ansible on control node"
  # grep -i rhel /etc/os-release
  os=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
  os_like=$(grep "^ID_LIKE=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
  # os=$(awk -F= '/^ID_LIKE=/{print $2}' /etc/os-release | tr -d '"')
  if [ "$os" = "centos" ]; then  # for centos
    ~/miniconda3/bin/conda install -y conda-forge::ansible==10.5.0
  elif [ "$os" = "debian" ]; then # for debian
    ~/miniconda3/bin/conda install -y conda-forge::ansible
  elif [ "$os_like" = "debian" ]; then # for ubuntu
    ~/miniconda3/bin/conda install -y conda-forge::ansible
  else
    echo "Unsupported OS: $os"
    exit 1
  fi
fi
~/miniconda3/bin/conda clean --all -y

if [ "$1" = "control" ]; then
  echo "create public key on control node"
  ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
fi

# ssh-copy-id vagrant@10.98.66.30
# ssh-copy-id vagrant@10.98.66.31
# ssh-copy-id vagrant@10.98.66.32
# ansible -i /vagrant/k8s-playbooks/inventory.ini all -m raw -a "uname -a"
#
# ansible-playbook -i inventory.ini playbook.yaml
#

set +x
