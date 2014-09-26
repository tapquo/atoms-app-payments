"use strict"

class Atoms.Molecule.Creditcard extends Atoms.Molecule.Form


  @extends  : true

  @events   : ["submit"]

  @default  :
    events: ["submit"],
    children: [
      "Atom.Input": id: "name", name: "name", type: "text", maxlength: 16, placeholder: "Type your creditcard name...", events: ["keyup"], required: true
    ,
      "Atom.Input": id: "number", name: "number", type: "number", maxlength: 16, placeholder: "Type your creditcard number...", events: ["keyup"], required: true
    ,
      "Atom.Input": id: "month", name: "month", type: "number", placeholder: "MM", min: 1, max: 12, events: ["keyup"], required: true
    ,
      "Atom.Input": id: "year", name: "year", type: "number", placeholder: "YYYY", maxlength: 4, events: ["keyup"], required: true
    ,
      "Atom.Input": id: "cvc", name: "cvc", type: "number", placeholder: "CVC", maxlength: 4, events: ["keyup"], required: true
    ,
      "Atom.Button": id: "submit", text: "Pay" ,  events: ["touch"], style: "fluid accept", disabled: true
    ]

  setValues: (attributes = {}) ->
    console.log "setValues", attributes
    @name.value(attributes.name)
    @number.value(attributes.number)
    @month.value(attributes.month)
    @year.value(attributes.year)
    @cvc.value(attributes.cvc)


  onInputKeyup: (event, atom) ->
    checked = true
    child.error false for child in @children when child.constructor.base is "Input"
    #Clear blank spaces:
    atom.value().trim
    atom.value().replace(/\s+/g,"")

    #Number check:
    if @number.value().length isnt 16 or not @validateCreditCard(@number.value())
      checked = false
      @number.error(true) if @number.value().length > 0
    #Month:
    else if not isNumber(@month.value()) or not ( 1 <= @month.value() <= 12 )
      checked = false
      @month.error(true) if @month.value().length > 0
    #Year:
    else if not isNumber(@year.value()) or not ( new Date().getFullYear() <= @year.value() )
      checked = false
      @year.error(true) if @year.value().length > 0
    #ExpirationDate < CurrentDate:
    else if new Date() >= new Date(@year.value(), @month.value(), 1)
      checked = false
      @year.error(true) if @year.value().length > 0
      @month.error(true) if @month.value().length > 0
    #CVC:
    else if not isNumber(@cvc.value()) or not ( 0 <= @cvc.value() <= 999 )
      checked = false
      @cvc.error(true) if @cvc.value().length > 0
    #name:
    else if @name.value().length < 4
      checked = false
      @name.error(true) if @name.value().length > 0

    if checked
      @submit.el.removeAttr "disabled"
    else
      @submit.el.attr "disabled", true


  validateCreditCard: (ccNumb) ->
    valid = "0123456789" # Valid digits in a credit card number
    len = ccNumb.length # The length of the submitted cc number
    iCCN = parseInt(ccNumb) # integer of ccNumb
    sCCN = ccNumb.toString() # string of ccNumb
    sCCN = sCCN.replace(/^\s+|\s+$/g, "").trim() # strip spaces

    iTotal = 0 # integer total set at zero
    bResult = false # by default assume it is NOT a valid cc

    # if it is NOT a number, you can either alert to the fact, or just pass a failure
    bResult = false unless isNumber(ccNumb) #alert("Not a Number");

    # Determine if it is the proper length
    if len is 0
      bResult = false
    else # ccNumb is a number and the proper length - let's see if it is a valid card number
      if len >= 15 # 15 or 16, for Amex or V/MC
        i = len # LOOP throught the digits of the card

        while i > 0
          calc = parseInt(iCCN) % 10 # right most digit
          calc = parseInt(calc) # assure it is an integer
          iTotal += calc # running total of the card number as we loop - Do Nothing to first digit
          i-- # decrement the count - move to the next digit in the card
          iCCN = iCCN / 10 # subtracts right most digit from ccNumb
          calc = parseInt(iCCN) % 10 # NEXT right most digit
          calc = calc * 2 # multiply the digit by two
          # Instead of some screwy method of converting 16 to a string and then parsing 1 and 6 and then adding them to make 7,
          # I use a simple switch statement to change the value of calc2 to 7 if 16 is the multiple.
          switch calc
            when 10 #5*2=10 & 1+0 = 1
              calc = 1
            when 12 #6*2=12 & 1+2 = 3
              calc = 3
            when 14 #7*2=14 & 1+4 = 5
              calc = 5
            when 16 #8*2=16 & 1+6 = 7
              calc = 7
            when 18 #9*2=18 & 1+8 = 9
              calc = 9
            else #4*2= 8 &   8 = 8  -same for all lower numbers
              calc = calc
          iCCN = iCCN / 10 # subtracts right most digit from ccNum
          iTotal += calc # running total of the card number as we loop
          i--
        # END OF LOOP
        if (iTotal % 10) is 0 # check to see if the sum Mod 10 is zero
          bResult = true # This IS (or could be) a valid credit card number.
        else
          bResult = false # This could NOT be a valid credit card number

    bResult # Return the results


#PUBLIC METHODS:
  isNumber = (n) ->
    not isNaN(parseFloat(n)) and isFinite(n)

