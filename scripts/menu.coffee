$ ->
  currentVariant = do ->
    $('#mainStyle').text().match(///
      url\( "? variants/ ([^\s"]+) \.css "? \)
    ///i)?[1]
  
  for variant of MessageStyle.variants
    $('<option>')
    .text(variant)
    .appendTo('#variant-selector')
  
  $('#variant-selector').val currentVariant
  
  $('.menu-panel .menu-toggle').click (event) ->
    $(this).closest('.menu-panel').toggleClass 'pinned'
  
  $('#variant-selector').change ->
    currentVariant = $(this).val()
    $('#mainStyle').text(""" @import url("variants/#{currentVariant}.css"); """)
    $('#main-menu').removeClass 'open'
    scrollToBottom()

