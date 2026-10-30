# Proposal

## Why

Rails 6.1 has had no fixes, security ones included, since October 2024. The upgrade goes one Rails minor version at a time, 6.1 to 7.0, then 7.1, 7.2, 8.0 and 8.1, so each step's breakage is small and the suite can pin it. This is the first.

## What Changes

- Rails 6.1.7.7 to 7.0.10, the last 7.0 release. Only Rails and the gems it needs change in the lockfile. `concurrent-ruby` stays at 1.2.3, because later versions break Rails 7.0 at boot.
- Rails 7.0 drops the classic autoloader, so Zeitwerk takes over. Under Zeitwerk, of the two files defining `UserMailer`, only the one in `app/controllers/` loads. That's the copy production already uses, and it sends from `crabazon@toddseller.com`. The mailer moves to `app/mailers/user_mailer.rb`, replacing the unused copy there, which named a different sender. Specs now pin the sender of both emails.
- The two Rails 7.0 deprecations that Rails 7.1 turns into errors are fixed now:
  - `config.active_record.legacy_connection_handling = false`;
  - `to_fs(:long)` for the order date on the order history page.
- No `config.load_defaults` change. Without it, Rails keeps its earlier cookie signing and session format, so signed-in customers stay signed in and keep their carts across the deploy, and a rollback to 6.1 still reads the new cookies.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. The shop's behavior is meant to stay exactly the same. The specs prove that, and two new assertions pin the email sender.

## Impact

- Changed:
  - `Gemfile`, `Gemfile.lock`, `config/application.rb`;
  - `app/views/orders/index.html.haml`;
  - `spec/requests/orders_spec.rb` and `spec/requests/registrations_spec.rb`.
- Moved: `app/controllers/user_mailer.rb` to `app/mailers/user_mailer.rb`, replacing the unused copy there.
- Production: one image rebuild and restart, with the README's rollback. No migrations.
- Out of scope:
  - adopting Rails 7.0 framework defaults (`load_defaults`);
  - Devise's `devise_error_messages!` deprecation (Devise 4.9 still supports it);
  - the Rails 7.1 step.
