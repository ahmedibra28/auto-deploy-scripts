#!/usr/bin/bash
cecho() {
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[1;33m"
    # ... ADD MORE COLORS
    NC="\033[0m" # No Color

    printf "${!1}${2} ${NC}\n"
}

# Constants
NVM_VERSION='0.39.1'
NODE_VERSION='--lts'
MONGO_DB_VERSION='6.0'
REMOTE_ADDR='$remote_addr'
HTTP_HOST='$http_host'
HTTP_UPGRADE='$http_upgrade'
HOST='$host'

cecho "YELLOW" "================> THESE AUTO-DEPLOY-CLI-CONFIGURATIN HAS 20 STEPS"
cecho "RED" "================> Please, answer all asked questions to success your deploying"

# UPDATING SERVER
cecho "GREEN" "================> 1. We're updaing server"
sudo apt update
sudo apt upgrade

# INSTALLING NVM
if [ ! -d "/root/.nvm" ]; then
    cecho "GREEN" "2. ================>  We're trying to install NVM, please bear with us"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash
    cecho "YELLOW" "================> NVM installed successfully, please reboot your machine and re-run the script again"
fi

# INSTALLING NODE.JS
if [ ! -d "/root/.nvm/versions/node" ]; then
    cecho "GREEN" "3. ================>  We're trying to install NODE.JS"

    . ~/.nvm/nvm.sh
    . ~/.profile
    . ~/.bashrc

    nvm install $NODE_VERSION
    if [ ! -d "/root/.nvm/versions/node" ]; then
        cecho "RED" " ================>  Sorry, we can't install NODE.JS, please install it mannually by typing <nvm install --lts> and re-run the script again"
        exit
    fi
fi

# INSTALLING PM2
if [ ! -d "/root/.pm2" ]; then
    cecho "GREEN" "4. ================>  We're trying to install PM2"

    . ~/.nvm/nvm.sh
    . ~/.profile
    . ~/.bashrc

    npm install pm2@latest -g
fi

cecho "GREEN" "5. =================>  Getting user's requirements"

# GITHUB_PROJECT_NAME
while [ -z "$GITHUB_PROJECT_NAME" ]; do
    read -p "What's your GitHub project name? " GITHUB_PROJECT_NAME
    if [ -z "$GITHUB_PROJECT_NAME" ]; then
        cecho "RED" "================> Please, enter your github project URL"
    fi
done

# PROJECT_DIR
while [ -z "$PROJECT_DIR" ]; do
    read -p "What directory do you want to store your project with one word? " PROJECT_DIR
    if [ -z "$PROJECT_DIR" ]; then
        cecho "RED" "================> Please, enter your project directory"
    fi
done

# MONGO_DB_NAME
while [ -z "$MONGO_DB_NAME" ]; do
    read -p "What's your Mongo Databse name? " MONGO_DB_NAME
    if [ -z "$MONGO_DB_NAME" ]; then
        cecho "RED" "================> Please, enter your mongo database name"
    fi
done

# INSTALLING MONGO
if [ "/root/.mongorc.js" != "/root/.mongorc.js" ]; then
    cecho "GREEN" "6. ================>  Installing Mongo DB"
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

    if [ "/root/.mongorc.js" != "/root/.mongorc.js" ]; then
        cecho "RED" "================> Sorry, we can't install Mongo DB, please install it mannually by typing <sudo apt-get install -y mongodb-org && sudo systemctl start mongod.service && sudo systemctl enable mongod> and re-run the script again"
        exit
    fi
fi

# INSTALLING NGINX
if [ ! -d "/etc/nginx" ]; then
    cecho "GREEN" "7. ================>  Installing Nginx"
    sudo apt update
    sudo apt install nginx
    sudo ufw app list
    sudo ufw allow 'Nginx HTTP'
    systemctl status nginx
fi

# CONFIGURING NGINX
if [ ! -d "/root/server_logs" ]; then
    cecho "GREEN" "8. ================>  Configuring Nginx"
    mkdir '/root/server_logs'
    touch '/root/server_logs/host.access.log'
fi
SERVER_LOGS='/root/server_logs/host.access.log'

while [ -z "$DOMAIN" ]; do
    read -p "What's your domain? e.g. example.com " DOMAIN
    if [ -z "$DOMAIN" ]; then
        cecho "RED" "================> Please, enter your domain"
    fi
done

while [ -z "$NGINX_DOMAIN" ]; do
    read -p "What's your nginx domain without . (dot)? e.g. example " NGINX_DOMAIN
    if [ -z "$NGINX_DOMAIN" ]; then
        cecho "RED" "================> Please, enter your nginx domain without . (dot)"
    fi
done

while [ -z "$PROXY_PORT" ]; do
    read -p "What's your proxy port? e.g. 3000 " PROXY_PORT
    if [ -z "$PROXY_PORT" ]; then
        cecho "RED" "================> Please, enter your proxy port"
    fi
done
if [ ! -d "/etc/nginx/sites-available/$NGINX_DOMAIN" ]; then
    printf "
server {
    #listen       80;
    server_name  $DOMAIN www.$DOMAIN;

    access_log $SERVER_LOGS;


    location / {
        proxy_set_header   X-Forwarded-For $REMOTE_ADDR;
        proxy_set_header   Host $HTTP_HOST;
        proxy_pass         "http://127.0.0.1:$PROXY_PORT";
        proxy_http_version 1.1;
        proxy_set_header Upgrade $HTTP_UPGRADE;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $HOST;
        proxy_cache_bypass $HTTP_UPGRADE;

    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    server_tokens off;

    location ~ /\.ht {
        deny  all;
    }

}
" >>"/etc/nginx/sites-available/$NGINX_DOMAIN"
fi

sudo systemctl restart nginx
if [ ! -d "/etc/nginx/sites-available/default" ]; then
    rm /etc/nginx/sites-available/default
    rm /etc/nginx/sites-enabled/default
    sudo ln -s /etc/nginx/sites-available/$NGINX_DOMAIN /etc/nginx/sites-enabled/
    sudo systemctl restart nginx
fi

if [ ! -d "/root/$PROJECT_DIR" ]; then
    cecho "GREEN" "9. =================> Downloading new files from GitHub"
    cd "/root"
    git clone https://github.com/ahmaat19/$GITHUB_PROJECT_NAME.git
fi

cecho "GREEN" "10. =================> Reneming directory to /root/$PROJECT_DIR"
# mv "/root/$GITHUB_PROJECT_NAME" "/root/$PROJECT_DIR"
cd "/root/$GITHUB_PROJECT_NAME"

cecho "GREEN" "11. =================> Create env variables to /root/$PROJECT_DIR/.env"
printf "NODE_ENV=production 
MONGO_URI=mongodb://localhost:27017/$MONGO_DB_NAME
JWT_SECRET=djkfjkdsf8dsf8ds7f9ds7g98" >>"./.env"

if [ -d "/root/.pm2" ]; then
    . ~/.nvm/nvm.sh
    . ~/.profile
    . ~/.bashrc
    cecho "GREEN" "12. =================> Installing dependencies"
    npm install

    cecho "GREEN" "13. =================> Running build command"
    npm run build

    cecho "GREEN" "14. =================> Deleting all running pm2 sessions "
    pm2 delete all

    cecho "GREEN" "15. =================> Removing pm2 sessions from root"
    pm2 unstartup

    cecho "GREEN" "16. =================> Starting server with pm2"
    pm2 start --name "$GITHUB_PROJECT_NAME" npm -- start

    cecho "GREEN" "19. =================> Freezing pm2 running sessions"
    pm2 startup

    cecho "GREEN" "20. =================> Saving pm2 running sessions"
    pm2 save
fi
cecho "GREEN" " ====================== SUCCESS ======================"
