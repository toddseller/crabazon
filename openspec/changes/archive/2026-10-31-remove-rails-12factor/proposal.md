# Proposal

## Why

`rails_12factor` is a Heroku-era gem whose last release was in 2014. It pulls in two gems:
- **`rails_serve_static_assets`** turns on Rails' public file server. Since Rails 5 that's already the default, and this app's `production.rb` never turns it off, so it's redundant. (The `config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?` line looks like it controls this, but Rails removed that setting in 5.1, so it does nothing.)
- **`rails_stdout_logging`** replaces the Rails logger with one that writes to STDOUT at the configured level, and sets `STDOUT.sync = true`. That's why `docker logs` shows each request as it happens. Without it, Rails writes to `log/production.log` inside the container, which `docker logs` doesn't show and every rebuild throws away.

Keeping an unmaintained gem for one setting hides how production logs. The dead lines next to it make it worse.

## What Changes

- `rails_12factor` leaves the Gemfile, and its two sub-gems leave the lockfile.
- `production.rb` says directly what the gem did for logging: `config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)`, with `STDOUT.sync = true`, replaces the commented-out logger example.
- **Dead lines deleted:**
  - `config.serve_static_files = ...` in `production.rb`, and its comment;
  - the second `config.log_level = :debug` in `production.rb`;
  - `config.log_formatter = ::Logger::Formatter.new` in `production.rb`, which Rails only uses when it builds the logger itself;
  - `config.serve_static_files` and `config.static_cache_control` in `test.rb`, both removed in Rails 5.1.
- The log stays at `:debug`, with the same plain format as now.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. The shop behaves exactly as before.

## Impact

- Changed: `Gemfile`, `Gemfile.lock`, `config/environments/production.rb`, `config/environments/test.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations, and nobody is signed out.
- Out of scope: lowering production's log level from `:debug` to Rails' default `:info`.
