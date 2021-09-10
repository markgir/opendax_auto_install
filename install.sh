#!/bin/bash -x

COMPOSE_VERSION="1.27.4"
COMPOSE_URL="https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)"

# Opendax bootstrap script
install_core() {
  sudo bash <<EOS
apt-get update
apt-get install -y -q git tmux gnupg2 dirmngr dbus htop curl libmariadbclient-dev-compat build-essential
EOS
}

log_rotation() {
  sudo bash <<EOS
mkdir -p /etc/docker
echo '
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "10"
  }
}' > /etc/docker/daemon.json
EOS
}

# Docker installation
install_docker() {
  curl -fsSL https://get.docker.com/ | bash
  sudo bash <<EOS
usermod -a -G docker app
curl -L "$COMPOSE_URL" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
EOS
}


install_ruby() {
  sudo -u app bash <<EOS
  curl -sSL https://rvm.io/mpapis.asc | gpg2 --import
  curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import
  curl -sSL https://get.rvm.io |  bash -s stable --ruby=2.6.6 --gems=rails
  source /home/app/.rvm/scripts/rvm
  rvm use 2.6.6
  
EOS

}

install_core
log_rotation
install_docker
install_ruby
