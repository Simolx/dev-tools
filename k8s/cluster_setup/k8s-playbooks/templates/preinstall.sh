#!/bin/bash

set -e
set -x
mkdir -p ~/miniconda3
curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh -o ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm ~/miniconda3/miniconda.sh

# eval "$($HOME/miniconda3/bin/conda shell.bash hook)"
~/miniconda3/bin/conda init
~/miniconda3/bin/conda update --all -y
if [ "$1" = "control" ]; then
  echo "install ansible on control node"
  ~/miniconda3/bin/conda install -y conda-forge::ansible
fi
~/miniconda3/bin/conda clean --all -y

if [ "$1" = "control" ]; then
  echo "create public key on control node"
  ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
fi

# ssh-copy-id vagrant@10.98.66.31
# ssh-copy-id vagrant@10.98.66.32
# ansible -i inventory.ini all -m raw -a "uname -a"
#
# ansible-playbook -i inventory.ini playbook.yaml
#

set +x
