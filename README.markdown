== Spree Order Gateway Input (SOGI)

= What it is
Sogi is an extension to allow spree to accept orders via a web-service. The
goal is to be flexible enough to support orders from many different vendors.
The goal of the first release is to support Amazon.com orders.

The goal is order *input*. A later plugin will deal with orders that need to be
delivered to other services (e.g. a fulfillment house).

= What it isn't
It isn't a full RESTful interface for managing orders. Again, the goal is order
*input* not order management. The current goal of the project does not include
show, update, or delete commands. However, if someone believes it would be
useful, feel free to write it and submit a pull request on github. 

= Requirements
Requires the spree custom_order_data extension (to be released).

= Friends

It is designed to be used with the amazon_merchant gem. However, this gem is not required. (alpha version ready, soon to be released)

