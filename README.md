# Setting up a Nexus3 Lab Server
This repo shows how to set up a nexus server for use in your home lab.

See the youtube video here:
## Prerequirements
We want to Generate certificate for Nginx and pull docker images with certificate,
you can use valid Generate or generate self-sign Generate.
## Using valid certificate
If you use valid certificate , comment below commands in `run.sh`.
```

#Generate certificate for Nginx
cd configs/secrets/
openssl genrsa -out ca.key 2048
openssl req -new -x509 -key ca.key -out ca.crt -config openssl.conf
openssl genrsa -out server.key 2048
openssl req -new -sha256 -key server.key -out nexus.csr -config openssl.conf
openssl x509 -req -in nexus.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -extensions v3_req -extfile openssl.conf

```
After that In `configs/nginx/default.conf` you can specify ssl_certificate,ssl_certificate_key file names.
## Generate self-sign certificate
In this project , All the commands needed to create the self-sign certificate are placed in the `run.sh` script.
next step setting server_name In `configs/nginx/default.conf` , in this project server_name is nexus.repository.com
```
server {
    listen       443 ssl;
    server_name  nexus.repository.ir;
    .
    .
    .

```

## Installation
This repo assumes you have docker and docker-compose installed.


You can run this using the `run.sh` convenience script (for first time):

```
./run.sh
```

In this script there is a command that  changes permissions on the `volume` subdirectory.  This seems only to be required on Linux docker hosts.

Alternaively, you can run it via `docker-compose` directly:

```
docker-compose up -d
```

You can watch the logs as nexus comes up:

```
docker logs -f lab-nexus-sever_nexus_1
```

You are waiting to see:

```
-------------------------------------------------

Started Sonatype Nexus OSS 3.19.1-01

-------------------------------------------------
```

(or whatever version is running)

Once it's running, visit:

https://localhost or https://nexus.artifactory.com

### First login
Click 'Sign In'.

You will sign in using the `admin` username.

You can find the initial admin password by running:

```
cat volume/admin.password
```

On first login, you will be prompted to change the admin password.

If you like, you can enable anonymous access.


### Private Docker Repository
**For the blob storage**
- Click the config (gear) icon.
- Navigate to 'Blob Stores'.
- Create a new Blob Store of type File.  
    - You can name it whatever you like, but a good choice is `docker-private`.
- Click 'Create Blob Store'.

**For the repo itself**
- Click 'Repositories'
- Click 'Create Repository' and select 'docker (hosted)'
- Give it some name (`docker-private`)
- Check 'HTTP' and give it a valid port (`8082`)
- Under Docker Index, select 'Use Docker Hub'
- Under Storage > Blob Store, select the blob store you created earlier (`docker-private`)
- Click 'Create Repository'

**Docker Config**

Make sure you add the new url and port to the `insecure-registries` section of the docker config.

Eg:

```
  "insecure-registries": [
    "localhost:8082"
  ],
```

#### Docker Login
To connect to the repository, you will need to login using the docker cli:

```
docker login https://nexus.artifactory.com
```

You can then provide user credentials (eg. - the admin user will work).

#### Tagging private images
When you build a docker impage you'd like to push to the private registry, be sure to prefix the image name with the registry url.

Example:

```
docker build -t nexus.artifactory.com/docker-private/myimage:latest .
```

Once it has been built, you can push it to the registry:

```
docker push nexus.artifactory.com/docker-private/myimage:latest
```
