# order-history Specification

## Purpose

Defines who can see which orders: a customer sees their own order history and order details, and no one else's.

## Requirements

### Requirement: Customers see only their own orders
The order history and each order's detail page SHALL show a signed-in customer only the orders they placed. Asking for any other order SHALL give the same "Order not found." response whether that order exists or not.

#### Scenario: Own order
- **WHEN** a signed-in customer opens one of their own orders
- **THEN** the order's products, quantities and total are shown

#### Scenario: Someone else's order
- **WHEN** a signed-in customer opens an order placed by another customer
- **THEN** they are sent to their order history with "Order not found." and none of that order's details are shown

#### Scenario: Order that doesn't exist
- **WHEN** a signed-in customer opens an order number that doesn't exist
- **THEN** they get the same response as for someone else's order

#### Scenario: History list
- **WHEN** a signed-in customer opens their order history
- **THEN** only orders they placed are listed
