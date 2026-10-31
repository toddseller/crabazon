# Tasks

## 0. Branch

- [x] 0.1 Create `rails-8-1` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Rails 8.1

- [x] 1.1 Upgrade: set `gem 'rails', '~> 8.1.4'` and run `bundle update rails --conservative`. Run the suite with the README's commands, and show it passes with the `to_time_preserves_timezone` deprecation and Devise's four route warnings.
- [x] 1.2 Delete `config.active_support.to_time_preserves_timezone = :zone` from `config/application.rb`. Verify:
  - the lockfile diff changes only Rails' own gems, `action_text-trix` and `benchmark`;
  - `bin/rails zeitwerk:check` passes;
  - the suite passes, and the only deprecations left are Devise's route warnings.

## 2. Production image

- [x] 2.1 Build the image on the Mac as `linux/amd64`, and run it with `RAILS_ENV=production` against a throwaway `postgres:18` loaded with the schema, with a product that has an image. Verify:
  - the startup log shows Rails 8.1.4;
  - `/`, sign-in, sign-up, forgot-password, the stylesheet and the script return 200, and `/admin` redirects to sign-in;
  - an admin sign-in reaches `/admin`;
  - `Devise.secret_key` equals `ENV["SECRET_KEY_BASE"]` (printed as a boolean only).

  Then prove sessions survive in both directions with the same `SECRET_KEY_BASE`:
  - a cookie signed in on an image built from `origin/master` (8.0) reaches `/admin` on 8.1;
  - an 8.1 cookie reaches `/admin` on 8.0.

  Remove the images and containers.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `rails-8-1`, then archive this change (no spec sync; it changes no requirements) as a second commit, `Archive rails-8-1`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's checks.
- Next change: Devise 5.
