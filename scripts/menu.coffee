class Menu
  constructor: (root) ->
    @root = $(root)
  
  open: -> @root.addClass 'open'
  close: -> @root.removeClass 'open'
  toggle: -> @root.toggleClass 'open'
  
  addCheckbox: (label, fn) ->
    uuid = Math.uuid()
    $("""
      <li>
        <input name="#{uuid}" type="checkbox">
        <label for="#{uuid}"></label>
      </li>
    """)
    .find('input').click(fn).end()
    .find('label').text(label).end()
    .appendTo @root
  
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
    .find('select')
      .tap(populator)
      .val(defaultValue)
      .change(fn)
      .end()
    .find('label').text(label).end()
    .appendTo @root
  
  addLink: (label, fn) ->
    $('<li><a></a></li>')
    .find('a').click(fn).end()
    .appendTo @root

window.Menu = Menu

$ ->
  Menu.mainMenu = new Menu '#main-menu > .menu'
  
  Menu.mainMenu.addSelect 'variant', {
    values: MessageStyle.variants.getOwnKeys(),
    defaultValue: $('#mainStyle').text().match(///
      url\( "? variants/ ([^\s"]+) \.css "? \)
    ///i)?[1]
  }, ->
    variant = $(this).val()
    $('#mainStyle').text("""@import url("variants/#{variant}.css");""")
    Menu.mainMenu.close()
    scrollToBottom()
  
  $('.menu-panel .menu-toggle').click (event) ->
    $(this).closest('.menu-panel').toggleClass 'pinned'
  
  $('#variant-selector').change ->

