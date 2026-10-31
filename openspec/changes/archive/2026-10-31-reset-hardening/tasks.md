# Tasks

## 0. Branch

- [x] 0.1 Create `reset-hardening` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Same answer and timing

- [x] 1.1 In `spec/requests/passwords_spec.rb`, add the failing tests:
  - replace "shows an error for an unknown email" with a test that an unknown address sends nothing, redirects to `/users/password/sent`, and that page names the address;
  - the page for a known address uses the new "If an account uses" wording;
  - asking for a reset enqueues the email instead of sending it during the request. Wrap the existing full-flow test's request in `perform_enqueued_jobs`, so it still reads the delivered email.

  Run them with the README's commands and show they fail for the right reasons: "Email not found", the old wording, and the mail delivered during the request.
- [x] 1.2 Write the code:
  - set `config.paranoid = true`;
  - add `send_devise_notification` with `deliver_later` to `User`;
  - change the wording in `sent.html.erb`.

  Run the whole suite; it passes.

## 2. Limit per address

- [x] 2.1 Add the failing tests:
  - a sixth request for the same address within an hour, differing only in case and spaces, sends nothing, redirects to the form and shows the try-again message;
  - another address still goes through;
  - a request an hour later goes through again (use `travel`).

  Clear the limit's store before each example. Show them fail: today the sixth request is sent.
- [x] 2.2 Add the `rate_limit` from design.md to `Users::PasswordsController`. Run the whole suite; it passes.

## 3. Production image

- [x] 3.1 Build the image on the Mac as `linux/amd64`, and run it with `RAILS_ENV=production` against a throwaway `postgres:18` with one user. Use curl with the page's CSRF token:
  - a known and an unknown address both get 302 to `/users/password/sent`;
  - each sent page names its address;
  - the sixth request for one address gets the try-again message.

  Use an unreachable SMTP host, and check that the known address's request still answers quickly, with the send failure only in the log. Remove the images and containers.

## 4. Review

- [x] 4.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `reset-hardening`, then archive this change (with spec sync into `customer-accounts`) as a second commit, `Archive reset-hardening`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps and run the Migration Plan's checks.
