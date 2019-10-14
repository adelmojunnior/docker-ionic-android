FROM beevelop/android-nodejs

ENV IONIC_VERSION 4.5.0
ENV CORDOVA_VERSION 8.1.2
ENV RUBY_VERSION 2.5.1

RUN apt-get update && apt-get install -y curl git bzip2 openssh-client build-essential libssl-dev libreadline-dev libcurl4-gnutls-dev && \
    npm i -g --unsafe-perm cordova@${CORDOVA_VERSION} && \
    npm i -g --unsafe-perm ionic@${IONIC_VERSION} && \
    ionic --no-interactive config set -g daemon.updates false && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

RUN apt-get update && apt-get install -y librsvg2-2 imagemagick graphicsmagick

WORKDIR /root

RUN git clone https://github.com/rbenv/rbenv.git /root/.rbenv && cd /root/.rbenv && src/configure && make -C src

RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build && \
    /root/.rbenv/plugins/ruby-build/install.sh

RUN cp /etc/profile /root/.profile
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh && \
    echo 'eval "$(rbenv init -)"' >> .bashrc

RUN eval "$(rbenv init -)"    

RUN rbenv install ${RUBY_VERSION} && rbenv global ${RUBY_VERSION} && rbenv rehash 

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    locale-gen en_US.UTF-8

# RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN bash -l -c "rbenv global ${RUBY_VERSION} && gem install fastlane && gem install bundler"