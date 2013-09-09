jQuery ->
  Home = {title: "Home", children: []}
  Home.add_child = (node)->
    node.parent = @
    @children.push(node)
    @
  
  class Node
    constructor: (params)->
      @children = []
      @collapse = true
      @note = params.note
      @text = params.text

    add_child: (node)->
      @parent = this
      @children.push(node)

    is_leaf: ()->
      @children.length == 0

    is_root: ()->
      @parent == null

    path: ->
      $node_path = [Home]
      $node = @
      while($node != Home)
        $node_path.push($node)
        $node = $node.parent
        
      return $node_path


      for child in @children
        $node_path.unshift(child)


      return $node_path

  class Page
    set_subject: ()->
      this

    bread_crumbs: ()->
      node.path()

  jQuery.extend window,
    Home: Home
    Node: Node
    Page: Page
