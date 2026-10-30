# Design

## Context

- Admin users are told apart by `users.role == 'admin'`. The layout already uses that check to show the Admin button, and `Users::SessionsController` sends admins to `/admin` after sign-in. Nothing on the server checks it. Only `UsersController` calls Devise's `authenticate_user!`.
- `resources :admin` routes every REST verb to `AdminController`, which has only `index`. `ProductsController#index` has no template, and `categories/index` is an empty template.
- Production's `web` container runs from `/usr/src/app`, the code copied into the image when it was built (March 2024). The `git pull` checkout is mounted at `/Rails-Docker` and nothing uses it. Today the two copies of `app/` are identical. The Dockerfile's `apt-get update` fails on Debian 10, because its repositories moved to `archive.debian.org`. The app host is x86_64.
- The test baseline gives request specs that sign in as an admin for every catalog action (`spec/requests/admin_spec.rb`), and none that asserts anonymous access, so adding the check keeps them green.

## Goals / Non-Goals

**Goals:**
- One check, applied to every catalog-management action, with a spec per route for both anonymous visitors and customers.
- A rebuild of the production image that can be rehearsed on the Mac and rolled back on the app host in one command.

**Non-Goals:**
- A roles or permissions library (Pundit, CanCanCan). There is one role, and one check.
- Hiding the product and category forms' links: only admin pages link to them already.
- Changing how admins are created (they're set in the database).

## Decisions

1. **One `authenticate_admin!` before-action, defined privately in `ApplicationController`.** It calls Devise's `authenticate_user!` first, so anonymous visitors get Devise's usual redirect to the sign-in page. A signed-in non-admin is redirected to `index_path` with `alert: 'That page is for admins.'`, which the layout already shows. `AdminController` uses it for every action. `ProductsController` and `CategoriesController` use it `except: [:index, :show]`, so the storefront stays public, and any action added later is guarded by default. Alternative: a separate admin namespace with its own base controller. That moves routes and views for no gain at this size.

2. **Redirect customers rather than answer 403 or 404.** It matches how the app already treats the sign-in flow and shows the reason in the existing alert area. Hiding the pages' existence (404) matters little, since the routes are conventional REST routes anyone can guess.

3. **Specs drive it, table-style.** `spec/requests/admin_access_spec.rb` loops over each guarded route (method and path) for an anonymous visitor and for a customer. Each example asserts the redirect and that product and category counts and names are unchanged. They are written first and shown failing against today's code.

4. **Fix the image build in place: the Dockerfile's apt step points at `archive.debian.org` first.** That's the same line the CI and README already use. The rest of the Dockerfile stays as it is. Alternative: mount `app/` from the checkout, or run from `/Rails-Docker`. The owner chose fixing the build, since the Ruby upgrade needs a working rebuild anyway, and this rehearses it.

5. **A `.dockerignore` listing `.env`, `.env.*`, `log/` and `tmp/`.** The build context is the whole checkout, so without it `ADD` and `COPY` put `.env` (on the app host: `SECRET_KEY_BASE`, `EMAIL_SECRET`) into the image. Production doesn't read it from there: compose passes it as environment variables, and `dotenv-rails` isn't installed in the production bundle. Rails recreates `log/` and `tmp/` at boot.

6. **Delete `ADD . /Rails-Docker` and the `.:/Rails-Docker` mount.** Nothing runs from that path, the mount exposed `.env` inside the container, and it hid that deploys need a build.

7. **Rehearse the build on the Mac as `linux/amd64` before touching the app host,** with a placeholder `DATABASE_URL` build argument. The build runs `assets:precompile`, which shouldn't need a database.

## Risks / Trade-offs

- [The rebuild fails on the app host] → The running container is untouched until `docker compose up`, so a failed build changes nothing on the site. The Mac rehearsal catches most failures first.
- [The new image behaves differently (gem resolution, precompiled assets)] → The current image is tagged `crabazon-web:previous` before the build. Rollback is retagging it to `latest` and running `docker compose up -d web`.
- [The 2024 image already holds a copy of the app host's `.env`] → It stays on the host, never pushed; delete it (`crabazon-web:previous`) once the rollback window closes.
- [The `DATABASE_URL` build argument is stored in the image history] → It no longer holds a password, which lives in the `.pgpass` file since the PostgreSQL 18 move.
- [An admin bookmark to a form now lands on sign-in after the session expires] → Expected. Sign-in sends admins to `/admin`.

## Migration Plan

1. Merge. CI runs the specs.
2. On the app host: switch the checkout's `origin` to HTTPS (it has no GitHub SSH key), then `git pull`.
3. `docker tag crabazon-web:latest crabazon-web:previous`, then `docker compose build web`, then `docker compose up -d web`.
4. Check:
   - anonymous `/admin` and `/products/new` redirect to `/users/sign_in`;
   - the home page and a product page return 200;
   - the owner signs in as an admin and edits a product.
5. Rollback: `docker tag crabazon-web:previous crabazon-web:latest && docker compose up -d web`.
