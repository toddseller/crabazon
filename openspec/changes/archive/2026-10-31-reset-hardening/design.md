# Design

## Context

See proposal.md, Why.

- **The controller:** `Users::PasswordsController` subclasses Devise's. Its `after_sending_reset_password_instructions_path_for` passes the typed address to the "Check your email" page through the flash.
- **Delivery:** Devise sends mail with `deliver_now`.
- **Server:** Puma runs as a single process with its default threads; there is no `config/puma.rb`.
- **Cache and jobs:** no cache store and no Active Job adapter are configured, so production uses Rails' defaults (a file cache in `tmp/cache`, and the in-process `:async` adapter). The test environment's cache is a null store.

## Goals / Non-Goals

**Goals:** one answer and one timing for any address; at most 5 requests per address per hour.

**Non-Goals:** sign-up enumeration, a per-IP limit, a job queue that survives restarts. The proposal gives the reasons.

## Decisions

### Devise's paranoid mode for the answer

`config.paranoid = true`.
- **How it works:** for an unknown address, Devise then reports success and redirects exactly as for a known one. The resource it hands to our redirect hook is a new, unsaved user carrying the typed email, so the "Check your email" page still names the address.
- **Sign-in:** paranoid mode also covers it, but sign-in's messages are already the same for both cases. The modules it changes most (confirmable, lockable) aren't used.
- **Alternative rejected:** overriding `create` ourselves. Paranoid mode is Devise's built-in for exactly this, and it is one line.

### The page wording becomes conditional

`sent.html.erb` changes to: "If an account uses **x**, we've sent it a link to reset your password." The rest stays: the 6-hour validity and the spam-folder hint. Devise's paranoid flash notice is already removed by our hook, as the plain notice was.

### Reset emails go out in the background

`User#send_devise_notification` calls `devise_mailer.send(notification, self, *args).deliver_later`. This is Devise's documented hook for this.
- **Why:** an SMTP round trip before the page answers would still separate known addresses from unknown ones by timing.
- **Scope:** it covers every Devise email, which for this app is the reset and the password-change notice. The welcome and order emails are sent by our own code and stay as they are.
- **The adapter:** production gets Rails' default `:async` adapter, which sends from a thread in the web process.
- **Alternative rejected:** a real job queue (Solid Queue, Sidekiq). That means a new process or tables for one email type.
- **Logging:** Active Job logs a job's arguments, and the reset email's arguments include the raw reset token. `ActionMailer::MailDeliveryJob.log_arguments = false`, in `filter_parameter_logging.rb`, keeps tokens out of the log. A spec checks this.

### The limit is Rails' `rate_limit`, keyed by address, with its own memory store

```ruby
rate_limit to: 5, within: 1.hour, only: :create,
           by: -> { params.dig(:user, :email).to_s.strip.downcase },
           with: -> { redirect_to new_user_password_path, alert: 'Too many reset requests for that address. Try again in an hour.' },
           store: ActiveSupport::Cache::MemoryStore.new
```
- **The key:** spaces trimmed and lowercased, matching how Devise matches emails.
- **The store:** a memory store bounded at 32 MB by default.
  - With one Puma process, every request sees the same counts.
  - The default file cache would add a file per address typed, and nothing ever deletes them.
  - Test's null store would never count at all.
- **Message on the form:** the layout already shows `alert` on every page, so the form needs no change.
- **Alternative rejected:** a per-IP key. See proposal.md, Out of scope.

## Risks / Trade-offs

- **[A failed send is silent]** With `deliver_later`, an SMTP failure is logged instead of showing an error page. The visitor sees "Check your email", and nothing arrives. → They can ask again, and today's failure page wasn't much more help.
- **[Restarts]** A restart drops both pending emails and the limit's counts. → Restarts only happen on deploy. Someone asking during that moment can ask again, and the counts start fresh.
- **[Shared address]** A visitor who hits the limit for someone else's address blocks that person's resets for an hour. → That only takes 5 requests, but it's no worse than the inbox flooding the limit stops, and it clears by itself.

## Migration Plan

1. Deploy with the README's steps. There's no migration, and sessions are kept.
2. Owner checks:
   - a reset for their own address arrives, and the page names the address;
   - a reset for a made-up address shows the same page.
3. Rollback: the README's `crabazon-web:previous` steps.
