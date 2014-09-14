#! /bin/bash

echo "nameserver 8.8.4.4" > /etc/resolv.conf

apt-get update
echo "set grub-pc/install_devices /dev/sda" | debconf-communicate
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

apt-get upgrade -y
apt-get install python-software-properties 
add-apt-repository -y ppa:webupd8team/java
apt-add-repository -y ppa:chris-lea/node.js
add-apt-repository -y ppa:cwchien/gradle

apt-get update
apt-get install -y oracle-java8-installer
apt-get install -y openjdk-7-jdk python-setuptools ruby ruby-rvm ruby-bundler maven coffeescript libjs-coffeescript gradle groovy rabbitmq-server  npm amqp-tools

# RabbitMQ
chkconfig rabbitmq-server on
service rabbitmq restart

cd /vagrant

# Install
    # UI
    (cd ui; easy_install pip; pip install pika)
    # Dictionary
    (cd dictionary; mvn install; mvn compile)
    # Game board
    (cd game_board; npm install; coffee -c *.coffee;)
    # Letter generator
    (cd letter_generator_highscores; gradle build)
    # scorekeeper
    (cd scorekeeper; gradle build)
    # scorer
    (cd scorer; gradle build)

# Run services
    # dict
    (cd dictionary/target/classes; java com/microserviceshack2/dictionary/Receiver & )
    # game board
    (cd game_board; coffee game_board_service & )
    # letters
    (cd letter_generator_highscores; gradle run & )
    # Highscores
    # TODO: Make this work - just wrong ATM.
    (cd letter_generator_highscores/build/classes/main; java highscore/Main & )
    # scorer
    (cd scorer; gradle run & )
    # scorekeeper
    (cd scorekeeper; gradle run & )
    

echo "Installed"
echo "to play: vagrant ssh -c \"./play-game.sh\""
echo "Game controls: a for left, d for right, s for down, n for new and q for quit."

./playgame.sh

