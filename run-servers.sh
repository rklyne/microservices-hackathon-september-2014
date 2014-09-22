
cd /home/vagrant

(cd combo; python ./archivist/archivist.py /rest-config.json &)
(cd combo; python ./web/httpserver.py /rest-config.json &)

