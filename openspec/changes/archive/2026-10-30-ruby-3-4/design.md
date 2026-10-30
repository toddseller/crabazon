# Design

## Context

A throwaway run on October 30 tried today's code on the current Ruby images, `ruby:3.3.13` and `ruby:3.4.12` (both Debian 13 with glibc 2.41), natively on arm64, against `postgres:18`:

- **Ruby 3.3.13:** today's lockfile installs and all 31 examples pass. Nokogiri 1.13.10 had to compile from source, because its prebuilt Linux gems stop at Ruby 3.1.
- **Ruby 3.4.12:** the failures came one at a time, each fix exposing the next.
  - Bundler 2.2.19, the version the lockfile names and the image installs, crashes on Ruby 3.4 (`DidYouMean::SPELL_CHECKERS`). Updating the lockfile's Bundler to 3.4's own 2.6.9 got past it.
  - Boot then failed with `cannot load such file -- base64`. Rails 6.1 requires `base64`, `bigdecimal`, `mutex_m` and `drb`, which Ruby 3.4 moved out of the default gems. Adding them to the Gemfile got past it.
  - Next, `factory_girl_rails` failed to load (`observer`, also moved out). Nothing uses it, so I removed it.
  - Then 31 examples ran with 3 failures, all in `product_spec.rb`. Faker 2.22 warns about positional arguments to `Faker::Number.between`, and that warning code crashes on Ruby 3.4 (`undefined method '[]' for nil`). The keyword form avoids it.

  What remained were warnings about `logger`, `ostruct` and `benchmark` leaving the default gems in Ruby 4.0.

`concurrent-ruby` is locked at 1.2.3. Version 1.3.5 and later break Rails 6.1 and 7.0 at boot (`uninitialized constant ...LoggerThreadSafeLevel::Logger`), so it must not be updated in this step.

Production builds its image with `bundle install --without development test`, a flag Bundler 2.6 deprecates.

## Goals / Non-Goals

**Goals:**
- Same behavior on Ruby 3.4.12, proven by the unchanged request specs, in CI and in a production-mode run of the built image.
- Change as few gem versions as possible.

**Non-Goals:**
- Upgrading Rails or any gem that doesn't block Ruby 3.4.
- Silencing the Ruby 4.0 warnings. That's done when the Ruby 4.0 step comes.

## Decisions

1. **Ruby 3.4.12 rather than 3.3.13.** The owner chose 3.4: supported about a year longer than 3.3, at the cost of the Gemfile additions and the spec fix above.

2. **Add the four gems unpinned,** each one line in the Gemfile, so Bundler locks the current releases.

3. **Update only Nokogiri and Bundler in the lockfile:** `bundle update nokogiri --conservative` and `bundle update --bundler=2.6.9`. Conservative mode leaves Nokogiri's dependencies alone where possible, and every other gem, `concurrent-ruby` included, stays put. Alternative: `bundle update` everything. That mixes unrelated gem changes into the Ruby step and would pull `concurrent-ruby` 1.3.5.

4. **Lockfile platforms:** `x86_64-linux` (production and CI) plus `aarch64-linux` (local runs on Apple silicon), both added with `bundle lock --add-platform`. The README drops `--platform linux/amd64`, which was only needed because Debian 10's glibc was too old for arm64 Nokogiri.

5. **Dockerfile:**
   - `FROM ruby:3.4.12`;
   - drop the `archive.debian.org` line and `gem install bundler -v 2.2.19`, since the image ships Bundler 2.6.9;
   - `ENV BUNDLE_WITHOUT="development test"` replaces the deprecated `--without` flag;
   - the apt package list stays as it is.

6. **CI and README** use `ruby:3.4.12` and drop the archive line and the Bundler install. They keep `apt-get install nodejs`, because `uglifier` needs a JavaScript runtime.

7. **Prove it runs in production mode before deploying.** Build the image on the Mac as `linux/amd64`, start `rails s` in it with `RAILS_ENV=production` against a throwaway `postgres:18`, and request:
   - the home page (200);
   - `/admin` (302 to sign-in);
   - the compiled stylesheet (200).

## Risks / Trade-offs

- [Rails 6.1 was never tested on Ruby 3.4 upstream] → The suite covers the shop's flows, and the production-mode run covers boot, assets and the Thin server. The owner checks sign-in, cart, checkout and an admin edit after deploy.
- [Native gems (`pg`, `bcrypt`, `eventmachine`, `sassc`, `ffi`) compile differently on amd64 than in the arm64 trial] → CI and the image build both run on amd64, before deploy.
- [`sassc` compiles slowly] → The image build takes a few minutes longer. That's acceptable for a manual deploy.

## Migration Plan

1. Merge; CI runs the suite on Ruby 3.4.12.
2. On the app host, the README's deploy steps: tag the image `previous`, `docker compose build web`, then `docker compose up -d web`.
3. Check:
   - the container log shows Ruby 3.4.12;
   - the home page, a product page and the stylesheet return 200;
   - `/admin` redirects to sign-in;
   - the owner signs in, adds to the cart, checks out and edits a product as an admin.
4. Rollback: the README's rollback steps. The database is untouched, since no migrations run.
