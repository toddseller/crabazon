# Tasks

## 0. Branch

- [x] 0.1 Create `password-reset-link` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Password reset

- [x] 1.1 Add `spec/requests/passwords_spec.rb`:
  - create a customer;
  - `POST /users/password` with their email, and expect one email to them from `crabazon@toddseller.com`;
  - take the link from the email, check it starts with `http://www.example.com/users/password/edit?reset_password_token=`, and open its path;
  - `PUT /users/password` with the token and a new, confirmed password;
  - sign out, then check the new password signs in and the old one doesn't.

  Run it with the README's commands and show it fails with "Missing host to link to!".
- [x] 1.2 Set `config.action_mailer.default_url_options = { host: 'www.example.com' }` in `test.rb`. Run the spec and show it now fails only on the sender.
- [x] 1.3 Set `config.mailer_sender = 'Crabazon <crabazon@toddseller.com>'` in `config/initializers/devise.rb`. Run the whole suite; it passes.
- [x] 1.4 Set `config.action_mailer.default_url_options = { host: 'crabazon.us', protocol: 'https' }` in `production.rb`.
- [x] 1.5 Delete `app/controllers/users/passwords_controller.rb`. Check that `bin/rails routes` still sends `/users/password` to `devise/passwords`, and run the whole suite; it passes, the reset spec included.

## 2. Production image

- [x] 2.1 Build the image on the Mac as `linux/amd64` and run it with `RAILS_ENV=production` against a throwaway `postgres:18` loaded with the schema, with a throwaway `SECRET_KEY_BASE`. Verify:
  - the startup log shows Rails 7.0.10, and `/users/password/new` returns 200;
  - in `rails runner`, rendering the reset email for a new user gives a link starting with `https://crabazon.us/users/password/edit?reset_password_token=`, and a sender of `crabazon@toddseller.com`.

  Remove the image and containers.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `password-reset-link`, then archive this change (with spec sync into `customer-accounts`) as a second commit, `Archive password-reset-link`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's checks.
- Next change: Rails 7.0 to 7.1.
