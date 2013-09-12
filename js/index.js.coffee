jQuery ->
  guid = ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c)->
      r = Math.random()*16|0
      v = if c == 'x' then r else (r&0x3|0x8)
      v.toString(16)

  class JSONSerializable
    toJSON: ->
      @["#class"] = @constructor.name
      @

    defined_class: (v)->
      typeof v      == "object" &&
      v             != null     &&
      v.constructor != Object   &&
      v.constructor != Array

    serialize: ->
      cache = {}; counter = 0
      JSON.stringify @, (k, v)=>
        if @defined_class(v)
          return {ref: v.ref_id} if v.ref_id
          counter++
          v.ref_id = "#{v.constructor.name}#{counter}"
          cache[v.ref_id] = v
        v

    @deserialize: (json)->
      cache = {}
      JSON.parse json, (k, v)->
        if @ref_id
          cache[@ref_id] = @
          delete @ref_id
        return cache[v.ref] if v.ref
        if @["#class"]
          @.__proto__ = window[@["#class"]]::
          delete @["#class"]
        v

  class Tree
    jQuery.extend @, JSONSerializable
    jQuery.extend @::, JSONSerializable::

    trees = {}
    type: "tree"
    text: "Home"

    constructor: ->
      @id = guid()
      @children = []
      trees[@id] = @

    @find: (id)->
      trees[id]

    add_child: (node)->
      node.parent = @
      node.tree = @
      @children.push(node)
      @

  class WFNode
    jQuery.extend @, JSONSerializable
    jQuery.extend @::, JSONSerializable::

    nodes = {}
    collapse: true
    type: "wfnode"

    constructor: (params)->
      @id = guid()
      @children = []
      @note = params.note
      @text = params.text
      @tree = if parent.constructor == Tree then parent else parent.tree
      nodes[@id] = @

    @find: (id)->
      nodes[id]

    remove: ->
      return if !@parent
      index = @parent.children.indexOf(this)
      @parent.children.splice(index, 1)

    add_child: (node)->
      node.parent = this
      @children.push(node)

    append_to: (node)->
      @parent = node
      node.children.push(this)

    is_leaf: ->
      @children.length == 0

    is_root: ->
      @parent.constructor == Tree

    path: ->
      node_path = []
      node = @
      while($node.constructor != Tree)
        node_path.unshift(node)
        node = node.parent
        
      node_path.unshift(Home)
      return node_path

  Page =
    type: "page"

    set_subject: (subject)->
      @subject = subject

    bread_crumbs: ->
      @subject.path() if @subject.path

  jQuery.extend window,
    WFNode: WFNode
    Page: Page
    guid: guid
    Tree: Tree
