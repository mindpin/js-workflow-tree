class Template
  re: /\$\[([\w\.\(\)]*)\]/g

  @make: (selector)->
    new @(selector)

  constructor: (type)->
    @raw = jQuery(".#{type}-template").html()

  compile: (data)->
    throw new Error("没有找到模板") if !@raw
    @raw.replace @re, (_, capture)=>
      call = eval("data.#{capture.split(".")[1..-1].join(".")}")
      if call instanceof Array
        call.map((child)-> child.compile()).join("")
      else call

  el: (data)->
    $(@compile(data)).hide()

class WithTemplate
  compile: ->
    @template.compile(@)

  el: ->
    @template.el(@)

jQuery.extend window,
  Template: Template
  WithTemplate: WithTemplate
