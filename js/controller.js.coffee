class WFNodeController
  get: (id)->
    window.location.hash = "/#{id}"
    node = WFNode.find(id)
    window.current_dataset =
      node: node

jQuery.extend window,
  node_controller: new WFNodeController
