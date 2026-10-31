# Tasks

## 0. Branch

- [x] 0.1 Create `devise-5` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Devise 5

- [x] 1.1 In `spec/requests/sessions_spec.rb`, expect "Invalid email or password." for a wrong password. Run it on Devise 4.9 with the README's commands and show it fails, since 4.9 says "Email".
- [x] 1.2 Run `bundle update devise --conservative`. Verify:
  - only Devise changes in the lockfile, to 5.0.4;
  - the whole suite passes;
  - no deprecation warnings remain.

## 2. Production image

- [x] 2.1 Build the image on the Mac as `linux/amd64`, and run it with `RAILS_ENV=production` against a throwaway `postgres:18` loaded with the schema, with a product that has an image. Verify:
  - the server boots with no deprecation warnings;
  - `/`, sign-in, sign-up and forgot-password return 200, and `/admin` redirects to sign-in;
  - an admin sign-in reaches `/admin`, and a wrong password shows "Invalid email or password.";
  - `Devise.secret_key` equals `ENV["SECRET_KEY_BASE"]` (printed as a boolean only).

  Then prove sessions survive in both directions with the same `SECRET_KEY_BASE`:
  - a cookie signed in on an image built from `origin/master` (Devise 4.9) reaches `/admin` with Devise 5;
  - a Devise 5 cookie reaches `/admin` on 4.9.

  Remove the images and containers.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `devise-5`, then archive this change (no spec sync; it changes no requirements) as a second commit, `Archive devise-5`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's checks.
