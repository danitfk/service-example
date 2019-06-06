## Flask App + RabbitMQ + PostgreSQL + Docker

The goal of this project was creating a Docker-Compose file to have these services:

1. Database (PostgreSQL)
2. Messaging queue (RabbitMQ)
3. HTTP App (Python app based on Flask + uWSGI)
4. Async Worker (Python, Celery)
5. NGINX Serving the HTTP app and its static files

### Clone source code and docker-compose

First make clone from [this](https://github.com/danitfk/service-example) repository into your local machine, Which `docker` and `docker-compose` installed before.

```bash
git clone https://github.com/danitfk/service-example
```

### Adjust environment variables

You can define some credentials related to **PostgreSQL** and **RabbitMQ** service in `.env` file like bellow:

```
POSTGRES_PASS=postgrepass
POSTGRES_USER=postgreuser
POSTGRES_DB=postgredb
RABBITMQ_DEFAULT_USER=rabbituser
RABBITMQ_DEFAULT_PASS=rabbitpass
RABBITMQ_DEFAULT_VHOST=rabbitvhost

```



### Generate a Self Signed SSL Certificate

You have to create *SSL Certificate* related files in `certs` directory like this:

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

### Run service compose file

First, make sure your system already has `docker-compose` then run docker-compose command:

```
docker-compose up -d 
```

After download and build images, output should be like this:

```shell
Starting serviceexample_broker_1 ... 
Starting serviceexample_broker_1
Starting serviceexample_db_1 ... 
Starting serviceexample_db_1 ... done
Starting serviceexample_app_1 ... 
Starting serviceexample_broker_1 ... done
Starting serviceexample_worker_1 ... 
Starting serviceexample_app_1 ... done
Starting serviceexample_proxy_1 ... 
Starting serviceexample_proxy_1
Starting serviceexample_migration_1 ... 
Starting serviceexample_proxy_1 ... done

```



## Some code changes  in source

To retrieve `BROKER_URL` in worker or `DATABASE_URL` in App I've done some code changes to get those variable from environment. ([worker.py](https://github.com/danitfk/service-example/commit/168b9b3fd10bda90d481f555aa2f114f3cf6cff7) and [alembic env.py](https://github.com/danitfk/service-example/commit/eadc78c3b081045696f051269fb08f558ed24648))

## NGINX Security

There are some best practices for secure a NGINX Web Server which publicly is available.

I did implement the important thing of NGINX security in Dockerized environment such as:

- Limit concurrent requests per IP
- Remove Server tokens (nginx version)
- Limit available methods (GET,POST,HEAD)
- Controlling buffer overflow attacks
- NGINX SSL Configuration (Using strong ciphers which Mozilla suggested, Disable old and vulnerable TLS version, Strong dhparam, etc.. )
- Avoid clickjacking with `X-Frame-Options SAMEORIGIN`
- Disable content-type sniffing on some browsers
- Enable the Cross-site-scripting (XSS) filter with `X-XSS-Protection "1; mode=block"`
- Force HTTPS

## Docker Security

### Non-root user for application

Based on best practices applications such as `app` and `migration` will run with non-root user. 

### Separated Network

I've applied two separated network `app` which applications' container such as `app`, `migration`, `broker`, `worker`, `db` connects to each other only in **Internal network** and another separated network `web` which `proxy` and `app` connects to each other.



## Better option for caching

As mentioned before in "DevOps Engineer assignment", caching in NGINX has to be done with *Mircocaching* but there is better option for caching. 

#### Serve static content (Images/styles/javascripts/...) directly on NGINX

It can be done through mounting static directory of flask as *ReadOnly* volume in NGINX and serve those file directly on NGINX and neither of requests will pass to the backend (uWSGI) in this case.

*With current setup, Caching will be done with **NGINX Microcache** but there can found configuration for serving content directly with expires headers in nginx.conf commented.*