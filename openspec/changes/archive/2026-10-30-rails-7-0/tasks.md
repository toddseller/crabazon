# Tasks

## 0. Branch

- [x] 0.1 Create `rails-7-0` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Rails 7.0

- [x] 1.1 Pin today's email sender:
  - in `spec/requests/orders_spec.rb`, the checkout example asserts the order email's `from` is `['crabazon@toddseller.com']`;
  - in `spec/requests/registrations_spec.rb`, the sign-up example asserts the same for the welcome email.

  Run the suite on Rails 6.1 with the README's commands. It passes, recording today's sender. Then temporarily swap the two mailer files and show both assertions fail, proving they catch a change of sender. Swap them back.
- [x] 1.2 Upgrade:
  - set `gem 'rails', '~> 7.0.10'` and run `bundle update rails --conservative`;
  - `git mv app/controllers/user_mailer.rb app/mailers/user_mailer.rb`, replacing the unused copy.

  Verify:
  - the lockfile diff changes only Rails' own gems and the gems they newly need or require newer versions of;
  - `concurrent-ruby` is still 1.2.3;
  - `bin/rails zeitwerk:check` passes;
  - the suite passes, sender assertions included.
- [x] 1.3 Show the two deprecations in the suite's output (legacy connection handling, `Time#to_s(:long)`). Add `config.active_record.legacy_connection_handling = false` to `config/application.rb`, and change `orders/index.html.haml` to `to_fs(:long)`. Verify the suite passes and the only deprecation left is Devise's `devise_error_messages!`.

## 2. Production image

- [x] 2.1 Build the image on the Mac as `linux/amd64`, and run it with `RAILS_ENV=production` against a throwaway `postgres:18` loaded with the schema. Verify:
  - the startup log shows Rails 7.0.10;
  - `/` and the sign-up form return 200, and `/admin` redirects to sign-in;
  - the stylesheet and script return 200;
  - an admin sign-in reaches `/admin`.

  Then prove sessions survive: sign in against the current production image (Rails 6.1, built from `origin/master`) with the same `SECRET_KEY_BASE`, send that cookie to the 7.0 container, and get `/admin` with 200. Remove the images and containers.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `rails-7-0`, then archive this change (no spec sync; it changes no requirements) as a second commit, `Archive rails-7-0`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's checks:
  - Rails 7.0.10 in the startup log;
  - the pages and assets return 200;
  - the owner signs in, uses the cart, checks out (the email comes from `crabazon@toddseller.com`) and edits a product.
- Next change: Rails 7.0 to 7.1.
