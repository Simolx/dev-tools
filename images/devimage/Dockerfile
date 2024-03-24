FROM ubuntu
ARG PY_ADDR
ARG USERNAME=developer
ARG USER_PASSWD

RUN apt update && \
    apt upgrade -y && \
    apt install -y sudo git vim tmux iputils-ping telnet zip curl wget p7zip-full p7zip-rar dos2unix file gnutls-bin dstat tmuxinator g++ gnupg2 && \
    apt autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN curl -o python_installer.sh -k -L $PY_ADDR && \
    bash python_installer.sh -p /opt/python3 -b && \
    /opt/python3/bin/conda update --all -y && \
    /opt/python3/bin/conda install -y conda-forge::tqdm conda-forge::powerline-status conda-forge::powerline-gitstatus conda-forge::py7zr && \
    /opt/python3/bin/conda clean --all -y && \
    rm -f python_installer.sh

RUN curl -L -k -o go_installer.tar.gz https://go.dev/dl/go1.22.1.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go_installer.tar.gz && \
    rm -f go_installer.tar.gz && \
    curl -k https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    nvm install 20 && \
    npm install -g @bazel/bazelisk && \
    bazelisk --version

RUN useradd -m ${USERNAME} && \
    echo "${USERNAME}:${USER_PASSWD}" | chpasswd && \
    usermod -aG sudo ${USERNAME} && \
    chsh -s /bin/bash ${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} vimrc /home/${USERNAME}/.vimrc
USER ${USERNAME}

RUN curl -k -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN curl -k --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

RUN /opt/python3/bin/conda init && \
    mkdir -p ${HOME}/.config/powerline && \
    repository=$(/opt/python3/bin/pip show powerline-status | grep Location | awk '{print $2}') && \
    cp -r ${repository}/powerline/config_files ${HOME}/.config/powerline && \
    echo source ${repository}/powerline/bindings/tmux/powerline.conf >> ${HOME}/.tmux.conf && \
    echo 'export PATH=$PATH:$HOME/.cargo/bin:/usr/local/go/bin' >> ${HOME}/.bashrc && \
    cat <<EOF >> ${HOME}/.bashrc
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. ${repository}/powerline/bindings/bash/powerline.sh

alias mux='tmuxinator'
alias tmux='tmux -u'
EOF
#    curl -O -L -k https://github.com/powerline/fonts/archive/refs/heads/master.zip && \

RUN cd ${HOME} && \
    curl -O -L -k http://192.168.0.105:8000/master.zip && \
    unzip master.zip && \
    cd fonts-master && \
    ./install.sh && \
    /opt/python3/bin/fc-cache ${HOME}/.local/share/fonts && \
    cd .. && \
    rm -rf fonts-master master.zip

RUN vim +PlugInstall +qall && \
    vim +GoInstallBinaries +qall

WORKDIR /home/${USERNAME} 

CMD ["/bin/bash"]
