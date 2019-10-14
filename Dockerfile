FROM beevelop/android-nodejs

ENV IONIC_VERSION 4.5.0
ENV CORDOVA_VERSION 8.1.2

RUN apt-get update && apt-get install -y curl git bzip2 openssh-client build-essential libssl-dev libreadline-dev libcurl4-gnutls-dev && \
    npm i -g --unsafe-perm cordova@${CORDOVA_VERSION} && \
    npm i -g --unsafe-perm ionic@${IONIC_VERSION} && \
    ionic --no-interactive config set -g daemon.updates false && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

WORKDIR /root

RUN git clone https://github.com/rbenv/rbenv.git /root/.rbenv && cd /root/.rbenv && src/configure && make -C src

RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build && \
    /root/.rbenv/plugins/ruby-build/install.sh

RUN cp /etc/profile /root/.profile
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh && \
    echo 'eval "$(rbenv init -)"' >> .bashrc && \
    echo 'export LC_ALL=en_US.UTF-8' >> .bashrc && \
    echo 'export LANG=en_US.UTF-8' >> .bashrc 

RUN eval "$(rbenv init -)"    

RUN rbenv install 2.5.1 && rbenv global 2.5.1 && rbenv rehash 

# RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN bash -l -c 'rbenv global 2.5.1 && gem install fastlane && gem install bundler'