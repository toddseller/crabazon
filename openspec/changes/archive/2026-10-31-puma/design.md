# Design

## Context

See proposal.md, Why.

- **Today's server:** compose runs `rails s -u thin -p 5666 -b '0.0.0.0'`. Thin serves one request at a time.
- **Database connections:** `DATABASE_URL` holds all of production's database settings, so the pool is Rails' default of 5. (The `production:` key in `database.yml` is indented under `test:`, so it never applies.)
- **The trial swap:**
  - `rails s` with no server named boots Puma 8.0.2 in single mode, with 0 to 5 threads;
  - it listens on the `-p` port even when `PORT` is set, which matters because production uses `PORT` for the SMTP port;
  - `-u thin` fails on the new bundle with "Could not load server".

## Goals / Non-Goals

**Goals:** Puma in place of Thin, with the same port, no new config file, and kept sessions.

**Non-Goals:** cluster mode, tuning threads, Puma plugins.

## Decisions

### Puma's defaults, no `config/puma.rb`

- **Why:** five threads match the pool of five, so no request ever waits for a database connection that another thread holds. One process keeps the reset limit's memory store and the in-process mail jobs shared, as they are now.
- **Alternative rejected:** Rails' generated `puma.rb`. It reads `PORT` for its port, and production's `PORT` is the SMTP port. It also adds settings this app has no use for.

### The app's code is safe with threads

- **No shared state:** nothing in `app/`, `lib/` or the initializers keeps state in class variables or globals.
- **Shared objects are thread-safe:** the reset limit's `MemoryStore` and the `:async` job adapter are both built for this.
- **Each request is separate:** Rails and Devise keep per-request state per thread.

### The compose command names no server

`rails s -p 5666 -b '0.0.0.0'`, as it was before Rack 3. rackup picks Puma first.
- **Alternative rejected:** `-u puma`. It's no safer, since neither form starts the old image.

## Risks / Trade-offs

- **[Rollback needs the old command]** The old image only starts with `-u thin`, and the new image only without it. → For this deploy only, a rollback also restores the previous `docker-compose.yml`. See the Migration Plan.
- **[Concurrency surprises]** Requests now really overlap. Two people buying the last item at the same moment is the case that matters. → Checkout already locks the product rows (`Product.lock`, in id order) inside its transaction, so the second checkout waits for the first and then sees the new stock. Task 2.1 runs two checkouts for the last item at once and checks that exactly one succeeds.

## Migration Plan

1. Deploy with the README's steps. `git pull` brings the new command. There's no migration, and sessions are kept.
2. Owner checks:
   - still signed in;
   - add to cart and check out;
   - the order email arrives;
   - edit a product.
3. Rollback for this deploy:
   1. on the app host, `git checkout <previous merge> -- docker-compose.yml` brings back `-u thin`;
   2. then the README's `crabazon-web:previous` steps;
   3. after the next good deploy, `git checkout master -- docker-compose.yml` undoes the step 1 edit.
