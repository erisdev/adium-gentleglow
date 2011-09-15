$ ->
  currentVariant = do ->
    $('#mainStyle').text().match(///
      url\( "? variants/ ([^\s"]+) \.css "? \)
    ///)?[1]
  
  $('.menu-panel .menu-toggle').click (event) ->
    $(this).closest('.menu-panel').toggleClass 'open'
  
  $('#variant-selector').change ->
    currentVariant = $(this).val()
    $('#mainStyle').text(""" @import url("variants/#{currentVariant}.css"); """)
    $('#main-menu').removeClass 'open'
    scrollToBottom()
  
  $.getJSON 'variants/variants.json', (variants) ->
    for variantName in variants
      $('<option>')
      .text(variantName)
      .appendTo('#variant-selector')
    
    $('#variant-selector').val currentVariant
