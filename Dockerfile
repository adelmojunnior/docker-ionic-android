FROM gradle:5.6.2-jdk8

WORKDIR /root

ENV IONIC_VERSION 4.5.0
ENV CORDOVA_VERSION 9.0.0
ENV RUBY_VERSION 2.5.1
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV NODEJS_VERSION 10.16.3 
ENV TZ America/Bahia
ENV PATH /root/.rbenv/bin:$PATH
ENV GIT_SSL_NO_VERIFY true
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y wget unzip curl git bzip2 openssh-client build-essential libssl-dev libreadline-dev libcurl4-gnutls-dev \
    librsvg2-2 imagemagick graphicsmagick tzdata ca-certificates zlib1g-dev --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

RUN mkdir -p ${ANDROID_HOME} && \
    cd ${ANDROID_HOME} && \
    wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O android_tools.zip && \
    unzip android_tools.zip && \
    rm android_tools.zip &&  \
    yes | sdkmanager --licenses && \
    sdkmanager 'platform-tools' && \
    sdkmanager 'platforms;android-28' && \
    sdkmanager 'build-tools;28.0.3' && \
    sdkmanager 'extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2' && \
    sdkmanager 'extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2' && \
    sdkmanager 'extras;google;m2repository' && \
    sdkmanager 'extras;android;m2repository' && \
    sdkmanager 'extras;google;google_play_services' 

RUN cp /etc/profile /root/.profile

ENV NVM_DIR /root/.nvm
ENV PATH $NVM_DIR/versions/node/v$NODEJS_VERSION/bin:$PATH

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | bash && . /root/.profile && . $NVM_DIR/nvm.sh && nvm install ${NODEJS_VERSION} 

RUN npm i -g --unsafe-perm cordova@${CORDOVA_VERSION} && \
    npm i -g --unsafe-perm ionic@${IONIC_VERSION} && \
    ionic --no-interactive config set -g daemon.updates false

RUN echo $TZ > /etc/timezone && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata 

RUN git clone https://github.com/rbenv/rbenv.git /root/.rbenv && cd /root/.rbenv && src/configure && make -C src

RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build && \
    /root/.rbenv/plugins/ruby-build/install.sh

RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh && \
    echo 'eval "$(rbenv init -)"' >> .bashrc

RUN eval "$(rbenv init -)"    

RUN rbenv install ${RUBY_VERSION} && rbenv global ${RUBY_VERSION} && rbenv rehash 

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf

RUN . /root/.profile
RUN rbenv global ${RUBY_VERSION} && /bin/bash -l -c "gem install bundler fastlane"
