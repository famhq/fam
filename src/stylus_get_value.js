var colors = require('./colors');

module.exports = function() {
  return function(style) {
    var nodes = this.nodes;
    return style.define('getValue', function(color) {
      isString = typeof color.string === 'string';
      var isVariable = isString && color.string.substring(0, 4) === 'var(';
      if(isVariable) {
        var variable = color.string.match(/\(([^)]+)\)/)[1];
        return new nodes.Literal(colors.default[variable]);
      }
      else
        return color;
    });
  };
};
