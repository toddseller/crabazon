# Proposal

## Why

Production logs at `:debug`, the most detailed level, which a 2016 comment justifies as "to ensure availability of diagnostic information". At that level every request also writes each SQL query and each rendered partial. The log becomes several times longer, and the lines that matter are harder to find: the request, its parameters, its response and any error. Rails' production default is `:info`.

## What Changes

- `config.log_level = :debug` becomes `:info` in `config/environments/production.rb`, and the comment goes.
- **Still logged:**
  - each request's "Started" line, its controller and filtered parameters, and its "Completed" status and timing;
  - mail deliveries, background job starts, warnings and errors with their backtraces.
- **No longer logged:** SQL queries, partial renders and cache lookups. Each page still logs one line for its top-level template.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. Nothing the shop does changes.

## Impact

- Changed: `config/environments/production.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations, and nobody is signed out.
- **Investigating a problem later:** an investigation that needs the SQL can run one-off commands with `docker compose run --rm web bin/rails runner`, or temporarily set the level back in a branch.
- Out of scope: an environment variable to change the level without a rebuild.
