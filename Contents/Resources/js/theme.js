function appendMessage(html) {
	var fragment = $(html);
	
	if ( fragment.hasClass('message') )
		$('.meta', fragment).colorHash('.sender', 0.6, 0.4);
	
	$('button', fragment).button();
	
	fragment.appendTo('#chat').fadeIn();
}

function replaceLastMessage(html) {
	$('#chat > section:last').remove();
	appendMessage(html);
}

window.appendNextMessage = appendMessage;

function checkIfScrollToBottomIsNeeded() {
	checkIfScrollToBottomIsNeeded.isNeeded = document.body.scrollTop >=
		(document.body.offsetHeight - (window.innerHeight * 1.2) );
	return checkIfScrollToBottomIsNeeded.isNeeded;
}
checkIfScrollToBottomIsNeeded.isNeeded = true;

function scrollPosition() {
	return document.body.scrollTop / (document.body.scrollHeight - window.innerHeight);
}

function scrollTo(percent, time, easing) {
	var target = percent * (document.body.scrollHeight - window.innerHeight);
	if ( easing && time )
		$('body').stop().animate({ scrollTop: target }, time, easing);
	else
		$('body').stop().scrollTop(target);
}

function scrollToBottom(immediate) {
	if ( immediate )
		scrollTo(1);
	else
		scrollTo(1, 700, 'easeOutBounce');
}

function scrollToBottomIfNeeded(immediate) {
	if ( checkIfScrollToBottomIsNeeded.isNeeded )
		scrollToBottom(immediate);
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

$(window).
	load(function() { scrollToBottom(true) }).
	resize(function() { scrollToBottomIfNeeded(true) });
