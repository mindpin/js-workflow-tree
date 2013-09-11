jQuery.fn.data_element_array = (data_attr)->
  @find("[data-#{data_attr}]").toArray()

class Template
  re: /\$\[([\w\.\(\)]*)\]/g

  @make: (model)->
    new @(model)

  constructor: (@model)->
    @$el = jQuery("[data-template=#{@model.type}]").clone()
    @$el.model = @model
    @slots = @$el.data_element_array("jslot")
    @updateables = @slots.filter (el)=>
      field = $(el).data("jslot")
      !(@model[field] instanceof Function)

    @collections = @$el.data_element_array("jcollection")
    @hidden = @$el.data_element_array("jhide")

  bind_events: ->
    jQuery(@updateables).on "change", (evt)=>
      $el = $(evt.target)
      field = $el.data("jslot")
      @model[field] = $el.val()

  unbind_events: ->
    jQuery(@updateables).off "change"

  append_to: (selector)->
    @compile()
    @$el.appendTo(selector)
    @bind_events()
    @$el

  fill_collection: ->
    @collections.forEach (el)=>
      $el = jQuery(el)
      @model[$el.data("jcollection")].forEach (model)=>
        model.template.append_to($el)

  fill_slots: ->
    @slots.forEach (el)=>
      $el = jQuery(el)
      value = @model[$el.data("jslot")]
      return $el.val(value()) if value instanceof Function
      $el.val(value)

  hide_hidden: ->
    @hidden.forEach (el)->
      $el = jQuery(el)
      $el.hide() if $el.data("jhide")

  compile: ->
    throw new Error("没有找到模板") if !@$el.length
    @fill_slots()
    @fill_collection()
    @hide_hidden()
    @

jQuery.extend window,
  Template: Template
