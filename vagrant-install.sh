#! /bin/bash

echo "nameserver 8.8.4.4" > /etc/resolv.conf

# Basic upgrades
apt-get update
echo "set grub-pc/install_devices /dev/sda" | debconf-communicate
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt-get upgrade -y

# And some extra PPAs
apt-get install -y python-software-properties 
add-apt-repository -y ppa:webupd8team/java
add-apt-repository -y ppa:chris-lea/node.js
add-apt-repository -y ppa:cwchien/gradle
add-apt-repository -y ppa:pitti/postgresql

# Then install the big stuff
apt-get update
apt-get install -y oracle-java8-installer python-setuptools maven coffeescript gradle rabbitmq-server amqp-tools python-psycopg2 curl git postgresql-9.2 
# apt-get install -y groovy  libjs-coffeescript ruby ruby-rvm ruby-bundler 

# RabbitMQ
# chkconfig rabbitmq-server on
service rabbitmq-server restart

# Postgres
# chkconfig postgresql on
service postgresql restart

# Setup postgres db
su postgres -c "psql -c \"create database micro\""
su postgres -c "psql -d micro -c \"create role vagrant with password 'vagrant' superuser login;\""
su postgres -c "psql -d micro -c \"create role microservices with password 'microservices' superuser login;\""
su postgres -c "psql -d micro -c \"CREATE TABLE facts ( id serial primary key, topic character varying(255), ts timestamp without time zone, content json);\""

# Install REST API for rabbit data
pip install pika
cat > /rest-config.json << EOF
{
    "exchange": "combo",
    "rabbit_host": "localhost",
    "rabbit_port": 5672,
    "pg_host": "localhost",
    "pg_database": "micro",
    "pg_user": "microservices",
    "pg_password": "microservices",
    "web_host": "0.0.0.0",
    "web_port": 8080,
    "web_url": "http://localhost:8080"
}
EOF
chmod 777 /rest-config.json
git clone https://github.com/douglassquirrel/combo
(cd combo; ./archivist/archivist /rest-config.json > /log-archivist.log &)
(cd combo; ./web/httpserver.py /rest-config.json > /log-rest-api.log &)

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
    # TODO: Provide libraries for this
    (cd dictionary/target/classes; java com/microserviceshack2/dictionary/Receiver & )
    # game board
    (cd game_board; coffee game_board_service & )
    # letters
    (cd letter_generator_highscores; gradle run & )
    # Highscores
    # TODO: Make this work - just wrong ATM.
    (cd letter_generator_highscores/build/classes/main; java highscore/Main & )
    # scorer
    # TODO: Make this Spring thing work
    (cd scorer; gradle run & )
    # scorekeeper
    (cd scorekeeper; gradle run & )
    

echo "Installed"
echo "to play: vagrant ssh -c \"./play-game.sh\""
echo "Game controls: a for left, d for right, s for down, n for new and q for quit."

./playgame.sh

