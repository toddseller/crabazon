# Tasks

## 0. Branch

- [x] 0.1 Create `remove-committed-secrets` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Remove the committed keys

- [x] 1.1 Add `spec/initializers/devise_spec.rb` asserting `Devise.secret_key` equals `Rails.application.secret_key_base`. Run it with the README's commands and show it fails because of the literal key.
- [x] 1.2 Remove the `config.secret_key` line from `config/initializers/devise.rb` (keep Devise's explanatory comment above it), and delete `config/secrets.yml`. Run the whole suite; it passes. Check that `git grep -nE "secret_key(_base)?\s*[:=]\s*['\"]?[0-9a-f]{32}"` finds nothing.

## 2. Production image

- [x] 2.1 Build the image on the Mac as `linux/amd64` and run it with `RAILS_ENV=production` against a throwaway `postgres:18` loaded with the schema. Verify:
  - without `SECRET_KEY_BASE`, the server refuses to start with Rails' missing `secret_key_base` error;
  - with a throwaway `SECRET_KEY_BASE`, the startup log shows Rails 7.0.10, `/` returns 200, and `/admin` redirects to sign-in;
  - `Devise.secret_key` equals `ENV["SECRET_KEY_BASE"]` (printed as a boolean only).

  Then prove sessions survive: sign in on an image built from `origin/master` with the same throwaway `SECRET_KEY_BASE`, send that cookie to the new container, and get `/admin` with 200. Remove the images and containers.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `remove-committed-secrets`, then archive this change (no spec sync; it changes no requirements) as a second commit, `Archive remove-committed-secrets`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's checks.
- Next change: Rails 7.0 to 7.1.
