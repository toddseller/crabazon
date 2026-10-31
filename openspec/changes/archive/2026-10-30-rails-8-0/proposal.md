# Proposal

## Why

Rails 7.2's security support ended in August 2026. This is the fourth step of the one-minor-at-a-time upgrade: 7.2 to 8.0, then 8.1.

## What Changes

- **Rails 7.2.3.2 to 8.0.5.1,** the latest 8.0 release, with `bundle update rails --conservative`. Besides Rails' own gems, `uri` is added and `cgi` drops out. Rack, `concurrent-ruby`, Devise and the Sprockets asset pipeline don't move.
- **One setting:** `config.active_support.to_time_preserves_timezone = :zone`, the value `load_defaults 8.0` sets and Rails 8.1 makes the only behavior. It silences Rails 8.0's one deprecation warning. Nothing in the app calls `to_time`, and the server runs in UTC, so nothing changes.
- **No `config.load_defaults`,** as in the earlier steps, so cookies stay compatible across the deploy and a rollback.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. The shop should behave exactly as before, and the specs prove that.

## Impact

- Changed: `Gemfile`, `Gemfile.lock`, `config/application.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations.
- Out of scope:
  - Rails 8.0 framework defaults;
  - Rails 8's new default stack (Propshaft, importmaps, Solid Cache, Queue and Cable). The app keeps Sprockets and its current gems;
  - the Rails 8.1 step.
