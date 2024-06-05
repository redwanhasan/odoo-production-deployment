# Step-1: need to install odoo

#Step-2: install nginx 
sudo apt update
sudo apt install nginx -y

#Step-3: 
sudo apt install nginx -y
ls
cd sites-available/
ls
sudo rm -r default
#create new file for odoo nginx configuration
sudo nano odoo_nginx.conf

#odoo_nginx.conf file contents Bellow : 
##########################################
#odoo server
upstream odoo {
server 127.0.0.1:8069;
}
upstream odoochat {
server 127.0.0.1:8072;
}


server {
listen 80;
#Here server_name value can be a domain name or a ip address 
server_name odoomates.tech www.odoomates.tech;

proxy_read_timeout 720s;
proxy_connect_timeout 720s;
proxy_send_timeout 720s;


# Add Headers for odoo proxy mode
proxy_set_header X-Forwarded-Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Real-IP $remote_addr;

# log
access_log /var/log/nginx/odoo.access.log;
error_log /var/log/nginx/odoo.error.log;

# Redirect requests to odoo backend server
location / {
proxy_redirect off;
proxy_pass http://odoo;
}
location /longpolling {
proxy_pass http://odoochat;
}

# common gzip
gzip_types text/css text/less text/plain text/xml application/xml application/json application/javascript;
gzip on;


client_body_in_file_only clean;
client_body_buffer_size 32K;
client_max_body_size 500M;
sendfile on;
send_timeout 600s;
keepalive_timeout 300;
}
##################################################

#Now create a soft link of odoo_nginx.conf in the /etc/nginx/sites-enabled
sudo ln -s /etc/nginx/sites-available/odoo_nginx.conf /etc/nginx/sites-enabled/odoo_nginx.conf

#Now check the soft link file 
cd ..
cd sites-enabled/
ls
sudo rm -r default

#Now check nginx is successfully install or not
sudo nginx -t

sudo service nginx stop
sudo service nginx start

#Now stop odoo 
sudo systemctl stop odoo16.service

#now add following command in /etc/odoo16.conf file to allow nginx proxy
proxy_mode=True

#Now start odoo 
sudo systemctl start odoo16.service

#Now enable nginx 
sudo systemctl enable nginx.service
