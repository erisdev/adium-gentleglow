var TMPL = {
	textShadow: '0px 0px 20px #{color}'
}

function template(string, params) {
	return string.replace(/#\{\s*([a-z0-9_]+)\s*\}/g, function(match, key) {
		return params[key]
	})
}

function appendMessage(html) {
	var fragment = $(html);
	
	if ( fragment.hasClass('message') ) {
		$('.meta', fragment).colorHash('.sender_id', {
			saturation: 0.5,
			luminance:  0.6,
			ignoreCase: true
		}).css('text-shadow', function(i, textShadow) {
			return template(TMPL.textShadow, { color: $(this).css('color') })
		});
	}
	
	if ( fragment.hasClass('action') ) {
		// reformat action text IRC style
		
		var sender  = $('.meta .sender', fragment).text();
		var content = $('.content', fragment);
		
		content.html(function(i, html) {
			// strips asterisks
			// we do this to the raw html to preserve formatting--gross, I know.
			return html.replace(/^(<[^>]+>)?\*(.+)\*(<[^>]+>)?$/, '$1$2$3');
		})
		
		// prepend the sender in a span of its own
		$('<span>').
			addClass('sender').
			text(sender + ' ').
			prependTo(content);
	}
	
	$('a', fragment).filter(function(i) {
		return $(this).text() == $(this).attr('href');
	}).text(function(i, text) {
		return text.replace(/\w+:\/\/([^\/]+)(?:\/.*)?/, '$1\u2026');
	}).addClass('shortened');
	
	$('button', fragment).button();
	
	
	fragment.hide().appendTo('#chat').fadeIn();
}

function replaceLastMessage(html) {
	$('#chat > section:last').remove();
	appendMessage(html);
}

window.appendNextMessage = appendMessage;

function checkIfScrollToBottomIsNeeded() {
	// TODO write a version of this that actually works
	return checkIfScrollToBottomIsNeeded.isNeeded = true;
}
checkIfScrollToBottomIsNeeded.isNeeded = true;

function scrollToBottom(immediate) {
	$('#chat').stop();
	$('#chat').scrollTo('100%', 700, { easing: 'easeOutBounce' });
}

function scrollToBottomIfNeeded() {
	if ( checkIfScrollToBottomIsNeeded.isNeeded )
		scrollToBottom();
}


function setStylesheet(id, url) {
	var style = $('#' + id);
	
	if ( !style || style.length == 0 )
		style = $('<style></style>').
			attr('id',    id).
			attr('type',  'text/css').
			attr('media', 'screen');
	
	style.text('@import url(' + url + ')');
}

$(window).load(function() { $.scrollTo('100%') })
