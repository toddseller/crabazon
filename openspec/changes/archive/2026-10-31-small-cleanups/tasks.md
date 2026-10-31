# Tasks

## 0. Branch

- [x] 0.1 Create `small-cleanups` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Admin product table

- [x] 1.1 In `spec/requests/admin_spec.rb`, add a failing test: on `/admin`, the header row has as many cells as a product row. Show it fail (4 against 6), add two empty `%th` to `app/views/admin/index.html.haml`, and run the whole suite; it passes.

## 2. Deploy docs and compose

- [x] 2.1 In `README.md`:
  - add `docker compose run --rm web bin/rails db:migrate` between `docker compose build web` and `docker compose up -d web`, with one sentence saying it does nothing when no migration is pending;
  - in the rollback steps, say that after a deploy that ran a migration, `docker compose run --rm web bin/rails db:rollback` comes first, while the new image is still current.
- [x] 2.2 Delete `version: "3.8"` from `docker-compose.yml`. Check with `docker compose config -q` (using a throwaway `.env` if none exists) that the file is valid and the warning is gone.

## 3. Rendered page

- [x] 3.1 Build the image as `linux/amd64`, run it in production mode against a throwaway `postgres:18` with an admin and a product, and take a headless Chrome screenshot of `/admin`. The header underline spans the whole table. Remove the images and containers.

## 4. Review

- [x] 4.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `small-cleanups`, then archive this change (no spec sync; it changes no requirements) as a second commit, `Archive small-cleanups`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's new steps, and the owner checks `/admin`.
