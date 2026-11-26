# Dev Command

## Generate PG Password and .env

```sh
cd /data/volumes/projects/bank-soal

POSTGRES_PASSWORD=$(openssl rand -hex 32)

sed "s/replace-with-generated-secret/${POSTGRES_PASSWORD}/" \
  deployment/.env.example > deployment/.env

chmod 600 deployment/.env
```

## Make directory

```sh
mkdir -p \
  deployment/data/postgres \
  deployment/data/backups
```

## If PG has permission issue

```sh
sudo chown -R 70:70 deployment/data/postgres
sudo chmod 700 deployment/data/postgres
```

## Install laravel

Running the composer thru `UID/GID 1000:1000`, not a root

```sh
docker compose \
  --env-file deployment/.env \
  -f deployment/compose.yaml \
  exec --user 1000:1000 backend \
  sh -lc '
    export COMPOSER_HOME=/tmp/composer-home
    export COMPOSER_CACHE_DIR=/tmp/composer-cache

    composer create-project laravel/laravel . "^13.0" --no-interaction
  '
```
