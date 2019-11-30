FROM chrismwendt/codeintel-bash-with-explainshell

ARG RPI_BUILD=false
ENV RPI_BUILD ${RPI_BUILD}

ENV container=docker \
    DEBIAN_FRONTEND=noninteractive \
    TERM=xterm

RUN \
    set -xe && apt-get update -y && \
    apt-get install -y \
    python sudo bash ca-certificates \
    locales \
    lsb-release \
    openssh-server \
    software-properties-common ansible && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    update-locale LANG=en_US.UTF-8 && \
    mkdir -p /var/run/sshd && \
    if [ "${RPI_BUILD}" = "false" ]; then \
        add-apt-repository ppa:jonathonf/backports -y; \
        else echo "skipping ppa"; \
    fi && \
    apt-get update -y && \
    apt-get -y install gdebi-core sshpass cron netcat net-tools iproute2 && \
    apt-get -y install \
    ansible \
    apt-utils \
    autoconf \
    bash \
    zsh \
    bash-completion \
    binutils-dev \
    bison \
    bridge-utils \
    build-essential \
    ca-certificates \
    ccache \
    ccze \
    # conntrack-tools \
    dhcping \
    # drill \
    ethtool \
    fping \
    curl \
    direnv \
    dnsutils \
    dstat \
    elfutils \
    file \
    fontconfig \
    gcc \
    git \
    iptables \
    iptraf-ng \
    libc6 \
    libc6-dev \
    liboping-dev \
    ipvsadm \
    git-core \
    htop \
    httpie \
    iftop \
    iotop \
    iperf \
    iperf3 \
    iputils-ping \
    jq \
    libevent-dev \
    libffi-dev \
    libncurses-dev \
    libncurses5-dev \
    libreadline6-dev \
    libssl-dev \
    libyaml-dev \
    locales \
    lsb-release \
    lsof \
    ltrace \
    make \
    mlocate \
    mtr \
    ncdu \
    nftables \
    net-tools \
    # net-snmp \
    netperf \
    tcptrack \
    ngrep \
    nmap \
    # nping \
    openssh-server \
    patch \
    perf-tools-unstable \
    procps \
    python \
    python-dev \
    python-pip \
    python-setuptools \
    rsyslog \
    ruby-full \
    silversearcher-ag \
    socat \
    software-properties-common \
    strace \
    sudo \
    sysstat \
    openssl \
    python-crypto \
    scapy \
    systemd \
    systemd-cron \
    tcptraceroute \
    util-linux \
    tcpdump \
    tmux \
    traceroute \
    tree \
    vim \
    wget \
    zlib1g-dev \
    && \
    apt-get install -y \
    zsh && \
    apt-get install apt-utils \
    python-setuptools \
    python-pip \
    software-properties-common \
    rsyslog \
    systemd \
    systemd-cron \
    sudo -y && \
    apt-get clean

RUN set -xe && apt-get update -y && \
    if [ "${RPI_BUILD}" = "false" ]; then \
        add-apt-repository ppa:openjdk-r/ppa -y; \
        else echo "skipping ppa"; \
    fi && \
    apt-get update && \
    apt-get install -y \
    openjdk-8-jdk

RUN git clone https://github.com/samoshkin/tmux-config \
    && ./tmux-config/install.sh \
    && rm -rf ./tmux-config && \
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install --all && \
    if [ "${RPI_BUILD}" = "false" ]; then \
        curl -L 'https://github.com/heppu/gkill/releases/download/v1.0.2/gkill-linux-amd64' > /usr/local/bin/gkill; \
        chmod +x /usr/local/bin/gkill; \
        curl -L 'https://github.com/rgburke/grv/releases/download/v0.1.2/grv_v0.1.2_linux64' > /usr/local/bin/grv; \
        chmod +x /usr/local/bin/grv; \
        curl -L 'https://github.com/sharkdp/fd/releases/download/v7.2.0/fd_7.2.0_amd64.deb' > /usr/local/src/fd_7.2.0_amd64.deb; \
        apt install -y /usr/local/src/fd_7.2.0_amd64.deb; \
    else \
        echo "skipping all adm builds ..."; \
    fi

COPY populate-explainshell.sh /populate-explainshell.sh
COPY run-bash-language-server.sh /run-bash-language-server.sh

RUN echo "# network interfaces" | tee -a /etc/mongodb.conf && \
    echo "net:" | tee -a /etc/mongodb.conf && \
    echo "  port: 27017" | tee -a /etc/mongodb.conf && \
    echo "  bindIp: 0.0.0.0" | tee -a /etc/mongodb.conf

RUN cd explainshell && ../populate-explainshell.sh

EXPOSE 27017
