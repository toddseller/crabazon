# Proposal

## Why

`public/assets/` holds 33 precompiled files committed in March 2024: the stylesheets, scripts, fonts and images, each with its fingerprint in the name, plus Sprockets' manifest. The image build compiles fresh ones with `assets:precompile` anyway, so the committed copies are leftovers:

- They go stale with every change to the JavaScript or CSS. During the last change, a test picked up the committed `application-*.js` instead of the current one.
- Ten logo tags in nine views hardcode the committed logo's fingerprinted file name, `/assets/crabazon-4c73…svg`. They work only because the logo hasn't changed since. A new logo, or a Sprockets update that changes the fingerprint, would break the logo on every page.

## What Changes

- `public/assets/` is deleted from the repo, and ignored by git and Docker, so the image always compiles its own assets.
- The ten logo tags name the asset, `crabazon.svg`, and let Rails add the fingerprint (`image_tag` or `asset_path`). So does the navbar's cart icon (`cart.svg`), which the guard spec found during apply.
- A spec fails if any view hardcodes a fingerprinted asset path again.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. Pages look the same; only where the logo's URL comes from changes.

## Impact

- Deleted: 33 files in `public/assets/`.
- Changed:
  - `.gitignore`, `.dockerignore`;
  - `app/views/devise/shared/_card.html.erb`, `app/views/layouts/application.html.haml`, `app/views/admin/index.html.haml`;
  - `app/views/index/index.html.haml`, `app/views/products/new.html.haml`, `app/views/products/edit.html.haml`;
  - `app/views/orders/new.html.haml`, `app/views/orders/index.html.haml`, `app/views/orders/show.html.haml`.
- New: `spec/views_spec.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations. On the app host, `git pull` removes the committed files from the checkout. The image never used them, since `assets:precompile` writes its own.
