# Design

## Context

A trial run on October 30, in a worktree of `master`, ran `bundle update devise --conservative` on Rails 8.1.4:

- **Gems:** Devise resolves to 5.0.4. Nothing else in the lockfile changes.
- **Suite:** 40 of 41 examples pass, and the four `devise_for` route deprecations are gone. The failure is "Sessions refuses a wrong password", which expects "Invalid Email or password.".
- **What a wrong password returns now,** probed in a spec:
  - status 200, no redirect;
  - flash alert "Invalid email or password.", which the page shows.
- **Why the wording changed:** in Devise 5, `Devise::FailureApp#i18n_message` fills `%{authentication_keys}` with `human_attribute_name(key).downcase_first`. The app's `config/locales/devise.en.yml` keeps the same `"Invalid %{authentication_keys} or password."` template.
- **Production mode:**
  - the image builds;
  - the server boots as Rails 8.1.4 with no deprecation warnings;
  - `/`, sign-in, sign-up and forgot-password return 200, and `/admin` redirects to sign-in.

  The trial run didn't check Devise's key against `SECRET_KEY_BASE`.

## Goals / Non-Goals

**Goals:**
- Devise 5, with no deprecation warnings left.
- Sign-in, sign-up, password reset and sessions behave as before, apart from the message's case.

**Non-Goals:**
- Devise 5's new options, or regenerating the initializer.

## Decisions

1. **Update only Devise, conservatively.** The Gemfile's `gem 'devise'` has no version, so no Gemfile change is needed.
2. **Accept Devise 5's wording** and change the spec's expected text. "Invalid email or password." reads better mid-sentence than "Email". Alternative: override the message in `devise.en.yml` to keep the capital. That's more config for no benefit.
3. **Check the key and sessions in production mode.** Devise's key decides password-reset tokens, and the session cookie must survive the deploy and a rollback. So the check covers both, as in the Rails steps.

## Risks / Trade-offs

- [Devise 5 changes something the specs don't cover] → The production-mode run signs in and reuses cookies in both directions. After deploy, the owner signs in, tries a wrong password, and runs a password reset.
- [Reset links emailed before the deploy stop working] → Only if Devise's key changes. The production-mode check compares it to `SECRET_KEY_BASE`.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps.
3. Check:
   - the owner stays signed in across the deploy;
   - a wrong password shows "Invalid email or password.";
   - a password reset works end to end.
4. Rollback: the README's rollback steps. No migrations.
