# shopping-cart Specification

## Purpose

Defines what the shopping cart accepts and what checkout requires, so a cart can never hold, or an order never record, a quantity the shop can't fill, and stock changes only by real purchases.

## Requirements

### Requirement: Cart quantities stay within stock
The cart SHALL hold, for each product, a whole number from 1 up to that product's current stock. A request that would set a quantity outside that range SHALL be refused with a message, leaving the cart unchanged.

#### Scenario: Adding past the stock
- **WHEN** a customer adds a product whose cart quantity already equals its stock
- **THEN** the request is refused with a message and the cart quantity stays the same

#### Scenario: Updating to an invalid quantity
- **WHEN** a customer updates a product's quantity to 0, a negative number, something that isn't a whole number, or more than the stock
- **THEN** the request is refused with a message and the cart quantity and total stay the same

#### Scenario: Updating to a valid quantity
- **WHEN** a customer updates a product's quantity to a whole number from 1 to the stock
- **THEN** the cart holds that quantity and the total reflects it

### Requirement: Checkout only fills what's in stock
Checkout SHALL create an order only when the cart has at least one product and every quantity is at most the product's current stock. Otherwise it SHALL create no order, change no stock, send no email, keep the cart, and tell the customer why.

#### Scenario: Stock dropped after adding
- **WHEN** a customer checks out a cart holding more of a product than is now in stock
- **THEN** no order is created, no stock changes, no email is sent, the cart is kept, and the customer sees a message naming the product

#### Scenario: Empty cart
- **WHEN** a customer checks out an empty cart
- **THEN** no order is created and no email is sent

#### Scenario: Valid cart
- **WHEN** a customer checks out a cart whose quantities are all within stock
- **THEN** one order is created whose total is the sum of current price times quantity, each product's stock goes down by its quantity, and the cart is emptied

### Requirement: Only signed-in customers check out
Checkout and order history SHALL require a signed-in user. A visitor who isn't signed in SHALL be sent to the sign-in page, with no order created and no stock changed, even if they have filled a cart.

#### Scenario: Visitor with a cart
- **WHEN** a visitor who isn't signed in adds a product and checks out
- **THEN** they are sent to the sign-in page, no order is created and the stock is unchanged

### Requirement: A failed confirmation email doesn't undo or repeat an order
When the order confirmation email can't be sent, the placed order SHALL stand, the cart SHALL be emptied and the customer SHALL be taken to the order, so checking out again can't place a duplicate.

#### Scenario: Email server down
- **WHEN** a customer checks out a valid cart and sending the confirmation email fails
- **THEN** the order exists, the cart is empty and the customer is sent to the order

### Requirement: Simultaneous checkouts can't oversell
When customers check out at the same time, the stock SHALL never go below zero, and the shop SHALL never record more orders of a product than its stock allowed.

#### Scenario: Last item, two buyers
- **WHEN** two customers each check out a cart holding the last unit of a product at the same moment
- **THEN** one order is created, the other checkout is refused, and the stock ends at zero
