# Proposal

## Why

The cart accepts any quantity, and checkout trusts it. A signed-in customer can set a quantity of -5 with one request to `POST /carts`. Checking out then *adds* 5 to the product's stock and records an order with a negative total. A quantity above the stock drives stock below zero. An empty cart checks out as an empty order and still sends a confirmation email. The only limits today are the page's quantity field and a greyed-out button, both in the browser.

## What Changes

- Adding a product refuses to take the cart's quantity past what's in stock.
- Updating a quantity accepts only a whole number from 1 to what's in stock. Zero, negatives, text and too much are refused, and the cart stays as it was. Removing a product stays the trash button's job.
- Checkout checks every line against current stock (stock may have dropped since the product was added) and refuses an empty cart. If anything is wrong, no order is created, no stock changes, no email goes out, and the customer sees why.
- The order total is computed at checkout from current prices and quantities, not taken from the session.
- Two customers checking out the last item at the same time can't both get it.
- Checkout and order history require signing in. Before, a visitor who wasn't signed in could fill a cart; the new checkout would have placed an order with no owner and taken the stock. Visitors are now sent to sign in.
- If the confirmation email fails, the order still stands, the cart is emptied and the customer lands on the order. The failure is logged. An error page would have invited a second, duplicate checkout.
- When the server refuses an update, an add or a checkout, the page reloads and shows the message in the layout's existing alert area. The checkout page's quantity field starts at 1.

## Capabilities

### New Capabilities

- `shopping-cart`: what the cart accepts and what checkout requires: quantities within stock, an order only for a valid cart, and stock that only checkout reduces.

### Modified Capabilities

None.

## Impact

- Changed:
  - `app/controllers/carts_controller.rb`, `app/controllers/orders_controller.rb` and `app/controllers/application_controller.rb` (a shared `refuse`);
  - `app/views/orders/new.html.haml` (`min: 1`);
  - `app/assets/javascripts/admin.js` (`min="1"`, plus error handlers that reload the page);
  - `spec/requests/cart_spec.rb` and `spec/requests/orders_spec.rb`.
- Production: a deploy with the README's build steps. Assets are precompiled during the build, so the JavaScript change ships with it.
- Out of scope:
  - `/orders/:id` shows any order to anyone who knows its number (products and total, no personal details); its own change;
  - price changes for items already in a cart, beyond the total using current prices;
  - the `p` debug output in the cart and order controllers, except where rewritten code drops it.
