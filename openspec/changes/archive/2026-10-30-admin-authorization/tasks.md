# Tasks

## 0. Branch

- [x] 0.1 Create `admin-authorization` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Admin-only catalog management

- [x] 1.1 Write `spec/requests/admin_access_spec.rb`, looping over each guarded route: `GET /admin`, `GET /products/new`, `POST /products`, `GET /products/:id/edit`, `PATCH /products/:id`, `DELETE /products/:id`, `GET /categories/new`, `POST /categories`, `GET /categories/:id/edit`, `PATCH /categories/:id` and `DELETE /categories/:id`. For an anonymous visitor, expect a redirect to `/users/sign_in`. For a signed-in customer, expect a redirect to `/index` with the alert `That page is for admins.`. In both cases, expect the product and category counts and names unchanged. Run it with the README's commands and show it failing because the requests get through today (no redirect, and a product or category changed).
- [x] 1.2 Add the private `authenticate_admin!` to `ApplicationController` (Devise's `authenticate_user!`, then the customer redirect). Use it as a `before_action` in `AdminController`, and `except: [:index, :show]` in `ProductsController` and `CategoriesController`. Verify `admin_access_spec.rb` passes. Verify the full suite passes with one pending example (sign-up), including the unchanged `admin_spec.rb` and `storefront_spec.rb`, whose anonymous product and category pages stay public.

## 2. A buildable production image

- [x] 2.1 Show the build failing today: `docker build --platform linux/amd64 --build-arg DATABASE_URL=postgres://placeholder@localhost/placeholder -t crabazon-web:rehearsal .` stops at `apt-get update`.
- [x] 2.2 In the Dockerfile, point apt at `archive.debian.org` before `apt-get update` (same line as CI, with a one-line why comment), and add a `.dockerignore` listing `.env`, `.env.*`, `log/` and `tmp/`. Verify the same build completes and that neither `/usr/src/app/.env` nor `/Rails-Docker/.env` exists in the image. Then run `rails runner 'puts Rails.env'` in a container from that image with `RAILS_ENV=production` and placeholder `DATABASE_URL` and `SECRET_KEY_BASE` values, and check it prints `production`. Remove the rehearsal image.
- [x] 2.3 In the README's Deployment section, replace the warning not to rebuild with the steps: tag the current image `crabazon-web:previous`, `git pull`, `docker compose build web`, `docker compose up -d web`. Add the rollback (retag and `up -d web`), and note that production runs the code in the image, so every code change needs the build. Check the commands match the design's Migration Plan.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `admin-authorization`, then archive this change (syncing `admin-access` into `openspec/specs/`) as a second commit, `Archive admin-authorization`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host:
  1. switch the checkout's `origin` to the HTTPS URL;
  2. `git pull`;
  3. tag `crabazon-web:previous`;
  4. `docker compose build web`;
  5. `docker compose up -d web`.
- Verify production:
  - anonymous `/admin` and `/products/new` redirect to the sign-in page;
  - the home page and a product page return 200;
  - the owner signs in as an admin and edits a product.
- Next changes: fix sign-up, then the Ruby step of the upgrade.
