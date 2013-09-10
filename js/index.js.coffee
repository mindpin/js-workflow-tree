jQuery ->
  Home = 
    template: Template.make("home")

    title: "Home"

    children: []

    add_child: (node)->
      node.parent = @
      @children.push(node)
      @
  
  jQuery.extend Home, WithTemplate::

  class Node
    jQuery.extend @::, WithTemplate::
    template: Template.make("node")
    collapse: true

    constructor: (params)->
      @children = []
      @note = params.note
      @text = params.text

    add_child: (node)->
      node.parent = this
      @children.push(node)

    is_leaf: ->
      @children.length == 0

    is_root: ->
      @parent == null

    path: ->
      $node_path = []
      $node = @
      while($node != Home)
        $node_path.unshift($node)
        $node = $node.parent
        
      $node_path.unshift(Home)
      return $node_path

  Page =
    template: Template.make("page")

    set_subject: (subject)->
      @subject = subject

    bread_crumbs: ->
      @subject.path() if @subject.path

  jQuery.extend Page, WithTemplate::

  jQuery.extend window,
    Home: Home
    Node: Node
    Page: Page
