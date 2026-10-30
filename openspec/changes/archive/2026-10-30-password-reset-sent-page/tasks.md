# Tasks

## 0. Branch

- [x] 0.1 Create `password-reset-sent-page` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. "Check your email" page

- [x] 1.1 In `spec/requests/passwords_spec.rb`, after the reset `post`, expect a redirect to `/users/password/sent`. Follow it and expect 200, the text `cara@example.com`, and no "You will receive an email" notice. Run it with the README's commands and show it fails because the redirect goes to the sign-in page.
- [x] 1.2 Add `Users::PasswordsController < Devise::PasswordsController`:
  - a `sent` action;
  - `after_sending_reset_password_instructions_path_for`, which puts `resource.email` in `flash[:reset_email]`, deletes `flash[:notice]` and returns `user_password_sent_path`.

  Route Devise's passwords to it, and add `get 'users/password/sent'` as `user_password_sent` in a `devise_scope :user` block. Add `app/views/devise/passwords/sent.html.erb` in the card, titled "Check your email". It names the address (or "your email address" when the flash is empty), says the link works for 6 hours, suggests checking spam, and links to sign-in. Run the whole suite; it passes.

## 2. Disabled buttons stay orange

- [x] 2.1 In `app/assets/stylesheets/styles/products_controller.scss`, add one rule for Bootstrap's disabled primary selectors, with their hover, focus and active states: `background-color: #e58c33; border-color: #f19833;`.

## 3. Production image

- [x] 3.1 Build the image on the Mac as `linux/amd64` and run it with `RAILS_ENV=production` against a throwaway `postgres:18` loaded with the schema, with a throwaway `SECRET_KEY_BASE`, `RAILS_SERVE_STATIC_FILES=true` and the mail delivery left failing. Verify:
  - the startup log shows Rails 7.0.10;
  - the compiled stylesheet contains the disabled rule;
  - a screenshot of the forgot-password page with its button disabled (through a test page or headless Chromium's JavaScript) shows it orange;
  - a screenshot of `/users/password/sent` with an empty flash shows the card with "your email address".

  The mail server can't be reached from the container, so the full send-and-redirect path is covered by the request spec and by the owner's check after deploy. Remove the image and containers.

## 4. Review

- [x] 4.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `password-reset-sent-page`, then archive this change (with spec sync into `customer-accounts`) as a second commit, `Archive password-reset-sent-page`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's checks.
- Next change: Rails 7.0 to 7.1.
