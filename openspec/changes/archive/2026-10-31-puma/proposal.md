# Proposal

## Why

The shop runs on Thin, which handles one request at a time in a single thread. Any slow request holds up every visitor behind it. Checkout is the clearest case: it sends the order email over SMTP before answering, so while one customer checks out, every other page waits too.

Thin also gets few releases, and since the Rack 3 upgrade it has to be named in the start command. Puma is Rails' default server and is actively maintained. It serves several requests at once with threads, and `rails s` picks it by itself.

## What Changes

- **Thin 2.0.1 is replaced by Puma 8.0.2** in the Gemfile. Thin's dependencies, EventMachine and daemons, leave the lockfile. Puma's one dependency, `nio4r`, is already there.
- **The compose command drops `-u thin`,** going back to `rails s -p 5666 -b '0.0.0.0'`.
- **Puma runs with its defaults:** one process, 0 to 5 threads. That fits the database connection pool of 5, so no `config/puma.rb` is added.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. The shop behaves as before, except that one slow request no longer holds up the others.

## Impact

- Changed: `Gemfile`, `Gemfile.lock`, `docker-compose.yml`.
- Production: one image rebuild and restart. No migrations, and nobody is signed out. The rollback for this one deploy also needs the previous compose file (see design.md).
- Out of scope: Puma's cluster mode with several worker processes, and a `config/puma.rb`.
