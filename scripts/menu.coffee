class $.model.Menu extends $.model.BaseModel
  @property 'title', '.ui-menuHeader'
  
  pin:          -> $(@rootElement).addClass    'ui-pinned'
  unpin:        -> $(@rootElement).removeClass 'ui-pinned'
  togglePinned: -> $(@rootElement).toggleClass 'ui-pinned'
  isPinned:     -> $(@rootElement).hasClass    'ui-pinned'
  
  addHTML: (html) ->
    $('<li>').html(html).appendTo this.find('.ui-menuContent')
  
  addCheckbox: (label, fn) ->
    uuid = Math.uuid()
    this.addHTML("""
      <input id="#{uuid}" type="checkbox">
      <label for="#{uuid}"></label>
    """)
    .find('input').click(fn).end()
    .find('label').text(label).end()
  
  addSelect: (label, {values, defaultValue}, fn) ->
    uuid = Math.uuid()
    populator = if $.isArray values
    then (select) -> $('<option>').text(value).appendTo(select) for value in values
    else (select) -> $('<option>').text(label).val(value).appendTo(select) for label, value of values
    this.addHTML("""
      <label for="#{uuid}"></label>
      <select name="#{uuid}"></select>
    """)
    .find('select').tap(populator).val(defaultValue).change(fn).end()
    .find('label').text(label).end()
  
  addLink: (label, fn) ->
    this.addHTML('<li><a></a></li>')
    .find('a').tap (link) ->
      if typeof fn is 'function'
      then link.click(fn)
      else link.attr(href: fn)

$('.ui-menu .ui-menuHeader').live 'click', (event) ->
  $(this).closest('.ui-menu').model().togglePinned()

$ ->
  currentVariantPattern = /// url\( "? variants/ ([^\s"]+) \.css "? \) ///i
  
  $('#main-menu').model().addSelect 'variant',
    values: MessageStyle.variants.getOwnKeys(),
    defaultValue: $('#mainStyle').text().match(currentVariantPattern)?[1]
  , ->
    $('#mainStyle').text("""@import url("Variants/#{$(this).val()}.css");""")
    $('#main-menu').model().unpin()
    scrollToBottom()
