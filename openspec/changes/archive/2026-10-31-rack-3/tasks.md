# Tasks

## 0. Branch

- [x] 0.1 Create `rack-3` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Rack 3

- [x] 1.1 Run `bundle update thin rack rack-session rackup --conservative`. Verify:
  - the lockfile diff moves only Thin, Rack, `rack-session` and `rackup`, and drops WEBrick;
  - `bin/rails zeitwerk:check` passes;
  - the suite passes with the README's commands, with no new deprecations.

  Rack 3.1 renamed status 422's symbol from `:unprocessable_entity` to `:unprocessable_content`. The RSpec matcher only knows the new name, and Rack warns on the old one, so rename it in `ApplicationController#refuse` and `spec/requests/cart_spec.rb`.
- [x] 1.2 Build the image and run it with the current compose command, with no server named. Show it fails at boot with "Could not find a server gem". Then add `-u thin` to the command in `docker-compose.yml`.

## 2. Production image

- [x] 2.1 Build the image on the Mac as `linux/amd64`, and run it with `RAILS_ENV=production` and the new command against a throwaway `postgres:18` with an admin, a customer and a product with an image. Verify:
  - the startup log names Thin 2.0.1, and the app reports Rack 3.2.8;
  - `/`, sign-in, the stylesheet and the script return 200, and `/admin` redirects to sign-in;
  - a customer signs in, adds to the cart over AJAX with the CSRF header, and checks out;
  - an admin creates and updates a product through the forms;
  - a session cookie from an image built from `origin/master` reaches `/admin` on the new image, and the reverse;
  - the old image starts with the new `-u thin` command.

  Remove the images and containers.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `rack-3`, then archive this change (no spec sync; it changes no requirements) as a second commit, `Archive rack-3`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's checks.
