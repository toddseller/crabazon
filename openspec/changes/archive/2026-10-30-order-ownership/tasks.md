# Tasks

## 0. Branch

- [x] 0.1 Create `order-ownership` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Order detail for its owner only

- [x] 1.1 In `spec/requests/orders_spec.rb`, add examples:
  - the signed-in customer's own order shows its product names and total;
  - another customer's order (with a product only that order has) redirects to `/orders` with `flash[:alert]` "Order not found.", and the response doesn't include that product's name;
  - an order id that doesn't exist gets the same redirect and alert.

  Run the file with the README's commands and show the other-customer example failing because the order is shown today.
- [x] 1.2 In `OrdersController#show`, look the order up with `current_user.orders.find_by(id: params[:id])` and redirect to `orders_path` with `alert: 'Order not found.'` when it's nil. Verify `orders_spec.rb` passes, then the full suite.

## 2. Review

- [x] 2.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `order-ownership`, then archive this change (syncing `order-history` into `openspec/specs/`) as a second commit, `Archive order-ownership`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps.
- Production check by the owner: their own order is shown; another customer's order number sends them to their history with "Order not found."
- Next change: the Ruby step of the upgrade.
