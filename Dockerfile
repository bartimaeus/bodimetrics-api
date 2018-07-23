FROM ruby:2.5.0-alpine3.7
LABEL maintainer="Eric Shelley <eric@webdesignbakery.com>"

# Install dependencies:
RUN apk add --no-cache build-base tzdata git curl tree vim \
  && gem install bundler

# Set an environment variable to store where the app is installed inside of the Docker image
ENV INSTALL_PATH /bodimetrics
RUN mkdir -p $INSTALL_PATH

# This sets the context of where commands will be ran in and is documented
# on Docker's website extensively.
WORKDIR $INSTALL_PATH

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

ENV BUNDLE_PATH=/bundle \
  BUNDLE_BIN=/bundle/bin \
  GEM_HOME=/bundle

ENV PATH="$BUNDLE_BIN:$PATH"

# Bundle all gems
RUN bundle install --jobs 20

# Copy in the application code from your work station at the current directory
# over to the working directory.
COPY . .

### Development environment setup ###
# Set the TERM and SHELL environment variables
ENV TERM xterm-256color
ENV SHELL $(which bash)

### Development environment customizations ###
RUN echo "export PAGER=more" >> /root/.profile && \
  echo "export PS1=\"🐳  \[\033[1;36m\]\h \[\033[1;34m\]\W\[\033[0;35m\] \[\033[1;36m\]# \[\033[0m\]\"" >> /root/.profile && \
  echo "alias ll='ls -lAh'" >> /root/.profile && \
  echo "alias l='ls -lah'" >> /root/.profile && \
  echo "alias dir='tree -d -L 1'" >> /root/.profile && \
  echo "alias be='bundle exec '" >> /root/.profile

COPY .pryrc /root/.pryrc
### END Development environment customizations ###

CMD [ "sh" ]
