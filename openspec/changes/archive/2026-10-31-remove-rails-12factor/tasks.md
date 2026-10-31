# Tasks

## 0. Branch

- [x] 0.1 Create `remove-rails-12factor` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Remove the gem

- [x] 1.1 Delete `gem 'rails_12factor'` and run `bundle install`. Check the lockfile drops exactly `rails_12factor`, `rails_serve_static_assets` and `rails_stdout_logging`. Build the production image as `linux/amd64` and run it against a throwaway `postgres:18`, to show what breaks:
  - the stylesheet still returns 200, since Rails' file server is on by default;
  - `docker logs` shows no request lines, because the log goes to `log/production.log` inside the container.
- [x] 1.2 In `production.rb`:
  - delete the `serve_static_files` line and its comment;
  - replace the commented-out logger with `STDOUT.sync = true` and `config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)`;
  - delete the second `log_level` line and the `log_formatter` line.

  Delete `config.serve_static_files = true` and `config.static_cache_control = ...` from `test.rb`, with their comment; Rails removed both settings in 5.1. Run the whole suite with the README's commands; it passes.

## 2. Production image

- [x] 2.1 Rebuild and run the image against the throwaway database with one product. Verify:
  - `/`, the stylesheet, the script and the logo return 200;
  - `docker logs` shows each request's "Started" line and SQL lines (debug level) within a second of the request, in the same plain format as an image built from `origin/master`;
  - a session cookie from the `origin/master` image still works on the new one.

  Remove the images and containers.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `remove-rails-12factor`, then archive this change (no spec sync; it changes no requirements) as a second commit, `Archive remove-rails-12factor`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps; check that the site's styles and images load and that `docker logs` shows requests.
