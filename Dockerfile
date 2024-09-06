FROM debian:bookworm-slim

LABEL mainteiner="cwo"
LABEL org.opencontainers.image.source=https://github.com/c-w-o/vscode-dev-env

ARG ssh_authorized_keys
ARG developer_user

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
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
        sudo \
        tar \
        htop \
        tmux

# right now it's totally unclear how vscode determines the correct commit id - or when it is updated. the commit id itself is stored inside the archive in a json file. however the
# content of the archive does not really match the installed version. therefore let vscode install it's remote extension as needed.
# also - most times the ssh fingerprint will change. you can disable the check in windows by placing the following in our C:\users\<you>\.ssh\config

# Host *
#     StrictHostKeyChecking no
#     UserKnownHostsFile=/dev/null

#RUN mkdir -p /var/opt/.vscode-server/bin && wget -qO- https://update.code.visualstudio.com/latest/server-linux-x64/stable | tar zxf - -C /var/opt/vscode-server --strip-components 1
RUN wget -qO /usr/bin/hdfind 'https://raw.githubusercontent.com/dhilfer/hdtools/main/hdfind' && chmod +x /usr/bin/hdfind
RUN wget -qO /usr/bin/hdgrep 'https://raw.githubusercontent.com/dhilfer/hdtools/main/hdgrep' && chmod +x /usr/bin/hdgrep
RUN wget -qO /usr/bin/hdontarget 'https://raw.githubusercontent.com/dhilfer/hdtools/main/hdontarget' && chmod +x /usr/bin/hdontarget
RUN wget -qO /usr/bin/hdpack 'https://raw.githubusercontent.com/dhilfer/hdtools/main/hdpack' && chmod +x /usr/bin/hdpack
RUN wget -qO /usr/bin/hdunpack 'https://raw.githubusercontent.com/dhilfer/hdtools/main/hdunpack' && chmod +x /usr/bin/hdunpack

RUN useradd -ms /bin/bash -G sudo -u 1000 -d /home/$developer_user $developer_user
RUN usermod -a -G sudo $developer_user
RUN echo "$developer_user:$developer_user" | chpasswd

USER $developer_user
VOLUME /home/$developer_user/.ssh

RUN mkdir -p /home/$developer_user/._ssh && \
    chmod 0700 /home/$developer_user/._ssh

RUN echo "$ssh_authorized_keys" > /home/$developer_user/._ssh/authorized_keys && \
    chmod 0600 /home/$developer_user/._ssh/authorized_keys

VOLUME /home/$developer_user/projects
WORKDIR /home/$developer_user

RUN pip3 install --upgrade pip --break-system-packages
RUN pip3 install urllib3 invoke --break-system-packages

RUN echo 'alias ll="ls -ahl"' > ~/.bashrc
#RUN ls -s /var/opt/vscode-server ~/.vscode-server
USER root
RUN echo "DEV_USER=$developer_user" > /root/user_env.sh
RUN service ssh restart
#CMD ["/usr/sbin/sshd", "-D"]

EXPOSE 22/tcp

STOPSIGNAL SIGINT

COPY launch.sh /
CMD ["/bin/bash", "-c", "/launch.sh" ]
