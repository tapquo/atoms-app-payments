"use strict"

class Atoms.Molecule.Creditcard extends Atoms.Molecule.Form

  @extends  : true

  @events   : ["submit"]

  @default  :
    events: ["submit"]
    children: [
      "Atom.Input": id: "name", type: "text", maxlength: 16, placeholder: "Type your creditcard name...", events: ["keyup"], required: true
    ,
      "Atom.Input": id: "number", type: "number", maxlength: 16, placeholder: "Type your creditcard number...", events: ["keyup"], required: true
    ,
      "Atom.Input": id: "month", type: "number", placeholder: "MM", min: 1, max: 12, events: ["keyup"], required: true
    ,
      "Atom.Input": id: "year", type: "number", placeholder: "YYYY", maxlength: 4, events: ["keyup"], required: true
    ,
      "Atom.Input": id: "cvc", type: "number", placeholder: "CVC", maxlength: 4, events: ["keyup"], required: true
    ,
      "Atom.Button": id: "submit", text: "Pay" ,  events: ["touch"], style: "fluid accept", disabled: true
    ]

  constructor: () ->


  onInputKeyup: (event, atom) ->





#PUBLIC METHODS:
  isNumber = (n) ->
    not isNaN(parseFloat(n)) and isFinite(n)

