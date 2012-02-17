window.HamlCoffeeHelpers = {
  
  htmlEscape: function(text) {
    return ("" + text).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\'/g, '&apos;').replace(/\"/g, '&quot;');
  },
  
  preserve: function(text) {
    return text.replace(/\\n/g, '&#x000A;');
  },
  
  findAndPreserve: function(text) {
    return text.replace(/<(textarea|pre)>([^]*?)<\/\1>/g, function(str, tag, content) {
      return "<\#{ tag }>\#{ content.replace /\\n/g, '&#x000A;' }</\#{ tag }>";
    });
  },
  
  cleanValue: function(value) {
    if (value === null || value === void 0) {
      return '';
    } else {
      return value;
    }
  },
  
  surround: function(start, end, fn) {
    return start + fn() + end;
  },
  
  succeed: function(end, fn) {
    return fn() + end;
  },
  
  precede: function(start, fn) {
    return start + fn();
  }
};