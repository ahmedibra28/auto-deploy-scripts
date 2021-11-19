#!/bin/bash
#!/bin/bash
cecho() {
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[1;33m"
    # ... ADD MORE COLORS
    NC="\033[0m" # No Color

    printf "${!1}${2} ${NC}\n"
}

# Constants
cecho "YELLOW" "================> THESE AUTO-DEPLOY-CLI-CONFIGURATIN HAS 20 STEPS"
cecho "GREEN" "1. =================>  Getting user\'s requirements"
read -p "What is your GitHub project name? " GITHUB_PROJECT_NAME
read -p "What directory do you want to store your project? " PROJECT_DIR
PROJECT_PATH="/home/$PROJECT_DIR"
read -p "Does your project requires MONGO DATABASE? (y/n) " IS_MONGO
case $IS_MONGO in
[yY] | [yY][eE][sS])
    read -p "What is your MONGO version? " MONGO_DB_VERSION
    read -p "What is your MONGO database name? " MONGO_DB_NAME
    # run mongodb installation here...
    ;;
esac
read -p "Does your project requires NODE.JS? (y/n) " IS_NODEJS
case $IS_NODEJS in
[yY] | [yY][eE][sS])
    read -p "What is your NVM version do you want to use? " NVM_VERSION
    # curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash
    read -p "What is your NODE.JS version do you want to use? " NODE_VERSION
    # nvm install $NODE_VERSION
    ;;
esac
read -p "Does your project requires ENV VARIABLES? (y/n) " IS_ENV
case $IS_ENV in
[yY] | [yY][eE][sS])
    ENV='.env'
    read -p "Enter your env variables by seperating , (comma)? " ENV_VARIABLES
    # run env installation here... cupture
    ;;
esac
case $IS_NODEJS in
[yY] | [yY][eE][sS])
    read -p "Does your project requires PM2 to run it in background? (y/n) " IS_PM2
    case $IS_PM2 in
    [yY] | [yY][eE][sS])
        read -p "What is your PM2 namespace do you want to use? " PM2_NAMESPACE
        # npm install pm2@latest -g
        ;;
    esac
    ;;
esac
read -p "Does your project requires NGINX? (y/n) " IS_NGINX
case $IS_NGINX in
[yY] | [yY][eE][sS])
    mkdir '/home/server_logs'
    touch '/home/server_logs/host.access.log'
    SERVER_LOGS='/home/server_logs/host.access.log'
    REMOTE_ADDR='$remote_addr'
    HTTP_HOST='$http_host'
    HTTP_UPGRADE='$http_upgrade'
    HOST='$host'
    # run nginx installtion here...
    read -p "Please, enter your domain name without . (dot) if you don\'t have enter \'example\' " NGINX_DOMAIN
    read -p "Please, enter your nginx proxy " NGINX_PROXY_PASS
    # run
    ;;
esac

cecho "GREEN" "9. =================>  Changing directory to /home/"
cd /home/

cecho "GREEN" "10. =================> Removing old files"
if [ -f $PROJECT_DIR ]; then
    rm -r $PROJECT_DIR
fi

cecho "GREEN" "11. =================> Downloading new files from GitHub"
git clone https://github.com/ahmaat19/$GITHUB_PROJECT_NAME.git

cecho "GREEN" "12. =================> Reneming directory to /home/$PROJECT_DIR"
mv $GITHUB_PROJECT_NAME ./$PROJECT_DIR

case $IS_ENV in
[yY] | [yY][eE][sS])
    cecho "GREEN" "13. =================> Create env variables to /home/DIMS/.env"
    cd /home/$PROJECT_DIR
    printf "NODE_ENV=production 
MONGO_URI=mongodb://localhost:27017/$MONGO_DB_NAME
JWT_TOKEN=mom&dad" >>"./$ENV"
    ;;
esac

case $IS_NODEJS in
[yY] | [yY][eE][sS])
    cecho "GREEN" "14. =================> Installing dependencies"
    npm install

    cecho "GREEN" "15. =================> Running build command"
    npm run build

    cecho "GREEN" "16. =================> Deleting all running pm2 sessions "
    pm2 delete all

    cecho "GREEN" "17. =================> Removing pm2 sessions from root"
    pm2 unstartup

    cecho "GREEN" "18. =================> Starting server with pm2"
    pm2 start --name $PM2_NAMESPACE npm -- start

    cecho "GREEN" "19. =================> Freezing pm2 running sessions"
    pm2 startup

    cecho "GREEN" "20. =================> Saving pm2 running sessions"
    pm2 save
    ;;
esac

cecho "GREEN" " ====================== SUCCESS ======================"

cecho "RED" "GITHUB: $GITHUB_PROJECT_NAME"
cecho "RED" "PROJECT DIR: $PROJECT_DIR"
cecho "RED" "IS MONGODB: $IS_MONGO"
cecho "RED" "MONGO_DB_VERSION: $MONGO_DB_VERSION"
cecho "RED" "MONGO_DB_NAME: $MONGO_DB_NAME"
cecho "RED" "NVM_VERSION: $NVM_VERSION"
cecho "RED" "IS_PM2: $IS_PM2"
cecho "RED" "PM2_NAMESPACE: $PM2_NAMESPACE"
cecho "RED" "IS_NGINX: $IS_NGINX"
cecho "RED" "SERVER_LOGS: $SERVER_LOGS"
cecho "RED" "NGINX_DOMAIN: $NGINX_DOMAIN"
cecho "RED" "NGINX_PROXY_PASS: $NGINX_PROXY_PASS"

cecho "RED" "REMOTE_ADDR: $REMOTE_ADDR"
cecho "RED" "HTTP_HOST: $HTTP_HOST"
cecho "RED" "HTTP_UPGRADE: $HTTP_UPGRADE"
cecho "RED" "HOST: $HOST"

cecho "RED" "IS_ENV: $IS_ENV"
cecho "RED" "ENV_VARIABLES: $ENV_VARIABLES"
cecho "RED" "ENV: $ENV"
