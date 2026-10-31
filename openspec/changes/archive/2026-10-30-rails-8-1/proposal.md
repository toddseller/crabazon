# Proposal

## Why

This is the last step of the one-minor-at-a-time upgrade: Rails 8.0 to 8.1, the current release series. After it, the shop is on a supported Rails.

## What Changes

- **Rails 8.0.5.1 to 8.1.4,** the latest 8.1 release, with `bundle update rails --conservative`. Besides Rails' own gems, `action_text-trix` is added and `benchmark` drops out. Rack, `concurrent-ruby`, Devise and the asset gems don't move.
- **`config.active_support.to_time_preserves_timezone = :zone` is removed.** The 8.0 step added it to opt in early. In 8.1 it's the only behavior, and the setting itself is deprecated.
- **No `config.load_defaults`,** as in the earlier steps, so cookies stay compatible across the deploy and a rollback.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. The shop should behave exactly as before, and the specs prove that.

## Impact

- Changed: `Gemfile`, `Gemfile.lock`, `config/application.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations.
- Known warning left: Devise 4.9's `devise_for` passes route options to Rails as a hash, which 8.1 deprecates for removal in 8.2. Devise 5 fixes it, and gets its own change next.
- Out of scope:
  - Devise 5;
  - Rails 8.1 framework defaults and the new default stack.
