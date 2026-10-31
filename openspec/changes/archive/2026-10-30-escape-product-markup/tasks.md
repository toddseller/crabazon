# Tasks

## 0. Branch

- [x] 0.1 Create `escape-product-markup` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Order email

- [x] 1.1 Add `spec/mailers/user_mailer_spec.rb`: render `UserMailer.order_email` for an order whose product's image URL is `https://example.com/a.png" onerror="x`. Parse the HTML with Nokogiri, and expect the product `img` to have that whole URL as `src` and no `onerror`. Run it with the README's commands and show it fails.
- [x] 1.2 Quote the `src` attribute in `order_email.html.erb`. Run the whole suite; it passes.

## 2. Cart and category picker

- [x] 2.1 Check production read-only: count products whose name contains `<`, expecting 0.
- [x] 2.2 Build a scratch test page that loads the app's compiled `application.js` and calls `buildRow` with a product named `<img src=x onerror="document.title='PWNED'">` and an image URL containing `" onerror="document.title='PWNED'`. Dump its DOM with headless Chromium, and show the title becomes "PWNED".
- [x] 2.3 In `admin.js`:
  - set the cart image with `.attr('src', ...)` and the name with `.text(...)`;
  - build the category label with `.attr` and `.text`, and remove it by comparing titles.

  Rebuild the assets, rerun the scratch page, and show the title stays unchanged, the name appears as text, and the `img` has the whole URL as its only `src`. Do the same for the category picker with a category named `a"b<i>`: tick and untick it, and check the label appears as text and goes away.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `escape-product-markup`, then archive this change (with spec sync into `product-catalog`) as a second commit, `Archive escape-product-markup`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's check.
