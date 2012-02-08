$(window).bind 'adium:file', (event) ->
  fileTransfer = event.file
  
  fileTransfer
  .css(position: 'fixed', left: '2em', bottom: '2em', right: '2em')
  .appendTo('body')
  .cssAnimate('fx-winkIn')
  
  fileTransfer.find('button').click (event) ->
    fileTransfer.cssAnimate 'fx-winkOut', -> fileTransfer.remove()
