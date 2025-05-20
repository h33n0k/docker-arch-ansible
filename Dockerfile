FROM archlinux:latest
LABEL maintainer="h33n0k"

ENV pip_packages="ansible cryptography"

# Install dependencies.
RUN pacman -Sy --noconfirm archlinux-keyring \
    && pacman -Syu --noconfirm \
       sudo \
       python \
       python-pip \
       python-setuptools \
       systemd \
       dbus \
       iproute2 \
       procps-ng \
    && pacman -Scc --noconfirm

# Fix lingering man/doc cruft
RUN rm -rf \
	/var/cache/pacman/pkg/* \
	/usr/share/{man,doc,info} \
	/tmp/* \
	/var/tmp/*

# Allow installing stuff to system Python.
RUN rm -f /usr/lib/python3.11/EXTERNALLY-MANAGED

# Upgrade pip to latest version and install pip packages
RUN pip install --upgrade pip --break-system-packages \
	&& pip install --break-system-packages ${pip_packages}

# Install Ansible inventory file.
RUN mkdir -p /etc/ansible \
	&& echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Mask unneeded getty services
RUN systemctl mask getty@tty1.service \
	&& systemctl mask getty.target

# Required for systemd to run inside Docker
VOLUME ["/sys/fs/cgroup"]
STOPSIGNAL SIGRTMIN+3

# Run systemd by default
CMD ["/usr/lib/systemd/systemd"]
