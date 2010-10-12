(function($) {
	
	function $percent(n) {
		return Math.round(n * 100) + '%'
	}
	
	function $hash(str) {
		var len = str.length, key = 0, g;
		for ( var i = 0; i < len; ++i ) {
			key = (key << 4) + str.charCodeAt(i);
			if ( g = key & 0xF0000000 )
				key ^= g >> 24;
			key &= ~g;
		}
		return key;
	}
	
	$.fn.colorHash = function(selector, sat, lum) {
		var q = this;
		
		if ( sat == null ) sat = 1.0;
		if ( lum == null ) lum = 0.5;
		
		this.css('color', function(i) {
			var str = ( selector ? $(selector, q[i]) : $(q[i]) ).text();
			
			return 'hsl(' + [
				$hash(str) % 360,
				$percent(sat),
				$percent(lum)
			].join(',') + ')';
		})
		
	}
	
})(jQuery)
