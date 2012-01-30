$(window).bind 'adium:file', (event) ->
  fileTransfer = event.file
  fileTransfer
  .css(position: 'fixed', left: 0, bottom: 0, right: 0)
  .find('button')
    .click((event)-> fileTransfer.fadeOut -> fileTransfer.remove() )
    .end()
  .appendTo('body')
  .fadeIn()
