FROM ubuntu

COPY bashrc /root/.bashrc

# install needed packages
RUN apt update && apt install -y \
        build-essential \
        cmake \
        curl \
        git \
        htop \
        neovim \
        python3 \
        tree \
        wget \
        zip \
        zlib1g && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    curl -o /usr/bin/neofetch https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch && \
    chmod +x /usr/bin/neofetch

# build llvm/clang
WORKDIR /tmp/build
COPY VulDetector/llvm_clang/clang.patch /tmp/clang.patch
RUN wget https://releases.llvm.org/6.0.1/llvm-6.0.1.src.tar.xz && \
    wget https://releases.llvm.org/6.0.1/cfe-6.0.1.src.tar.xz && \
    tar -xvf cfe-6.0.1.src.tar.xz && \
    tar -xvf llvm-6.0.1.src.tar.xz && \
    rm cfe-6.0.1.src.tar.xz && \
    rm llvm-6.0.1.src.tar.xz && \
    mv cfe-6.0.1.src clang && \
    patch -p0 < /tmp/clang.patch && \
    mv llvm-6.0.1.src llvm && \
    cp -r clang llvm/tools/ && \
    mkdir -p llvm/build && \
    cd llvm/build && \
    cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" .. && \
    make && \
    make install && \
    rm -rf /tmp/build /tmp/clang.patch

# no longer need python3
RUN apt install -y \
        python2 \
        python-pip && \
    ln -sf /usr/bin/python2 /usr/bin/python && \
    ln -sf /usr/bin/pip2 /usr/bin/pip && \
    pip install scikit-learn matplotlib 

WORKDIR /code

CMD ["tail", "-f", "/dev/null"]
