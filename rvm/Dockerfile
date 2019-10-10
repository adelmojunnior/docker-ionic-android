FROM beevelop/android-nodejs

ENV IONIC_VERSION 4.5.0
ENV CORDOVA_VERSION 8.1.2

RUN apt-get update && apt-get install -y curl git bzip2 openssh-client && \
    npm i -g --unsafe-perm cordova@${CORDOVA_VERSION} && \
    npm i -g --unsafe-perm ionic@${IONIC_VERSION} && \
    ionic --no-interactive config set -g daemon.updates false && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

WORKDIR /root

RUN command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
    curl -sSL https://get.rvm.io | bash -s stable 

RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 2.5.1 && gem install fastlane && gem install bundler"
