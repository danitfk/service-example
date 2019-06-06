## Flask App + RabbitMQ + PostgreSQL + Docker

The goal of this project was creating a Docker-Compose file to have these services:

1. Database (PostgreSQL)
2. Messaging queue (RabbitMQ)
3. HTTP App (Python app based on Flask + uWSGI)
4. Async Worker (Python, Celery)
5. NGINX Serving the HTTP app and its static files

Before you begin, You have to create *SSL Certificate* related files in `certs` directory like this:

### Generate a Self Signed SSL Certificate

First We will create a Self Signed SSL Certificate with openssl. *Make sure openssl package installed on your system ([How to install openssl](https://websiteforstudents.com/manually-install-the-latest-openssl-toolkit-on-ubuntu-16-04-18-04-lts/))*

```bash
# Create certs directory if not exists
mkdir certs
# Generate a self-signed key and certificate pair with OpenSSL
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout certs/nginx-selfsigned.key -out certs/nginx-selfsigned.crt
```

The entirety of the prompts will look something like this:

```yaml
Country Name (2 letter code) [AU]:US
State or Province Name (full name) [Some-State]:New York
Locality Name (eg, city) []:New York City
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Bouncy Castles, Inc.
Organizational Unit Name (eg, section) []:Ministry of Water Slides
Common Name (e.g. server FQDN or YOUR name) []:server_IP_address
Email Address []:admin@your_domain.com
```

### Generate Diffie-Hellman group

It may takes a while,to reduce time change 4096 to 2048.

```Shell
openssl dhparam -out certs/dhparam.pem 4096
```



