"use strict"

class Atoms.Molecule.StripeCreditCard extends Atoms.Molecule.Form

  @extends  : true

  @events   : ["submit", "error"]

  @default  :
    events  : ["submit", "error"]
    children: [
        "Atom.Input": id: "number", type: "tel", placeholder: "Credit card number", required: true, events: ["keyup"], maxlength: 16
      ,
        "Atom.Input": id: "month", type: "tel", placeholder: "MM", events: ["keyup"], maxlength: 2
      ,
        "Atom.Input": id: "year", type: "tel", placeholder: "YYYY", events: ["keyup"], maxlength: 4
      ,
        "Atom.Input": id: "cvc", type: "tel", placeholder: "CVC", events: ["keyup"], maxlength: 3
      ,
        "Atom.Button": id: "submit", text: "Send Payment", style: "fluid accept", disabled: true
    ]

  constructor: ->
    super
    do __loadScript if Atoms.$("[data-extension=stripe]").length is 0
    if @attributes.amount
      @submit.el.html (@attributes.concept or "Pay") + " #{@attributes.amount}"

  # Instance Methods
  post: (token) =>
    parameters =
      token     : token
      amount    : @attributes.amount
      reference : @attributes.reference

    $$.ajax
      url         : @attributes.url
      type        : "POST"
      dataType    : "json"
      data        : parameters
      contentType : "application/x-www-form-urlencoded"
      success: (xhr) =>
        @bubble "submit", xhr
        __?.Dialog.Loading.hide()
      error: (xhr, error) =>
        @bubble "error", error
        __?.Dialog.Loading.hide()

  # -- Children Bubble Events --------------------------------------------------
  onButtonTouch: (event, form) ->
    __?.Dialog.Loading.show()

    Stripe.setPublishableKey @attributes.key
    parameters =
      number    : @number.value()
      cvc       : @cvc.value()
      exp_month : @month.value()
      exp_year  : @year.value()
    window.Stripe.createToken parameters, (status, response) =>
      if response.error
        __?.Dialog.Loading.hide()
        @bubble "error", response.error
      else
        @post response.id
    false

  onInputKeyup: ->
    valid = true
    child.error false for child in @children when child.constructor.base is "Input"

    if not @attributes.url or not @attributes.key
      valid = false
    else if not Stripe.validateCardNumber @number.value()
      valid = false
      @number.error true
    else if not @month.value() or isNaN(parseInt(@month.value())) or @month.value().length < 2 or parseInt(@month.value()) > 12
      valid = false
      @month.error true
    else if not @year.value() or isNaN(parseInt(@year.value())) or parseInt(@year.value()) < new Date().getFullYear()
      valid = false
      @year.error true
    else if not Stripe.validateCVC @cvc.value()
      valid = false
      @cvc.error true

    if valid
      @submit.el.removeAttr "disabled"
    else
      @submit.el.attr "disabled", true
    false

__loadScript = (callback) ->
  script = document.createElement("script")
  script.type = "text/javascript"
  script.src = "https://js.stripe.com/v1/"
  script.setAttribute "data-extension", "stripe"
  document.body.appendChild script
