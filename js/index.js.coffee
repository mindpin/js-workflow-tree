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
      this_clone = jQuery.extend(true, {}, @)
      JSON.stringify this_clone, (k, v)=>
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
      node.append_to(@)

    remove_child: (node)->
      node.remove()

    serialize_obj: ->
      return {
        id: @id
        text: @text
        note: @note
        children: @children.map (child)=> child.serialize_obj()
      }

    serialize: ->
      JSON.stringify @serialize_obj()

    @deserialize: (string)->
      obj = JSON.parse(string)
      tree = new Tree
      @_deserialize_r(tree, obj)

      return tree

    @_deserialize_r: (node, obj)->
      for obj_child in obj.children
        node_child = new WFNode({
          id: obj_child.id
          text: obj_child.text
          note: obj_child.note  
        })

        node.add_child node_child
        @_deserialize_r node_child, obj_child

  class WFNode
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
      index = @parent.children.indexOf(@)
      @prev.next = @next if @prev
      @next.prev = @prev if @next
      @next = undefined
      @prev = undefined
      @parent.children.splice(index, 1)
      @parent = undefined

    add_child: (node)->
      node.append_to(@)

    remove_child: (node)->
      node.remove()

    give_children: (node)->
      return false if node.children.length > 0
      node.children = @children
      @children = []
      node.children.forEach (child)=>
        child.parent = node
      true

    indent: ->
      return false if !@prev
      new_parent = @prev
      @remove()
      @append_to(new_parent)
      true

    outdent: ->
      return false if @is_base()
      new_sibling = @parent
      @remove()
      new_sibling.after(@)
      true

    index: ->
      @parent.children.indexOf(@)

    before: (node)->
      return if !@parent
      index = @index()
      node.parent = @parent

      if @prev
         @prev.next = node
         node.prev = @prev

      @prev = node
      node.next = @

      @parent.children.splice(index, 0, node)

    after: (node)->
      return if !@parent
      index =  @index() + 1 
      node.parent = @parent

      if @next
         @next.prev = node
         node.next = @next

      @next = node
      node.prev = @

      @parent.children.splice(index, 0, node)

    append_to: (parent)->
      @parent = parent
      last = @parent.children[@parent.children.length - 1]
      @parent.children.push(@)
      if last
        last.next = @
        @.prev = last
      @

    is_leaf: ->
      @children.length == 0

    is_base: ->
      @parent.constructor == Tree

    path: ->
      node_path = []
      node = @
      while($node.constructor != Tree)
        node_path.unshift(node)
        node = node.parent
        
      node_path.unshift(Home)
      return node_path

    serialize_obj: ->
      # id, #text, #note, #children
      return {
        id: @id
        text: @text
        note: @note
        children: @children.map (child)=> child.serialize_obj()
      }

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
