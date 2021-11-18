# Auto Deploy Script

These scripts will help you to deploy your node.js based project to cloud e.g. <digitalocean.com>.

Each script depends on other script.

Start running from `start-auto-deploy.sh`

Copy the following code to your remote terminal.

```shell
chmod +x ./start-auto-deploy.sh
./start-auto-deploy.sh
```

At **Step 3**, it will go restart the whole machine to pickup installed NVM.

install node.js manually.

```shell
nvm install -lts
```
