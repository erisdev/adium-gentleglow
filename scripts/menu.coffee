class $.model.Menu extends $.model.BaseModel
  @property 'title', '.ui-menuHeader'
  
  pin:          -> $(@rootElement).addClass    'ui-pinned'
  unpin:        -> $(@rootElement).removeClass 'ui-pinned'
  togglePinned: -> $(@rootElement).toggleClass 'ui-pinned'
  isPinned:     -> $(@rootElement).hasClass    'ui-pinned'
  
  addCheckbox: (label, fn) ->
    uuid = Math.uuid()
    $("""
      <li>
        <input id="#{uuid}" type="checkbox">
        <label for="#{uuid}"></label>
      </li>
    """)
    .find('input').click(fn).end()
    .find('label').text(label).end()
    .appendTo $(@rootElement).find('.ui-menuContent')
  
  addSelect: (label, {values, defaultValue}, fn) ->
    uuid = Math.uuid()
    populator = if $.isArray values
    then (select) -> $('<option>').text(value).appendTo(select) for value in values
    else (select) -> $('<option>').text(label).val(value).appendTo(select) for label, value of values
    $("""
      <li>
        <label for="#{uuid}"></label>
        <select name="#{uuid}"></select>
      </li>
    """)
    .find('select').tap(populator).val(defaultValue).change(fn).end()
    .find('label').text(label).end()
    .appendTo $(@rootElement).find('.ui-menuContent')
  
  addLink: (label, fn) ->
    $('<li><a></a></li>')
    .find('a').tap((link) ->
      if typeof fn is 'function'
      then link.click(fn)
      else link.attr(href: fn) )
    .appendTo $(@rootElement).find('.ui-menuContent')

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
