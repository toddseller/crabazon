# Design

## Context

- `devise_for :users` routes sign-up to `Users::RegistrationsController`. It has `before_action :configure_sign_up_params`, which calls the removed `devise_parameter_sanitizer.for`, so every `POST /users` fails before `create` runs. The `create` behind it bypasses Devise:
  - it builds the user from `params[:user].permit(:name, :email, :password)`, ignoring the confirmation;
  - it never signs the user in;
  - it redirects to `after_sign_in_path_for`, overridden to return the result of `sign_in`, not a path.
- The index page reads `session[:cart][...]` for signed-in users, so a signed-in user with no cart in the session gets an error page. Sign-in sets `session[:cart] = {}` for that reason.
- `User` uses Devise's `validatable` with `password_length: 6..72`. `:confirmable` isn't enabled, so a new account can sign in at once.
- The sign-up form (`devise/registrations/new.html.erb`) already sends name, email, password and confirmation, and shows Devise's error messages.
- `app/controllers/registrations_controller.rb` defines a second `RegistrationsController` that no route uses.
- Admin pages check `users.role == 'admin'` (the admin-access spec).

## Goals / Non-Goals

**Goals:**
- Use Devise's own sign-up, with the fewest overrides.
- Make sure no sign-up request can set `role`.

**Non-Goals:**
- Email confirmation, captchas or rate limiting of sign-ups.
- Moving the welcome email to a background job. There's no job queue, and checkout already sends its email inline.

## Decisions

1. **Devise's `create` with a block, not a custom `create`.** `super do |user| ... end` runs after Devise saves the user. When the user was saved, the block sets `session[:cart] = {}` and sends `UserMailer.welcome_email(user).deliver_now`. Devise then signs the user in and redirects, or re-renders the form with errors. Alternative: fix the custom `create` in place. That keeps its bugs (ignored confirmation, no sign-in) and duplicates what Devise does.

2. **Permit only `name` on top of Devise's defaults:** `devise_parameter_sanitizer.permit(:sign_up, keys: [:name])`. Devise's defaults are email, password and password confirmation. Anything else, `role` included, is dropped. A spec sends `role=admin` and checks the account isn't an admin and is refused `/admin`.

3. **`after_sign_up_path_for` returns `index_path`,** where a customer lands after signing in. The broken `after_sign_in_path_for` override goes.

4. **Delete `app/controllers/registrations_controller.rb`.** Nothing routes to it, and its name makes it look like the live controller.

5. **Specs:**
   - `spec/requests/registrations_spec.rb` covers each scenario in the spec, and follows the redirect to check the index page renders.
   - The pending example in `sessions_spec.rb` is removed rather than un-pended, since the new file covers sign-up fully.
   - The specs are written first and shown failing on the `devise_parameter_sanitizer.for` error.

## Risks / Trade-offs

- [SMTP fails in production during sign-up] → The account is saved first, but the visitor sees an error page, because production raises delivery errors. Checkout already has the same exposure. The deploy check sends one real welcome email.
- [Bots create accounts once sign-up works] → Accounts get no privileges: no admin role, and orders are only theirs. Revisit if junk accounts appear.

## Migration Plan

1. Merge; CI runs the specs.
2. Deploy on the app host with the README's build steps.
3. Production check: the owner signs up with a throwaway address, sees the index page while signed in, and receives the welcome email. Then the test account is deleted (`User.find_by(email: ...).destroy` in `rails runner`, with the owner's approval).
4. Rollback: the README's rollback steps.
