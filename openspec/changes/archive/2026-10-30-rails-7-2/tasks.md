# Tasks

## 0. Branch

- [x] 0.1 Create `rails-7-2` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Tests keep raising

- [x] 1.1 In `config/environments/test.rb`, set `config.action_dispatch.show_exceptions = :none`. Run the whole suite on Rails 7.1 with the README's commands; it passes.

## 2. Rails 7.2

- [x] 2.1 Upgrade:
  - set `gem 'rails', '~> 7.2.3'` and run `bundle update rails --conservative`;
  - run the suite and show it stops at DatabaseCleaner's `schema_migration` error;
  - run `bundle update database_cleaner-active_record --conservative`.

  Verify:
  - the lockfile diff changes only Rails' own gems, `concurrent-ruby`, `useragent` and `database_cleaner-active_record`;
  - `bin/rails zeitwerk:check` passes;
  - the suite passes with no deprecation warnings.

  Then temporarily raise inside `index/index.html.haml`, and show that the storefront spec gets a 500 page, because Better Errors catches the exception. Restore the view.
- [x] 2.2 Move `better_errors` and `binding_of_caller` from the `:development, :test` group into a `:development` group. Repeat the broken-view check and show the spec now fails with the raised error itself. Restore the view, and run the whole suite; it passes.

## 3. Production image

- [x] 3.1 Build the image on the Mac as `linux/amd64`, and run it with `RAILS_ENV=production` against a throwaway `postgres:18` loaded with the schema, with a product that has an image. Verify:
  - the startup log shows Rails 7.2.3.2;
  - `/`, sign-in, sign-up, forgot-password and the stylesheet return 200, and `/admin` redirects to sign-in;
  - an admin sign-in reaches `/admin`;
  - `Devise.secret_key` equals `ENV["SECRET_KEY_BASE"]` (printed as a boolean only).

  Then prove sessions survive in both directions with the same `SECRET_KEY_BASE`:
  - a cookie signed in on an image built from `origin/master` (7.1) reaches `/admin` on 7.2;
  - a 7.2 cookie reaches `/admin` on 7.1.

  Remove the images and containers.

## 4. Review

- [x] 4.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `rails-7-2`, then archive this change (no spec sync; it changes no requirements) as a second commit, `Archive rails-7-2`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's checks.
- Next change: Rails 7.2 to 8.0.
