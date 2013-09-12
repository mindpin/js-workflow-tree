jQuery ->
  guid = ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c)->
      r = Math.random()*16|0
      v = if c == 'x' then r else (r&0x3|0x8)
      v.toString(16)

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
      node.parent = @
      node.tree = @
      @children.push(node)
      @

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

    add_child: (node)->
      node.parent = this
      @children.push(node)

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
