# Proposal

## Why

Rails 7.1 is out of support. This is the third step of the one-minor-at-a-time upgrade: 7.1 to 7.2, then 8.0 and 8.1. Rails 7.2 also removes `Rails.application.secrets`, which ends the last deprecation warning left from 7.1.

## What Changes

- **Rails 7.1.6 to 7.2.3.2,** the latest 7.2 release, with `bundle update rails --conservative`.
  - Besides Rails' own gems, only `useragent` is new, and `concurrent-ruby` moves from 1.2.3 to 1.3.8, the version Rails 7.2 requires. The 1.2.3 hold dated from Rails 7.0, which broke with later versions; 7.2 doesn't.
  - Rack stays at 2.2.9, and Devise at 4.9.3.
- **`database_cleaner-active_record` 2.1.0 to 2.2.2,** a test-only gem. 2.1.0 calls a Rails internal that 7.2 removed, so the suite can't start.
- **Tests raise real errors:**
  - `config.action_dispatch.show_exceptions = false` becomes `:none`. In 7.1, `false` still meant "raise errors in tests"; in 7.2 it falls through to "show error pages".
  - `better_errors` and `binding_of_caller` move to a development-only group. Better Errors switches itself on wherever `consider_all_requests_local` is true, which includes tests. So far it has caught every exception in specs and turned it into a 500 page, on 7.1 too, which hid the real error and stack trace. A spec that doesn't check the status could pass over an error page.
- **No `config.load_defaults`,** as in the earlier steps, so cookies stay compatible across the deploy and a rollback.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. The shop should behave exactly as before, and the specs prove that.

## Impact

- Changed: `Gemfile`, `Gemfile.lock`, `config/environments/test.rb`.
- Tests: specs now get real exceptions. No spec expects a 500 page.
- Production: one image rebuild and restart, with the README's rollback. No migrations.
- Out of scope:
  - Rails 7.2 framework defaults;
  - other gem updates;
  - the Rails 8.0 step.
