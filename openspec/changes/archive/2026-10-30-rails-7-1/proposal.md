# Proposal

## Why

Rails 7.0 left security support in 2025. This is the second step of the one-minor-at-a-time upgrade: 7.0 to 7.1, then 7.2, 8.0 and 8.1. Each step stays small enough for the suite to pin what breaks.

## What Changes

- **Rails 7.0.10 to 7.1.6,** the last 7.1 release, with `bundle update rails --conservative`. Only Rails and the gems it needs change in the lockfile.
  - New dependencies include `rack-session`, `rackup`, `irb` and `connection_pool`.
  - Rack stays at 2.2.9, `concurrent-ruby` at 1.2.3 and Devise at 4.9.3.
- **Two settings Rails 7.1 requires:**
  - `config.active_record.legacy_connection_handling = false` is removed, because Rails 7.1 raises an error at boot while it's there;
  - `config.active_support.cache_format_version = 7.1` replaces the 6.1 cache format, which 7.1 deprecates and 7.2 removes. The app never uses `Rails.cache`, so nothing stored is affected.
- **Devise's error helper:**
  - the account forms switch from the deprecated `devise_error_messages!` to the partial it already renders, `devise/shared/error_messages`;
  - the confirmation and unlock pages, the two other users of the helper, are deleted, because the user model enables neither module.
- **No `config.load_defaults`.** As in the 7.0 step, cookie signing and the session format stay as they are, so customers stay signed in across the deploy, and a rollback to 7.0 still reads the new cookies.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. The shop should behave exactly as before. The specs prove that, plus one new assertion for the forgot-password form's error message.

## Impact

- Changed:
  - `Gemfile`, `Gemfile.lock`, `config/application.rb`;
  - `app/views/devise/passwords/new.html.erb`, `app/views/devise/passwords/edit.html.erb`;
  - `app/views/devise/registrations/new.html.erb`, `app/views/devise/registrations/edit.html.erb`;
  - `spec/requests/passwords_spec.rb`.
- Deleted: `app/views/devise/confirmations/new.html.erb`, `app/views/devise/unlocks/new.html.erb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations.
- Out of scope:
  - adopting Rails 7.1 framework defaults (`load_defaults`);
  - Devise 5, which a plain `bundle update devise` would pull in (it fails 4 specs);
  - the Rails 7.2 step.
