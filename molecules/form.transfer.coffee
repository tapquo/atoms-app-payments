"use strict"

class Atoms.Molecule.Transfer extends Atoms.Molecule.Form

  CODE_LENGTHS =
    AD: 24
    AE: 23
    AT: 20
    AZ: 28
    BA: 20
    BE: 16
    BG: 22
    BH: 22
    BR: 29
    CH: 21
    CR: 21
    CY: 28
    CZ: 24
    DE: 22
    DK: 18
    DO: 28
    EE: 20
    ES: 24
    FI: 18
    FO: 18
    FR: 27
    GB: 22
    GI: 23
    GL: 18
    GR: 27
    GT: 28
    HR: 21
    HU: 28
    IE: 22
    IL: 23
    IS: 26
    IT: 27
    JO: 30
    KW: 30
    KZ: 20
    LB: 28
    LI: 21
    LT: 20
    LU: 20
    LV: 21
    MC: 27
    MD: 24
    ME: 22
    MK: 19
    MR: 27
    MT: 31
    MU: 30
    NL: 18
    NO: 15
    PK: 24
    PL: 28
    PS: 29
    PT: 25
    QA: 29
    RO: 24
    RS: 22
    SA: 24
    SE: 24
    SI: 19
    SK: 24
    SM: 27
    TN: 24
    TR: 26

  @extends  : true

  @events   : ["submit"]

  @default  :
    events: ["submit"]
    children: [
      "Atom.Input": id: "countrycode", type: "text", maxlength: 2, placeholder: "Country code", events: ["keyup"], required: true
    ,
      "Atom.Input": id: "checkdigits", type: "number", maxlength: 2, placeholder: "Check digits", events: ["keyup"], required: true
    ,
      "Atom.Input": id: "bankandoffice", type: "text", maxlength: 30, placeholder: "Bank and office", events: ["keyup"], required: true
    ,
      "Atom.Button": id: "submit", text: "Pay" ,  events: ["touch"], style: "fluid accept", disabled: true
    ]

  setValues: (attributes = {}) ->
    console.log "setValues", attributes
    @countrycode.value(attributes.countrycode)
    @checkdigits.value(attributes.checkdigits)
    @bankandoffice.value(attributes.bankandoffice)


  onInputKeyup: (event, atom) ->
    checked = true
    child.error false for child in @children when child.constructor.base is "Input"
    #Clear blank spaces:
    atom.value().trim
    atom.value().replace(/\s+/g,"")

    if @countrycode.value().length > 0 and @checkdigits.value().length > 0 and @bankandoffice.value().length > 0
      iban = @countrycode.value() + @checkdigits.value() + @bankandoffice.value()
      iban = String(iban).toUpperCase().replace(/[^A-Z0-9]/g, "") # keep only alphanumeric characters
      code = iban.match(/^([A-Z]{2})(\d{2})([A-Z\d]+)$/) # match and capture (1) the country code, (2) the check digits, and (3) the rest
      digits = (code[3] + code[1] + code[2]).replace(/[A-Z]/g, (letter) ->
          String letter.charCodeAt(0) - 55 #get asiggned number for letter
      )

    #Countrycode check:
    if @countrycode.value().length isnt 2
      checked = false
      @countrycode.error(true) if @countrycode.value().length > 0
    #Check digits:
    else if @checkdigits.value().length isnt 2
      checked = false
      @checkdigits.error(true) if @checkdigits.value().length > 0
    #check bankandoffice:
    else if !code or iban.length isnt CODE_LENGTHS[code[1]] or mod97(digits) isnt 1
      checked = false
      @bankandoffice.error(true) if @bankandoffice.value().length > 0


    if checked
      @submit.el.removeAttr "disabled"
    else
      @submit.el.attr "disabled", true

#PUBLIC METHODS:
  isNumber = (n) ->
    not isNaN(parseFloat(n)) and isFinite(n)

  mod97 = (string) ->
    return 0 if !string
    checksum = string.slice(0, 2)
    offset = 2
    while offset < string.length
      fragment = String(checksum) + string.substring(offset, offset + 7)
      checksum = parseInt(fragment, 10) % 97
      offset += 7
    checksum



