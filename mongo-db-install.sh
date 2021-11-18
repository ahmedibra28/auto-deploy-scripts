MONGO_DB_VERSION='5.0'

wget -qO - https://www.mongodb.org/static/pgp/server-$MONGO_DB_VERSION.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/$MONGO_DB_VERSION multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-$MONGO_DB_VERSION.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod.service
sudo systemctl enable mongod

echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-database hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-org-shell hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections
