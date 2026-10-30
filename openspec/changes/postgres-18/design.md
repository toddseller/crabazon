# Design

## Context

- `docker-compose.yml` runs `web` with `env_file: .env`, and compose reads the same root `.env` for interpolation, so `PGPASS_FILE` and `DATABASE_URL` live in one file (unlike tsr's two). Production uses `url: <%= ENV['DATABASE_URL'] %>` through the `pg` gem, which is libpq; libpq reads the file named by `PGPASSFILE` only when the URL has no password.
- On the app host, `~/crabazon` is a plain checkout of `master`. Deploys are manual: `git pull`, then `docker compose up -d`. The `crabazon-web` image was built on 2024-03-24 from `ruby:2.6.7` (Debian 10, libpq 11) and has never been rebuilt. `docker diff` shows the container writes only `tmp/` and `log/`, and products store image URLs, not files, so recreating the container loses nothing.
- Rebuilding the image would likely fail: Debian 10's apt repositories have moved to archive.debian.org, and the Dockerfile runs `apt-get update`.
- There is no runnable test suite: the image is built `--without development test`, and the Mac's Ruby is 3.4, which the locked Rails 6.1 and bundler 2.2 don't support. Making the suite run again is the first step of the Ruby and Rails upgrade.
- Rails runs no DDL at boot, so `crabazon_app` needs ownership only for future migrations. It still owns everything, as `tsr_app` does, so `db:migrate` works after the upgrade.

## Goals / Non-Goals

**Goals:**
- The app on PostgreSQL 18 as `crabazon_app`, with its password only in the app host's `~/.pgpass`.
- No rebuild of the image as part of this change.

**Non-Goals:**
- The Ruby and Rails upgrade, the Dockerfile's Debian base, and the `DATABASE_URL` build argument in the Dockerfile (once the URL has no password, future builds no longer bake one in).
- Retiring the old server; it stays as the rollback.
- Docker secrets or another secret store; one file on one host doesn't need them.

## Decisions

1. **Mount `${PGPASS_FILE:-/dev/null}` at `/run/secrets/pgpass`, read-only, and set `PGPASSFILE=/run/secrets/pgpass`.** The same as MMDb and tsr. `/dev/null` always exists, so without `PGPASS_FILE` Docker mounts an empty file instead of creating a directory at a missing path, and libpq never opens it while the URL holds a password. Alternative: a production-only override file kept out of git, which would hide the production setup from the repository.

2. **Trial before merge, with the existing image.** The image's libpq 11 against a PostgreSQL 18 server (SCRAM authentication, `.pgpass`) and Rails 6.1's catalog queries on 18 are the only untested links, and the image can't be rebuilt to try anything else. On the app host, `docker compose run --rm` starts a one-off `web` container on a spare port with the password-less `DATABASE_URL`, the mount and `PGPASSFILE` passed on the command line, so the live container is untouched. It uses compose rather than `docker run --env-file` because `.env` has `KEY = 'value'` lines, which compose parses and `docker run` does not.

3. **No automated test for the compose file.** Nothing can run RSpec today (see Context), and adding a test that never runs proves nothing. The compose wiring is checked with `docker compose config` on the Mac (the mount resolves to `/dev/null` without `PGPASS_FILE` and to the path with it); the trial proves the mechanism with the real image; the deploy with `PGPASS_FILE` unset proves the fallback; the cutover proves the wiring end to end.

4. **Restore with `--no-owner --no-acl --role=crabazon_app` into a database `OWNER crabazon_app`,** using PostgreSQL 18's tools on the Mac (`/opt/homebrew/opt/libpq/bin`), as tsr did. The old superuser's ownership and grants don't follow the data.

## Risks / Trade-offs

- [Someone runs `docker compose up --build` or `docker compose build` on the app host] → the build most likely fails at `apt-get update`; the old image survives, but the deploy stalls. The README warns against it until the upgrade lands.
- [libpq 11 or Rails 6.1 misbehave on PostgreSQL 18] → the trial finds out before anything merges; if it fails, the move waits for the upgrade's new image.
- [`~/.pgpass` deleted or its mode loosened on the app host] → libpq ignores a file others can read and the app fails to connect at boot, loudly; the cutover check catches it.
- [Orders or sign-ups written between the trial and the cutover] → the cutover takes a fresh dump with `web` stopped.
- [The old superuser password stays in the 2024 image's history and the Mac's `.env`] → after the cutover, remove it from the Mac's `.env`; rotate it on the old server once nothing else there uses it.

## Migration Plan

1. Trial (before merge, with the owner's approval): drop and recreate `crabazon` on the new server `OWNER crabazon_app`, dump the old `crabazon` and restore it, compare row counts per table and ownership, then on the app host run the existing image once with the password-less URL and the mount, and check the home page, a sign-in and `SELECT current_user`.
2. Merge, then deploy on the app host: `git pull`, `docker compose up -d web`. `PGPASS_FILE` is unset, so the recreated container still uses the old server; check the site.
3. Cutover: stop `web`; drop and recreate `crabazon` on the new server and rerun the trial's dump and restore; compare counts and ownership. In `~/crabazon/.env` set `PGPASS_FILE=/home/<user>/.pgpass` and `DATABASE_URL=postgres://crabazon_app@<new-db-host>:5432/crabazon`; check `docker compose config` shows the mount; `docker compose up -d web`; verify the site through the tunnel, a sign-in, `SELECT current_user` and row counts.
4. Afterwards: remove the old password from the Mac's `.env` and delete the dump.
5. Rollback: restore the old `DATABASE_URL`, unset `PGPASS_FILE`, `docker compose up -d web`. The old server is untouched; anything written after the cutover would have to be copied back by hand.
