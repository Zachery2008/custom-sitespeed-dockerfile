FROM debian:stable

# Install dependencies https://github.com/sitespeedio/docker-visualmetrics-deps/blob/master/Dockerfile
ARG FFMPEG_BUILD=5.1.2
ENV DEBIAN_FRONTEND noninteractive

# Lets install all dependencies for VisualMetrics
RUN buildDeps='wget ca-certificates build-essential' && \
    apt-get update -y && apt-get install -y \
    imagemagick \
    libjpeg-dev \
    python3 \
    python3-dev \
    python3-pip \
    python-is-python3 \
    xz-utils \
    sudo \
    curl \
    gnupg2 \
    bzip2 \
    xvfb \
    ffmpeg \
    libavcodec-extra \
    $buildDeps \
    --no-install-recommends --force-yes && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    python -m pip install --upgrade pip && \
    python -m pip install --upgrade setuptools && \
    python -m pip install pyssim OpenCV-Python Numpy image && \
    wget https://ffmpeg.org/releases/ffmpeg-$FFMPEG_BUILD.tar.xz && \
    tar --strip-components 1 -C /usr/bin -xf ffmpeg-$FFMPEG_BUILD.tar.xz --wildcards ffmpeg*/ff*  && \
    rm ffmpeg-$FFMPEG_BUILD.tar.xz 
    #apt-get purge -y --auto-remove $buildDeps

# Install Node https://github.com/nodesource/distributions
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs
RUN apt-get install -q -y aptitude
RUN aptitude install -q -y npm

# Install Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update && apt-get install -y google-chrome-stable

# Install Firefox
RUN apt-get update && apt-get install -y libdbus-glib-1-2 firefox-esr

# Download and install the latest version of Firefox
RUN export FIREFOX_VERSION=$(wget -q -O - "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" | awk -F '[:/]' '{print $6}')
RUN wget "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" -O firefox-latest.tar.bz2
RUN tar xjf firefox-latest.tar.bz2 -C /opt/
RUN ln -nsf /opt/firefox/firefox /usr/bin/firefox

# Install Edge
RUN wget -q -O - https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list
RUN apt-get update && apt-get install -y microsoft-edge-dev

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install sitespeed.io https://github.com/sitespeedio/sitespeed.io/blob/main/Dockerfile
ARG TARGETPLATFORM=linux/amd64

ENV SITESPEED_IO_BROWSERTIME__XVFB true
ENV SITESPEED_IO_BROWSERTIME__DOCKER true

COPY docker/webpagereplay/$TARGETPLATFORM/wpr /usr/local/bin/
COPY docker/webpagereplay/wpr_cert.pem /webpagereplay/certs/
COPY docker/webpagereplay/wpr_key.pem /webpagereplay/certs/
COPY docker/webpagereplay/deterministic.js /webpagereplay/scripts/deterministic.js
COPY docker/webpagereplay/LICENSE /webpagereplay/

RUN sudo apt-get update && sudo apt-get install libnss3-tools python2 \
    net-tools \
    build-essential \
    iproute2 -y && \
    mkdir -p $HOME/.pki/nssdb && \
    certutil -d $HOME/.pki/nssdb -N

ENV PATH="/usr/local/bin:${PATH}"

RUN wpr installroot --https_cert_file /webpagereplay/certs/wpr_cert.pem --https_key_file /webpagereplay/certs/wpr_key.pem

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app/
COPY npm-shrinkwrap.json /usr/src/app/
RUN npm install --production && npm cache clean --force
COPY . /usr/src/app

COPY docker/scripts/start.sh /start.sh

## This is to avoid click the OK button
RUN mkdir -m 0750 /root/.android
ADD docker/adb/insecure_shared_adbkey /root/.android/adbkey
ADD docker/adb/insecure_shared_adbkey.pub /root/.android/adbkey.pub

# Allow all users to run commands needed by sitespeedio/throttle via sudo
# See https://github.com/sitespeedio/throttle/blob/main/lib/tc.js
RUN echo 'ALL ALL=NOPASSWD: /usr/sbin/tc, /usr/sbin/route, /usr/sbin/ip' > /etc/sudoers.d/tc

ENTRYPOINT ["/start.sh"]
VOLUME /sitespeed.io
WORKDIR /sitespeed.io
