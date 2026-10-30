# Design

## Context

- **Devise's create:** `Devise::PasswordsController#create` sends the email. When `successfully_sent?` (which also sets the `send_instructions` flash notice), it redirects to `after_sending_reset_password_instructions_path_for(resource_name)`, which defaults to the sign-in page. `resource` is the user found by email at that point.
- **Routes:** `devise_for :users` overrides only the sessions and registrations controllers. Passwords use Devise's own controller.
- **Card:** `devise/shared/_card.html.erb` renders the logo, the title, the page's content and the Devise links. All four account pages use it.
- **Button:**
  - every `f.submit` gets `data-disable-with`, which jQuery UJS uses to disable the button while the form is sending;
  - Bootstrap 3.3.7 styles `.btn-primary.disabled`, `.btn-primary[disabled]` and `fieldset[disabled] .btn-primary`, with their hover, focus and active states, as `#337ab7`;
  - `products_controller.scss` sets `.btn-primary` to `#e58c33`, and its hover, active and focus states to `#f19833`, but has no disabled rule.
- **Reset window:** `config.reset_password_within = 6.hours`.

## Goals / Non-Goals

**Goals:**
- After asking for a reset, the customer sees clearly that the email was sent, and where.
- Primary buttons stay orange while their form sends.

**Non-Goals:**
- Changing what happens with an unknown email. Devise re-renders the form with "Email not found", as today.
- A "resend" button. Asking again from the form does the same.

## Decisions

1. **A `sent` action on a `Users::PasswordsController` subclass of Devise's,** routed as `devise_for ... passwords: 'users/passwords'` plus `GET /users/password/sent` inside `devise_scope :user`. Its `after_sending_reset_password_instructions_path_for` stores the address in `flash[:reset_email]`, drops Devise's `:notice`, and returns the new path.
   - The page reads the address from the flash. On a reload the flash is gone, so the page says "your email address" instead.
   - Alternative: the address in the URL query. That puts customer emails in server logs and browser history.
   - Alternative: render the page straight from `create`. That means overriding Devise's `create`, and a reload would resubmit the form and send a second email.
2. **Drop the notice there rather than blank the locale string.** It keeps the change in one place, and the page replaces exactly that message.
3. **One CSS rule for the disabled states,** matching Bootstrap's selectors and setting `background-color: #e58c33; border-color: #f19833;`. Bootstrap's `opacity: .65` and `cursor: not-allowed` still apply, so a disabled button looks faded, as everywhere else in Bootstrap.

## Risks / Trade-offs

- [The sent page shows the address someone typed] → Only the address entered in this browser's request, and only for an existing account. Devise already shows "Email not found" for others, so nothing new is revealed.
- [Signed-in users opening `/users/password/sent`] → Devise's `require_no_authentication` applies to every action in the controller, so they're sent to their landing page.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps.
3. Check:
   - asking for a reset keeps the button orange and lands on "Check your email" with the address;
   - the emailed link still resets the password and lands signed in.
4. Rollback: the README's rollback steps. No migrations.
