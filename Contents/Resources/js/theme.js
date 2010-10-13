function appendMessage(html) {
	var fragment = $(html);
	
	if ( fragment.hasClass('message') )
		$('.meta', fragment).colorHash('.sender', {
			saturation: 0.6,
			luminance:  0.4,
			ignoreCase: true
		});
	
	$('a', fragment).text(function(i, text) {
		return text.replace(/[\/\+&;]+(?=\w)/g, '$&\u200b')
	});
	
	$('button', fragment).button();
	
	
	fragment.appendTo('#chat').fadeIn();
}

function replaceLastMessage(html) {
	$('#chat > section:last').remove();
	appendMessage(html);
}

window.appendNextMessage = appendMessage;

function checkIfScrollToBottomIsNeeded() {
	var need = checkIfScrollToBottomIsNeeded.isNeeded =
		$.scrollTo.max(document.body) == document.body.scrollTop;
	return need;
}
checkIfScrollToBottomIsNeeded.isNeeded = true;

function scrollToBottom(immediate) {
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
