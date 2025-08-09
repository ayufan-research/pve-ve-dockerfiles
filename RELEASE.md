## Buy me a Coffee

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Y8Y8GCP24)

If you found it useful :)

## Use docker image

For starting quickly all images are precompiled and hosted at https://hub.docker.com/r/ayufan/proxmox-ve/tags.

```bash
docker pull ayufan/proxmox-ve:#{GIT_TAG_NAME}
```

## Run as a docker container

```bash
wget https://raw.githubusercontent.com/ayufan-research/pve-ve-dockerfiles/refs/heads/master/docker-compose.yml
```

Adapt `docker-compose.yml` to your environment.

**Run container:**

```
TAG=#{GIT_TAG_NAME} docker-compose up -d
```

**Configure root password:**

```bash
docker-compose exec pve passwd
```

Then login to `https://<ip>:8006/` with `root`.
