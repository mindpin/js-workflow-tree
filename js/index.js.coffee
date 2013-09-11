jQuery ->
  Home = 
    template: Template.make(@)

    title: "Home"

    type: "home"

    children: []

    add_child: (node)->
      node.parent = @
      @children.push(node)
      @
  
  class Node
    collapse: true
    type: "node"

    constructor: (params)->
      @template = Template.make(@)
      @children = []
      @note = params.note
      @text = params.text

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
    template: Template.make(@)

    type: "page"

    set_subject: (subject)->
      @subject = subject

    bread_crumbs: ->
      @subject.path() if @subject.path

  jQuery.extend window,
    Home: Home
    Node: Node
    Page: Page
