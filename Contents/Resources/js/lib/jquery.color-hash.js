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
	
	var $ch = $.fn.colorHash = function(selector, options) {
		var q = this, o = { };
		
		if ( arguments.length == 1 ) {
			options  = selector;
			selector = null;
		}
		
		$.extend(o, $ch.DEFAULTS, options);
		
		this.css('color', function(i) {
			var str;
			
			if ( selector     ) str = $(selector, q.get(i)).text();
			else                str = $(q.get(i)).text();
			if ( o.ignoreCase ) str = str.toLowerCase();
			
			return 'hsl(' + [
				$hash(str) % 360,
				$percent(o.saturation),
				$percent(o.luminance)
			].join(',') + ')';
		})
		
	};
	
	$ch.DEFAULTS = {
		saturation: 1.0,
		luminance:  0.5,
		ignoreCase: false
	};
	
})(jQuery)
