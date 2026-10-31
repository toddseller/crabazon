# Design

## Context

See proposal.md, Why.

- **How the server starts:** production runs `bundle exec rails s -p 5666 -b '0.0.0.0'` from `docker-compose.yml`. With no server named, Rails asks Rack for a default.
  - Rack 2.2 tries Puma, Thin, Falcon and WEBrick, in that order.
  - Puma isn't in the bundle, so production runs Thin today: one process, serving requests through EventMachine.
  - (The reset-hardening design called it Puma. Its reasoning holds for Thin too: one process sees every request.)
- **rackup 2:** it tries only Puma, Falcon and WEBrick, unless `-u` or `RACKUP_HANDLER` names a server.
- **Thin 2.0:** it registers itself as the `thin` handler for both Rack 2 and Rack 3.

## Goals / Non-Goals

**Goals:** Rack 3 with the same server, the same behavior and kept sessions.

**Non-Goals:** a different web server; any Rack 3 feature, such as streaming bodies.

## Decisions

### Keep Thin, and name it in the start command

`rails s -u thin -p 5666 -b '0.0.0.0'`.
- **Why:** the compose file is the only place that starts the server, so this is the whole fix. The bundle doesn't change apart from the version bumps.
- **Alternative rejected: switching to Puma.** rackup would pick Puma by itself, and it's Rails' default and threaded. But that swaps the server under a live shop as part of a library upgrade, and its threads would bring new behavior to check. It can be its own change.
- **Alternative rejected: `RACKUP_HANDLER=thin` in the environment.** It does the same job, but sits further from the command it affects.

### A conservative update of exactly the four gems

`bundle update thin rack rack-session rackup --conservative`. A trial run showed only those four move, and WEBrick drops out.

## Risks / Trade-offs

- **[Rack 3 response rules]** Rack 3 requires lowercase header names and treats bodies differently. Rails 8.1 already follows those rules, but Thin's handling under Rack 3 is new code for this app. → The production image check covers pages, assets, sign-in cookies, the AJAX cart and CSRF, a form post and a redirect.
- **[Forgotten start command]** Running `rails s` anywhere without `-u thin` fails with "Couldn't find handler for: puma, falcon, webrick". → It fails loudly at boot rather than misbehaving, and compose is the only place that starts it.

## Migration Plan

1. Deploy with the README's steps. `git pull` brings the new compose command along with the code. There's no migration, and sessions are kept.
2. Owner checks:
   - still signed in;
   - add to cart and check out;
   - the order email arrives;
   - edit a product.
3. Rollback: the README's `crabazon-web:previous` steps alone. The new `-u thin` command also starts the old image, because Rack 2 has a `thin` handler too. Task 2.1 checks this.
