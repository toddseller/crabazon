# Design

## Context

A trial run on October 30 replaced `cache_format_version = 7.1` with `config.load_defaults 8.1` in a worktree of `master`:

- **Suite:** 32 of 42 examples failed with "Validation failed: User must exist". Rails 5.0's default makes `belongs_to` required, and `Product belongs_to :user`, but `db/schema.rb`'s `products` table has no `user_id`. Nothing reads `product.user` or `user.products`. `User has_many :products, through: :orders_products` names an association `User` doesn't define. With both deleted, 42 examples pass with no deprecations.
- **Production data** (read-only): 16 products. 118 orders, all with a `user_id`, but 24 of those users no longer exist. 201 order lines, none missing their order or product. Orders are never updated after checkout, so the 24 never run the now-required `belongs_to :user` check.
- **Production mode** on `linux/amd64`:
  - **CSRF:** sign-in without a token is refused (422), and with one it works. `POST /carts/:id` and `POST /orders` with jquery_ujs's `X-CSRF-Token` header work (200), and without it are refused (422).
  - **Cookies:** a session from the `master` image isn't accepted (sent to sign-in), and a new session isn't accepted by `master` either.
  - **Cookies, old format kept:** with `use_authenticated_cookie_encryption = false` and `key_generator_hash_digest_class = OpenSSL::Digest::SHA1`, sessions work both ways. The owner chose the new format instead.
- **Forms and calls:**
  - every view form uses `form_for` or Devise's helpers, which add the token, except `orders/new`'s `%form{action: '/orders', method: 'POST'}`;
  - the `#order-checkout` button posts through `$.ajax`, and `admin.js`'s other calls also use `$.ajax`;
  - the layout has `csrf_meta_tags`, which jquery_ujs reads.
- **Proxy:** production sits behind a Cloudflare tunnel. Its redirects already go to `https://crabazon.us/...`, so Rails sees the HTTPS scheme and host. That matters because Rails' default CSRF origin check compares the browser's `Origin` header with them.
- **Tests:** `config/environments/test.rb` sets `allow_forgery_protection = false`, so specs only see CSRF where a spec turns it on.

## Goals / Non-Goals

**Goals:**
- Run on Rails 8.1's defaults, with CSRF protection on.
- No page or form breaks.

**Non-Goals:**
- Keeping sessions across the deploy, by the owner's choice.
- Cleaning up the 24 orders whose user is gone.

## Decisions

1. **`config.load_defaults 8.1` in place of the cache format line,** and delete `cookies_serializer.rb`, which repeats a value `load_defaults` sets.
2. **Delete the two dead associations** rather than mark `belongs_to :user` optional. The column doesn't exist, so the association can never have worked.
3. **A hidden `authenticity_token` field in the checkout form** (`hidden_field_tag :authenticity_token, form_authenticity_token`), so a native submit is accepted too. Converting the form to `form_tag` would also work, but changes more markup.
4. **CSRF specs turn protection on for themselves.** They set `ActionController::Base.allow_forgery_protection = true` around each example, so the rest of the suite keeps posting freely.
5. **Adopt the new cookie format** (owner's decision). Deploying signs everyone out, and rolling back does it again.

## Risks / Trade-offs

- [A page posts without a token and breaks] → All forms but one use Rails helpers, the one is fixed, and the AJAX calls carry the header. The production-mode run posts each kind. After deploy, the owner signs in, uses the cart, checks out, and edits a product and a category.
- [The origin check rejects posts behind the tunnel] → Production already sees `https://crabazon.us` as its own base URL. A real sign-in after deploy confirms it.
- [Everyone is signed out] → Accepted. Customers sign in again. Carts were session-only anyway.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps. Everyone is signed out.
3. Check:
   - the owner signs in, adds to the cart, checks out (the email arrives), and edits a product and a category;
   - a password reset works end to end.
4. Rollback: the README's rollback steps. This signs everyone out again. No migrations.
