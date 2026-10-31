# Tasks

## 0. Branch

- [x] 0.1 Create `puma` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Swap the server

- [x] 1.1 Replace `gem 'thin'` with `gem 'puma'` and run `bundle install`. Verify:
  - the lockfile drops Thin, EventMachine and daemons, and adds only Puma;
  - the suite passes with the README's commands.
- [x] 1.2 Remove `-u thin` from the command in `docker-compose.yml`.

## 2. Production image

- [x] 2.1 Build the image as `linux/amd64` and run it with the new command, `RAILS_ENV=production` and `PORT=465`, against a throwaway `postgres:18` with an admin, two customers and one product with a stock of 1. Verify:
  - the log shows Puma 8.0.2, single mode, 0 to 5 threads, listening on 5666;
  - `/`, the stylesheet and the script return 200, and `/admin` redirects to sign-in;
  - the two customers each put the product in their cart, then check out at the same moment: exactly one order is created, and the stock ends at 0;
  - with `MAIL_HOST` pointing at an address that never answers, a checkout waits on the order email for about 5 seconds; meanwhile another page still answers at once. That's the reason for the change; on the old Thin image the same page waits behind the checkout. (The other checks use Rails' `:test` mail delivery, through an initializer mounted only for the check.)
  - an admin creates and updates a product;
  - a session cookie from an image built from `origin/master` reaches `/admin` on the new image;
  - the old image doesn't start with the new command, and does with `-u thin`, which confirms the rollback step.

  Remove the images and containers.

## 3. Review

- [x] 3.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `puma`, then archive this change (no spec sync; it changes no requirements) as a second commit, `Archive puma`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's checks.
