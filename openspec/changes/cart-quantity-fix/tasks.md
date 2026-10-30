# Tasks

## 0. Branch

- [x] 0.1 Create `cart-quantity-fix` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Cart quantities

- [x] 1.1 In `spec/requests/cart_spec.rb`, add examples for refused updates:
  - a quantity of 0, -3, `abc` or more than the stock gets 422 with an `error` in the JSON, and `flash[:alert]` is set;
  - each leaves `session[:cart]` and `session[:cart_total]` unchanged;
  - adding a product whose cart quantity already equals its stock is refused the same way.

  Run the file with the README's commands and show the new examples failing because the requests are accepted today.
- [x] 1.2 In `CartsController`, add the private quantity check (an `Integer` from 1 to the stock) and the refusal: `flash[:alert]`, then 422 JSON for XHR, or a redirect otherwise. Use them in `add` (the incremented quantity) and `update_cart` (parsed with `Integer(..., exception: false)`), and drop the `p` debug lines in the methods touched. Verify `cart_spec.rb` passes, including the original add, update and remove example.

## 2. Checkout

- [x] 2.1 In `spec/requests/orders_spec.rb`, add two examples:
  - **Stock dropped:** a cart whose quantity exceeds stock that dropped after adding is refused. No new order, stock unchanged, no email, the cart kept, and an alert naming the product.
  - **Empty cart:** refused with no order and no email.

  Make the valid checkout example also check the total is computed from current prices (change a price after adding). Run the file and show the new examples failing.
- [x] 2.2 Rewrite `OrdersController#create`:
  - one `Order.transaction`, which locks the cart's products with `Product.lock.where(id: ...).order(:id)`;
  - validate every line and refuse an empty cart before any write;
  - compute the total from current prices, create the order and its lines, and lower stock with `decrement!`;
  - send the email after the transaction;
  - refuse with the same 422 JSON or alert-and-redirect (to `/orders/new`) as the cart.

  Drop the `p` debug lines and `removeStock`. Verify `orders_spec.rb` passes, then the full suite.

## 3. Checkout page

- [x] 3.1 Set the quantity field's minimum to 1 in `app/views/orders/new.html.haml` and in `buildRow` in `admin.js`. Add `error:` handlers that reload the page to the add, update and checkout AJAX calls.

  Verify by building the image on the Mac as in the README (`docker build --platform linux/amd64` with a placeholder `DATABASE_URL`). In the image, the `application-*.js` that `public/assets`' manifest names for `application.js` must contain `location.reload` and `min="1"`. Then remove the image. `git status` must show no changes under `public/assets`.

## 4. Review

- [x] 4.1 Run `ponytail:ponytail-review` on the uncommitted diff. Report its findings, including whether checkout locks the products before reading the stock it validates, and wait for the owner to pick fixes before the first commit.

- [x] 4.2 Review fixes, each spec-first: `OrdersController` requires sign-in (a visitor's checkout is sent to sign-in with no order and no stock change), and a failed confirmation email is caught and logged after the cart is emptied (the order stands and the customer lands on it). Verify the full suite passes.

## Workflow follow-up

- Commit the code on `cart-quantity-fix`, then archive this change (syncing `shopping-cart` into `openspec/specs/`) as a second commit, `Archive cart-quantity-fix`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps.
- Production check by the owner:
  - quantities of 0 and above the stock show the alert, and the cart is unchanged;
  - a valid checkout gives the right total and stock.
- Next change: the Ruby step of the upgrade.
