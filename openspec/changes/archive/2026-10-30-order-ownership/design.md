# Design

## Context

- `OrdersController` requires sign-in for every action, as of the cart quantity fix. `index` lists `Order.where(user_id: current_user)`. `show` uses `Order.find(params[:id])` with no owner check.
- `User has_many :orders`. Order ids are sequential.
- The test environment runs Better Errors (it's in the `:development, :test` group, and the test environment sets `consider_all_requests_local`). A raised `RecordNotFound` would therefore become an error page in specs, while production would show the 404 page.

## Goals / Non-Goals

**Goals:**
- Look up orders through the signed-in user, so the database query itself scopes to the owner.

**Non-Goals:**
- Admin access to all orders.
- Hiding order ids (UUIDs, slugs). Once the owner is checked, sequential ids reveal nothing.

## Decisions

1. **`current_user.orders.find_by(id: params[:id])`, and redirect to `orders_path` with `alert: 'Order not found.'` when it's nil.** The query can't return another customer's order, so there's no separate permission check to forget. A missing order and someone else's order get the same response.
   - Alternative: `current_user.orders.find`, which raises a 404. That gives the same protection, but the visitor sees the bare 404 page instead of their history, and in specs Better Errors turns the exception into an error page, which is a poor thing to assert on.

2. **Admins get no exception.** No page lists other customers' orders for admins, and adding one is a feature, not this fix.

3. **Specs go in `orders_spec.rb`,** with the customer and orders it already sets up. Each scenario is asserted, including that the other customer's product name doesn't appear in the response. They're written first and shown failing.

## Risks / Trade-offs

- [An admin who used `/orders/:id` to look up a customer's order loses that] → No link to it exists in the app. If it's needed, it becomes its own admin feature.

## Migration Plan

1. Merge; CI runs the specs.
2. Deploy with the README's build steps.
3. Production check: the owner opens one of their own orders (shown), then the number of an order they didn't place (sent to their history with "Order not found.").
4. Rollback: the README's rollback steps.
