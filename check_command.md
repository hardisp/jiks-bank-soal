# Check command

## Check free PORT

```sh
sudo ss -tulnp | grep :5432
```

## Check docker config

```sh
docker compose \
  --env-file deployment/.env \
  -f deployment/compose.yaml \
  config
```

## Check database connection (PGSQL)

```sh
docker compose \
	--env-file deployment/.env \
	-f deployment/compose.yaml \
	exec postgres sh -c \
	'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT version();"'
```

## Check PHP Extension

```sh
docker compose \
  --env-file deployment/.env \
  -f deployment/compose.yaml \
  exec backend php -m
```

## Check NGINX

```sh
docker compose \
  --env-file deployment/.env \
  -f deployment/compose.yaml \
  exec backend-nginx nginx -t
```

