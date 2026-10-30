# Tasks

## 0. Branch

- [x] 0.1 Create `rails-7-1` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Devise's error partial

- [x] 1.1 In `spec/requests/passwords_spec.rb`, add an example: asking for a reset with an unknown email sends no email and shows "Email not found". Run it with the README's commands on Rails 7.0. It passes, recording today's output. Then temporarily remove `devise_error_messages!` from `passwords/new.html.erb` and show it fails. Restore it.
- [x] 1.2 Replace `devise_error_messages!` with `render "devise/shared/error_messages", resource: resource` in passwords new and edit, and in registrations new and edit. Delete `devise/confirmations/new.html.erb` and `devise/unlocks/new.html.erb`. Run the whole suite; it passes with no `devise_error_messages!` deprecation.

## 2. Rails 7.1

- [x] 2.1 Upgrade:
  - set `gem 'rails', '~> 7.1.6'` and run `bundle update rails --conservative`;
  - in `config/application.rb`, replace the `legacy_connection_handling` line with `config.active_support.cache_format_version = 7.1`.

  Verify:
  - the lockfile diff changes only Rails' own gems and the gems they newly need or require newer versions of;
  - `concurrent-ruby` is still 1.2.3, and Devise 4.9.3;
  - `bin/rails zeitwerk:check` passes;
  - the suite passes, and the only deprecation left is Devise's `Rails.application.secrets` warning.

## 3. Production image

- [x] 3.1 Build the image on the Mac as `linux/amd64`, and run it with `RAILS_ENV=production` against a throwaway `postgres:18` loaded with the schema. Verify:
  - the startup log shows Rails 7.1.6;
  - `/`, sign-in, sign-up, forgot-password and the stylesheet return 200, and `/admin` redirects to sign-in;
  - an admin sign-in reaches `/admin`.

  Then prove sessions survive in both directions with the same `SECRET_KEY_BASE`:
  - a cookie signed in on an image built from `origin/master` (7.0) reaches `/admin` on 7.1;
  - a cookie signed in on 7.1 reaches `/admin` on 7.0.

  Remove the images and containers, and the earlier trial's leftovers (`spike-ruby`, `spike-db`, `spike-net`, the `spike-gems` volume and the scratchpad `spike` folder).

## 4. Review

- [x] 4.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `rails-7-1`, then archive this change (no spec sync; it changes no requirements) as a second commit, `Archive rails-7-1`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's checks.
- Next change: Rails 7.1 to 7.2.
