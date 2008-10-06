= Spree Order Gateway Input (SOGI, pronounced "soggy")

== What it is
Sogi is an extension to allow spree to accept orders via a web-service. The
goal is to be flexible enough to support orders from many different vendors.
The goal of the first release is to support Amazon.com orders.

The goal is order *input*. A later plugin will deal with orders that need to be
delivered to other services (e.g. a fulfillment house).

== What it isn't
It isn't a full RESTful interface for managing orders. Again, the goal is order
*input* not order management. The current goal of the project does not include
show, update, or delete commands. However, if someone believes it would be
useful, feel free to write it and submit a pull request on github. 

== Requirements
Requires the spree custom_order_data extension (to be released).

== Friends
It is designed to be used with the amazon_merchant gem. However, this gem is not required. (alpha version ready, soon to be released)


== My notes
TODO, move these into a new file once we start making releases.

should have a generator eventually?
subclass of Sogi::OrderParser
Sogi::AmazonOrderParser < Sogi::OrderParser

you post the order to the controller.
the controller makes an instance of order_input_format order parser
then passes the param[:order] to it.
today this is a single order? however, in the future, should probably support multiple
orders at a time.

the parser should just turn the orders into spree objects. 
* how do we deal with, say, 
  * existing orders?
  * existing customers, if we can even tell that
  * a failure to have enough information? a failure to parse?

what we dont want to do is leave the db in a half-baked state. 


... 
when parsing xml
the assumption is that the order is all a subelement of a particular element
(Even when you have many), so somehow specify what that order element is then
all of your method values and be dsl-like specifying that the xpath to the
element where you can find your data will be.

So there is a parser,
then something else takes the parser and actually creates the objects based on it. 

what is a good name for it. 
