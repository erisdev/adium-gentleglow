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
			saturation: 0.6,
			luminance:  0.4,
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
	
	$('a', fragment).text(function(i, text) {
		return text.replace(/[\/\+&;]+(?=\w)/g, '$&\u200b')
	});
	
	$('button', fragment).button();
	
	
	fragment.hide().appendTo('#chat').fadeIn();
}

function replaceLastMessage(html) {
	$('#chat > section:last').remove();
	appendMessage(html);
}

window.appendNextMessage = appendMessage;

function checkIfScrollToBottomIsNeeded() {
	var scroll = document.body.scrollTop,
	    height = window.innerHeight,
	    limit  = $.scrollTo.max(document.body);
	
	var need = checkIfScrollToBottomIsNeeded.isNeeded =
		scroll - (height / 2) < limit;
	return need;
}
checkIfScrollToBottomIsNeeded.isNeeded = true;

function scrollToBottom(immediate) {
	$('body').stop();
	$.scrollTo('100%', 700, { easing: 'easeOutBounce' });
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
