(function() {
	
	var Media = window.Media = {
		handlers: [ ]
	};
	
	Media.register = function(pattern, fn) {
		this.handlers.push({ pattern: pattern, fn: fn });
	};
	
	Media.createImageCell = function(imageUri, thumbnailUri, title) {
		return (
			$('<a>')
			.attr('href', imageUri)
			.append(
				$('<img>')
				.error(function() { $(this).addClass('broken') })
				.attr('src', thumbnailUri)
				.attr('alt', title)
				.attr('title', title)));
	}
	
	Media.loadMedia = function(message, link) {
		var handler, match, media, container, uri, title;
		
		container = $('.media', message);
		uri       = link.href;
		title     = $(link).text();
		
		for ( var i = 0, L = Media.handlers.length; i < L; ++i )
		{
			handler = this.handlers[i];
			if ( match = uri.match(handler.pattern) )
			{
				media = handler.fn.apply(this, [title].concat(match));
				$('<div>')
					.addClass('media-item')
					.append(media)
					.appendTo(container);
			}
		};
	}
	
})();

Media.register(/^https?:\/\/(?:i\.)?imgur\.com\/([a-z0-9]+)(?:\..+)?$/i, function(title, uri, id) {
	return Media.createImageCell(
		'http://imgur.com/' + id,
		'http://i.imgur.com/' + id + 's.png',
		title);
});

(function() {
	var fn = function(title, uri, id) {
		return Media.createImageCell(
			uri, 'http://img.youtube.com/vi/' + id + '/1.jpg', title);
	}
	
	Media.register(/youtube\.com\/watch.*v=([a-z0-9_]+)/i, fn);
	Media.register(/youtu\.be\/([a-z0-9_]+)/i, fn);
})();
