require 'jquery/model'

class $.model.Message extends $.model.BaseModel
  @property 'displayName', '.gg-messageSender'
  @property 'userName',    '.gg-messageSenderId'
  @property 'timestamp',   '.gg-messageTimestamp'
  @property 'body',        '.gg-messageBody'
  
  isAction: -> $(@rootElement).hasClass 'action'
  isHistory: -> $(@rootElement).hasClass 'history'
  isMention: -> $(@rootElement).hasClass 'mention'
  isMessage: -> $(@rootElement).hasClass 'message'
  
  getDate: ->
    # No, seriously. `Date(...)` properly parses an ISO string, but it returns
    # another string representation; `new Date(...)` returns a Date object and
    # can't parse ISO strings (at least in Chrome, where this style is tested)
    # but it can parse the string returned by `Date(...)`.
    # The JavaScript Date object: an exercise in _for god's sake, why_.
    new Date Date $(@rootElement).find('.gg-messageTimestamp').attr('datetime')

# TODO separate StatusMessage class with appropriate methods
$.model.StatusMessage = $.model.Message
