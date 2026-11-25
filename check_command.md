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
