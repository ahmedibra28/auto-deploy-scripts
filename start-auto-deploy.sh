cecho() {
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[1;33m"
    # ... ADD MORE COLORS
    NC="\033[0m" # No Color

    printf "${!1}${2} ${NC}\n"
}

# Constants
cecho "YELLOW" "================> THESE AUTO-DEPLOY-CONFIGURATIN HAS 20 STEPS"
cecho "GREEN" "1. =================>  Creating project directory base"
PROJECT_NAME="DIMS" # Project name from github
PROJECT_DIR="DIMS"  # Project directory
PROJECT_PATH="/home/$PROJECT_DIR"

cecho "GREEN" "2. =================>  Updating the server"
chmod +x server-update.sh
./server-update.sh

cecho "GREEN" "3. =================>  Installing NVM"
chmod +x nvm-install.sh
./nvm-install.sh
reboot # must restart the machine, if not NVM not gonna work

cecho "GREEN" "4. =================>  Installing Node.js from NVM"
chmod +x node-install.sh
./node-install.sh # You have to install manually nvm install --lts

cecho "GREEN" "5. =================>  Installing MongoDB"
chmod +x mongo-db-install.sh
./mongo-db-install.sh

cecho "GREEN" "6. =================>  Installing Nginx"
chmod +x nginx-install.sh
./nginx-install.sh

cecho "GREEN" "7. =================>  Configuring Nginx"
chmod +x nginx-configuration.sh
./nginx-configuration.sh

cecho "GREEN" "8. =================>  Installing PM2"
chmod +x pm2-install.sh
./pm2-install.sh

cecho "GREEN" "9. =================>  Changing directory to /home/"
cd /home/

cecho "GREEN" "10. =================> Removing old files"
rm -r $PROJECT_DIR

cecho "GREEN" "11. =================> Downloading new files from GitHub"
git clone https://github.com/ahmaat19/$PROJECT_NAME.git

cecho "GREEN" "12. =================> Reneming directory to /home/$PROJECT_DIR"
# mv $PROJECT_NAME $PROJECT_DIR

cecho "GREEN" "13. =================> Create env variables to /home/DIMS/.env"
chmod +x env.sh
./env.sh

cecho "GREEN" "14. =================> Installing dependencies"
cd /home/$PROJECT_DIR
npm install

cecho "GREEN" "15. =================> Running build command"
npm run build

cecho "GREEN" "16. =================> Deleting all running pm2 sessions "
pm2 delete all

cecho "GREEN" "17. =================> Removing pm2 sessions from root"
pm2 unstartup

cecho "GREEN" "18. =================> Starting server with pm2"
pm2 start --name $PROJECT_DIR npm -- start

cecho "GREEN" "19. =================> Freezing pm2 running sessions"
pm2 startup

cecho "GREEN" "20. =================> Saving pm2 running sessions"
pm2 save

cecho "GREEN" " ====================== SUCCESS ======================"
