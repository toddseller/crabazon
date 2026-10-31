# Design

## Context

- **Committed assets:** `git ls-files public/assets` lists 33 files, added in commit `e2b1756` (March 2024), including `.sprockets-manifest-*.json` and `application-*.js`/`.css`. `.gitignore` doesn't list `public/assets`, and neither does `.dockerignore`.
- **Build:** the Dockerfile runs `COPY . /usr/src/app`, then `bundle exec rake assets:precompile`. Precompiling writes into `public/assets/` next to whatever was copied in.
- **Live container:** it has one `.sprockets-manifest-*.json`, which maps `crabazon.svg` to `crabazon-4c73156e….svg`. The logo's content hasn't changed, so the fresh fingerprint equals the committed one.
- **Logo references** (10 in 9 files):
  - `%img{src: '/assets/crabazon-4c73….svg'}` in `index/index`, `products/new`, `products/edit`, `orders/new`, `orders/index`, `orders/show`, and the cart modal in `layouts/application`;
  - `<img src="/assets/crabazon-4c73….svg">` in `devise/shared/_card.html.erb`;
  - `image_tag('/assets/crabazon-4c73….svg')` in `admin/index`;
  - `image_tag('crabazon-4c73….svg')` in the layout's navbar.

  All render `/assets/crabazon-4c73….svg` today, which returns 200. No mailer view references `/assets/`.
- **Cart icon** (found while applying): the layout's navbar has `%img{src: '/assets/cart-<fingerprint>.svg'}`, the only other fingerprinted path in the views.
- **Test environment:** assets compile on demand, so `asset_path('crabazon.svg')` returns the current fingerprinted path, and requests for it are served.

## Goals / Non-Goals

**Goals:**
- No compiled assets in the repo, and builds that use only freshly compiled ones.
- No view depends on a particular fingerprint.

**Non-Goals:**
- Moving to Propshaft or changing the asset pipeline.
- Tidying the logo markup beyond its URL.

## Decisions

1. **`git rm -r public/assets`, plus `/public/assets` in `.gitignore` and `public/assets/` in `.dockerignore`.** The Docker ignore matters because `docker build .` copies untracked files too: a developer's local precompile would otherwise slip into the image.
2. **Refer to the logo by name:**
   - `asset_path('crabazon.svg')` where the markup is a plain `img` tag, so classes and alt text stay as they are;
   - `image_tag('crabazon.svg')` where the code already calls `image_tag`.
3. **A guard spec** reads every file under `app/views` and fails on any `-<64 hex digits>.` file name, with or without `/assets/`, which also catches the navbar's `image_tag('crabazon-….svg')`. It fails today with the nine files, and passes once they name the asset. That's the test-first step, since the pages render the same before and after.

## Risks / Trade-offs

- [A page outside `app/views` still points at a committed file] → The grep in the guard spec covers views. `app/`, `config/` and `lib/` have no other fingerprinted paths, per the same pattern.
- [The image build relied on a committed file] → The production-mode check builds from a checkout without them, and loads every asset the pages reference.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps. The pull deletes the checkout's committed assets, and the build compiles fresh ones.
3. Check: the logo shows on the home page, the sign-in card, the admin page and an order page. The stylesheet and script load, and the cart modal works.
4. Rollback: the README's rollback steps. The previous image has its own compiled assets.
