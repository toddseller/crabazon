# Proposal

## Why

Anyone on the internet can open `/admin` and create, edit or delete products and categories without signing in: `AdminController`, `ProductsController` and `CategoriesController` have no login or role check, and the only admin check is the redirect after sign-in. This is the live site's most serious hole, and the test baseline that just landed means it can be closed with specs around it.

## What Changes

- `/admin`, and the new, create, edit, update and delete routes for products and categories, require a signed-in user whose `role` is `admin`. Anonymous visitors are sent to the sign-in page; signed-in customers are sent to the index page with a message. Nothing changes in the database for either.
- The storefront stays public: the home page, product pages and category pages.
- The production image builds again: the Dockerfile points apt at `archive.debian.org`, so the fix can be deployed. Production runs the code baked into its image (built in March 2024), not the `git pull` checkout, so a code change only reaches the site through a rebuild.
- A `.dockerignore` keeps `.env` (and `log/`, `tmp/`) out of the image. With none, the build copied the secrets in `.env` into it; production reads them from compose's `env_file` instead.
- The unused second copy of the app goes: the Dockerfile's `ADD . /Rails-Docker` and compose's mount of the checkout at `/Rails-Docker`. Nothing ran from it, and it made `git pull` look like a deploy.
- The README's deploy steps include the rebuild and a rollback to the previous image, replacing the warning not to rebuild.

## Capabilities

### New Capabilities

- `admin-access`: who may manage the catalog (the admin pages and the product and category writes) and what everyone else sees instead.

### Modified Capabilities

None.

## Impact

- Changed: `app/controllers/application_controller.rb`, `admin_controller.rb`, `products_controller.rb`, `categories_controller.rb`, `Dockerfile`, `docker-compose.yml`, `README.md`.
- New: `.dockerignore`, `spec/requests/admin_access_spec.rb`.
- Production: one image rebuild on the app host and a restart of `web`, with the current image kept under a tag for rollback.
- Out of scope: sign-up (still broken; its own change), `/orders` for anonymous visitors (it errors instead of asking them to sign in), and building the image in CI.
