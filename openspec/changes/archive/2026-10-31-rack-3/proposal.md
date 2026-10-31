# Proposal

## Why

The shop runs on Rack 2.2, while Rails 8.1 and every other gem in the bundle already support Rack 3. Rack 2 only gets security fixes now. The one gem holding it back is Thin, the web server, whose 1.x releases require Rack below 3.

## What Changes

- **Thin 1.8.2 to 2.0.1, and Rack 2.2.9 to 3.2.8,** with `bundle update thin rack rack-session rackup --conservative`.
  - `rack-session` goes from 1.0.2 to 2.1.2, and `rackup` from 1.0.1 to 2.3.1.
  - WEBrick drops out, because nothing needs it any more.
  - No other gem moves.
- **Status 422 uses its Rack 3 name,** `:unprocessable_content`. The response is unchanged.
- **The server is named when it starts.** Rack 2 picked Thin by itself. rackup 2's automatic choice only knows Puma, Falcon and WEBrick, so without a name `rails s` would find no server and the site wouldn't start. The compose command adds `-u thin`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. The shop should behave exactly as before, and the specs prove that.

## Impact

- Changed: `Gemfile.lock`, `docker-compose.yml`, and the 422 status name in `app/controllers/application_controller.rb` and `spec/requests/cart_spec.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations, and sessions are kept.
- Out of scope:
  - switching to Puma, Rails' default server;
  - removing `rails_12factor`, which Rails has not needed since version 5.
