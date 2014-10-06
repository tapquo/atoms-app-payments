"use strict"

class Atoms.Molecule.Creditcard extends Atoms.Molecule.Form

  @extends  : true

  @events   : ["submit"]

  @default  :
    events: ["submit"],
    children: [
      "Atom.Input": id: "name", name: "name", type: "text", placeholder: "Credit card name", events: ["keyup"], required: true
    ,
      "Atom.Input": id: "number", name: "number", type: "tel", maxlength: 16, placeholder: "Credit card number", events: ["keyup"], required: true
    ,
      "Atom.Input": id: "month", name: "month", type: "tel", placeholder: "MM", min: 1, max: 12, events: ["keyup"], required: true
    ,
      "Atom.Input": id: "year", name: "year", type: "tel", placeholder: "YYYY", minlength: 4, maxlength: 4, events: ["keyup"], required: true
    ,
      "Atom.Input": id: "cvc", name: "cvc", type: "tel", placeholder: "CVC", maxlength: 4, events: ["keyup"], required: true
    ,
      "Atom.Button": id: "submit", text: "Send Payment" ,  events: ["touch"], style: "fluid accept", disabled: true
    ]

  setValues: (attributes = {}) ->
    @[item].value attributes[item] for item of attributes


  # -- Children Bubble Events --------------------------------------------------
  onInputKeyup: (event, atom) ->
    checked = true
    child.error false for child in @children when child.constructor.base is "Input"
    atom.value().trim
    atom.value().replace(/\s+/g,"")

    if @number.value().length isnt 16 or not @validateCreditCard(@number.value())
      checked = false
      @number.error(true) if @number.value().length > 0
    else if not isNumber(@month.value()) or not ( 1 <= @month.value() <= 12 )
      checked = false
      @month.error(true) if @month.value().length > 0
    else if not isNumber(@year.value()) or not ( new Date().getFullYear() <= @year.value() )
      checked = false
      @year.error(true) if @year.value().length > 0
    else if new Date() >= new Date(@year.value(), @month.value(), 1)
      checked = false
      @year.error(true) if @year.value().length > 0
      @month.error(true) if @month.value().length > 0
    else if not isNumber(@cvc.value()) or not ( 0 <= @cvc.value() <= 999 )
      checked = false
      @cvc.error(true) if @cvc.value().length > 0
    else if @name.value().length < 4
      checked = false
      @name.error(true) if @name.value().length > 0

    if checked
      @submit.el.removeAttr "disabled"
    else
      @submit.el.attr "disabled", true


  validateCreditCard: (ccNumb) ->
    valid = "0123456789"
    len = ccNumb.length
    iCCN = parseInt(ccNumb)
    sCCN = ccNumb.toString()
    sCCN = sCCN.replace(/^\s+|\s+$/g, "").trim()

    iTotal = 0
    bResult = false

    bResult = false unless isNumber(ccNumb)

    if len is 0
      bResult = false
    else
      if len >= 15
        i = len

        while i > 0
          calc = parseInt(iCCN) % 10
          calc = parseInt(calc)
          iTotal += calc
          i--
          iCCN = iCCN / 10
          calc = parseInt(iCCN) % 10
          calc = calc * 2
          switch calc
            when 10
              calc = 1
            when 12
              calc = 3
            when 14
              calc = 5
            when 16
              calc = 7
            when 18
              calc = 9
            else
              calc = calc
          iCCN = iCCN / 10
          iTotal += calc
          i--
        if (iTotal % 10) is 0
          bResult = true
        else
          bResult = false

    bResult

  isNumber = (n) ->
    not isNaN(parseFloat(n)) and isFinite(n)
