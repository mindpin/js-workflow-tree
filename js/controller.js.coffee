class WFNodeController
  layout: Page

  get: (id)->
    window.location.hash = "/#{id}"
    node = WFNode.find(id)
    @layout.set_subject(node)
    window.current_dataset =
      node: node
      template: node.template

jQuery.extend window,
  node_controller: new WFNodeController
