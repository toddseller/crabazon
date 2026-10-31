# Tasks

## 0. Branch

- [x] 0.1 Create `sign-up-confirmation` from a freshly fetched `origin/master` with no upstream, and check with `git status` that you're on it and this change's artifacts came along.

## 1. Confirmation before the first sign-in

- [x] 1.1 Give each spec's `User.create!` `confirmed_at: Time.current` (17 call sites), and run the suite; it still passes.
- [x] 1.2 Rewrite `spec/requests/registrations_spec.rb`'s sign-up example, and add failing specs:
  - a valid sign-up creates an unconfirmed account, signs nobody in, redirects to `/users/sign_up/sent`, which names the address, and queues one confirmation email;
  - the email's link confirms the account and redirects to sign-in with the confirmed message, after which sign-in lands on `/index`;
  - signing in before confirming, with the right password, is refused with the confirm-first message.

  Show them fail: today sign-up signs in at once and sends the welcome email.
- [x] 1.3 Add `:confirmable`, set `allow_unconfirmed_access_for = 0.days` and `reconfirmable = false`, add the `sent` route and action and its card view, and remove the welcome email call and the cart line from `create`. Add the migration that sets `confirmed_at = created_at` where it's null, with a no-op down step, and update `db/schema.rb`. Give `db/seeds.rb`'s users `confirmed_at`. Run the whole suite; it passes.

## 2. A taken address looks like a new sign-up

- [x] 2.1 Add failing specs:
  - a valid sign-up with a taken email creates nothing, redirects to the same sent page naming the address, and queues one notice to the owner;
  - a taken email with a mismatched confirmation shows only the mismatch, sends nothing, and the page never contains "already been taken".

  Show them fail on "Email has already been taken".
- [x] 2.2 Write out `create` as design.md describes, and add `UserMailer#sign_up_attempt`. Run the whole suite; it passes.

## 3. Email design

- [x] 3.1 Add failing mailer specs. The confirmation, reset and notice emails each:
  - contain the header logo image, a heading, and an orange button whose link is the confirm, change-password or sign-in URL;
  - have the subject named in design.md.

  The notice also links to the reset page. Show them fail on today's plain emails.
- [x] 3.2 Cut `layouts/email.html.erb` and `shared/_email_button.html.erb` from the welcome email, and drop the footer's unsubscribe line. Set Devise's mailer layout, and write the three email views and subjects. Delete the welcome email method, its views and its preview entry. Style `confirmations/new` with the shared card. Run the whole suite; it passes.

## 4. Production image

- [x] 4.1 Build the image as `linux/amd64` and run it in production mode against a throwaway `postgres:18` loaded from the current schema, with one user created before the migration. Use Rails' `:test` mail delivery through a mounted initializer, and read the emails with `rails runner`. Verify:
  - after `db:migrate`, the old user is confirmed and still signs in;
  - a new sign-up gets the sent page, its confirmation link signs in after confirming, and an early sign-in is refused;
  - a taken address gets the same page and the owner's notice;
  - the resend page works.

  Render the three emails to HTML files and take headless Chrome screenshots, to compare with the welcome email's design. Remove the images and containers.

## 5. Review

- [x] 5.1 Run `ponytail:ponytail-review` on the uncommitted diff, report its findings and wait for the owner to pick fixes before the first commit.

## Workflow follow-up

- Commit the code on `sign-up-confirmation`, then archive this change (with spec sync into `customer-accounts`) as a second commit, `Archive sign-up-confirmation`, and open one PR. The required `test` check must pass.
- After merge, with the owner's approval, deploy on the app host with the README's steps (including `db:migrate`) and run the Migration Plan's checks.
