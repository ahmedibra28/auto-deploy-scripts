mkdir '/home/server_logs'
touch '/home/server_logs/host.access.log'
SERVER_LOGS='/home/server_logs/host.access.log'
PROXY_PASS='"http://127.0.0.1:3000"'
NGINX_DOMAIN='example'
DOMAIN='ahmaat.tk'

SIGN_DOLLAR='$'
REMOTE_ADD='remote_addr'
HTTP_HOST='http_host'
HTTP_UPGRADE='http_upgrade'
HOST='host'

printf "
server {
    #listen       80;
    server_name  $DOMAIN www.$DOMAIN;

    access_log $SERVER_LOGS;


    location / {
        proxy_set_header   X-Forwarded-For $SIGN_DOLLAR$REMOTE_ADD;
        proxy_set_header   Host $SIGN_DOLLAR$HTTP_HOST;
        proxy_pass         "$PROXY_PASS";
        proxy_http_version 1.1;
        proxy_set_header Upgrade $SIGN_DOLLAR$HTTP_UPGRADE;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $SIGN_DOLLAR$HOST;
        proxy_cache_bypass $SIGN_DOLLAR$HTTP_UPGRADE;

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

sudo systemctl restart nginx
sudo ln -s /etc/nginx/sites-available/$NGINX_DOMAIN /etc/nginx/sites-enabled/
sudo systemctl restart nginx
