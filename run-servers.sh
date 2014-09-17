
cd /home/vagrant

(cd combo; python ./archivist/archivist.py /rest-config.json > /log-archivist.log &)
(cd combo; python ./web/httpserver.py /rest-config.json > /log-rest-api.log &)

