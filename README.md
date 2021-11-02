# CardReader

Example of using the Visoin API to read credit card.  Demo is geared to work as needed in a specific project, but should be easy to change to other needs.

## Key things
### CreditCardValidator.swift
*Uses code from https://github.com/DigitalForms/CCValidator.  Needed to make some changes, so not pulling the code, rather imported it and changed locally.*

Used to check a string to see if it is a cc num.  Can also test a string to see if it is a cc date.

### CreditCardScanner.swift
Takes a Vision Request, grabs the images, then looks for ccnum, ccdate, and name.  When all three are found, calls the lambda cardDataFound if it was set. 

### PreviewView.swift
UIView that knows how to capture video and display it.

