# Proposal

## Why

Any signed-in user can open any order at `/orders/:id`. Order numbers are sequential, so stepping through them shows every other customer's purchases: products, quantities and totals. `OrdersController#show` looks the order up by id alone. The order history list already shows only the customer's own orders, so the detail page is the one gap.

## What Changes

- `/orders/:id` shows an order only to the customer who placed it.
- Anyone else, admins included, is sent to their order history with "Order not found." The same response comes back whether the order exists or not, so it doesn't reveal which order numbers exist.
- A request spec covers your own order, someone else's order, and an order number that doesn't exist.

## Capabilities

### New Capabilities

- `order-history`: who can see which orders: the history list and the order detail page.

### Modified Capabilities

None.

## Impact

- Changed: `app/controllers/orders_controller.rb` (`show`), `spec/requests/orders_spec.rb`.
- Production: a deploy with the README's build steps.
- Out of scope: an admin view of all orders, which the app has never had.
