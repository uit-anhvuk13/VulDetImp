FROM ubuntu

COPY bashrc /root/.bashrc

# install needed packages
RUN apt update && apt install -y \
        build-essential \
        cmake \
        clang \
        clang-tools \
        curl \
        git \
        htop \
        llvm \
        neovim \
        python2 \
        python-pip \
        tree \
        wget \
        zip \
        zlib1g && \
    ln -sf /usr/bin/python2 /usr/bin/python && \
    ln -sf /usr/bin/pip2 /usr/bin/pip && \
    pip install scikit-learn matplotlib && \
    curl -o /usr/bin/neofetch https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch && \
    chmod +x /usr/bin/neofetch

WORKDIR /code

CMD ["tail", "-f", "/dev/null"]
