# Design

## Context

- **Cart modal:**
  - `CartsController` returns the cart as JSON, each product with its `name`, `product_image`, `price`, `quantity`, `id` and `cart_quantity`;
  - `buildRow(product)` in `admin.js` builds the row and is a global function;
  - the image is `$('<img src="' + product.product_image + '"/>')`;
  - the name is `buildTd(product.name)`, and `buildTd` calls `.append(value)`, which parses a string as HTML;
  - `price` and the total are numbers formatted with `toFixed`, and `id`, `cart_quantity` and `quantity` come from integer columns.
- **Order email:** `<img src=<%= "#{product.product_image}" %> width="50px" ...>`. `<%= %>` escapes `&`, `<`, `>` and quotes, but the attribute has no quotes, so a space ends it.
- **Category picker:**
  - `multiSelectCheckboxes` reads the ticked category's label with `.text()`;
  - it builds `'<span title="' + title + '">' + title + '</span>'` and appends that HTML;
  - on untick it removes `$('span[title="' + title + '"]')`, a selector that a quote in the name breaks.
- **Server-rendered views:** HAML `%img{src: ...}` and `<%= product.name %>` escape and quote. The Rails-rendered views need no change.
- **Tests:** there is no JavaScript test setup, and no mailer spec checks the email's HTML.

## Goals / Non-Goals

**Goals:**
- No product or category value can add markup in the cart, the email or the category picker.

**Non-Goals:**
- Validating that image URLs are well-formed.
- Adding a JavaScript test framework.

## Decisions

1. **Use jQuery's own setters in `buildRow`:**
   - `$('<img>').attr('src', product.product_image)`;
   - `buildTd($('<span>').text(product.name))`.

   `buildTd` stays as it is, because its other callers pass numbers or built elements.
2. **Quote the attribute in the email:** `<img src="<%= product.product_image %>" ...>`. ERB already escapes quotes, so quoting is all that's missing.
3. **Category picker:**
   - build the label with `$('<span>').attr('title', title).text(title)`;
   - remove it with `.filter(function () { return $(this).attr('title') === title; })`.
4. **Tests:**
   - a mailer spec renders the order email for a product whose URL contains `" onerror="x`, and checks with Nokogiri that the `img` has the whole URL as `src` and no `onerror`;
   - the JavaScript is checked in headless Chromium: a page loads the app's compiled `application.js` and calls `buildRow` with a hostile product, and the dumped DOM must show the name as text, the URL as one `src`, and no script having run. That runs before and after the fix.

## Risks / Trade-offs

- [A name that relied on HTML, such as `<b>` in a product name, now shows the tags] → No product name in production contains `<`, which the apply step checks with a read-only count.

## Migration Plan

1. Merge; CI runs the suite.
2. Deploy on the app host with the README's steps.
3. Check: the owner opens the cart, which shows images and names as before, ticks and unticks categories on a product form, and places an order whose email shows the product images.
4. Rollback: the README's rollback steps. No migrations.
