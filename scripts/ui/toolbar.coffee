exports.addButton = (label, icon, action) ->
  $('<li>')
  .addClass('ui-toolbarButton')
  .attr(title: label)
  .text(label)
  .css
    backgroundImage: """url("#{icon}")"""
    backgroundRepeat: 'no-repeat'
    backgroundPosition: 'center'
    backgroundSize: '100%'
  .bind('click', action)
  .appendTo '#gg-toolbar'

