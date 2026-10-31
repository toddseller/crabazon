# Proposal

## Why

Three places put a product's or category's text into HTML without escaping or quoting it. Admins type these values, so a mistyped or hostile value runs as markup:

- **The cart modal,** which every signed-in customer sees. `buildRow` in `app/assets/javascripts/admin.js` builds `'<img src="' + product.product_image + '"/>'` by string concatenation, and appends `product.name` with jQuery's `.append`, which parses a string as HTML. A product named `<img src=x onerror=...>`, or an image URL containing `"`, runs script in customers' browsers.
- **The order email.** `user_mailer/order_email.html.erb` writes `<img src=<%= product.product_image %> ...>` without quotes. ERB escapes the value, but an unquoted attribute ends at the first space, so a URL with a space can add attributes to the tag.
- **The admin's category picker.** `multiSelectCheckboxes` copies a ticked category's name into the dropdown as HTML, and removes it again by putting the name into a CSS selector, which breaks on a quote.

The values come only from admins, so this is defense in depth. If an admin account were taken over, the cart path would reach every customer.

## What Changes

- The cart row sets the image with `.attr('src', ...)` and the name with `.text(...)`, so neither is parsed as HTML.
- The order email quotes the `src` attribute.
- The category picker builds its label with `.text` and `.attr`, and finds it again by comparing titles, not with a selector string.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `product-catalog`: adds that product and category text is always shown as text.

## Impact

- Changed:
  - `app/assets/javascripts/admin.js`;
  - `app/views/user_mailer/order_email.html.erb`.
- New: `spec/mailers/user_mailer_spec.rb`.
- Production: one image rebuild and restart, with the README's rollback. No migrations. Existing products render the same.
- Out of scope:
  - Rails-rendered pages, whose HAML and ERB already escape these values;
  - a JavaScript test setup. The JavaScript is checked in a headless browser instead.
