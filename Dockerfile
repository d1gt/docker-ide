FROM archlinux:latest

ARG GO_VERSION=1.25.3
ARG UID=1000
ARG GID=1000

RUN pacman -Syu --noconfirm archlinux-keyring 
RUN pacman -S --noconfirm --needed \
        base-devel git redis curl wget sudo xsel openssh \
        podman podman-compose shadow fuse-overlayfs \
        neovim nodejs npm python-pynvim luajit gopls zsh delve 

RUN groupadd -g ${GID} hostgroup \
    && useradd -m -u ${UID} -g ${GID} -G wheel -s /bin/zsh me \
    && echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/wheel

RUN echo me:${UID}:5000 > /etc/subuid; 
RUN echo me:${GID}:5000 > /etc/subgid;


VOLUME /var/lib/containers
VOLUME /home/podman/.local/share/containers

RUN echo -e "[registries.search]\nregistries = ['docker.io', 'quay.io']" \
        > /etc/containers/registries.conf

USER me
WORKDIR /home/me

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -- --unattended

RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz && \
    echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.zshrc && \
    echo 'export GOPATH=$HOME/go' >> ~/.zshrc && \
    mkdir -p ~/go/{bin,src,pkg}

RUN sudo pacman -S --needed --noconfirm git base-devel && \
    git clone https://aur.archlinux.org/yay-bin.git && \
    cd yay-bin && \
    makepkg --noconfirm -si && \
    cd .. && \
    rm -rf yay-bin

RUN mkdir -p ~/.config/nvim ~/.local/share/nvim
COPY --chown=${UID}:${GID} config/nvim/init.lua .config/nvim/init.lua
COPY --chown=${UID}:${GID} config/aliases .aliases

RUN echo 'plugins=(git npm node python sudo)' >> ~/.zshrc && \
    echo 'source ~/.aliases' >> ~/.zshrc

RUN nvim --headless +Lazy! +qall

RUN nvim --headless +TSUpdateSync! +'sleep 10' +qall!

CMD ["zsh"]
