jQuery.fn.data_element_array = (data_attr)->
  @find("[data-#{data_attr}]").toArray()

jQuery.fn.is_tag = (tag_name)->
  @[0].tagName.toLowerCase() == tag_name.toLowerCase()

class Template
  re: /\$\[([\w\.\(\)]*)\]/g

  @make: (model)->
    new @(model)

  constructor: (@model)->
    @$el         = jQuery("[data-jtemplate=#{@model.type}]").clone()
    @$el.model   = @model
    @slots       = @$el.data_element_array("jslot")
    @updateables = @slots.filter (el)=>
      $el      = $(el)
      is_input = $el.is_tag("input") || $el.is_tag("textarea")
      field    = $el.data("jslot")
      !(@model[field] instanceof Function) && is_input

    @collections = @$el.data_element_array("jcollection")
    @hidden = @$el.data_element_array("jhide")

  bind_events: ->
    jQuery(@collections).on "collection_update", =>
      @fill_collections()

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

  destroy: ->
    @unbind_events()
    @$el.remove()
    @model.template = Template.make(@model)

  fill_collections: ->
    @collections.forEach (el)=>
      $el = jQuery(el)
      @model[$el.data("jcollection")].forEach (model)=>
        model.template.append_to($el)

  fill_slots: ->
    @slots.forEach (el)=>
      $el      = jQuery(el)
      field    = $el.data("jslot")
      value    = if value instanceof Function then @model[field]() else @model[field]
      el_field = if $el.is_tag("textarea") || $el.is_tag("input") then "val" else "text"
      $el[el_field](value)

  hide_hidden: ->
    @hidden.forEach (el)->
      $el = jQuery(el)
      $el.hide() if $el.data("jhide")

  compile: ->
    throw new Error("没有找到模板") if !@$el.length
    @fill_slots()
    @fill_collections()
    @hide_hidden()
    @

jQuery.extend window,
  Template: Template
