FROM ubuntu:18.04

#install yocto requirements
RUN apt-get update && apt-get -y install gawk wget git-core \
    diffstat unzip texinfo gcc-multilib build-essential \
    chrpath socat cpio python python3 python3-pip \
    python3-pexpect xz-utils debianutils iputils-ping \
    libsdl1.2-dev xterm tar locales

#remove link to dash
RUN rm /bin/sh && ln -s bash /bin/sh

#set locale
RUN locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

#setup user
ENV USER_NAME antisoup
ARG host_uid=1001
ARG host_gid=1001
RUN groupadd -g $host_gid $USER_NAME && \
    useradd -g $host_gid -m -s /bin/bash -u $host_uid $USER_NAME
USER $USER_NAME

#setup build dirs
ENV BUILD_SRC_DIR /home/$USER_NAME/yocto/src/
ENV BUILD_OUT_DIR /home/$USER_NAME/yocto/out/
RUN mkdir -p $BUILD_SRC_DIR $BUILD_OUT_DIR

#start build
WORKDIR $BUILD_OUT_DIR
ENV TEMPLATECONF=$BUILD_SRC_DIR/meta-antisoup/conf/template
CMD $BUILD_SRC_DIR/$BUILD_TOOLS_SCR -y -d $BUILD_SRC_DIR/poky/3.1.3/ &&\
    source $BUILD_SRC_DIR/poky/3.1.3/environment-setup-$(uname -m)-pokysdk-linux &&\
    source $BUILD_SRC_DIR/poky/oe-init-build-env &&\
    build && bitbake antisoup-image-dev
