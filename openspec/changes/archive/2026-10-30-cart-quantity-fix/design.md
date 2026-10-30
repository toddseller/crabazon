# Design

## Context

- The cart is `session[:cart]`, a hash of product id (as a string) to quantity, kept in Rails' encrypted cookie session. A customer can't edit it directly, only through `CartsController`.
- `CartsController`:
  - `add` increments the quantity without a check;
  - `update_cart` stores `params[:product_quantities].to_i`, so text becomes 0;
  - `remove` deletes the line;
  - all three answer XHR with JSON (`cart`, `cart_total`) and otherwise redirect. The page's JavaScript (`admin.js`) only handles success.
- `OrdersController#create`:
  - takes the total from `session[:cart_total]`;
  - creates the order, then one `OrdersProduct` per line;
  - lowers stock with `quantity -= n` and `save`, outside any transaction;
  - sends the order email, then empties the cart.

  The checkout button posts by XHR and expects `{ id }`. The existing spec posts without XHR and expects a redirect to the order.
- The layout shows `flash[:alert]` on every page.

## Goals / Non-Goals

**Goals:**
- Server-side checks at each place a quantity enters (add, update) and at checkout, with no reliance on the browser.
- Checkout all-or-nothing, and safe when two checkouts race for the same stock.

**Non-Goals:**
- Holding stock for items sitting in a cart. Stock is only claimed at checkout.
- A new cart UI. The existing alert area and a page reload carry the message.

## Decisions

1. **One quantity rule, used three times.** A private `CartsController` method accepts a quantity only when it is an `Integer` from 1 to `product.quantity`. `update_cart` parses with `Integer(params[:product_quantities], exception: false)`, so `"2abc"` and `"1.5"` are refused instead of becoming 2 or 1. `add` checks the incremented quantity. Checkout applies the same bounds to each line.

2. **Refusals:**
   - The server sets `flash[:alert]` and answers XHR with `422` and `{ error: message }`. Other requests are redirected to where they went before (`/` for add, `/orders/new` for update and checkout).
   - The JavaScript's add, update and checkout calls get an `error:` handler that reloads the page, which then shows the alert and the real cart.

   Alternative: show the message in the modal from JavaScript. That's more JavaScript for no extra safety.

3. **Checkout in one transaction with row locks.**
   - Inside `Order.transaction`, load the cart's products with `Product.lock.where(id: ids).order(:id)`. The fixed order means two checkouts lock rows in the same sequence and can't deadlock.
   - Validate every line (product exists, quantity from 1 to stock) and refuse an empty cart, before writing anything.
   - Compute the total from current prices.
   - Create the order and its lines, and lower stock with `decrement!`: one atomic `UPDATE`, which skips unrelated product validations.

   The email is sent after the transaction commits, so a refused or rolled-back checkout never emails. Alternative: an optimistic `UPDATE ... WHERE quantity >= n` per line. That's equally safe, but the row lock keeps validation and writing in plain Ruby.

4. **Order total from current prices,** summed from the locked products, not `session[:cart_total]`. The session total could be stale after a price change, and it was another value checkout took on trust.

5. **`OrdersController` requires sign-in** (`before_action :authenticate_user!`). The cart endpoints are public, and once checkout stopped calling `current_user.id` up front, a visitor's checkout would have created an ownerless order and taken stock. Found in review.

6. **A failed confirmation email is caught and logged, after the cart is emptied.** Rails doesn't write the session cookie when an exception escapes the request, so letting the email error through would keep the cart full and invite a duplicate order. Found in review.

7. **Tests:**
   - `cart_spec.rb` gets the refusals: 0, -3, `abc`, more than stock, and an add past stock. Each checks the 422, the alert, and that the cart is unchanged.
   - `orders_spec.rb` gets stock dropping after adding (no order, no stock change, no email, cart kept) and the empty cart.
   - Each is written first and shown failing.
   - The two-buyer race is covered by the lock, not a test. A threaded request spec would share one database connection per thread and be flaky. A review step checks the lock is taken before any read used for validation.

## Risks / Trade-offs

- [The row lock serializes checkouts of the same products] → Checkouts are rare and short at this shop's size.
- [A cart may hold products that were deleted since] → Checkout refuses with a message. `add`, `update` and the cart page would error on a missing product today, and that stays out of scope.
- [The page reload loses an unsaved quantity typed into another row] → Acceptable; each row updates on its own button.

## Migration Plan

1. Merge; CI runs the specs.
2. Deploy with the README's build steps.
3. Production check: the owner adds a product, tries a quantity of 0 and then one above the stock (each shows the alert, and the cart is unchanged), then a valid quantity, and checks out. The order total and stock are right.
4. Rollback: the README's rollback steps.
