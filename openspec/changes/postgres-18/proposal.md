# Proposal

## Why

Crabazon's database runs on PostgreSQL 11.17 on Debian 10 at <old-db-host>, both past end of life, and the app connects to it as a superuser, with that password in `.env`. The new PostgreSQL 18 server at <new-db-host> already has a `crabazon` database and a `crabazon_app` login, and the app host's `~/.pgpass` (mode 600) holds its password. MMDb and tsr moved to the same server the same way.

## What Changes

- `docker-compose.yml` mounts a password file into the `web` container, read-only, and points libpq at it with `PGPASSFILE`. The host path comes from `PGPASS_FILE` in `.env` and defaults to `/dev/null`, so a setup without it works as before, with the password in `DATABASE_URL`.
- `README.md` gets a short deployment section: `PGPASS_FILE`, the password-less `DATABASE_URL`, and a warning not to rebuild the image on the app host until the Ruby and Rails upgrade replaces its Debian 10 base.
- A trial copy on the new server, run with the existing image, before merging: it is the only proof that the image's libpq 11 and Rails 6.1 work against PostgreSQL 18.
- The cutover (stop `web`, a fresh dump and restore, the server's `.env`, `docker compose up -d web`) follows the merge as an operational step. The old server stays untouched as the rollback.

## Capabilities

### New Capabilities

- `database-access`: how the app reaches its database: as a login limited to that database, with the password from a file outside the repository.

### Modified Capabilities

None.

## Impact

- `docker-compose.yml` (mount and environment), `README.md`.
- No app code, gem or image change. The `pg` gem uses libpq, which reads `PGPASSFILE` itself.
- Deploy: `docker compose up -d web` recreates the container from the existing `crabazon-web` image (built 2024-03-24); nothing rebuilds it. The container holds no state beyond `tmp/` and `log/`.
- Out of scope: the Ruby and Rails upgrade, which follows as its own changes and replaces the image.
