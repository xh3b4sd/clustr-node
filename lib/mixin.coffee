exports.Mixin = (mixins...) ->
  class ClassReference

  for mixin in mixins
    for key, value of mixin::
      ClassReference::[key] = value

  ClassReference
