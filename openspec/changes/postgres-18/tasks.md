# Tasks

## 0. Branch

- [x] 0.1 Create `postgres-18` from a freshly fetched `origin/master`, and check with `git status` that you're on that branch and this change's artifacts came along.

## 1. Trial on the new server (operational, each step with the owner's approval)

- [x] 1.1 With the new server's admin login and PostgreSQL 18's tools (`/opt/homebrew/opt/libpq/bin`), check whether `crabazon` on <new-db-host> holds any tables, then drop and recreate it `OWNER crabazon_app`; verify `\l crabazon` shows that owner.
- [x] 1.2 Dump the old `crabazon` from <old-db-host> into the scratchpad and restore it with `--no-owner --no-acl --role=crabazon_app`; verify every table's row count matches the old database and every table, sequence and the database itself is owned by `crabazon_app`.
- [x] 1.3 On the app host in `~/crabazon`, run the existing image once with `docker compose run --rm -p 5667:5666` and `-e DATABASE_URL=postgres://crabazon_app@<new-db-host>:5432/crabazon -e PGPASSFILE=/run/secrets/pgpass -v /home/<user>/.pgpass:/run/secrets/pgpass:ro`, starting `rails s` on port 5666; verify the home page, a category, a product page and a sign-in work on port 5667, and that `rails runner` prints `crabazon_app` for `SELECT current_user`. Stop the one-off container and check `crabazon-web-1` is still serving.

## 2. Password file for the web container

- [x] 2.1 In `docker-compose.yml`, give `web` a read-only volume `${PGPASS_FILE:-/dev/null}:/run/secrets/pgpass:ro` and `PGPASSFILE=/run/secrets/pgpass` in its `environment`, with a one-line why comment; verify `docker compose config` resolves the mount's source to `/dev/null` with `PGPASS_FILE` unset and to a scratch path with `PGPASS_FILE=<path>` set in the shell. No automated test (design decision 3).
- [x] 2.2 Add a short Deployment section to `README.md`: deploys are `git pull` and `docker compose up -d web`; `PGPASS_FILE` in `.env` names the host password file and `DATABASE_URL` then omits the password; the database is PostgreSQL 18; don't rebuild the image on the app host until the Ruby and Rails upgrade replaces its Debian 10 base. Verify the section renders and its commands match 2.1.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit on `postgres-18` and open the PR with `gh`; the owner merges.
- Deploy on the app host (`git pull`, `docker compose up -d web`, never `--build`) with `PGPASS_FILE` unset, and check the site still serves from the old server.
- Cutover as in design.md's Migration Plan, with the owner's approval for the `.env` edit and the drop and restore; verify through the tunnel, a sign-in, `SELECT current_user` and row counts.
- Afterwards: remove the old password from the Mac's `.env`, delete the dump, and archive the change with the delta synced into `openspec/specs/database-access/spec.md`.
- Then start the Ruby and Rails upgrade as its own change, beginning with a test suite that runs against `postgres:18`.
