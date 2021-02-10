# ------------------------------------------------------------------------------
# Pull base image
FROM ubuntu:18.04

# ------------------------------------------------------------------------------
# Arguments
ARG WORKDIR=/root

# ------------------------------------------------------------------------------
# Install tools via apt
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -y update && \
    apt -y install git \
    wget \
    python3 \
    python3-dev \
    python3-setuptools \
    python3-usb \
    python3-pip \
    software-properties-common \
    build-essential \
    astyle \
    mercurial \
    ninja-build \
    && apt clean && rm -rf /var/lib/apt/lists


# ------------------------------------------------------------------------------
# Install Python modules (which are not included in requirements.txt)
RUN pip3 install -U \
    mbed-cli \
    mbed-tools \
    awscli

# Set up mbed environment
WORKDIR /root/
RUN wget https://github.com/ARMmbed/mbed-os/raw/master/requirements.txt && \
    pip3 install -r requirements.txt

# ------------------------------------------------------------------------------
# Install updated cmake - refer https://cmake.org/install/ 
COPY cmake-3.20.0-rc3-Linux-x86_64.sh /tmp
RUN sh /tmp/cmake-3.20.0-rc3-Linux-x86_64.sh --exclude-subdir --prefix=/usr/local

# ------------------------------------------------------------------------------
# Install arm-none-eabi-gcc
WORKDIR /root/
RUN wget -q https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/RC2.1/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2 && \
    tar -xjf gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2 && \
    rm gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2
ENV PATH="/root/gcc-arm-none-eabi-9-2019-q4-major/bin:${PATH}"


# ------------------------------------------------------------------------------
# Display and save environment settings
RUN python3 --version | tee env_settings && \
    arm-none-eabi-gcc --version | tee -a env_settings && \
    (echo -n 'mbed-cli ' && mbed --version) | tee -a env_settings && \
    (echo -n 'mbed-greentea ' && mbedgt --version) | tee -a env_settings && \
    (echo -n 'mbed-host-tests ' && mbedhtrun --version) | tee -a env_settings

WORKDIR /root

