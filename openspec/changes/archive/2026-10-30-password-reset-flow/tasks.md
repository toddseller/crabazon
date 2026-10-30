# Tasks

## 0. Branch

- [x] 0.1 Create `password-reset-flow` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Reset lands on the index page

- [x] 1.1 In `spec/requests/passwords_spec.rb`, submit the new password with `headers: { 'HTTP_REFERER' => link }`, as a browser does. Expect a redirect to `/index`, then follow it and expect 200 with the customer signed in. Run it with the README's commands and show it fails, redirecting to the reset link as in the production log.
- [x] 1.2 Replace `ApplicationController#after_sign_in_path_for` with sign-in's rule, keyed on `resource` (admins to `admin_index_path`, others to `index_path`), and delete the copy in `Users::SessionsController`. Run the reset spec and show it now fails on `/index` with the production error, `undefined method '[]' for nil`.
- [x] 1.3 In `ApplicationController#cart`, add `session[:cart] ||= {} if user_signed_in?` before the cart is read. Run the whole suite; it passes, including the sessions specs for both landing pages.

## 2. Account pages share the sign-in card

- [x] 2.1 Add `app/views/devise/shared/_card.html.erb` with the frame from `devise/sessions/new.html.erb`: container, row, `.sign-in` column, logo, `h2.text-center` with the `title` local, `yield`, and the Devise links. Move sign-in and sign-up into it; their forms stay as they are.
- [x] 2.2 Render `devise/passwords/new.html.erb` and `edit.html.erb` in the card, with titles "Forgot your password?" and "Change your password". Give their fields `.form-group` and `.form-control`, and their buttons `btn btn-primary` with `id="sign-in-button"`. Keep the hidden token field, `devise_error_messages!`, autofocus and the minimum-length hint.
- [x] 2.3 Delete `app/views/devise/sessions/new.html.haml`. Run the whole suite; it passes.

## 3. Production image

- [x] 3.1 Build the image on the Mac as `linux/amd64` and run it with `RAILS_ENV=production` against a throwaway `postgres:18` loaded with the schema, with a throwaway `SECRET_KEY_BASE` and `RAILS_SERVE_STATIC_FILES=true`. Verify:
  - the startup log shows Rails 7.0.10;
  - sign-in, sign-up and forgot-password return 200, and so does change-password with a real token;
  - screenshots of all four pages show the same card;
  - a reset submitted with a `Referer` header redirects to `/index`;
  - an admin sign-in lands on `/admin`;
  - after signing in with "Remember Me", a request carrying only the remember-me cookie (no session cookie) gets `/` with 200.

  Remove the image and containers.

## 4. Review

- [x] 4.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `password-reset-flow`, then archive this change (with spec sync into `customer-accounts`) as a second commit, `Archive password-reset-flow`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's checks.
- Next change: Rails 7.0 to 7.1.
