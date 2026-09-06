FROM ubuntu

ARG CONDA_VERSION="2025.12-2"
ARG GO_VERSION="1.26.3"
ARG NVM_VERSION="v0.40.4"
ARG NODE_VERSION="26"
ARG USERNAME=developer
ARG USER_PASSWD

ENV TZ='Asia/Shanghai' \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y sudo tree git vim tmux openssh-client net-tools dnsutils iputils-ping telnet zip curl wget p7zip-full dos2unix file gnutls-bin dstat tmuxinator g++ gnupg2 && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN curl -o python_installer.sh -L https://repo.anaconda.com/archive/Anaconda3-${CONDA_VERSION}-Linux-$(uname -m).sh && \
    bash python_installer.sh -p /opt/python3 -b && \
    /opt/python3/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    /opt/python3/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
    /opt/python3/bin/conda update --all -y && \
    pypackages="conda-forge::py7zr" && \
    [ "$(uname -m)" = "x86_64" ] && pypackages="conda-forge::powerline-status conda-forge::powerline-gitstatus ${pypackages}" || echo && \
    /opt/python3/bin/conda install -y ${pypackages} && \
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
#    curl --resolve raw.githubusercontent.com:443:${GITHUB_RAW_IP} -o-  https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

RUN useradd -m ${USERNAME} && \
    echo "${USERNAME}:${USER_PASSWD}" | chpasswd && \
    usermod -aG sudo ${USERNAME} && \
    chsh -s /bin/bash ${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} vimrc /home/${USERNAME}/.vimrc
USER ${USERNAME}

RUN GITHUB_RAW_IP=$(nslookup  raw.githubusercontent.com 8.8.8.8 | grep Address | grep -v '8.8.8.8' | head -n 1 | awk '{print $2}') && \
    curl --resolve raw.githubusercontent.com:443:${GITHUB_RAW_IP} -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash && \
    NVM_DIR="$HOME/.nvm" && \
    . "$NVM_DIR/nvm.sh" && \
    . "$NVM_DIR/bash_completion" && \
    nvm install ${NODE_VERSION} && \
    npm install -g @bazel/bazelisk

RUN GITHUB_RAW_IP=$(nslookup  raw.githubusercontent.com 8.8.8.8 | grep Address | grep -v '8.8.8.8' | head -n 1 | awk '{print $2}') && \
    curl --resolve raw.githubusercontent.com:443:${GITHUB_RAW_IP} -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN /opt/python3/bin/conda init && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ${HOME}/.bashrc && \
    echo "alias mux='tmuxinator'" >> ${HOME}/.bashrc && \
    echo "alias tmux='tmux -u'" >> ${HOME}/.bashrc && \
    [ "$(uname -m)" = "x86_64" ] && mkdir -p ${HOME}/.config/powerline && \
    repository=$(/opt/python3/bin/pip show powerline-status | grep Location | awk '{print $2}') && \
    cp -r ${repository}/powerline/config_files ${HOME}/.config/powerline && \
    echo source ${repository}/powerline/bindings/tmux/powerline.conf >> ${HOME}/.tmux.conf || echo && \
    [ "$(uname -m)" = "aarch64" ] && echo || cat <<EOF >> ${HOME}/.bashrc
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. ${repository}/powerline/bindings/bash/powerline.sh

EOF

RUN [ "$(uname -m)" = "x86_64" ] && cd ${HOME} && \
    curl -O -L https://github.com/powerline/fonts/archive/refs/heads/master.zip && \
    unzip master.zip && \
    cd fonts-master && \
    ./install.sh && \
    /opt/python3/bin/fc-cache ${HOME}/.local/share/fonts && \
    cd .. && \
    rm -rf fonts-master master.zip || echo

RUN PATH=$PATH:/usr/local/go/bin && \
    /usr/local/go/bin/go env -w GOPROXY=https://goproxy.cn,direct && \
    vim +PlugInstall +qall && \
    vim +GoInstallBinaries +qall

RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH=/home/${USERNAME}/.local/bin:$PATH
ENV ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic \
    ANTHROPIC_MODEL=deepseek-v4-pro[1m] \
    ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-pro[1m] \
    ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-pro[1m] \
    ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash \
    CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash \
    CLAUDE_CODE_EFFORT_LEVEL=max

RUN claude plugin marketplace add anthropics/claude-plugins-official && \
    claude plugin install superpowers && \
    claude plugin install frontend-design && \
    claude plugin install context7 && \
    claude plugin install code-simplifier && \
    claude plugin install claude-md-management && \
    claude plugin install gopls-lsp && \
    claude plugin install pyright-lsp && \
    claude plugin install skill-creator && \
    claude plugin install feature-dev

WORKDIR /home/${USERNAME} 

CMD ["/bin/bash"]
