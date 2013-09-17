class WorkflowTreeControlUi
  constructor: (@ui)->
    @$page = @ui.$page
    @render()
    @bind_events()

  render: ->
    @$elm = jQuery('<div></div>')
      .addClass('controls')
      .hide()

    @$expand_btn = jQuery('<div></div>')
      .addClass('expand-btn')
      .prop('draggable', false)
      .appendTo(@$elm)

  bind_events: ->
    @$expand_btn.on 'click', =>
      if @node.collapsed
        @$expand_btn.removeClass('plus').addClass('minus')
        @node.node_ui.expand()
      else
        @$expand_btn.addClass('plus').removeClass('minus')
        @node.node_ui.collapse()

  show_on: (@node)->
    # console.log @node.text, @node.is_leaf()

    if node.is_leaf()
      @hide()
    else
      if @node.collapsed
        @$expand_btn.addClass('plus').removeClass('minus')
      else
        @$expand_btn.removeClass('plus').addClass('minus')

      @$elm.appendTo(@node.node_ui.$name).show()

  hide: ->
    @$elm.hide()

class WorkflowTreeEditorUi
  constructor: (@ui)->
    @$page = @ui.$page
    @render()
    @bind_events()
    @set_timer()

  set_main_focus: (bool)->
    if bool
      @is_main = true
      @$elm.addClass 'focus'
    else
      @is_main = false
      @$elm.removeClass 'focus'

  render: ->
    @$elm = jQuery('<div></div>')
      .addClass('editor')

    @$textarea = jQuery('<textarea></textarea>')
      .appendTo(@$elm)

    @$elm.appendTo(@$page)

  focus_to: (node, pos)->
    @focus_node = node

    offset = node.node_ui.offset()

    @$elm.css
      left: offset.left + 30
      top: offset.top
      right: 40
      height: node.node_ui.height()

    if @focus_node.is_base()
      @$elm.addClass('base')
    else
      @$elm.removeClass('base')

    @$textarea.val(node.text)

    if typeof(pos) == 'number'
      if pos == -1
        @set_key_cursor_pos(node.text.length)
      else
        @set_key_cursor_pos(pos)


  blur: ->
    @$textarea.blur()

  bind_events: ->
    @$textarea.on 'focus', =>
      if @ui.focus_editor != @
        @ui.change_editor()

    @$textarea.on 'mouseover', =>
      @focus_node.node_ui.show_control()

    @$textarea.on 'keydown', (evt)=>

      if evt.keyCode == 13
        evt.preventDefault()

        t = @get_text_of_key_cursor()
        @focus_node.node_ui.append_new_child t.before, t.after
        setTimeout =>
          @set_key_cursor_pos(0)
        , 1

      # backspace
      if evt.keyCode == 8
        t = @get_text_of_key_cursor()
        if t.before == ''
          @focus_node.node_ui.back_remove t.after

      # ↑
      if evt.keyCode == 38
        evt.preventDefault()
        @focus_node.node_ui.focus_up(0)

      # ↓
      if evt.keyCode == 40
        evt.preventDefault()
        @focus_node.node_ui.focus_down(0)

      # ←
      if evt.keyCode == 37
        if @caret() == 0
          evt.preventDefault()
          @focus_node.node_ui.focus_up(-1)

      # →
      if evt.keyCode == 39
        if @caret() == @focus_node.text.length
          evt.preventDefault()
          @focus_node.node_ui.focus_down(0)

      # tab
      if evt.keyCode == 9
        if evt.shiftKey
          evt.preventDefault()
          @focus_node.node_ui.tab_outdent()
        else
          evt.preventDefault()
          @focus_node.node_ui.tab_indent()

  set_timer: ->
    setInterval =>
      if @is_main && @focus_node
        @focus_node.node_ui.update_text(@$textarea.val())
    , 100

  # 取得输入光标在框里的位置
  caret: ->
    node = @$textarea[0]

    if node.selectionStart 
      return node.selectionStart

    else if(!document.selection) 
      return 0

    c    = "\u0001"
    sel  = document.selection.createRange()
    txt  = sel.text
    dul  = sel.duplicate()
    len  = 0

    try
      dul.moveToElementText(node)
    catch e
      return 0

    sel.text = txt + c
    len = dul.text.indexOf(c)
    sel.moveStart('character', -1)
    sel.text = ""
    return len

  get_text_of_key_cursor: ->
    return {
      before: @$textarea.val()[0...@caret()]
      after: @$textarea.val()[@caret()..-1]
    }

  set_key_cursor_pos: (pos)->
    node = @$textarea[0]

    if node.setSelectionRange
      node.setSelectionRange pos, pos

    else if node.createTextRange
      range = node.createTextRange()
      range.collapse(true)
      range.moveEnd('character', pos)
      range.moveStart('character', pos)
      range.select()

class WorkflowTreeNodeUi
  constructor: (@node)->
    @render()

  render: ->
    @$elm = jQuery('<div></div>')
      .addClass('wfnode')
      .data('node', @node)

    @$name = jQuery('<div></div>')
      .addClass('name')
      .appendTo(@$elm)

    @$joint = jQuery('<div></div>')
      .addClass('joint')
      .html('•')
      .appendTo(@$name)

    @$text = jQuery('<div></div>')
      .addClass('text')
      .html(@node.text)
      .appendTo(@$name)

    @$arrow = jQuery('<div></div>')
      .addClass('arrow')
      .appendTo(@$name)

    @$children = jQuery('<div></div>')
      .addClass('children')
      .appendTo(@$elm)

    if @node.collapsed
      @$children.hide()
      @$elm.addClass('collapsed')
    
    if @node.next && @node.next.node_ui
      @node.next.node_ui.$elm.before(@$elm)
    else if @node.prev
      @node.prev.node_ui.$elm.after(@$elm)
    else if @node.parent
      @$elm.appendTo(@node.parent.node_ui.$children)
    else
      @$elm.addClass('root').appendTo(@node.tree_ui.$page)

  focus: (pos)->
    editor = @node.tree_ui.focus_editor
    editor.focus_to(@node, pos)

  hover: ->
    editor = @node.tree_ui.hover_editor
    editor.focus_to(@node)
    editor.blur()

  show_control: ->
    control = @node.tree_ui.control
    control.show_on(@node)

  hide_control: ->
    control = @node.tree_ui.control
    control.hide()

  offset: ->
    pos = @$elm.position()
    return {
      left: pos.left + 24
      top: pos.top
    }

  height: ->
    @$text.height()

  # 当前子树最后一个叶子节点
  # 需要考虑折叠的情况
  last_leaf_node: ->
    return @node if @node.is_leaf() || @node.collapsed
    children = @node.children
    children[children.length - 1].node_ui.last_leaf_node()

  # 下一个子树的第一个节点
  next_tree_first_node: ->
    return @node.next if @node.next
    return @node.parent.node_ui.next_tree_first_node() if !@node.is_base()

  prev_ui: ->
    return @node.prev.node_ui if @node.prev

  next_ui: ->
    return @node.next.node_ui if @node.next

  # 视觉上的上一个节点
  # 折起来的节点不考虑
  visible_up_node: ->
    return @prev_ui().last_leaf_node() if @node.prev
    return @node.parent if !@node.is_base()

  # 视觉上的下一个节点
  # 折起来的节点不考虑
  visible_down_node: ->
    return @next_tree_first_node() if @node.is_leaf() || @node.collapsed
    return @node.children[0]

  focus_up: (pos)->
    @visible_up_node().node_ui.focus(pos) if @visible_up_node()

  focus_down: (pos)->
    @visible_down_node().node_ui.focus(pos) if @visible_down_node()

  append_new_child: (before_text, after_text)->
    new_node = new WFNode({
      text: after_text
    })

    # 三种情况：
    # 第1种情况，node没有子节点，或node被折叠
    #   向上添加相邻兄弟节点

    # 第2种情况，node有子节点， after_text 不为空
    #   向上添加相邻兄弟节点
    
    # 第3种情况，node有子节点， after_text 为空
    #   向目前的第一个子节点添加 prev 节点

    if @node.is_leaf() || @node.collapsed
      @node.before(new_node)
      new_node.text = before_text
      @node.node_ui.update_text(after_text)
      focus_node = @node

    else 
      if after_text.length > 0
        @node.before(new_node)
        new_node.text = before_text
        @node.node_ui.update_text(after_text)
        focus_node = @node

      else
        @node.children[0].before(new_node)
        focus_node = new_node

    new_node.tree_ui = @node.tree_ui
    new_node.node_ui = new WorkflowTreeNodeUi(new_node)

    setTimeout =>
      focus_node.node_ui.focus(0)
    , 1

    @save()

  back_remove: (text)->
    # 多情况：
    # 第一种情况，node有prev，prev是叶子
    #   将 prev.text + text 赋值给当前节点，移除prev
    # 第二种情况，node有prev，prev不是叶子
    #   如果 node.text == '' 且 node 是叶子，移除当前node，聚焦 visible_up_node
    #   否则什么都不做
    # 第三种情况，node有parent
    #   如果 node.text == '' 且 node 是叶子，移除当前node，聚焦 node.parent
    #   否则什么都不做

    if @node.prev 
      if @node.prev.is_leaf()
        pos = @node.prev.text.length
        @update_text("#{@node.prev.text}#{text}")
        @node.prev.node_ui.remove()
        focus_node = @node
      else
        if @node.text == '' && @node.is_leaf()
          focus_node = @visible_up_node()
          pos = focus_node.text.length
          @remove()
        else
          return false
    else if !@node.is_base()
      if @node.text == '' && @node.is_leaf()
        focus_node = @node.parent
        pos = focus_node.text.length
        @remove()
      else
        return false
    else
      return false


    setTimeout =>
      focus_node.node_ui.focus(pos)
    , 1

    @save()

  tab_indent: ->
    if @node.indent()
      @$elm.appendTo(@node.parent.node_ui.$children)

      setTimeout =>
        @focus()
      , 1

      @save()

  tab_outdent: ->
    if @node.outdent()
      @node.prev.node_ui.$elm.after(@$elm)

      setTimeout =>
        @focus()
      , 1

      @save()

  _change_parent: ->


  update_text: (text)->
    if @node.text != text
      @node.text = text
      @$text.html(text)
      @save()

  expand: ->
    @node.collapsed = false
    @node.node_ui.$children.slideDown(100)  
    @node.node_ui.focus(0) 
    @$elm.removeClass('collapsed')
    @save()

  collapse: ->
    @node.collapsed = true
    @node.node_ui.$children.slideUp(100)
    @node.node_ui.focus(0)
    @$elm.addClass('collapsed')
    @save()

  remove: ->
    @$elm.remove()
    @node.remove()
    @save()

  save: ->
    @node.tree_ui.save()

class WorkflowTreeUi
  constructor: (@tree)->

  render: ->
    @build_page()
    @build_editor()
    @build_control()
    @build_nodes()

    @bind_events()

    @tree.children[0].node_ui.focus()
    # @tree.children[0].node_ui.hover()
    @hover_editor.focus_to(@tree.children[0])

  build_page: ->
    if !@$page
      @$page = jQuery('<div></div>')
        .addClass('workflow-tree-page')
        .prependTo(jQuery('body'))

  build_editor: ->
    if !@focus_editor
      @focus_editor = new WorkflowTreeEditorUi(@)
      @hover_editor = new WorkflowTreeEditorUi(@)
      @focus_editor.set_main_focus(true)

  build_control: ->
    if !@control
      @control = new WorkflowTreeControlUi(@)

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
    e = @focus_editor
    @focus_editor = @hover_editor
    @hover_editor = e

    @focus_editor.set_main_focus(true)
    @hover_editor.set_main_focus(false)

  bind_events: ->
    @$page.delegate '.wfnode .name', 'mouseenter', ->
      $node = jQuery(this).closest('.wfnode')
      node = $node.data('node')
      node.node_ui.hover()
      node.node_ui.show_control()

    @$page.delegate '.wfnode .name', 'mouseleave', ->
      $node = jQuery(this).closest('.wfnode')
      node = $node.data('node')
      node.node_ui.hide_control()

  save: ->
    # console.log @tree.serialize()
    window.localStorage.setItem('tree', @tree.serialize())

jQuery.extend window,
  WorkflowTreeUi: WorkflowTreeUi