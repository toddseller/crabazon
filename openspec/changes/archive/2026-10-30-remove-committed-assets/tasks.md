# Tasks

## 0. Branch

- [x] 0.1 Create `remove-committed-assets` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Logo by name

- [x] 1.1 Add `spec/views_spec.rb`: no file under `app/views` contains `/assets/<name>-<64 hex digits>`. Run it with the README's commands and show it fails, listing the nine files.
- [x] 1.2 Replace the ten logo references:
  - `asset_path('crabazon.svg')` in the plain `img` tags;
  - `image_tag('crabazon.svg')` in the two `image_tag` calls.

  Do the same for the navbar's cart icon with `asset_path('cart.svg')`, which the guard spec found once its pattern also matched names without `/assets/`. Run the whole suite; it passes.

## 2. Remove the committed assets

- [x] 2.1 `git rm -r public/assets`. Add `/public/assets` to `.gitignore` and `public/assets/` to `.dockerignore`.

## 3. Production image

- [x] 3.1 Build the image on the Mac as `linux/amd64` from a clean checkout of the branch (no `public/assets`), and run it with `RAILS_ENV=production` against a throwaway `postgres:18` loaded with the schema and a product with an image. Verify:
  - every `/assets/...` URL in `/`, `/users/sign_in`, `/admin` (signed in as admin) and an order page returns 200;
  - the logo URL is still `crabazon-4c73….svg`;
  - the container's `public/assets` has exactly one Sprockets manifest.

  Remove the image and containers.

## 4. Review

- [x] 4.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `remove-committed-assets`, then archive this change (no spec sync; it changes no requirements) as a second commit, `Archive remove-committed-assets`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's check.
