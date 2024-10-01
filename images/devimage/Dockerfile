FROM ubuntu

ARG CONDA_VERSION="2024.06-1"
ARG GO_VERSION="1.23.1"
ARG NVM_VERSION="v0.39.7"
ARG NODE_VERSION="20"
ARG HELM_VERSION=
ARG USERNAME=developer
ARG USER_PASSWD

RUN apt update && \
    apt upgrade -y && \
    apt install -y sudo tree git vim tmux openssh-client net-tools dnsutils iputils-ping telnet zip curl wget p7zip-full p7zip-rar dos2unix file gnutls-bin dstat tmuxinator g++ gnupg2 && \
    apt autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN curl -o python_installer.sh -L https://repo.anaconda.com/archive/Anaconda3-${CONDA_VERSION}-Linux-$(uname -m).sh && \
    bash python_installer.sh -p /opt/python3 -b && \
    /opt/python3/bin/conda update --all -y && \
    /opt/python3/bin/conda install -y conda-forge::powerline-status conda-forge::powerline-gitstatus conda-forge::py7zr conda-forge::airflow && \
    /opt/python3/bin/conda clean --all -y && \
    rm -f python_installer.sh

RUN curl -L -o go_installer.tar.gz https://go.dev/dl/go${GO_VERSION}.linux-`dpkg --print-architecture`.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go_installer.tar.gz && \
    rm -f go_installer.tar.gz

RUN helm_latest_release_response=$( curl -L --silent --show-error --fail https://get.helm.sh/helm-latest-version 2>&1 || true ) && \
    curl -o helm-linux.tar.gz https://get.helm.sh/helm-${helm_latest_release_response}-linux-`dpkg --print-architecture`.tar.gz && \
    tar -C /usr/local/bin -xzf helm-linux.tar.gz linux-`dpkg --print-architecture`/helm  --strip-components 1 && \
    chown root:root /usr/local/bin/helm && \
    rm -f helm-linux.tar.gz

# RUN GITHUB_RAW_IP=$(nslookup  raw.githubusercontent.com 8.8.8.8 | grep Address | grep -v '8.8.8.8' | head -n 1 | awk '{print $2}') && \
#    curl --resolv raw.githubusercontent.com:443:${GITHUB_RAW_IP} -o-  https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

RUN useradd -m ${USERNAME} && \
    echo "${USERNAME}:${USER_PASSWD}" | chpasswd && \
    usermod -aG sudo ${USERNAME} && \
    chsh -s /bin/bash ${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} vimrc /home/${USERNAME}/.vimrc
USER ${USERNAME}

RUN GITHUB_RAW_IP=$(nslookup  raw.githubusercontent.com 8.8.8.8 | grep Address | grep -v '8.8.8.8' | head -n 1 | awk '{print $2}') && \
    curl --resolv raw.githubusercontent.com:443:${GITHUB_RAW_IP} -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash && \
    NVM_DIR="$HOME/.nvm" && \
    . "$NVM_DIR/nvm.sh" && \
    . "$NVM_DIR/bash_completion" && \
    nvm install ${NODE_VERSION} && \
    npm install -g @bazel/bazelisk

RUN GITHUB_RAW_IP=$(nslookup  raw.githubusercontent.com 8.8.8.8 | grep Address | grep -v '8.8.8.8' | head -n 1 | awk '{print $2}') && \
    curl --resolv raw.githubusercontent.com:443:${GITHUB_RAW_IP} -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN /opt/python3/bin/conda init && \
    mkdir -p ${HOME}/.config/powerline && \
    repository=$(/opt/python3/bin/pip show powerline-status | grep Location | awk '{print $2}') && \
    cp -r ${repository}/powerline/config_files ${HOME}/.config/powerline && \
    echo source ${repository}/powerline/bindings/tmux/powerline.conf >> ${HOME}/.tmux.conf && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ${HOME}/.bashrc && \
    cat <<EOF >> ${HOME}/.bashrc
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. ${repository}/powerline/bindings/bash/powerline.sh

alias mux='tmuxinator'
alias tmux='tmux -u'
EOF

RUN cd ${HOME} && \
    curl -O -L https://github.com/powerline/fonts/archive/refs/heads/master.zip && \
    unzip master.zip && \
    cd fonts-master && \
    ./install.sh && \
    /opt/python3/bin/fc-cache ${HOME}/.local/share/fonts && \
    cd .. && \
    rm -rf fonts-master master.zip

RUN /usr/local/go/bin/go env -w GOPROXY=https://goproxy.cn,direct && \
    vim +PlugInstall +qall && \
    vim +GoInstallBinaries +qall

WORKDIR /home/${USERNAME} 

CMD ["/bin/bash"]
