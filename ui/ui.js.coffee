class WorkflowTreeEditorUi
  constructor: (@ui)->
    @$page = @ui.$page
    @render()
    @bind_events()

  render: ->
    @$elm = jQuery('<div></div>')
      .addClass('editor')

    @$textarea = jQuery('<textarea></textarea>')
      .appendTo(@$elm)

    @$elm.appendTo(@$page)

  focus_to: (node)->
    offset = node.node_ui.offset()

    @$elm.css
      left: offset.left
      top: offset.top
      right: 40
      height: node.node_ui.height()

    @$textarea.val(node.text)

  blur: ->
    @$textarea.blur()

  bind_events: ->
    @$textarea.on 'focus', =>
      if @ui.editor != @
        @ui.change_editor()

class WorkflowTreeNodeUi
  constructor: (@node)->
    @render()

  render: ->
    @$elm = jQuery('<div></div>')
      .addClass('wfnode')
      .data('node', @node)

    @$text = jQuery('<div></div>')
      .addClass('text')
      .html(@node.text)
      .appendTo(@$elm)

    @$children = jQuery('<div></div>')
      .addClass('children')
      .appendTo(@$elm)
      
    if @node.parent
      @$elm.appendTo(@node.parent.node_ui.$children)
    else
      @$elm.addClass('root').appendTo(@node.tree_ui.$page)

  focus: ->
    editor = @node.tree_ui.editor
    editor.focus_to(@node)

  hover: ->
    editor = @node.tree_ui.hover_editor
    editor.focus_to(@node)
    editor.blur()

  offset: ->
    @$elm.position()

  height: ->
    @$text.height()


class WorkflowTreeUi
  constructor: (@tree)->

  render: ->
    @build_page()
    @build_editor()
    @build_nodes()

    @tree.children[0].node_ui.focus()
    @tree.children[0].node_ui.hover()

    @bind_events()

  build_page: ->
    if !@$page
      @$page = jQuery('<div></div>')
        .addClass('workflow-tree-page')
        .prependTo(jQuery('body'))

  build_editor: ->
    if !@editor
      @editor = new WorkflowTreeEditorUi(@)
      @hover_editor = new WorkflowTreeEditorUi(@)

  build_nodes: ->
    if @tree.children.length == 0
      @tree.add_child new WFNode({})

    @_build_r(@tree)

  _build_r: (node)->
    node.tree_ui = @
    node.node_ui = new WorkflowTreeNodeUi(node)
    for child in node.children
      @_build_r(child)

  change_editor: ->
    e = @editor
    @editor = @hover_editor
    @hover_editor = e

  bind_events: ->
    @$page.delegate '.wfnode .text', 'mouseover', ->
      $node = jQuery(this).closest('.wfnode')
      node = $node.data('node')
      node.node_ui.hover()

jQuery.extend window,
  WorkflowTreeUi: WorkflowTreeUi