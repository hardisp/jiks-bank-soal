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

sudo chown -R 70:70 backend/storage/logs/laravel.log
sudo chmod 600 backend/storage/logs/laravel.log

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

## Install Filament

```sh
docker compose \
  --env-file deployment/.env \
  -f deployment/compose.yaml \
  exec --user 1000:1000 backend \
  sh -lc '
    export COMPOSER_HOME=/tmp/composer-home
    export COMPOSER_CACHE_DIR=/tmp/composer-cache

    composer require filament/filament:"^5.12" --no-interaction
  '
```

## Set the first user as Admin

Change env var ADMIN_EMAIL and run:

```sh
docker compose \
  --env-file deployment/.env \
  -f deployment/compose.yaml \
  exec backend \
  php artisan db:seed --class=AdminUserSeeder
```

## Make Migration

Running the `artisan`` thru `UID/GID 1000:1000`, not a root (for file permission issue)

```sh
docker compose \
  --env-file deployment/.env \
  -f deployment/compose.yaml \
  exec --user 1000:1000 backend \
  php artisan make:migration add_role_to_users_table --table=users
```

## Make Policy inside docker

```sh
docker compose \
  --env-file deployment/.env \
  -f deployment/compose.yaml \
  exec --user 1000:1000 backend \
  php artisan make:policy UserPolicy --model=User
```

Jika sudah dibuat dan lupa set user permission, jalankan ini:

```sh 
docker compose \
  --env-file deployment/.env \
  -f deployment/compose.yaml \
  exec --user root backend \
  chown -R 1000:33 app/Policies
```

Ubah `app/Policies` ke path yang dituju

**Artinya**:
- 1000: UID host user.
- 33: GID www-data.
- -R: berlaku untuk seluruh isi folder, termasuk file dan subfolder.

### Verifikasi

```sh
docker compose \                                                                                                                  hardi@homeserver
  --env-file deployment/.env \
  -f deployment/compose.yaml \
  exec backend \
  ls -la app/Policies
```

## Install Laravel Sacntum

```sh
docker compose \
  --env-file deployment/.env \
  -f deployment/compose.yaml \
  exec --user 1000:33 backend \
  composer require laravel/sanctum
```

```sh
docker compose \
  --env-file deployment/.env \
  -f deployment/compose.yaml \
  exec backend \
  sh -lc '
    composer show laravel/sanctum
    php artisan list --raw | grep install:api
  '
```

```sh
docker compose \
  --env-file deployment/.env \
  -f deployment/compose.yaml \
  exec --user 1000:33 backend \
  php artisan install:api
```