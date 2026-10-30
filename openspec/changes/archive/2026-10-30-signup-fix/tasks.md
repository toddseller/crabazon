# Tasks

## 0. Branch

- [x] 0.1 Create `signup-fix` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Sign-up

- [x] 1.1 Write `spec/requests/registrations_spec.rb`:
  - A successful sign-up creates a user with the name and email, signs them in, and redirects to `/index`. Following the redirect returns 200. One welcome email goes to the address.
  - A taken email creates no user, sends no email, and shows "Email has already been taken".
  - A mismatched confirmation creates no user, sends no email, and shows "Password confirmation doesn't match Password".
  - With `role: 'admin'` in the params, the account's `role` is nil and `GET /admin` redirects to `/index`.

  Delete the pending sign-up example from `spec/requests/sessions_spec.rb`. Run the new file with the README's commands and show it failing on the `devise_parameter_sanitizer.for` NoMethodError.
- [x] 1.2 Rewrite `app/controllers/users/registrations_controller.rb`:
  - `create` calls `super` with a block that, for a saved user, sets `session[:cart] = {}` and sends the welcome email;
  - `configure_sign_up_params` uses `devise_parameter_sanitizer.permit(:sign_up, keys: [:name])`;
  - `after_sign_up_path_for` returns `index_path`;
  - the commented-out generator stubs and the `after_sign_in_path_for` override are removed.

  Delete `app/controllers/registrations_controller.rb`. Verify `registrations_spec.rb` passes, and that the full suite passes with no pending examples.

## 2. Review

- [x] 2.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `signup-fix`, then archive this change (syncing `customer-accounts` into `openspec/specs/`) as a second commit, `Archive signup-fix`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps.
- Production check:
  - the owner signs up with a throwaway address, lands on the index page signed in, and receives the welcome email;
  - with approval, delete that test account.
- Next changes: reject zero or negative cart quantities; then the Ruby step of the upgrade.
