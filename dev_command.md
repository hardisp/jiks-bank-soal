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