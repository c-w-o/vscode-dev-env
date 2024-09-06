FROM debian:bookworm-slim

LABEL mainteiner="cwo"
LABEL org.opencontainers.image.source=https://github.com/c-w-o/vscode-dev-env

ARG ssh_authorized_keys
ARG developer_user

RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
        libc6 \
        libstdc++6 \
        python3 \
        python3-pip \
        nano \
        wget \
        ca-certificates \
        subversion \
        git \
        openssh-server \
        ssh \
        sudo

RUN wget -O- https://aka.ms/install-vscode-server/setup.sh | /bin/sh

RUN useradd -ms /bin/bash -G sudo -u 1000 -d /home/$developer_user $developer_user
RUN usermod -a -G sudo $developer_user
RUN echo "$developer_user:$developer_user" | chpasswd

USER $developer_user

RUN mkdir -p /home/$developer_user/.ssh && \
    chmod 0700 /home/$developer_user/.ssh
RUN echo "$ssh_authorized_keys" > /home/$developer_user/.ssh/authorized_keys && \
    chmod 0600 /home/$developer_user/.ssh/authorized_keys
RUN ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -q -N ""

VOLUME /home/$developer_user/projects
WORKDIR /home/$developer_user

RUN pip3 install --upgrade pip --break-system-packages
RUN pip3 install urllib3 invoke --break-system-packages

USER root
RUN service ssh restart

EXPOSE 22/tcp

STOPSIGNAL SIGINT

CMD ["/usr/sbin/sshd", "-D"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]
