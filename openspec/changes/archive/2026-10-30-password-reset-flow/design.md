# Design

## Context

- **The loop, from the production log:** `PUT /users/password` saved the password and redirected to the `/users/password/edit?reset_password_token=...` URL it came from. Every following `GET` of that URL hit Devise's `require_no_authentication` filter and was redirected to the same URL.
- **Devise's redirects:** `Devise::PasswordsController#after_resetting_password_path_for` returns `after_sign_in_path_for(resource)` when `sign_in_after_reset_password` is on, which is the default. `require_no_authentication` also redirects signed-in users to `after_sign_in_path_for`, on every Devise page except sign-out.
- **This app's two versions:**
  - `ApplicationController#after_sign_in_path_for` uses Devise's default only when the referer is the sign-in page; otherwise it returns the stored location, then `request.referer`, then `root_path`.
  - `Users::SessionsController#after_sign_in_path_for` sends admins to `admin_index_path` and others to `index_path`. It overrides the first for sign-in only.
  - `Users::RegistrationsController#after_sign_up_path_for` returns `index_path`, so sign-up doesn't use either.
- **Nothing stores a location:** the app never calls `store_location_for`. Devise's `authenticate_user!` does store one for a signed-out visitor sent to sign-in, but sign-in's own override already ignores it.
- **The cart:** `session[:cart]` is created only in `Users::SessionsController#create` and `Users::RegistrationsController#create` (and reset after checkout). The index, category and product pages index into it whenever `user_signed_in?`, so a signed-in session without a cart raises. `ApplicationController#cart` runs before every action and already reads it. `CartsController` creates it on demand (`session[:cart] ||= {}`).
- **Why the reset spec missed it:** request specs send no `Referer` header, so the fallback went to `root_path`. The spec also never checked where the reset redirects.
- **Views:**
  - `devise/sessions/new.html.erb` and `devise/registrations/new.html.erb` repeat the same frame: `.container > .row > .col-lg-offset-3.col-lg-6.sign-in`, the logo `img.sign-in-image.center-block`, `h2.text-center`, the form, then `render "devise/shared/links"`.
  - Their fields use `.form-group` with `.form-control`, and the button is `btn btn-primary` with `id="sign-in-button"`.
  - `devise/passwords/new.html.erb` and `edit.html.erb` have none of this.
  - `devise/sessions/new.html.haml` is an older sign-in page. Production renders the `.erb` one, as the owner's screenshot of the sign-in page shows.

## Goals / Non-Goals

**Goals:**
- A reset ends with the customer signed in on `/index`.
- No Devise redirect can loop.
- All four account pages look the same.

**Non-Goals:**
- Returning a user to the page they were on before signing in. The app doesn't do that today for sign-in either.
- Restyling the account edit page, or any page outside Devise.

## Decisions

1. **Move sign-in's version up, keyed on `resource`.** `ApplicationController#after_sign_in_path_for(resource)` returns `resource.role == 'admin' ? admin_index_path : index_path`, and the sessions controller's copy goes. One rule for every Devise redirect, and it never points at a Devise page, so nothing can loop. It reads `resource` rather than `current_user`, because Devise passes the user it just signed in.
   - Alternative: keep the referer and skip it when it's a Devise page. More code, and it keeps a behavior that sign-in already doesn't use.
   - Alternative: set `sign_in_after_reset_password = false`. That only fixes the reset, and makes the customer sign in again.
2. **Give every signed-in session a cart in `ApplicationController#cart`:** `session[:cart] ||= {} if user_signed_in?`. That fixes it once, for the reset, remember-me and any other path Devise uses to sign someone in, instead of in each view that reads the cart. Signed-out visitors keep having no cart, so the layout's cart badge stays as it is.
3. **A card partial rendered as a layout.** Each page calls `render layout: 'devise/shared/card', locals: { title: '...' } do ... end`, and the partial holds the frame, the logo, the title, a `yield` for the form, and the links. The four pages stop repeating the frame. The logo keeps the same `src` the pages use today.
4. **Password forms reuse sign-in's classes:**
   - `.form-group`, `.form-control`, and the `btn btn-primary` button with `id="sign-in-button"`;
   - change-password keeps its "characters minimum" hint, laid out like sign-up's;
   - both keep `devise_error_messages!`, since replacing it everywhere belongs with the Rails 7.1 work.
5. **Delete `sessions/new.html.haml`.** Two templates for one action leave which one renders up to handler order. The `.erb` one is what production shows.

## Risks / Trade-offs

- [A signed-in user opening sign-up from a product page lands on `/index`, not the product] → Accepted. Sign-in already behaves that way.
- [Restyled forms break a field name] → The reset spec submits both password forms, and the sessions and registrations specs submit the other two.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps.
3. Check:
   - sign-in, sign-up, forgot-password and change-password all show the card;
   - the owner resets their password from the emailed link and lands signed in on `/index`, and the shop works without clearing cookies;
   - the owner signs in as admin and lands on `/admin`.
4. Rollback: the README's rollback steps. No migrations.
