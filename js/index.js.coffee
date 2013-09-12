jQuery ->
  guid = ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c)->
      r = Math.random()*16|0
      v = if c == 'x' then r else (r&0x3|0x8)
      v.toString(16)

  Home = 
    title: "Home"

    type: "home"

    children: []

    add_child: (node)->
      node.parent = @
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
      nodes[@id] = @

    @find: (id)->
      nodes[id]

    add_child: (node)->
      node.parent = this
      @children.push(node)

    is_leaf: ->
      @children.length == 0

    is_root: ->
      @parent == Home

    path: ->
      node_path = []
      node = @
      while($node != Home)
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
    Home: Home
    WFNode: WFNode
    Page: Page
    guid: guid
