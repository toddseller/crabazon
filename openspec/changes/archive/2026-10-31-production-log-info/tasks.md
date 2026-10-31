# Tasks

## 0. Branch

- [x] 0.1 Create `production-log-info` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Log level

- [x] 1.1 Set `config.log_level = :info` in `config/environments/production.rb` and delete its comment. Run the whole suite with the README's commands; it passes.

## 2. Production image

- [x] 2.1 Build the image as `linux/amd64` and run it in production mode against a throwaway `postgres:18` with one product. Request `/`, a product page, and `/admin` signed out. Verify that `docker logs` shows each "Started", "Processing" and "Completed" line (`/admin` completes as 401, the Devise rejection behind its redirect), at most one "Rendered" line per page, and no SQL lines. Remove the images and containers.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `production-log-info`, then archive this change (no spec sync; it changes no requirements) as a second commit, `Archive production-log-info`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps, and check that a tagged request's "Started" line still reaches `docker logs`.
