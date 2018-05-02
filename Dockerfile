# Use an official Python runtime as a parent image
FROM drupaldocker/php:7.1-cli

# Set the working directory to /build-tools-ci
WORKDIR /build-tools-ci

# Copy the current directory contents into the container at /build-tools-ci
ADD . /build-tools-ci

# Get respoitories for Linux packages
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo  "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Collect the components we need for this image
RUN apt-get update
RUN composer -n global require -n "hirak/prestissimo:^0.3"
RUN mkdir -p /usr/local/share/terminus
RUN /usr/bin/env COMPOSER_BIN_DIR=/usr/local/bin composer -n --working-dir=/usr/local/share/terminus require pantheon-systems/terminus:"^1.8"
RUN mkdir -p /usr/local/share/drush
RUN /usr/bin/env composer -n --working-dir=/usr/local/share/drush require drush/drush "^8"
RUN ln -fs /usr/local/share/drush/vendor/drush/drush/drush /usr/local/bin/drush
RUN chmod +x /usr/local/bin/drush

# Install Node.js
RUN sudo apt-get install -y nodejs
# Install NPM
RUN npm i -g npm
# Install PNPM
RUN curl -L https://unpkg.com/@pnpm/self-installer | node
RUN sudo pnpm install
# Install Yarn
RUN sudo apt-get install yarn
# Install Gulp Globally
RUN sudo npm install -g phantomjs-prebuilt --unsafe-perm
RUN sudo npm install -g gulp gulp-cli

env TERMINUS_PLUGINS_DIR /usr/local/share/terminus-plugins
RUN mkdir -p /usr/local/share/terminus-plugins
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-build-tools-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-secrets-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-rsync-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-quicksilver-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-composer-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-drupal-console-plugin:^1
RUN composer -n create-project -d /usr/local/share/terminus-plugins pantheon-systems/terminus-mass-update:^1
