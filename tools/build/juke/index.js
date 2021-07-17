(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory();
	else if(typeof define === 'function' && define.amd)
		define([], factory);
	else if(typeof exports === 'object')
		exports["juke"] = factory();
	else
		root["juke"] = factory();
})(global, function() {
return /******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./.yarn/cache/ansi-styles-npm-4.3.0-245c7d42c7-ea02c0179f.zip/node_modules/ansi-styles/index.js":
/*!*******************************************************************************************************!*\
  !*** ./.yarn/cache/ansi-styles-npm-4.3.0-245c7d42c7-ea02c0179f.zip/node_modules/ansi-styles/index.js ***!
  \*******************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/* module decorator */ module = __webpack_require__.nmd(module);


const wrapAnsi16 = (fn, offset) => (...args) => {
  const code = fn(...args);
  return `\u001B[${code + offset}m`;
};

const wrapAnsi256 = (fn, offset) => (...args) => {
  const code = fn(...args);
  return `\u001B[${38 + offset};5;${code}m`;
};

const wrapAnsi16m = (fn, offset) => (...args) => {
  const rgb = fn(...args);
  return `\u001B[${38 + offset};2;${rgb[0]};${rgb[1]};${rgb[2]}m`;
};

const ansi2ansi = n => n;

const rgb2rgb = (r, g, b) => [r, g, b];

const setLazyProperty = (object, property, get) => {
  Object.defineProperty(object, property, {
    get: () => {
      const value = get();
      Object.defineProperty(object, property, {
        value,
        enumerable: true,
        configurable: true
      });
      return value;
    },
    enumerable: true,
    configurable: true
  });
};
/** @type {typeof import('color-convert')} */


let colorConvert;

const makeDynamicStyles = (wrap, targetSpace, identity, isBackground) => {
  if (colorConvert === undefined) {
    colorConvert = __webpack_require__(/*! color-convert */ "./.yarn/cache/color-convert-npm-2.0.1-79730e935b-3d5d8a011a.zip/node_modules/color-convert/index.js");
  }

  const offset = isBackground ? 10 : 0;
  const styles = {};

  for (const [sourceSpace, suite] of Object.entries(colorConvert)) {
    const name = sourceSpace === 'ansi16' ? 'ansi' : sourceSpace;

    if (sourceSpace === targetSpace) {
      styles[name] = wrap(identity, offset);
    } else if (typeof suite === 'object') {
      styles[name] = wrap(suite[targetSpace], offset);
    }
  }

  return styles;
};

function assembleStyles() {
  const codes = new Map();
  const styles = {
    modifier: {
      reset: [0, 0],
      // 21 isn't widely supported and 22 does the same thing
      bold: [1, 22],
      dim: [2, 22],
      italic: [3, 23],
      underline: [4, 24],
      inverse: [7, 27],
      hidden: [8, 28],
      strikethrough: [9, 29]
    },
    color: {
      black: [30, 39],
      red: [31, 39],
      green: [32, 39],
      yellow: [33, 39],
      blue: [34, 39],
      magenta: [35, 39],
      cyan: [36, 39],
      white: [37, 39],
      // Bright color
      blackBright: [90, 39],
      redBright: [91, 39],
      greenBright: [92, 39],
      yellowBright: [93, 39],
      blueBright: [94, 39],
      magentaBright: [95, 39],
      cyanBright: [96, 39],
      whiteBright: [97, 39]
    },
    bgColor: {
      bgBlack: [40, 49],
      bgRed: [41, 49],
      bgGreen: [42, 49],
      bgYellow: [43, 49],
      bgBlue: [44, 49],
      bgMagenta: [45, 49],
      bgCyan: [46, 49],
      bgWhite: [47, 49],
      // Bright color
      bgBlackBright: [100, 49],
      bgRedBright: [101, 49],
      bgGreenBright: [102, 49],
      bgYellowBright: [103, 49],
      bgBlueBright: [104, 49],
      bgMagentaBright: [105, 49],
      bgCyanBright: [106, 49],
      bgWhiteBright: [107, 49]
    }
  }; // Alias bright black as gray (and grey)

  styles.color.gray = styles.color.blackBright;
  styles.bgColor.bgGray = styles.bgColor.bgBlackBright;
  styles.color.grey = styles.color.blackBright;
  styles.bgColor.bgGrey = styles.bgColor.bgBlackBright;

  for (const [groupName, group] of Object.entries(styles)) {
    for (const [styleName, style] of Object.entries(group)) {
      styles[styleName] = {
        open: `\u001B[${style[0]}m`,
        close: `\u001B[${style[1]}m`
      };
      group[styleName] = styles[styleName];
      codes.set(style[0], style[1]);
    }

    Object.defineProperty(styles, groupName, {
      value: group,
      enumerable: false
    });
  }

  Object.defineProperty(styles, 'codes', {
    value: codes,
    enumerable: false
  });
  styles.color.close = '\u001B[39m';
  styles.bgColor.close = '\u001B[49m';
  setLazyProperty(styles.color, 'ansi', () => makeDynamicStyles(wrapAnsi16, 'ansi16', ansi2ansi, false));
  setLazyProperty(styles.color, 'ansi256', () => makeDynamicStyles(wrapAnsi256, 'ansi256', ansi2ansi, false));
  setLazyProperty(styles.color, 'ansi16m', () => makeDynamicStyles(wrapAnsi16m, 'rgb', rgb2rgb, false));
  setLazyProperty(styles.bgColor, 'ansi', () => makeDynamicStyles(wrapAnsi16, 'ansi16', ansi2ansi, true));
  setLazyProperty(styles.bgColor, 'ansi256', () => makeDynamicStyles(wrapAnsi256, 'ansi256', ansi2ansi, true));
  setLazyProperty(styles.bgColor, 'ansi16m', () => makeDynamicStyles(wrapAnsi16m, 'rgb', rgb2rgb, true));
  return styles;
} // Make the export immutable


Object.defineProperty(module, 'exports', {
  enumerable: true,
  get: assembleStyles
});

/***/ }),

/***/ "./.yarn/cache/balanced-match-npm-1.0.0-951a2ad706-f515a605fe.zip/node_modules/balanced-match/index.js":
/*!*************************************************************************************************************!*\
  !*** ./.yarn/cache/balanced-match-npm-1.0.0-951a2ad706-f515a605fe.zip/node_modules/balanced-match/index.js ***!
  \*************************************************************************************************************/
/***/ ((module) => {



module.exports = balanced;

function balanced(a, b, str) {
  if (a instanceof RegExp) a = maybeMatch(a, str);
  if (b instanceof RegExp) b = maybeMatch(b, str);
  var r = range(a, b, str);
  return r && {
    start: r[0],
    end: r[1],
    pre: str.slice(0, r[0]),
    body: str.slice(r[0] + a.length, r[1]),
    post: str.slice(r[1] + b.length)
  };
}

function maybeMatch(reg, str) {
  var m = str.match(reg);
  return m ? m[0] : null;
}

balanced.range = range;

function range(a, b, str) {
  var begs, beg, left, right, result;
  var ai = str.indexOf(a);
  var bi = str.indexOf(b, ai + 1);
  var i = ai;

  if (ai >= 0 && bi > 0) {
    begs = [];
    left = str.length;

    while (i >= 0 && !result) {
      if (i == ai) {
        begs.push(i);
        ai = str.indexOf(a, i + 1);
      } else if (begs.length == 1) {
        result = [begs.pop(), bi];
      } else {
        beg = begs.pop();

        if (beg < left) {
          left = beg;
          right = bi;
        }

        bi = str.indexOf(b, i + 1);
      }

      i = ai < bi && ai >= 0 ? ai : bi;
    }

    if (begs.length) {
      result = [left, right];
    }
  }

  return result;
}

/***/ }),

/***/ "./.yarn/cache/brace-expansion-npm-1.1.11-fb95eb05ad-4c878e25e4.zip/node_modules/brace-expansion/index.js":
/*!****************************************************************************************************************!*\
  !*** ./.yarn/cache/brace-expansion-npm-1.1.11-fb95eb05ad-4c878e25e4.zip/node_modules/brace-expansion/index.js ***!
  \****************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {



var concatMap = __webpack_require__(/*! concat-map */ "./.yarn/cache/concat-map-npm-0.0.1-85a921b7ee-554e28d9ee.zip/node_modules/concat-map/index.js");

var balanced = __webpack_require__(/*! balanced-match */ "./.yarn/cache/balanced-match-npm-1.0.0-951a2ad706-f515a605fe.zip/node_modules/balanced-match/index.js");

module.exports = expandTop;
var escSlash = '\0SLASH' + Math.random() + '\0';
var escOpen = '\0OPEN' + Math.random() + '\0';
var escClose = '\0CLOSE' + Math.random() + '\0';
var escComma = '\0COMMA' + Math.random() + '\0';
var escPeriod = '\0PERIOD' + Math.random() + '\0';

function numeric(str) {
  return parseInt(str, 10) == str ? parseInt(str, 10) : str.charCodeAt(0);
}

function escapeBraces(str) {
  return str.split('\\\\').join(escSlash).split('\\{').join(escOpen).split('\\}').join(escClose).split('\\,').join(escComma).split('\\.').join(escPeriod);
}

function unescapeBraces(str) {
  return str.split(escSlash).join('\\').split(escOpen).join('{').split(escClose).join('}').split(escComma).join(',').split(escPeriod).join('.');
} // Basically just str.split(","), but handling cases
// where we have nested braced sections, which should be
// treated as individual members, like {a,{b,c},d}


function parseCommaParts(str) {
  if (!str) return [''];
  var parts = [];
  var m = balanced('{', '}', str);
  if (!m) return str.split(',');
  var pre = m.pre;
  var body = m.body;
  var post = m.post;
  var p = pre.split(',');
  p[p.length - 1] += '{' + body + '}';
  var postParts = parseCommaParts(post);

  if (post.length) {
    p[p.length - 1] += postParts.shift();
    p.push.apply(p, postParts);
  }

  parts.push.apply(parts, p);
  return parts;
}

function expandTop(str) {
  if (!str) return []; // I don't know why Bash 4.3 does this, but it does.
  // Anything starting with {} will have the first two bytes preserved
  // but *only* at the top level, so {},a}b will not expand to anything,
  // but a{},b}c will be expanded to [a}c,abc].
  // One could argue that this is a bug in Bash, but since the goal of
  // this module is to match Bash's rules, we escape a leading {}

  if (str.substr(0, 2) === '{}') {
    str = '\\{\\}' + str.substr(2);
  }

  return expand(escapeBraces(str), true).map(unescapeBraces);
}

function identity(e) {
  return e;
}

function embrace(str) {
  return '{' + str + '}';
}

function isPadded(el) {
  return /^-?0\d/.test(el);
}

function lte(i, y) {
  return i <= y;
}

function gte(i, y) {
  return i >= y;
}

function expand(str, isTop) {
  var expansions = [];
  var m = balanced('{', '}', str);
  if (!m || /\$$/.test(m.pre)) return [str];
  var isNumericSequence = /^-?\d+\.\.-?\d+(?:\.\.-?\d+)?$/.test(m.body);
  var isAlphaSequence = /^[a-zA-Z]\.\.[a-zA-Z](?:\.\.-?\d+)?$/.test(m.body);
  var isSequence = isNumericSequence || isAlphaSequence;
  var isOptions = m.body.indexOf(',') >= 0;

  if (!isSequence && !isOptions) {
    // {a},b}
    if (m.post.match(/,.*\}/)) {
      str = m.pre + '{' + m.body + escClose + m.post;
      return expand(str);
    }

    return [str];
  }

  var n;

  if (isSequence) {
    n = m.body.split(/\.\./);
  } else {
    n = parseCommaParts(m.body);

    if (n.length === 1) {
      // x{{a,b}}y ==> x{a}y x{b}y
      n = expand(n[0], false).map(embrace);

      if (n.length === 1) {
        var post = m.post.length ? expand(m.post, false) : [''];
        return post.map(function (p) {
          return m.pre + n[0] + p;
        });
      }
    }
  } // at this point, n is the parts, and we know it's not a comma set
  // with a single entry.
  // no need to expand pre, since it is guaranteed to be free of brace-sets


  var pre = m.pre;
  var post = m.post.length ? expand(m.post, false) : [''];
  var N;

  if (isSequence) {
    var x = numeric(n[0]);
    var y = numeric(n[1]);
    var width = Math.max(n[0].length, n[1].length);
    var incr = n.length == 3 ? Math.abs(numeric(n[2])) : 1;
    var test = lte;
    var reverse = y < x;

    if (reverse) {
      incr *= -1;
      test = gte;
    }

    var pad = n.some(isPadded);
    N = [];

    for (var i = x; test(i, y); i += incr) {
      var c;

      if (isAlphaSequence) {
        c = String.fromCharCode(i);
        if (c === '\\') c = '';
      } else {
        c = String(i);

        if (pad) {
          var need = width - c.length;

          if (need > 0) {
            var z = new Array(need + 1).join('0');
            if (i < 0) c = '-' + z + c.slice(1);else c = z + c;
          }
        }
      }

      N.push(c);
    }
  } else {
    N = concatMap(n, function (el) {
      return expand(el, false);
    });
  }

  for (var j = 0; j < N.length; j++) {
    for (var k = 0; k < post.length; k++) {
      var expansion = pre + N[j] + post[k];
      if (!isTop || isSequence || expansion) expansions.push(expansion);
    }
  }

  return expansions;
}

/***/ }),

/***/ "./.yarn/cache/chalk-npm-4.1.1-f1ce6bae57-445c12db7a.zip/node_modules/chalk/source/index.js":
/*!**************************************************************************************************!*\
  !*** ./.yarn/cache/chalk-npm-4.1.1-f1ce6bae57-445c12db7a.zip/node_modules/chalk/source/index.js ***!
  \**************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {



const ansiStyles = __webpack_require__(/*! ansi-styles */ "./.yarn/cache/ansi-styles-npm-4.3.0-245c7d42c7-ea02c0179f.zip/node_modules/ansi-styles/index.js");

const {
  stdout: stdoutColor,
  stderr: stderrColor
} = __webpack_require__(/*! supports-color */ "./.yarn/cache/supports-color-npm-7.2.0-606bfcf7da-8e57067c39.zip/node_modules/supports-color/index.js");

const {
  stringReplaceAll,
  stringEncaseCRLFWithFirstIndex
} = __webpack_require__(/*! ./util */ "./.yarn/cache/chalk-npm-4.1.1-f1ce6bae57-445c12db7a.zip/node_modules/chalk/source/util.js");

const {
  isArray
} = Array; // `supportsColor.level` → `ansiStyles.color[name]` mapping

const levelMapping = ['ansi', 'ansi', 'ansi256', 'ansi16m'];
const styles = Object.create(null);

const applyOptions = (object, options = {}) => {
  if (options.level && !(Number.isInteger(options.level) && options.level >= 0 && options.level <= 3)) {
    throw new Error('The `level` option should be an integer from 0 to 3');
  } // Detect level if not set manually


  const colorLevel = stdoutColor ? stdoutColor.level : 0;
  object.level = options.level === undefined ? colorLevel : options.level;
};

class ChalkClass {
  constructor(options) {
    // eslint-disable-next-line no-constructor-return
    return chalkFactory(options);
  }

}

const chalkFactory = options => {
  const chalk = {};
  applyOptions(chalk, options);

  chalk.template = (...arguments_) => chalkTag(chalk.template, ...arguments_);

  Object.setPrototypeOf(chalk, Chalk.prototype);
  Object.setPrototypeOf(chalk.template, chalk);

  chalk.template.constructor = () => {
    throw new Error('`chalk.constructor()` is deprecated. Use `new chalk.Instance()` instead.');
  };

  chalk.template.Instance = ChalkClass;
  return chalk.template;
};

function Chalk(options) {
  return chalkFactory(options);
}

for (const [styleName, style] of Object.entries(ansiStyles)) {
  styles[styleName] = {
    get() {
      const builder = createBuilder(this, createStyler(style.open, style.close, this._styler), this._isEmpty);
      Object.defineProperty(this, styleName, {
        value: builder
      });
      return builder;
    }

  };
}

styles.visible = {
  get() {
    const builder = createBuilder(this, this._styler, true);
    Object.defineProperty(this, 'visible', {
      value: builder
    });
    return builder;
  }

};
const usedModels = ['rgb', 'hex', 'keyword', 'hsl', 'hsv', 'hwb', 'ansi', 'ansi256'];

for (const model of usedModels) {
  styles[model] = {
    get() {
      const {
        level
      } = this;
      return function (...arguments_) {
        const styler = createStyler(ansiStyles.color[levelMapping[level]][model](...arguments_), ansiStyles.color.close, this._styler);
        return createBuilder(this, styler, this._isEmpty);
      };
    }

  };
}

for (const model of usedModels) {
  const bgModel = 'bg' + model[0].toUpperCase() + model.slice(1);
  styles[bgModel] = {
    get() {
      const {
        level
      } = this;
      return function (...arguments_) {
        const styler = createStyler(ansiStyles.bgColor[levelMapping[level]][model](...arguments_), ansiStyles.bgColor.close, this._styler);
        return createBuilder(this, styler, this._isEmpty);
      };
    }

  };
}

const proto = Object.defineProperties(() => {}, { ...styles,
  level: {
    enumerable: true,

    get() {
      return this._generator.level;
    },

    set(level) {
      this._generator.level = level;
    }

  }
});

const createStyler = (open, close, parent) => {
  let openAll;
  let closeAll;

  if (parent === undefined) {
    openAll = open;
    closeAll = close;
  } else {
    openAll = parent.openAll + open;
    closeAll = close + parent.closeAll;
  }

  return {
    open,
    close,
    openAll,
    closeAll,
    parent
  };
};

const createBuilder = (self, _styler, _isEmpty) => {
  const builder = (...arguments_) => {
    if (isArray(arguments_[0]) && isArray(arguments_[0].raw)) {
      // Called as a template literal, for example: chalk.red`2 + 3 = {bold ${2+3}}`
      return applyStyle(builder, chalkTag(builder, ...arguments_));
    } // Single argument is hot path, implicit coercion is faster than anything
    // eslint-disable-next-line no-implicit-coercion


    return applyStyle(builder, arguments_.length === 1 ? '' + arguments_[0] : arguments_.join(' '));
  }; // We alter the prototype because we must return a function, but there is
  // no way to create a function with a different prototype


  Object.setPrototypeOf(builder, proto);
  builder._generator = self;
  builder._styler = _styler;
  builder._isEmpty = _isEmpty;
  return builder;
};

const applyStyle = (self, string) => {
  if (self.level <= 0 || !string) {
    return self._isEmpty ? '' : string;
  }

  let styler = self._styler;

  if (styler === undefined) {
    return string;
  }

  const {
    openAll,
    closeAll
  } = styler;

  if (string.indexOf('\u001B') !== -1) {
    while (styler !== undefined) {
      // Replace any instances already present with a re-opening code
      // otherwise only the part of the string until said closing code
      // will be colored, and the rest will simply be 'plain'.
      string = stringReplaceAll(string, styler.close, styler.open);
      styler = styler.parent;
    }
  } // We can move both next actions out of loop, because remaining actions in loop won't have
  // any/visible effect on parts we add here. Close the styling before a linebreak and reopen
  // after next line to fix a bleed issue on macOS: https://github.com/chalk/chalk/pull/92


  const lfIndex = string.indexOf('\n');

  if (lfIndex !== -1) {
    string = stringEncaseCRLFWithFirstIndex(string, closeAll, openAll, lfIndex);
  }

  return openAll + string + closeAll;
};

let template;

const chalkTag = (chalk, ...strings) => {
  const [firstString] = strings;

  if (!isArray(firstString) || !isArray(firstString.raw)) {
    // If chalk() was called by itself or with a string,
    // return the string itself as a string.
    return strings.join(' ');
  }

  const arguments_ = strings.slice(1);
  const parts = [firstString.raw[0]];

  for (let i = 1; i < firstString.length; i++) {
    parts.push(String(arguments_[i - 1]).replace(/[{}\\]/g, '\\$&'), String(firstString.raw[i]));
  }

  if (template === undefined) {
    template = __webpack_require__(/*! ./templates */ "./.yarn/cache/chalk-npm-4.1.1-f1ce6bae57-445c12db7a.zip/node_modules/chalk/source/templates.js");
  }

  return template(chalk, parts.join(''));
};

Object.defineProperties(Chalk.prototype, styles);
const chalk = Chalk(); // eslint-disable-line new-cap

chalk.supportsColor = stdoutColor;
chalk.stderr = Chalk({
  level: stderrColor ? stderrColor.level : 0
}); // eslint-disable-line new-cap

chalk.stderr.supportsColor = stderrColor;
module.exports = chalk;

/***/ }),

/***/ "./.yarn/cache/chalk-npm-4.1.1-f1ce6bae57-445c12db7a.zip/node_modules/chalk/source/templates.js":
/*!******************************************************************************************************!*\
  !*** ./.yarn/cache/chalk-npm-4.1.1-f1ce6bae57-445c12db7a.zip/node_modules/chalk/source/templates.js ***!
  \******************************************************************************************************/
/***/ ((module) => {



const TEMPLATE_REGEX = /(?:\\(u(?:[a-f\d]{4}|\{[a-f\d]{1,6}\})|x[a-f\d]{2}|.))|(?:\{(~)?(\w+(?:\([^)]*\))?(?:\.\w+(?:\([^)]*\))?)*)(?:[ \t]|(?=\r?\n)))|(\})|((?:.|[\r\n\f])+?)/gi;
const STYLE_REGEX = /(?:^|\.)(\w+)(?:\(([^)]*)\))?/g;
const STRING_REGEX = /^(['"])((?:\\.|(?!\1)[^\\])*)\1$/;
const ESCAPE_REGEX = /\\(u(?:[a-f\d]{4}|{[a-f\d]{1,6}})|x[a-f\d]{2}|.)|([^\\])/gi;
const ESCAPES = new Map([['n', '\n'], ['r', '\r'], ['t', '\t'], ['b', '\b'], ['f', '\f'], ['v', '\v'], ['0', '\0'], ['\\', '\\'], ['e', '\u001B'], ['a', '\u0007']]);

function unescape(c) {
  const u = c[0] === 'u';
  const bracket = c[1] === '{';

  if (u && !bracket && c.length === 5 || c[0] === 'x' && c.length === 3) {
    return String.fromCharCode(parseInt(c.slice(1), 16));
  }

  if (u && bracket) {
    return String.fromCodePoint(parseInt(c.slice(2, -1), 16));
  }

  return ESCAPES.get(c) || c;
}

function parseArguments(name, arguments_) {
  const results = [];
  const chunks = arguments_.trim().split(/\s*,\s*/g);
  let matches;

  for (const chunk of chunks) {
    const number = Number(chunk);

    if (!Number.isNaN(number)) {
      results.push(number);
    } else if (matches = chunk.match(STRING_REGEX)) {
      results.push(matches[2].replace(ESCAPE_REGEX, (m, escape, character) => escape ? unescape(escape) : character));
    } else {
      throw new Error(`Invalid Chalk template style argument: ${chunk} (in style '${name}')`);
    }
  }

  return results;
}

function parseStyle(style) {
  STYLE_REGEX.lastIndex = 0;
  const results = [];
  let matches;

  while ((matches = STYLE_REGEX.exec(style)) !== null) {
    const name = matches[1];

    if (matches[2]) {
      const args = parseArguments(name, matches[2]);
      results.push([name].concat(args));
    } else {
      results.push([name]);
    }
  }

  return results;
}

function buildStyle(chalk, styles) {
  const enabled = {};

  for (const layer of styles) {
    for (const style of layer.styles) {
      enabled[style[0]] = layer.inverse ? null : style.slice(1);
    }
  }

  let current = chalk;

  for (const [styleName, styles] of Object.entries(enabled)) {
    if (!Array.isArray(styles)) {
      continue;
    }

    if (!(styleName in current)) {
      throw new Error(`Unknown Chalk style: ${styleName}`);
    }

    current = styles.length > 0 ? current[styleName](...styles) : current[styleName];
  }

  return current;
}

module.exports = (chalk, temporary) => {
  const styles = [];
  const chunks = [];
  let chunk = []; // eslint-disable-next-line max-params

  temporary.replace(TEMPLATE_REGEX, (m, escapeCharacter, inverse, style, close, character) => {
    if (escapeCharacter) {
      chunk.push(unescape(escapeCharacter));
    } else if (style) {
      const string = chunk.join('');
      chunk = [];
      chunks.push(styles.length === 0 ? string : buildStyle(chalk, styles)(string));
      styles.push({
        inverse,
        styles: parseStyle(style)
      });
    } else if (close) {
      if (styles.length === 0) {
        throw new Error('Found extraneous } in Chalk template literal');
      }

      chunks.push(buildStyle(chalk, styles)(chunk.join('')));
      chunk = [];
      styles.pop();
    } else {
      chunk.push(character);
    }
  });
  chunks.push(chunk.join(''));

  if (styles.length > 0) {
    const errMessage = `Chalk template literal is missing ${styles.length} closing bracket${styles.length === 1 ? '' : 's'} (\`}\`)`;
    throw new Error(errMessage);
  }

  return chunks.join('');
};

/***/ }),

/***/ "./.yarn/cache/chalk-npm-4.1.1-f1ce6bae57-445c12db7a.zip/node_modules/chalk/source/util.js":
/*!*************************************************************************************************!*\
  !*** ./.yarn/cache/chalk-npm-4.1.1-f1ce6bae57-445c12db7a.zip/node_modules/chalk/source/util.js ***!
  \*************************************************************************************************/
/***/ ((module) => {



const stringReplaceAll = (string, substring, replacer) => {
  let index = string.indexOf(substring);

  if (index === -1) {
    return string;
  }

  const substringLength = substring.length;
  let endIndex = 0;
  let returnValue = '';

  do {
    returnValue += string.substr(endIndex, index - endIndex) + substring + replacer;
    endIndex = index + substringLength;
    index = string.indexOf(substring, endIndex);
  } while (index !== -1);

  returnValue += string.substr(endIndex);
  return returnValue;
};

const stringEncaseCRLFWithFirstIndex = (string, prefix, postfix, index) => {
  let endIndex = 0;
  let returnValue = '';

  do {
    const gotCR = string[index - 1] === '\r';
    returnValue += string.substr(endIndex, (gotCR ? index - 1 : index) - endIndex) + prefix + (gotCR ? '\r\n' : '\n') + postfix;
    endIndex = index + 1;
    index = string.indexOf('\n', endIndex);
  } while (index !== -1);

  returnValue += string.substr(endIndex);
  return returnValue;
};

module.exports = {
  stringReplaceAll,
  stringEncaseCRLFWithFirstIndex
};

/***/ }),

/***/ "./.yarn/cache/color-convert-npm-2.0.1-79730e935b-3d5d8a011a.zip/node_modules/color-convert/conversions.js":
/*!*****************************************************************************************************************!*\
  !*** ./.yarn/cache/color-convert-npm-2.0.1-79730e935b-3d5d8a011a.zip/node_modules/color-convert/conversions.js ***!
  \*****************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {



/* MIT license */

/* eslint-disable no-mixed-operators */
const cssKeywords = __webpack_require__(/*! color-name */ "./.yarn/cache/color-name-npm-1.1.4-025792b0ea-3e1c9a4dee.zip/node_modules/color-name/index.js"); // NOTE: conversions should only return primitive values (i.e. arrays, or
//       values that give correct `typeof` results).
//       do not use box values types (i.e. Number(), String(), etc.)


const reverseKeywords = {};

for (const key of Object.keys(cssKeywords)) {
  reverseKeywords[cssKeywords[key]] = key;
}

const convert = {
  rgb: {
    channels: 3,
    labels: 'rgb'
  },
  hsl: {
    channels: 3,
    labels: 'hsl'
  },
  hsv: {
    channels: 3,
    labels: 'hsv'
  },
  hwb: {
    channels: 3,
    labels: 'hwb'
  },
  cmyk: {
    channels: 4,
    labels: 'cmyk'
  },
  xyz: {
    channels: 3,
    labels: 'xyz'
  },
  lab: {
    channels: 3,
    labels: 'lab'
  },
  lch: {
    channels: 3,
    labels: 'lch'
  },
  hex: {
    channels: 1,
    labels: ['hex']
  },
  keyword: {
    channels: 1,
    labels: ['keyword']
  },
  ansi16: {
    channels: 1,
    labels: ['ansi16']
  },
  ansi256: {
    channels: 1,
    labels: ['ansi256']
  },
  hcg: {
    channels: 3,
    labels: ['h', 'c', 'g']
  },
  apple: {
    channels: 3,
    labels: ['r16', 'g16', 'b16']
  },
  gray: {
    channels: 1,
    labels: ['gray']
  }
};
module.exports = convert; // Hide .channels and .labels properties

for (const model of Object.keys(convert)) {
  if (!('channels' in convert[model])) {
    throw new Error('missing channels property: ' + model);
  }

  if (!('labels' in convert[model])) {
    throw new Error('missing channel labels property: ' + model);
  }

  if (convert[model].labels.length !== convert[model].channels) {
    throw new Error('channel and label counts mismatch: ' + model);
  }

  const {
    channels,
    labels
  } = convert[model];
  delete convert[model].channels;
  delete convert[model].labels;
  Object.defineProperty(convert[model], 'channels', {
    value: channels
  });
  Object.defineProperty(convert[model], 'labels', {
    value: labels
  });
}

convert.rgb.hsl = function (rgb) {
  const r = rgb[0] / 255;
  const g = rgb[1] / 255;
  const b = rgb[2] / 255;
  const min = Math.min(r, g, b);
  const max = Math.max(r, g, b);
  const delta = max - min;
  let h;
  let s;

  if (max === min) {
    h = 0;
  } else if (r === max) {
    h = (g - b) / delta;
  } else if (g === max) {
    h = 2 + (b - r) / delta;
  } else if (b === max) {
    h = 4 + (r - g) / delta;
  }

  h = Math.min(h * 60, 360);

  if (h < 0) {
    h += 360;
  }

  const l = (min + max) / 2;

  if (max === min) {
    s = 0;
  } else if (l <= 0.5) {
    s = delta / (max + min);
  } else {
    s = delta / (2 - max - min);
  }

  return [h, s * 100, l * 100];
};

convert.rgb.hsv = function (rgb) {
  let rdif;
  let gdif;
  let bdif;
  let h;
  let s;
  const r = rgb[0] / 255;
  const g = rgb[1] / 255;
  const b = rgb[2] / 255;
  const v = Math.max(r, g, b);
  const diff = v - Math.min(r, g, b);

  const diffc = function (c) {
    return (v - c) / 6 / diff + 1 / 2;
  };

  if (diff === 0) {
    h = 0;
    s = 0;
  } else {
    s = diff / v;
    rdif = diffc(r);
    gdif = diffc(g);
    bdif = diffc(b);

    if (r === v) {
      h = bdif - gdif;
    } else if (g === v) {
      h = 1 / 3 + rdif - bdif;
    } else if (b === v) {
      h = 2 / 3 + gdif - rdif;
    }

    if (h < 0) {
      h += 1;
    } else if (h > 1) {
      h -= 1;
    }
  }

  return [h * 360, s * 100, v * 100];
};

convert.rgb.hwb = function (rgb) {
  const r = rgb[0];
  const g = rgb[1];
  let b = rgb[2];
  const h = convert.rgb.hsl(rgb)[0];
  const w = 1 / 255 * Math.min(r, Math.min(g, b));
  b = 1 - 1 / 255 * Math.max(r, Math.max(g, b));
  return [h, w * 100, b * 100];
};

convert.rgb.cmyk = function (rgb) {
  const r = rgb[0] / 255;
  const g = rgb[1] / 255;
  const b = rgb[2] / 255;
  const k = Math.min(1 - r, 1 - g, 1 - b);
  const c = (1 - r - k) / (1 - k) || 0;
  const m = (1 - g - k) / (1 - k) || 0;
  const y = (1 - b - k) / (1 - k) || 0;
  return [c * 100, m * 100, y * 100, k * 100];
};

function comparativeDistance(x, y) {
  /*
  	See https://en.m.wikipedia.org/wiki/Euclidean_distance#Squared_Euclidean_distance
  */
  return (x[0] - y[0]) ** 2 + (x[1] - y[1]) ** 2 + (x[2] - y[2]) ** 2;
}

convert.rgb.keyword = function (rgb) {
  const reversed = reverseKeywords[rgb];

  if (reversed) {
    return reversed;
  }

  let currentClosestDistance = Infinity;
  let currentClosestKeyword;

  for (const keyword of Object.keys(cssKeywords)) {
    const value = cssKeywords[keyword]; // Compute comparative distance

    const distance = comparativeDistance(rgb, value); // Check if its less, if so set as closest

    if (distance < currentClosestDistance) {
      currentClosestDistance = distance;
      currentClosestKeyword = keyword;
    }
  }

  return currentClosestKeyword;
};

convert.keyword.rgb = function (keyword) {
  return cssKeywords[keyword];
};

convert.rgb.xyz = function (rgb) {
  let r = rgb[0] / 255;
  let g = rgb[1] / 255;
  let b = rgb[2] / 255; // Assume sRGB

  r = r > 0.04045 ? ((r + 0.055) / 1.055) ** 2.4 : r / 12.92;
  g = g > 0.04045 ? ((g + 0.055) / 1.055) ** 2.4 : g / 12.92;
  b = b > 0.04045 ? ((b + 0.055) / 1.055) ** 2.4 : b / 12.92;
  const x = r * 0.4124 + g * 0.3576 + b * 0.1805;
  const y = r * 0.2126 + g * 0.7152 + b * 0.0722;
  const z = r * 0.0193 + g * 0.1192 + b * 0.9505;
  return [x * 100, y * 100, z * 100];
};

convert.rgb.lab = function (rgb) {
  const xyz = convert.rgb.xyz(rgb);
  let x = xyz[0];
  let y = xyz[1];
  let z = xyz[2];
  x /= 95.047;
  y /= 100;
  z /= 108.883;
  x = x > 0.008856 ? x ** (1 / 3) : 7.787 * x + 16 / 116;
  y = y > 0.008856 ? y ** (1 / 3) : 7.787 * y + 16 / 116;
  z = z > 0.008856 ? z ** (1 / 3) : 7.787 * z + 16 / 116;
  const l = 116 * y - 16;
  const a = 500 * (x - y);
  const b = 200 * (y - z);
  return [l, a, b];
};

convert.hsl.rgb = function (hsl) {
  const h = hsl[0] / 360;
  const s = hsl[1] / 100;
  const l = hsl[2] / 100;
  let t2;
  let t3;
  let val;

  if (s === 0) {
    val = l * 255;
    return [val, val, val];
  }

  if (l < 0.5) {
    t2 = l * (1 + s);
  } else {
    t2 = l + s - l * s;
  }

  const t1 = 2 * l - t2;
  const rgb = [0, 0, 0];

  for (let i = 0; i < 3; i++) {
    t3 = h + 1 / 3 * -(i - 1);

    if (t3 < 0) {
      t3++;
    }

    if (t3 > 1) {
      t3--;
    }

    if (6 * t3 < 1) {
      val = t1 + (t2 - t1) * 6 * t3;
    } else if (2 * t3 < 1) {
      val = t2;
    } else if (3 * t3 < 2) {
      val = t1 + (t2 - t1) * (2 / 3 - t3) * 6;
    } else {
      val = t1;
    }

    rgb[i] = val * 255;
  }

  return rgb;
};

convert.hsl.hsv = function (hsl) {
  const h = hsl[0];
  let s = hsl[1] / 100;
  let l = hsl[2] / 100;
  let smin = s;
  const lmin = Math.max(l, 0.01);
  l *= 2;
  s *= l <= 1 ? l : 2 - l;
  smin *= lmin <= 1 ? lmin : 2 - lmin;
  const v = (l + s) / 2;
  const sv = l === 0 ? 2 * smin / (lmin + smin) : 2 * s / (l + s);
  return [h, sv * 100, v * 100];
};

convert.hsv.rgb = function (hsv) {
  const h = hsv[0] / 60;
  const s = hsv[1] / 100;
  let v = hsv[2] / 100;
  const hi = Math.floor(h) % 6;
  const f = h - Math.floor(h);
  const p = 255 * v * (1 - s);
  const q = 255 * v * (1 - s * f);
  const t = 255 * v * (1 - s * (1 - f));
  v *= 255;

  switch (hi) {
    case 0:
      return [v, t, p];

    case 1:
      return [q, v, p];

    case 2:
      return [p, v, t];

    case 3:
      return [p, q, v];

    case 4:
      return [t, p, v];

    case 5:
      return [v, p, q];
  }
};

convert.hsv.hsl = function (hsv) {
  const h = hsv[0];
  const s = hsv[1] / 100;
  const v = hsv[2] / 100;
  const vmin = Math.max(v, 0.01);
  let sl;
  let l;
  l = (2 - s) * v;
  const lmin = (2 - s) * vmin;
  sl = s * vmin;
  sl /= lmin <= 1 ? lmin : 2 - lmin;
  sl = sl || 0;
  l /= 2;
  return [h, sl * 100, l * 100];
}; // http://dev.w3.org/csswg/css-color/#hwb-to-rgb


convert.hwb.rgb = function (hwb) {
  const h = hwb[0] / 360;
  let wh = hwb[1] / 100;
  let bl = hwb[2] / 100;
  const ratio = wh + bl;
  let f; // Wh + bl cant be > 1

  if (ratio > 1) {
    wh /= ratio;
    bl /= ratio;
  }

  const i = Math.floor(6 * h);
  const v = 1 - bl;
  f = 6 * h - i;

  if ((i & 0x01) !== 0) {
    f = 1 - f;
  }

  const n = wh + f * (v - wh); // Linear interpolation

  let r;
  let g;
  let b;
  /* eslint-disable max-statements-per-line,no-multi-spaces */

  switch (i) {
    default:
    case 6:
    case 0:
      r = v;
      g = n;
      b = wh;
      break;

    case 1:
      r = n;
      g = v;
      b = wh;
      break;

    case 2:
      r = wh;
      g = v;
      b = n;
      break;

    case 3:
      r = wh;
      g = n;
      b = v;
      break;

    case 4:
      r = n;
      g = wh;
      b = v;
      break;

    case 5:
      r = v;
      g = wh;
      b = n;
      break;
  }
  /* eslint-enable max-statements-per-line,no-multi-spaces */


  return [r * 255, g * 255, b * 255];
};

convert.cmyk.rgb = function (cmyk) {
  const c = cmyk[0] / 100;
  const m = cmyk[1] / 100;
  const y = cmyk[2] / 100;
  const k = cmyk[3] / 100;
  const r = 1 - Math.min(1, c * (1 - k) + k);
  const g = 1 - Math.min(1, m * (1 - k) + k);
  const b = 1 - Math.min(1, y * (1 - k) + k);
  return [r * 255, g * 255, b * 255];
};

convert.xyz.rgb = function (xyz) {
  const x = xyz[0] / 100;
  const y = xyz[1] / 100;
  const z = xyz[2] / 100;
  let r;
  let g;
  let b;
  r = x * 3.2406 + y * -1.5372 + z * -0.4986;
  g = x * -0.9689 + y * 1.8758 + z * 0.0415;
  b = x * 0.0557 + y * -0.2040 + z * 1.0570; // Assume sRGB

  r = r > 0.0031308 ? 1.055 * r ** (1.0 / 2.4) - 0.055 : r * 12.92;
  g = g > 0.0031308 ? 1.055 * g ** (1.0 / 2.4) - 0.055 : g * 12.92;
  b = b > 0.0031308 ? 1.055 * b ** (1.0 / 2.4) - 0.055 : b * 12.92;
  r = Math.min(Math.max(0, r), 1);
  g = Math.min(Math.max(0, g), 1);
  b = Math.min(Math.max(0, b), 1);
  return [r * 255, g * 255, b * 255];
};

convert.xyz.lab = function (xyz) {
  let x = xyz[0];
  let y = xyz[1];
  let z = xyz[2];
  x /= 95.047;
  y /= 100;
  z /= 108.883;
  x = x > 0.008856 ? x ** (1 / 3) : 7.787 * x + 16 / 116;
  y = y > 0.008856 ? y ** (1 / 3) : 7.787 * y + 16 / 116;
  z = z > 0.008856 ? z ** (1 / 3) : 7.787 * z + 16 / 116;
  const l = 116 * y - 16;
  const a = 500 * (x - y);
  const b = 200 * (y - z);
  return [l, a, b];
};

convert.lab.xyz = function (lab) {
  const l = lab[0];
  const a = lab[1];
  const b = lab[2];
  let x;
  let y;
  let z;
  y = (l + 16) / 116;
  x = a / 500 + y;
  z = y - b / 200;
  const y2 = y ** 3;
  const x2 = x ** 3;
  const z2 = z ** 3;
  y = y2 > 0.008856 ? y2 : (y - 16 / 116) / 7.787;
  x = x2 > 0.008856 ? x2 : (x - 16 / 116) / 7.787;
  z = z2 > 0.008856 ? z2 : (z - 16 / 116) / 7.787;
  x *= 95.047;
  y *= 100;
  z *= 108.883;
  return [x, y, z];
};

convert.lab.lch = function (lab) {
  const l = lab[0];
  const a = lab[1];
  const b = lab[2];
  let h;
  const hr = Math.atan2(b, a);
  h = hr * 360 / 2 / Math.PI;

  if (h < 0) {
    h += 360;
  }

  const c = Math.sqrt(a * a + b * b);
  return [l, c, h];
};

convert.lch.lab = function (lch) {
  const l = lch[0];
  const c = lch[1];
  const h = lch[2];
  const hr = h / 360 * 2 * Math.PI;
  const a = c * Math.cos(hr);
  const b = c * Math.sin(hr);
  return [l, a, b];
};

convert.rgb.ansi16 = function (args, saturation = null) {
  const [r, g, b] = args;
  let value = saturation === null ? convert.rgb.hsv(args)[2] : saturation; // Hsv -> ansi16 optimization

  value = Math.round(value / 50);

  if (value === 0) {
    return 30;
  }

  let ansi = 30 + (Math.round(b / 255) << 2 | Math.round(g / 255) << 1 | Math.round(r / 255));

  if (value === 2) {
    ansi += 60;
  }

  return ansi;
};

convert.hsv.ansi16 = function (args) {
  // Optimization here; we already know the value and don't need to get
  // it converted for us.
  return convert.rgb.ansi16(convert.hsv.rgb(args), args[2]);
};

convert.rgb.ansi256 = function (args) {
  const r = args[0];
  const g = args[1];
  const b = args[2]; // We use the extended greyscale palette here, with the exception of
  // black and white. normal palette only has 4 greyscale shades.

  if (r === g && g === b) {
    if (r < 8) {
      return 16;
    }

    if (r > 248) {
      return 231;
    }

    return Math.round((r - 8) / 247 * 24) + 232;
  }

  const ansi = 16 + 36 * Math.round(r / 255 * 5) + 6 * Math.round(g / 255 * 5) + Math.round(b / 255 * 5);
  return ansi;
};

convert.ansi16.rgb = function (args) {
  let color = args % 10; // Handle greyscale

  if (color === 0 || color === 7) {
    if (args > 50) {
      color += 3.5;
    }

    color = color / 10.5 * 255;
    return [color, color, color];
  }

  const mult = (~~(args > 50) + 1) * 0.5;
  const r = (color & 1) * mult * 255;
  const g = (color >> 1 & 1) * mult * 255;
  const b = (color >> 2 & 1) * mult * 255;
  return [r, g, b];
};

convert.ansi256.rgb = function (args) {
  // Handle greyscale
  if (args >= 232) {
    const c = (args - 232) * 10 + 8;
    return [c, c, c];
  }

  args -= 16;
  let rem;
  const r = Math.floor(args / 36) / 5 * 255;
  const g = Math.floor((rem = args % 36) / 6) / 5 * 255;
  const b = rem % 6 / 5 * 255;
  return [r, g, b];
};

convert.rgb.hex = function (args) {
  const integer = ((Math.round(args[0]) & 0xFF) << 16) + ((Math.round(args[1]) & 0xFF) << 8) + (Math.round(args[2]) & 0xFF);
  const string = integer.toString(16).toUpperCase();
  return '000000'.substring(string.length) + string;
};

convert.hex.rgb = function (args) {
  const match = args.toString(16).match(/[a-f0-9]{6}|[a-f0-9]{3}/i);

  if (!match) {
    return [0, 0, 0];
  }

  let colorString = match[0];

  if (match[0].length === 3) {
    colorString = colorString.split('').map(char => {
      return char + char;
    }).join('');
  }

  const integer = parseInt(colorString, 16);
  const r = integer >> 16 & 0xFF;
  const g = integer >> 8 & 0xFF;
  const b = integer & 0xFF;
  return [r, g, b];
};

convert.rgb.hcg = function (rgb) {
  const r = rgb[0] / 255;
  const g = rgb[1] / 255;
  const b = rgb[2] / 255;
  const max = Math.max(Math.max(r, g), b);
  const min = Math.min(Math.min(r, g), b);
  const chroma = max - min;
  let grayscale;
  let hue;

  if (chroma < 1) {
    grayscale = min / (1 - chroma);
  } else {
    grayscale = 0;
  }

  if (chroma <= 0) {
    hue = 0;
  } else if (max === r) {
    hue = (g - b) / chroma % 6;
  } else if (max === g) {
    hue = 2 + (b - r) / chroma;
  } else {
    hue = 4 + (r - g) / chroma;
  }

  hue /= 6;
  hue %= 1;
  return [hue * 360, chroma * 100, grayscale * 100];
};

convert.hsl.hcg = function (hsl) {
  const s = hsl[1] / 100;
  const l = hsl[2] / 100;
  const c = l < 0.5 ? 2.0 * s * l : 2.0 * s * (1.0 - l);
  let f = 0;

  if (c < 1.0) {
    f = (l - 0.5 * c) / (1.0 - c);
  }

  return [hsl[0], c * 100, f * 100];
};

convert.hsv.hcg = function (hsv) {
  const s = hsv[1] / 100;
  const v = hsv[2] / 100;
  const c = s * v;
  let f = 0;

  if (c < 1.0) {
    f = (v - c) / (1 - c);
  }

  return [hsv[0], c * 100, f * 100];
};

convert.hcg.rgb = function (hcg) {
  const h = hcg[0] / 360;
  const c = hcg[1] / 100;
  const g = hcg[2] / 100;

  if (c === 0.0) {
    return [g * 255, g * 255, g * 255];
  }

  const pure = [0, 0, 0];
  const hi = h % 1 * 6;
  const v = hi % 1;
  const w = 1 - v;
  let mg = 0;
  /* eslint-disable max-statements-per-line */

  switch (Math.floor(hi)) {
    case 0:
      pure[0] = 1;
      pure[1] = v;
      pure[2] = 0;
      break;

    case 1:
      pure[0] = w;
      pure[1] = 1;
      pure[2] = 0;
      break;

    case 2:
      pure[0] = 0;
      pure[1] = 1;
      pure[2] = v;
      break;

    case 3:
      pure[0] = 0;
      pure[1] = w;
      pure[2] = 1;
      break;

    case 4:
      pure[0] = v;
      pure[1] = 0;
      pure[2] = 1;
      break;

    default:
      pure[0] = 1;
      pure[1] = 0;
      pure[2] = w;
  }
  /* eslint-enable max-statements-per-line */


  mg = (1.0 - c) * g;
  return [(c * pure[0] + mg) * 255, (c * pure[1] + mg) * 255, (c * pure[2] + mg) * 255];
};

convert.hcg.hsv = function (hcg) {
  const c = hcg[1] / 100;
  const g = hcg[2] / 100;
  const v = c + g * (1.0 - c);
  let f = 0;

  if (v > 0.0) {
    f = c / v;
  }

  return [hcg[0], f * 100, v * 100];
};

convert.hcg.hsl = function (hcg) {
  const c = hcg[1] / 100;
  const g = hcg[2] / 100;
  const l = g * (1.0 - c) + 0.5 * c;
  let s = 0;

  if (l > 0.0 && l < 0.5) {
    s = c / (2 * l);
  } else if (l >= 0.5 && l < 1.0) {
    s = c / (2 * (1 - l));
  }

  return [hcg[0], s * 100, l * 100];
};

convert.hcg.hwb = function (hcg) {
  const c = hcg[1] / 100;
  const g = hcg[2] / 100;
  const v = c + g * (1.0 - c);
  return [hcg[0], (v - c) * 100, (1 - v) * 100];
};

convert.hwb.hcg = function (hwb) {
  const w = hwb[1] / 100;
  const b = hwb[2] / 100;
  const v = 1 - b;
  const c = v - w;
  let g = 0;

  if (c < 1) {
    g = (v - c) / (1 - c);
  }

  return [hwb[0], c * 100, g * 100];
};

convert.apple.rgb = function (apple) {
  return [apple[0] / 65535 * 255, apple[1] / 65535 * 255, apple[2] / 65535 * 255];
};

convert.rgb.apple = function (rgb) {
  return [rgb[0] / 255 * 65535, rgb[1] / 255 * 65535, rgb[2] / 255 * 65535];
};

convert.gray.rgb = function (args) {
  return [args[0] / 100 * 255, args[0] / 100 * 255, args[0] / 100 * 255];
};

convert.gray.hsl = function (args) {
  return [0, 0, args[0]];
};

convert.gray.hsv = convert.gray.hsl;

convert.gray.hwb = function (gray) {
  return [0, 100, gray[0]];
};

convert.gray.cmyk = function (gray) {
  return [0, 0, 0, gray[0]];
};

convert.gray.lab = function (gray) {
  return [gray[0], 0, 0];
};

convert.gray.hex = function (gray) {
  const val = Math.round(gray[0] / 100 * 255) & 0xFF;
  const integer = (val << 16) + (val << 8) + val;
  const string = integer.toString(16).toUpperCase();
  return '000000'.substring(string.length) + string;
};

convert.rgb.gray = function (rgb) {
  const val = (rgb[0] + rgb[1] + rgb[2]) / 3;
  return [val / 255 * 100];
};

/***/ }),

/***/ "./.yarn/cache/color-convert-npm-2.0.1-79730e935b-3d5d8a011a.zip/node_modules/color-convert/index.js":
/*!***********************************************************************************************************!*\
  !*** ./.yarn/cache/color-convert-npm-2.0.1-79730e935b-3d5d8a011a.zip/node_modules/color-convert/index.js ***!
  \***********************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {



const conversions = __webpack_require__(/*! ./conversions */ "./.yarn/cache/color-convert-npm-2.0.1-79730e935b-3d5d8a011a.zip/node_modules/color-convert/conversions.js");

const route = __webpack_require__(/*! ./route */ "./.yarn/cache/color-convert-npm-2.0.1-79730e935b-3d5d8a011a.zip/node_modules/color-convert/route.js");

const convert = {};
const models = Object.keys(conversions);

function wrapRaw(fn) {
  const wrappedFn = function (...args) {
    const arg0 = args[0];

    if (arg0 === undefined || arg0 === null) {
      return arg0;
    }

    if (arg0.length > 1) {
      args = arg0;
    }

    return fn(args);
  }; // Preserve .conversion property if there is one


  if ('conversion' in fn) {
    wrappedFn.conversion = fn.conversion;
  }

  return wrappedFn;
}

function wrapRounded(fn) {
  const wrappedFn = function (...args) {
    const arg0 = args[0];

    if (arg0 === undefined || arg0 === null) {
      return arg0;
    }

    if (arg0.length > 1) {
      args = arg0;
    }

    const result = fn(args); // We're assuming the result is an array here.
    // see notice in conversions.js; don't use box types
    // in conversion functions.

    if (typeof result === 'object') {
      for (let len = result.length, i = 0; i < len; i++) {
        result[i] = Math.round(result[i]);
      }
    }

    return result;
  }; // Preserve .conversion property if there is one


  if ('conversion' in fn) {
    wrappedFn.conversion = fn.conversion;
  }

  return wrappedFn;
}

models.forEach(fromModel => {
  convert[fromModel] = {};
  Object.defineProperty(convert[fromModel], 'channels', {
    value: conversions[fromModel].channels
  });
  Object.defineProperty(convert[fromModel], 'labels', {
    value: conversions[fromModel].labels
  });
  const routes = route(fromModel);
  const routeModels = Object.keys(routes);
  routeModels.forEach(toModel => {
    const fn = routes[toModel];
    convert[fromModel][toModel] = wrapRounded(fn);
    convert[fromModel][toModel].raw = wrapRaw(fn);
  });
});
module.exports = convert;

/***/ }),

/***/ "./.yarn/cache/color-convert-npm-2.0.1-79730e935b-3d5d8a011a.zip/node_modules/color-convert/route.js":
/*!***********************************************************************************************************!*\
  !*** ./.yarn/cache/color-convert-npm-2.0.1-79730e935b-3d5d8a011a.zip/node_modules/color-convert/route.js ***!
  \***********************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {



const conversions = __webpack_require__(/*! ./conversions */ "./.yarn/cache/color-convert-npm-2.0.1-79730e935b-3d5d8a011a.zip/node_modules/color-convert/conversions.js");
/*
	This function routes a model to all other models.

	all functions that are routed have a property `.conversion` attached
	to the returned synthetic function. This property is an array
	of strings, each with the steps in between the 'from' and 'to'
	color models (inclusive).

	conversions that are not possible simply are not included.
*/


function buildGraph() {
  const graph = {}; // https://jsperf.com/object-keys-vs-for-in-with-closure/3

  const models = Object.keys(conversions);

  for (let len = models.length, i = 0; i < len; i++) {
    graph[models[i]] = {
      // http://jsperf.com/1-vs-infinity
      // micro-opt, but this is simple.
      distance: -1,
      parent: null
    };
  }

  return graph;
} // https://en.wikipedia.org/wiki/Breadth-first_search


function deriveBFS(fromModel) {
  const graph = buildGraph();
  const queue = [fromModel]; // Unshift -> queue -> pop

  graph[fromModel].distance = 0;

  while (queue.length) {
    const current = queue.pop();
    const adjacents = Object.keys(conversions[current]);

    for (let len = adjacents.length, i = 0; i < len; i++) {
      const adjacent = adjacents[i];
      const node = graph[adjacent];

      if (node.distance === -1) {
        node.distance = graph[current].distance + 1;
        node.parent = current;
        queue.unshift(adjacent);
      }
    }
  }

  return graph;
}

function link(from, to) {
  return function (args) {
    return to(from(args));
  };
}

function wrapConversion(toModel, graph) {
  const path = [graph[toModel].parent, toModel];
  let fn = conversions[graph[toModel].parent][toModel];
  let cur = graph[toModel].parent;

  while (graph[cur].parent) {
    path.unshift(graph[cur].parent);
    fn = link(conversions[graph[cur].parent][cur], fn);
    cur = graph[cur].parent;
  }

  fn.conversion = path;
  return fn;
}

module.exports = function (fromModel) {
  const graph = deriveBFS(fromModel);
  const conversion = {};
  const models = Object.keys(graph);

  for (let len = models.length, i = 0; i < len; i++) {
    const toModel = models[i];
    const node = graph[toModel];

    if (node.parent === null) {
      // No possible conversion, or this node is the source model.
      continue;
    }

    conversion[toModel] = wrapConversion(toModel, graph);
  }

  return conversion;
};

/***/ }),

/***/ "./.yarn/cache/color-name-npm-1.1.4-025792b0ea-3e1c9a4dee.zip/node_modules/color-name/index.js":
/*!*****************************************************************************************************!*\
  !*** ./.yarn/cache/color-name-npm-1.1.4-025792b0ea-3e1c9a4dee.zip/node_modules/color-name/index.js ***!
  \*****************************************************************************************************/
/***/ ((module) => {



module.exports = {
  "aliceblue": [240, 248, 255],
  "antiquewhite": [250, 235, 215],
  "aqua": [0, 255, 255],
  "aquamarine": [127, 255, 212],
  "azure": [240, 255, 255],
  "beige": [245, 245, 220],
  "bisque": [255, 228, 196],
  "black": [0, 0, 0],
  "blanchedalmond": [255, 235, 205],
  "blue": [0, 0, 255],
  "blueviolet": [138, 43, 226],
  "brown": [165, 42, 42],
  "burlywood": [222, 184, 135],
  "cadetblue": [95, 158, 160],
  "chartreuse": [127, 255, 0],
  "chocolate": [210, 105, 30],
  "coral": [255, 127, 80],
  "cornflowerblue": [100, 149, 237],
  "cornsilk": [255, 248, 220],
  "crimson": [220, 20, 60],
  "cyan": [0, 255, 255],
  "darkblue": [0, 0, 139],
  "darkcyan": [0, 139, 139],
  "darkgoldenrod": [184, 134, 11],
  "darkgray": [169, 169, 169],
  "darkgreen": [0, 100, 0],
  "darkgrey": [169, 169, 169],
  "darkkhaki": [189, 183, 107],
  "darkmagenta": [139, 0, 139],
  "darkolivegreen": [85, 107, 47],
  "darkorange": [255, 140, 0],
  "darkorchid": [153, 50, 204],
  "darkred": [139, 0, 0],
  "darksalmon": [233, 150, 122],
  "darkseagreen": [143, 188, 143],
  "darkslateblue": [72, 61, 139],
  "darkslategray": [47, 79, 79],
  "darkslategrey": [47, 79, 79],
  "darkturquoise": [0, 206, 209],
  "darkviolet": [148, 0, 211],
  "deeppink": [255, 20, 147],
  "deepskyblue": [0, 191, 255],
  "dimgray": [105, 105, 105],
  "dimgrey": [105, 105, 105],
  "dodgerblue": [30, 144, 255],
  "firebrick": [178, 34, 34],
  "floralwhite": [255, 250, 240],
  "forestgreen": [34, 139, 34],
  "fuchsia": [255, 0, 255],
  "gainsboro": [220, 220, 220],
  "ghostwhite": [248, 248, 255],
  "gold": [255, 215, 0],
  "goldenrod": [218, 165, 32],
  "gray": [128, 128, 128],
  "green": [0, 128, 0],
  "greenyellow": [173, 255, 47],
  "grey": [128, 128, 128],
  "honeydew": [240, 255, 240],
  "hotpink": [255, 105, 180],
  "indianred": [205, 92, 92],
  "indigo": [75, 0, 130],
  "ivory": [255, 255, 240],
  "khaki": [240, 230, 140],
  "lavender": [230, 230, 250],
  "lavenderblush": [255, 240, 245],
  "lawngreen": [124, 252, 0],
  "lemonchiffon": [255, 250, 205],
  "lightblue": [173, 216, 230],
  "lightcoral": [240, 128, 128],
  "lightcyan": [224, 255, 255],
  "lightgoldenrodyellow": [250, 250, 210],
  "lightgray": [211, 211, 211],
  "lightgreen": [144, 238, 144],
  "lightgrey": [211, 211, 211],
  "lightpink": [255, 182, 193],
  "lightsalmon": [255, 160, 122],
  "lightseagreen": [32, 178, 170],
  "lightskyblue": [135, 206, 250],
  "lightslategray": [119, 136, 153],
  "lightslategrey": [119, 136, 153],
  "lightsteelblue": [176, 196, 222],
  "lightyellow": [255, 255, 224],
  "lime": [0, 255, 0],
  "limegreen": [50, 205, 50],
  "linen": [250, 240, 230],
  "magenta": [255, 0, 255],
  "maroon": [128, 0, 0],
  "mediumaquamarine": [102, 205, 170],
  "mediumblue": [0, 0, 205],
  "mediumorchid": [186, 85, 211],
  "mediumpurple": [147, 112, 219],
  "mediumseagreen": [60, 179, 113],
  "mediumslateblue": [123, 104, 238],
  "mediumspringgreen": [0, 250, 154],
  "mediumturquoise": [72, 209, 204],
  "mediumvioletred": [199, 21, 133],
  "midnightblue": [25, 25, 112],
  "mintcream": [245, 255, 250],
  "mistyrose": [255, 228, 225],
  "moccasin": [255, 228, 181],
  "navajowhite": [255, 222, 173],
  "navy": [0, 0, 128],
  "oldlace": [253, 245, 230],
  "olive": [128, 128, 0],
  "olivedrab": [107, 142, 35],
  "orange": [255, 165, 0],
  "orangered": [255, 69, 0],
  "orchid": [218, 112, 214],
  "palegoldenrod": [238, 232, 170],
  "palegreen": [152, 251, 152],
  "paleturquoise": [175, 238, 238],
  "palevioletred": [219, 112, 147],
  "papayawhip": [255, 239, 213],
  "peachpuff": [255, 218, 185],
  "peru": [205, 133, 63],
  "pink": [255, 192, 203],
  "plum": [221, 160, 221],
  "powderblue": [176, 224, 230],
  "purple": [128, 0, 128],
  "rebeccapurple": [102, 51, 153],
  "red": [255, 0, 0],
  "rosybrown": [188, 143, 143],
  "royalblue": [65, 105, 225],
  "saddlebrown": [139, 69, 19],
  "salmon": [250, 128, 114],
  "sandybrown": [244, 164, 96],
  "seagreen": [46, 139, 87],
  "seashell": [255, 245, 238],
  "sienna": [160, 82, 45],
  "silver": [192, 192, 192],
  "skyblue": [135, 206, 235],
  "slateblue": [106, 90, 205],
  "slategray": [112, 128, 144],
  "slategrey": [112, 128, 144],
  "snow": [255, 250, 250],
  "springgreen": [0, 255, 127],
  "steelblue": [70, 130, 180],
  "tan": [210, 180, 140],
  "teal": [0, 128, 128],
  "thistle": [216, 191, 216],
  "tomato": [255, 99, 71],
  "turquoise": [64, 224, 208],
  "violet": [238, 130, 238],
  "wheat": [245, 222, 179],
  "white": [255, 255, 255],
  "whitesmoke": [245, 245, 245],
  "yellow": [255, 255, 0],
  "yellowgreen": [154, 205, 50]
};

/***/ }),

/***/ "./.yarn/cache/concat-map-npm-0.0.1-85a921b7ee-554e28d9ee.zip/node_modules/concat-map/index.js":
/*!*****************************************************************************************************!*\
  !*** ./.yarn/cache/concat-map-npm-0.0.1-85a921b7ee-554e28d9ee.zip/node_modules/concat-map/index.js ***!
  \*****************************************************************************************************/
/***/ ((module) => {



module.exports = function (xs, fn) {
  var res = [];

  for (var i = 0; i < xs.length; i++) {
    var x = fn(xs[i], i);
    if (isArray(x)) res.push.apply(res, x);else res.push(x);
  }

  return res;
};

var isArray = Array.isArray || function (xs) {
  return Object.prototype.toString.call(xs) === '[object Array]';
};

/***/ }),

/***/ "./.yarn/cache/fs.realpath-npm-1.0.0-c8f05d8126-698a91b169.zip/node_modules/fs.realpath/index.js":
/*!*******************************************************************************************************!*\
  !*** ./.yarn/cache/fs.realpath-npm-1.0.0-c8f05d8126-698a91b169.zip/node_modules/fs.realpath/index.js ***!
  \*******************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {



module.exports = realpath;
realpath.realpath = realpath;
realpath.sync = realpathSync;
realpath.realpathSync = realpathSync;
realpath.monkeypatch = monkeypatch;
realpath.unmonkeypatch = unmonkeypatch;

var fs = __webpack_require__(/*! fs */ "fs");

var origRealpath = fs.realpath;
var origRealpathSync = fs.realpathSync;
var version = process.version;
var ok = /^v[0-5]\./.test(version);

var old = __webpack_require__(/*! ./old.js */ "./.yarn/cache/fs.realpath-npm-1.0.0-c8f05d8126-698a91b169.zip/node_modules/fs.realpath/old.js");

function newError(er) {
  return er && er.syscall === 'realpath' && (er.code === 'ELOOP' || er.code === 'ENOMEM' || er.code === 'ENAMETOOLONG');
}

function realpath(p, cache, cb) {
  if (ok) {
    return origRealpath(p, cache, cb);
  }

  if (typeof cache === 'function') {
    cb = cache;
    cache = null;
  }

  origRealpath(p, cache, function (er, result) {
    if (newError(er)) {
      old.realpath(p, cache, cb);
    } else {
      cb(er, result);
    }
  });
}

function realpathSync(p, cache) {
  if (ok) {
    return origRealpathSync(p, cache);
  }

  try {
    return origRealpathSync(p, cache);
  } catch (er) {
    if (newError(er)) {
      return old.realpathSync(p, cache);
    } else {
      throw er;
    }
  }
}

function monkeypatch() {
  fs.realpath = realpath;
  fs.realpathSync = realpathSync;
}

function unmonkeypatch() {
  fs.realpath = origRealpath;
  fs.realpathSync = origRealpathSync;
}

/***/ }),

/***/ "./.yarn/cache/fs.realpath-npm-1.0.0-c8f05d8126-698a91b169.zip/node_modules/fs.realpath/old.js":
/*!*****************************************************************************************************!*\
  !*** ./.yarn/cache/fs.realpath-npm-1.0.0-c8f05d8126-698a91b169.zip/node_modules/fs.realpath/old.js ***!
  \*****************************************************************************************************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {



// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.
var pathModule = __webpack_require__(/*! path */ "path");

var isWindows = process.platform === 'win32';

var fs = __webpack_require__(/*! fs */ "fs"); // JavaScript implementation of realpath, ported from node pre-v6


var DEBUG = process.env.NODE_DEBUG && /fs/.test(process.env.NODE_DEBUG);

function rethrow() {
  // Only enable in debug mode. A backtrace uses ~1000 bytes of heap space and
  // is fairly slow to generate.
  var callback;

  if (DEBUG) {
    var backtrace = new Error();
    callback = debugCallback;
  } else callback = missingCallback;

  return callback;

  function debugCallback(err) {
    if (err) {
      backtrace.message = err.message;
      err = backtrace;
      missingCallback(err);
    }
  }

  function missingCallback(err) {
    if (err) {
      if (process.throwDeprecation) throw err; // Forgot a callback but don't know where? Use NODE_DEBUG=fs
      else if (!process.noDeprecation) {
          var msg = 'fs: missing callback ' + (err.stack || err.message);
          if (process.traceDeprecation) console.trace(msg);else console.error(msg);
        }
    }
  }
}

function maybeCallback(cb) {
  return typeof cb === 'function' ? cb : rethrow();
}

var normalize = pathModule.normalize; // Regexp that finds the next partion of a (partial) path
// result is [base_with_slash, base], e.g. ['somedir/', 'somedir']

if (isWindows) {
  var nextPartRe = /(.*?)(?:[\/\\]+|$)/g;
} else {
  var nextPartRe = /(.*?)(?:[\/]+|$)/g;
} // Regex to find the device root, including trailing slash. E.g. 'c:\\'.


if (isWindows) {
  var splitRootRe = /^(?:[a-zA-Z]:|[\\\/]{2}[^\\\/]+[\\\/][^\\\/]+)?[\\\/]*/;
} else {
  var splitRootRe = /^[\/]*/;
}

exports.realpathSync = function realpathSync(p, cache) {
  // make p is absolute
  p = pathModule.resolve(p);

  if (cache && Object.prototype.hasOwnProperty.call(cache, p)) {
    return cache[p];
  }

  var original = p,
      seenLinks = {},
      knownHard = {}; // current character position in p

  var pos; // the partial path so far, including a trailing slash if any

  var current; // the partial path without a trailing slash (except when pointing at a root)

  var base; // the partial path scanned in the previous round, with slash

  var previous;
  start();

  function start() {
    // Skip over roots
    var m = splitRootRe.exec(p);
    pos = m[0].length;
    current = m[0];
    base = m[0];
    previous = ''; // On windows, check that the root exists. On unix there is no need.

    if (isWindows && !knownHard[base]) {
      fs.lstatSync(base);
      knownHard[base] = true;
    }
  } // walk down the path, swapping out linked pathparts for their real
  // values
  // NB: p.length changes.


  while (pos < p.length) {
    // find the next part
    nextPartRe.lastIndex = pos;
    var result = nextPartRe.exec(p);
    previous = current;
    current += result[0];
    base = previous + result[1];
    pos = nextPartRe.lastIndex; // continue if not a symlink

    if (knownHard[base] || cache && cache[base] === base) {
      continue;
    }

    var resolvedLink;

    if (cache && Object.prototype.hasOwnProperty.call(cache, base)) {
      // some known symbolic link.  no need to stat again.
      resolvedLink = cache[base];
    } else {
      var stat = fs.lstatSync(base);

      if (!stat.isSymbolicLink()) {
        knownHard[base] = true;
        if (cache) cache[base] = base;
        continue;
      } // read the link if it wasn't read before
      // dev/ino always return 0 on windows, so skip the check.


      var linkTarget = null;

      if (!isWindows) {
        var id = stat.dev.toString(32) + ':' + stat.ino.toString(32);

        if (seenLinks.hasOwnProperty(id)) {
          linkTarget = seenLinks[id];
        }
      }

      if (linkTarget === null) {
        fs.statSync(base);
        linkTarget = fs.readlinkSync(base);
      }

      resolvedLink = pathModule.resolve(previous, linkTarget); // track this, if given a cache.

      if (cache) cache[base] = resolvedLink;
      if (!isWindows) seenLinks[id] = linkTarget;
    } // resolve the link, then start over


    p = pathModule.resolve(resolvedLink, p.slice(pos));
    start();
  }

  if (cache) cache[original] = p;
  return p;
};

exports.realpath = function realpath(p, cache, cb) {
  if (typeof cb !== 'function') {
    cb = maybeCallback(cache);
    cache = null;
  } // make p is absolute


  p = pathModule.resolve(p);

  if (cache && Object.prototype.hasOwnProperty.call(cache, p)) {
    return process.nextTick(cb.bind(null, null, cache[p]));
  }

  var original = p,
      seenLinks = {},
      knownHard = {}; // current character position in p

  var pos; // the partial path so far, including a trailing slash if any

  var current; // the partial path without a trailing slash (except when pointing at a root)

  var base; // the partial path scanned in the previous round, with slash

  var previous;
  start();

  function start() {
    // Skip over roots
    var m = splitRootRe.exec(p);
    pos = m[0].length;
    current = m[0];
    base = m[0];
    previous = ''; // On windows, check that the root exists. On unix there is no need.

    if (isWindows && !knownHard[base]) {
      fs.lstat(base, function (err) {
        if (err) return cb(err);
        knownHard[base] = true;
        LOOP();
      });
    } else {
      process.nextTick(LOOP);
    }
  } // walk down the path, swapping out linked pathparts for their real
  // values


  function LOOP() {
    // stop if scanned past end of path
    if (pos >= p.length) {
      if (cache) cache[original] = p;
      return cb(null, p);
    } // find the next part


    nextPartRe.lastIndex = pos;
    var result = nextPartRe.exec(p);
    previous = current;
    current += result[0];
    base = previous + result[1];
    pos = nextPartRe.lastIndex; // continue if not a symlink

    if (knownHard[base] || cache && cache[base] === base) {
      return process.nextTick(LOOP);
    }

    if (cache && Object.prototype.hasOwnProperty.call(cache, base)) {
      // known symbolic link.  no need to stat again.
      return gotResolvedLink(cache[base]);
    }

    return fs.lstat(base, gotStat);
  }

  function gotStat(err, stat) {
    if (err) return cb(err); // if not a symlink, skip to the next path part

    if (!stat.isSymbolicLink()) {
      knownHard[base] = true;
      if (cache) cache[base] = base;
      return process.nextTick(LOOP);
    } // stat & read the link if not read before
    // call gotTarget as soon as the link target is known
    // dev/ino always return 0 on windows, so skip the check.


    if (!isWindows) {
      var id = stat.dev.toString(32) + ':' + stat.ino.toString(32);

      if (seenLinks.hasOwnProperty(id)) {
        return gotTarget(null, seenLinks[id], base);
      }
    }

    fs.stat(base, function (err) {
      if (err) return cb(err);
      fs.readlink(base, function (err, target) {
        if (!isWindows) seenLinks[id] = target;
        gotTarget(err, target);
      });
    });
  }

  function gotTarget(err, target, base) {
    if (err) return cb(err);
    var resolvedLink = pathModule.resolve(previous, target);
    if (cache) cache[base] = resolvedLink;
    gotResolvedLink(resolvedLink);
  }

  function gotResolvedLink(resolvedLink) {
    // resolve the link, then start over
    p = pathModule.resolve(resolvedLink, p.slice(pos));
    start();
  }
};

/***/ }),

/***/ "./.yarn/cache/glob-npm-7.1.6-1ce3a5189a-789977b524.zip/node_modules/glob/common.js":
/*!******************************************************************************************!*\
  !*** ./.yarn/cache/glob-npm-7.1.6-1ce3a5189a-789977b524.zip/node_modules/glob/common.js ***!
  \******************************************************************************************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {



exports.alphasort = alphasort;
exports.alphasorti = alphasorti;
exports.setopts = setopts;
exports.ownProp = ownProp;
exports.makeAbs = makeAbs;
exports.finish = finish;
exports.mark = mark;
exports.isIgnored = isIgnored;
exports.childrenIgnored = childrenIgnored;

function ownProp(obj, field) {
  return Object.prototype.hasOwnProperty.call(obj, field);
}

var path = __webpack_require__(/*! path */ "path");

var minimatch = __webpack_require__(/*! minimatch */ "./.yarn/cache/minimatch-npm-3.0.4-6e76f51c23-47eab92639.zip/node_modules/minimatch/minimatch.js");

var isAbsolute = __webpack_require__(/*! path-is-absolute */ "./.yarn/cache/path-is-absolute-npm-1.0.1-31bc695ffd-907e1e3e6a.zip/node_modules/path-is-absolute/index.js");

var Minimatch = minimatch.Minimatch;

function alphasorti(a, b) {
  return a.toLowerCase().localeCompare(b.toLowerCase());
}

function alphasort(a, b) {
  return a.localeCompare(b);
}

function setupIgnores(self, options) {
  self.ignore = options.ignore || [];
  if (!Array.isArray(self.ignore)) self.ignore = [self.ignore];

  if (self.ignore.length) {
    self.ignore = self.ignore.map(ignoreMap);
  }
} // ignore patterns are always in dot:true mode.


function ignoreMap(pattern) {
  var gmatcher = null;

  if (pattern.slice(-3) === '/**') {
    var gpattern = pattern.replace(/(\/\*\*)+$/, '');
    gmatcher = new Minimatch(gpattern, {
      dot: true
    });
  }

  return {
    matcher: new Minimatch(pattern, {
      dot: true
    }),
    gmatcher: gmatcher
  };
}

function setopts(self, pattern, options) {
  if (!options) options = {}; // base-matching: just use globstar for that.

  if (options.matchBase && -1 === pattern.indexOf("/")) {
    if (options.noglobstar) {
      throw new Error("base matching requires globstar");
    }

    pattern = "**/" + pattern;
  }

  self.silent = !!options.silent;
  self.pattern = pattern;
  self.strict = options.strict !== false;
  self.realpath = !!options.realpath;
  self.realpathCache = options.realpathCache || Object.create(null);
  self.follow = !!options.follow;
  self.dot = !!options.dot;
  self.mark = !!options.mark;
  self.nodir = !!options.nodir;
  if (self.nodir) self.mark = true;
  self.sync = !!options.sync;
  self.nounique = !!options.nounique;
  self.nonull = !!options.nonull;
  self.nosort = !!options.nosort;
  self.nocase = !!options.nocase;
  self.stat = !!options.stat;
  self.noprocess = !!options.noprocess;
  self.absolute = !!options.absolute;
  self.maxLength = options.maxLength || Infinity;
  self.cache = options.cache || Object.create(null);
  self.statCache = options.statCache || Object.create(null);
  self.symlinks = options.symlinks || Object.create(null);
  setupIgnores(self, options);
  self.changedCwd = false;
  var cwd = process.cwd();
  if (!ownProp(options, "cwd")) self.cwd = cwd;else {
    self.cwd = path.resolve(options.cwd);
    self.changedCwd = self.cwd !== cwd;
  }
  self.root = options.root || path.resolve(self.cwd, "/");
  self.root = path.resolve(self.root);
  if (process.platform === "win32") self.root = self.root.replace(/\\/g, "/"); // TODO: is an absolute `cwd` supposed to be resolved against `root`?
  // e.g. { cwd: '/test', root: __dirname } === path.join(__dirname, '/test')

  self.cwdAbs = isAbsolute(self.cwd) ? self.cwd : makeAbs(self, self.cwd);
  if (process.platform === "win32") self.cwdAbs = self.cwdAbs.replace(/\\/g, "/");
  self.nomount = !!options.nomount; // disable comments and negation in Minimatch.
  // Note that they are not supported in Glob itself anyway.

  options.nonegate = true;
  options.nocomment = true;
  self.minimatch = new Minimatch(pattern, options);
  self.options = self.minimatch.options;
}

function finish(self) {
  var nou = self.nounique;
  var all = nou ? [] : Object.create(null);

  for (var i = 0, l = self.matches.length; i < l; i++) {
    var matches = self.matches[i];

    if (!matches || Object.keys(matches).length === 0) {
      if (self.nonull) {
        // do like the shell, and spit out the literal glob
        var literal = self.minimatch.globSet[i];
        if (nou) all.push(literal);else all[literal] = true;
      }
    } else {
      // had matches
      var m = Object.keys(matches);
      if (nou) all.push.apply(all, m);else m.forEach(function (m) {
        all[m] = true;
      });
    }
  }

  if (!nou) all = Object.keys(all);
  if (!self.nosort) all = all.sort(self.nocase ? alphasorti : alphasort); // at *some* point we statted all of these

  if (self.mark) {
    for (var i = 0; i < all.length; i++) {
      all[i] = self._mark(all[i]);
    }

    if (self.nodir) {
      all = all.filter(function (e) {
        var notDir = !/\/$/.test(e);
        var c = self.cache[e] || self.cache[makeAbs(self, e)];
        if (notDir && c) notDir = c !== 'DIR' && !Array.isArray(c);
        return notDir;
      });
    }
  }

  if (self.ignore.length) all = all.filter(function (m) {
    return !isIgnored(self, m);
  });
  self.found = all;
}

function mark(self, p) {
  var abs = makeAbs(self, p);
  var c = self.cache[abs];
  var m = p;

  if (c) {
    var isDir = c === 'DIR' || Array.isArray(c);
    var slash = p.slice(-1) === '/';
    if (isDir && !slash) m += '/';else if (!isDir && slash) m = m.slice(0, -1);

    if (m !== p) {
      var mabs = makeAbs(self, m);
      self.statCache[mabs] = self.statCache[abs];
      self.cache[mabs] = self.cache[abs];
    }
  }

  return m;
} // lotta situps...


function makeAbs(self, f) {
  var abs = f;

  if (f.charAt(0) === '/') {
    abs = path.join(self.root, f);
  } else if (isAbsolute(f) || f === '') {
    abs = f;
  } else if (self.changedCwd) {
    abs = path.resolve(self.cwd, f);
  } else {
    abs = path.resolve(f);
  }

  if (process.platform === 'win32') abs = abs.replace(/\\/g, '/');
  return abs;
} // Return true, if pattern ends with globstar '**', for the accompanying parent directory.
// Ex:- If node_modules/** is the pattern, add 'node_modules' to ignore list along with it's contents


function isIgnored(self, path) {
  if (!self.ignore.length) return false;
  return self.ignore.some(function (item) {
    return item.matcher.match(path) || !!(item.gmatcher && item.gmatcher.match(path));
  });
}

function childrenIgnored(self, path) {
  if (!self.ignore.length) return false;
  return self.ignore.some(function (item) {
    return !!(item.gmatcher && item.gmatcher.match(path));
  });
}

/***/ }),

/***/ "./.yarn/cache/glob-npm-7.1.6-1ce3a5189a-789977b524.zip/node_modules/glob/glob.js":
/*!****************************************************************************************!*\
  !*** ./.yarn/cache/glob-npm-7.1.6-1ce3a5189a-789977b524.zip/node_modules/glob/glob.js ***!
  \****************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {



// Approach:
//
// 1. Get the minimatch set
// 2. For each pattern in the set, PROCESS(pattern, false)
// 3. Store matches per-set, then uniq them
//
// PROCESS(pattern, inGlobStar)
// Get the first [n] items from pattern that are all strings
// Join these together.  This is PREFIX.
//   If there is no more remaining, then stat(PREFIX) and
//   add to matches if it succeeds.  END.
//
// If inGlobStar and PREFIX is symlink and points to dir
//   set ENTRIES = []
// else readdir(PREFIX) as ENTRIES
//   If fail, END
//
// with ENTRIES
//   If pattern[n] is GLOBSTAR
//     // handle the case where the globstar match is empty
//     // by pruning it out, and testing the resulting pattern
//     PROCESS(pattern[0..n] + pattern[n+1 .. $], false)
//     // handle other cases.
//     for ENTRY in ENTRIES (not dotfiles)
//       // attach globstar + tail onto the entry
//       // Mark that this entry is a globstar match
//       PROCESS(pattern[0..n] + ENTRY + pattern[n .. $], true)
//
//   else // not globstar
//     for ENTRY in ENTRIES (not dotfiles, unless pattern[n] is dot)
//       Test ENTRY against pattern[n]
//       If fails, continue
//       If passes, PROCESS(pattern[0..n] + item + pattern[n+1 .. $])
//
// Caveat:
//   Cache all stats and readdirs results to minimize syscall.  Since all
//   we ever care about is existence and directory-ness, we can just keep
//   `true` for files, and [children,...] for directories, or `false` for
//   things that don't exist.
module.exports = glob;

var fs = __webpack_require__(/*! fs */ "fs");

var rp = __webpack_require__(/*! fs.realpath */ "./.yarn/cache/fs.realpath-npm-1.0.0-c8f05d8126-698a91b169.zip/node_modules/fs.realpath/index.js");

var minimatch = __webpack_require__(/*! minimatch */ "./.yarn/cache/minimatch-npm-3.0.4-6e76f51c23-47eab92639.zip/node_modules/minimatch/minimatch.js");

var Minimatch = minimatch.Minimatch;

var inherits = __webpack_require__(/*! inherits */ "./.yarn/cache/inherits-npm-2.0.4-c66b3957a0-98426da247.zip/node_modules/inherits/inherits.js");

var EE = __webpack_require__(/*! events */ "events").EventEmitter;

var path = __webpack_require__(/*! path */ "path");

var assert = __webpack_require__(/*! assert */ "assert");

var isAbsolute = __webpack_require__(/*! path-is-absolute */ "./.yarn/cache/path-is-absolute-npm-1.0.1-31bc695ffd-907e1e3e6a.zip/node_modules/path-is-absolute/index.js");

var globSync = __webpack_require__(/*! ./sync.js */ "./.yarn/cache/glob-npm-7.1.6-1ce3a5189a-789977b524.zip/node_modules/glob/sync.js");

var common = __webpack_require__(/*! ./common.js */ "./.yarn/cache/glob-npm-7.1.6-1ce3a5189a-789977b524.zip/node_modules/glob/common.js");

var alphasort = common.alphasort;
var alphasorti = common.alphasorti;
var setopts = common.setopts;
var ownProp = common.ownProp;

var inflight = __webpack_require__(/*! inflight */ "./.yarn/cache/inflight-npm-1.0.6-ccedb4b908-17c53fc42c.zip/node_modules/inflight/inflight.js");

var util = __webpack_require__(/*! util */ "util");

var childrenIgnored = common.childrenIgnored;
var isIgnored = common.isIgnored;

var once = __webpack_require__(/*! once */ "./.yarn/cache/once-npm-1.4.0-ccf03ef07a-57afc24653.zip/node_modules/once/once.js");

function glob(pattern, options, cb) {
  if (typeof options === 'function') cb = options, options = {};
  if (!options) options = {};

  if (options.sync) {
    if (cb) throw new TypeError('callback provided to sync glob');
    return globSync(pattern, options);
  }

  return new Glob(pattern, options, cb);
}

glob.sync = globSync;
var GlobSync = glob.GlobSync = globSync.GlobSync; // old api surface

glob.glob = glob;

function extend(origin, add) {
  if (add === null || typeof add !== 'object') {
    return origin;
  }

  var keys = Object.keys(add);
  var i = keys.length;

  while (i--) {
    origin[keys[i]] = add[keys[i]];
  }

  return origin;
}

glob.hasMagic = function (pattern, options_) {
  var options = extend({}, options_);
  options.noprocess = true;
  var g = new Glob(pattern, options);
  var set = g.minimatch.set;
  if (!pattern) return false;
  if (set.length > 1) return true;

  for (var j = 0; j < set[0].length; j++) {
    if (typeof set[0][j] !== 'string') return true;
  }

  return false;
};

glob.Glob = Glob;
inherits(Glob, EE);

function Glob(pattern, options, cb) {
  if (typeof options === 'function') {
    cb = options;
    options = null;
  }

  if (options && options.sync) {
    if (cb) throw new TypeError('callback provided to sync glob');
    return new GlobSync(pattern, options);
  }

  if (!(this instanceof Glob)) return new Glob(pattern, options, cb);
  setopts(this, pattern, options);
  this._didRealPath = false; // process each pattern in the minimatch set

  var n = this.minimatch.set.length; // The matches are stored as {<filename>: true,...} so that
  // duplicates are automagically pruned.
  // Later, we do an Object.keys() on these.
  // Keep them as a list so we can fill in when nonull is set.

  this.matches = new Array(n);

  if (typeof cb === 'function') {
    cb = once(cb);
    this.on('error', cb);
    this.on('end', function (matches) {
      cb(null, matches);
    });
  }

  var self = this;
  this._processing = 0;
  this._emitQueue = [];
  this._processQueue = [];
  this.paused = false;
  if (this.noprocess) return this;
  if (n === 0) return done();
  var sync = true;

  for (var i = 0; i < n; i++) {
    this._process(this.minimatch.set[i], i, false, done);
  }

  sync = false;

  function done() {
    --self._processing;

    if (self._processing <= 0) {
      if (sync) {
        process.nextTick(function () {
          self._finish();
        });
      } else {
        self._finish();
      }
    }
  }
}

Glob.prototype._finish = function () {
  assert(this instanceof Glob);
  if (this.aborted) return;
  if (this.realpath && !this._didRealpath) return this._realpath();
  common.finish(this);
  this.emit('end', this.found);
};

Glob.prototype._realpath = function () {
  if (this._didRealpath) return;
  this._didRealpath = true;
  var n = this.matches.length;
  if (n === 0) return this._finish();
  var self = this;

  for (var i = 0; i < this.matches.length; i++) this._realpathSet(i, next);

  function next() {
    if (--n === 0) self._finish();
  }
};

Glob.prototype._realpathSet = function (index, cb) {
  var matchset = this.matches[index];
  if (!matchset) return cb();
  var found = Object.keys(matchset);
  var self = this;
  var n = found.length;
  if (n === 0) return cb();
  var set = this.matches[index] = Object.create(null);
  found.forEach(function (p, i) {
    // If there's a problem with the stat, then it means that
    // one or more of the links in the realpath couldn't be
    // resolved.  just return the abs value in that case.
    p = self._makeAbs(p);
    rp.realpath(p, self.realpathCache, function (er, real) {
      if (!er) set[real] = true;else if (er.syscall === 'stat') set[p] = true;else self.emit('error', er); // srsly wtf right here

      if (--n === 0) {
        self.matches[index] = set;
        cb();
      }
    });
  });
};

Glob.prototype._mark = function (p) {
  return common.mark(this, p);
};

Glob.prototype._makeAbs = function (f) {
  return common.makeAbs(this, f);
};

Glob.prototype.abort = function () {
  this.aborted = true;
  this.emit('abort');
};

Glob.prototype.pause = function () {
  if (!this.paused) {
    this.paused = true;
    this.emit('pause');
  }
};

Glob.prototype.resume = function () {
  if (this.paused) {
    this.emit('resume');
    this.paused = false;

    if (this._emitQueue.length) {
      var eq = this._emitQueue.slice(0);

      this._emitQueue.length = 0;

      for (var i = 0; i < eq.length; i++) {
        var e = eq[i];

        this._emitMatch(e[0], e[1]);
      }
    }

    if (this._processQueue.length) {
      var pq = this._processQueue.slice(0);

      this._processQueue.length = 0;

      for (var i = 0; i < pq.length; i++) {
        var p = pq[i];
        this._processing--;

        this._process(p[0], p[1], p[2], p[3]);
      }
    }
  }
};

Glob.prototype._process = function (pattern, index, inGlobStar, cb) {
  assert(this instanceof Glob);
  assert(typeof cb === 'function');
  if (this.aborted) return;
  this._processing++;

  if (this.paused) {
    this._processQueue.push([pattern, index, inGlobStar, cb]);

    return;
  } //console.error('PROCESS %d', this._processing, pattern)
  // Get the first [n] parts of pattern that are all strings.


  var n = 0;

  while (typeof pattern[n] === 'string') {
    n++;
  } // now n is the index of the first one that is *not* a string.
  // see if there's anything else


  var prefix;

  switch (n) {
    // if not, then this is rather simple
    case pattern.length:
      this._processSimple(pattern.join('/'), index, cb);

      return;

    case 0:
      // pattern *starts* with some non-trivial item.
      // going to readdir(cwd), but not include the prefix in matches.
      prefix = null;
      break;

    default:
      // pattern has some string bits in the front.
      // whatever it starts with, whether that's 'absolute' like /foo/bar,
      // or 'relative' like '../baz'
      prefix = pattern.slice(0, n).join('/');
      break;
  }

  var remain = pattern.slice(n); // get the list of entries.

  var read;
  if (prefix === null) read = '.';else if (isAbsolute(prefix) || isAbsolute(pattern.join('/'))) {
    if (!prefix || !isAbsolute(prefix)) prefix = '/' + prefix;
    read = prefix;
  } else read = prefix;

  var abs = this._makeAbs(read); //if ignored, skip _processing


  if (childrenIgnored(this, read)) return cb();
  var isGlobStar = remain[0] === minimatch.GLOBSTAR;
  if (isGlobStar) this._processGlobStar(prefix, read, abs, remain, index, inGlobStar, cb);else this._processReaddir(prefix, read, abs, remain, index, inGlobStar, cb);
};

Glob.prototype._processReaddir = function (prefix, read, abs, remain, index, inGlobStar, cb) {
  var self = this;

  this._readdir(abs, inGlobStar, function (er, entries) {
    return self._processReaddir2(prefix, read, abs, remain, index, inGlobStar, entries, cb);
  });
};

Glob.prototype._processReaddir2 = function (prefix, read, abs, remain, index, inGlobStar, entries, cb) {
  // if the abs isn't a dir, then nothing can match!
  if (!entries) return cb(); // It will only match dot entries if it starts with a dot, or if
  // dot is set.  Stuff like @(.foo|.bar) isn't allowed.

  var pn = remain[0];
  var negate = !!this.minimatch.negate;
  var rawGlob = pn._glob;
  var dotOk = this.dot || rawGlob.charAt(0) === '.';
  var matchedEntries = [];

  for (var i = 0; i < entries.length; i++) {
    var e = entries[i];

    if (e.charAt(0) !== '.' || dotOk) {
      var m;

      if (negate && !prefix) {
        m = !e.match(pn);
      } else {
        m = e.match(pn);
      }

      if (m) matchedEntries.push(e);
    }
  } //console.error('prd2', prefix, entries, remain[0]._glob, matchedEntries)


  var len = matchedEntries.length; // If there are no matched entries, then nothing matches.

  if (len === 0) return cb(); // if this is the last remaining pattern bit, then no need for
  // an additional stat *unless* the user has specified mark or
  // stat explicitly.  We know they exist, since readdir returned
  // them.

  if (remain.length === 1 && !this.mark && !this.stat) {
    if (!this.matches[index]) this.matches[index] = Object.create(null);

    for (var i = 0; i < len; i++) {
      var e = matchedEntries[i];

      if (prefix) {
        if (prefix !== '/') e = prefix + '/' + e;else e = prefix + e;
      }

      if (e.charAt(0) === '/' && !this.nomount) {
        e = path.join(this.root, e);
      }

      this._emitMatch(index, e);
    } // This was the last one, and no stats were needed


    return cb();
  } // now test all matched entries as stand-ins for that part
  // of the pattern.


  remain.shift();

  for (var i = 0; i < len; i++) {
    var e = matchedEntries[i];
    var newPattern;

    if (prefix) {
      if (prefix !== '/') e = prefix + '/' + e;else e = prefix + e;
    }

    this._process([e].concat(remain), index, inGlobStar, cb);
  }

  cb();
};

Glob.prototype._emitMatch = function (index, e) {
  if (this.aborted) return;
  if (isIgnored(this, e)) return;

  if (this.paused) {
    this._emitQueue.push([index, e]);

    return;
  }

  var abs = isAbsolute(e) ? e : this._makeAbs(e);
  if (this.mark) e = this._mark(e);
  if (this.absolute) e = abs;
  if (this.matches[index][e]) return;

  if (this.nodir) {
    var c = this.cache[abs];
    if (c === 'DIR' || Array.isArray(c)) return;
  }

  this.matches[index][e] = true;
  var st = this.statCache[abs];
  if (st) this.emit('stat', e, st);
  this.emit('match', e);
};

Glob.prototype._readdirInGlobStar = function (abs, cb) {
  if (this.aborted) return; // follow all symlinked directories forever
  // just proceed as if this is a non-globstar situation

  if (this.follow) return this._readdir(abs, false, cb);
  var lstatkey = 'lstat\0' + abs;
  var self = this;
  var lstatcb = inflight(lstatkey, lstatcb_);
  if (lstatcb) fs.lstat(abs, lstatcb);

  function lstatcb_(er, lstat) {
    if (er && er.code === 'ENOENT') return cb();
    var isSym = lstat && lstat.isSymbolicLink();
    self.symlinks[abs] = isSym; // If it's not a symlink or a dir, then it's definitely a regular file.
    // don't bother doing a readdir in that case.

    if (!isSym && lstat && !lstat.isDirectory()) {
      self.cache[abs] = 'FILE';
      cb();
    } else self._readdir(abs, false, cb);
  }
};

Glob.prototype._readdir = function (abs, inGlobStar, cb) {
  if (this.aborted) return;
  cb = inflight('readdir\0' + abs + '\0' + inGlobStar, cb);
  if (!cb) return; //console.error('RD %j %j', +inGlobStar, abs)

  if (inGlobStar && !ownProp(this.symlinks, abs)) return this._readdirInGlobStar(abs, cb);

  if (ownProp(this.cache, abs)) {
    var c = this.cache[abs];
    if (!c || c === 'FILE') return cb();
    if (Array.isArray(c)) return cb(null, c);
  }

  var self = this;
  fs.readdir(abs, readdirCb(this, abs, cb));
};

function readdirCb(self, abs, cb) {
  return function (er, entries) {
    if (er) self._readdirError(abs, er, cb);else self._readdirEntries(abs, entries, cb);
  };
}

Glob.prototype._readdirEntries = function (abs, entries, cb) {
  if (this.aborted) return; // if we haven't asked to stat everything, then just
  // assume that everything in there exists, so we can avoid
  // having to stat it a second time.

  if (!this.mark && !this.stat) {
    for (var i = 0; i < entries.length; i++) {
      var e = entries[i];
      if (abs === '/') e = abs + e;else e = abs + '/' + e;
      this.cache[e] = true;
    }
  }

  this.cache[abs] = entries;
  return cb(null, entries);
};

Glob.prototype._readdirError = function (f, er, cb) {
  if (this.aborted) return; // handle errors, and cache the information

  switch (er.code) {
    case 'ENOTSUP': // https://github.com/isaacs/node-glob/issues/205

    case 'ENOTDIR':
      // totally normal. means it *does* exist.
      var abs = this._makeAbs(f);

      this.cache[abs] = 'FILE';

      if (abs === this.cwdAbs) {
        var error = new Error(er.code + ' invalid cwd ' + this.cwd);
        error.path = this.cwd;
        error.code = er.code;
        this.emit('error', error);
        this.abort();
      }

      break;

    case 'ENOENT': // not terribly unusual

    case 'ELOOP':
    case 'ENAMETOOLONG':
    case 'UNKNOWN':
      this.cache[this._makeAbs(f)] = false;
      break;

    default:
      // some unusual error.  Treat as failure.
      this.cache[this._makeAbs(f)] = false;

      if (this.strict) {
        this.emit('error', er); // If the error is handled, then we abort
        // if not, we threw out of here

        this.abort();
      }

      if (!this.silent) console.error('glob error', er);
      break;
  }

  return cb();
};

Glob.prototype._processGlobStar = function (prefix, read, abs, remain, index, inGlobStar, cb) {
  var self = this;

  this._readdir(abs, inGlobStar, function (er, entries) {
    self._processGlobStar2(prefix, read, abs, remain, index, inGlobStar, entries, cb);
  });
};

Glob.prototype._processGlobStar2 = function (prefix, read, abs, remain, index, inGlobStar, entries, cb) {
  //console.error('pgs2', prefix, remain[0], entries)
  // no entries means not a dir, so it can never have matches
  // foo.txt/** doesn't match foo.txt
  if (!entries) return cb(); // test without the globstar, and with every child both below
  // and replacing the globstar.

  var remainWithoutGlobStar = remain.slice(1);
  var gspref = prefix ? [prefix] : [];
  var noGlobStar = gspref.concat(remainWithoutGlobStar); // the noGlobStar pattern exits the inGlobStar state

  this._process(noGlobStar, index, false, cb);

  var isSym = this.symlinks[abs];
  var len = entries.length; // If it's a symlink, and we're in a globstar, then stop

  if (isSym && inGlobStar) return cb();

  for (var i = 0; i < len; i++) {
    var e = entries[i];
    if (e.charAt(0) === '.' && !this.dot) continue; // these two cases enter the inGlobStar state

    var instead = gspref.concat(entries[i], remainWithoutGlobStar);

    this._process(instead, index, true, cb);

    var below = gspref.concat(entries[i], remain);

    this._process(below, index, true, cb);
  }

  cb();
};

Glob.prototype._processSimple = function (prefix, index, cb) {
  // XXX review this.  Shouldn't it be doing the mounting etc
  // before doing stat?  kinda weird?
  var self = this;

  this._stat(prefix, function (er, exists) {
    self._processSimple2(prefix, index, er, exists, cb);
  });
};

Glob.prototype._processSimple2 = function (prefix, index, er, exists, cb) {
  //console.error('ps2', prefix, exists)
  if (!this.matches[index]) this.matches[index] = Object.create(null); // If it doesn't exist, then just mark the lack of results

  if (!exists) return cb();

  if (prefix && isAbsolute(prefix) && !this.nomount) {
    var trail = /[\/\\]$/.test(prefix);

    if (prefix.charAt(0) === '/') {
      prefix = path.join(this.root, prefix);
    } else {
      prefix = path.resolve(this.root, prefix);
      if (trail) prefix += '/';
    }
  }

  if (process.platform === 'win32') prefix = prefix.replace(/\\/g, '/'); // Mark this as a match

  this._emitMatch(index, prefix);

  cb();
}; // Returns either 'DIR', 'FILE', or false


Glob.prototype._stat = function (f, cb) {
  var abs = this._makeAbs(f);

  var needDir = f.slice(-1) === '/';
  if (f.length > this.maxLength) return cb();

  if (!this.stat && ownProp(this.cache, abs)) {
    var c = this.cache[abs];
    if (Array.isArray(c)) c = 'DIR'; // It exists, but maybe not how we need it

    if (!needDir || c === 'DIR') return cb(null, c);
    if (needDir && c === 'FILE') return cb(); // otherwise we have to stat, because maybe c=true
    // if we know it exists, but not what it is.
  }

  var exists;
  var stat = this.statCache[abs];

  if (stat !== undefined) {
    if (stat === false) return cb(null, stat);else {
      var type = stat.isDirectory() ? 'DIR' : 'FILE';
      if (needDir && type === 'FILE') return cb();else return cb(null, type, stat);
    }
  }

  var self = this;
  var statcb = inflight('stat\0' + abs, lstatcb_);
  if (statcb) fs.lstat(abs, statcb);

  function lstatcb_(er, lstat) {
    if (lstat && lstat.isSymbolicLink()) {
      // If it's a symlink, then treat it as the target, unless
      // the target does not exist, then treat it as a file.
      return fs.stat(abs, function (er, stat) {
        if (er) self._stat2(f, abs, null, lstat, cb);else self._stat2(f, abs, er, stat, cb);
      });
    } else {
      self._stat2(f, abs, er, lstat, cb);
    }
  }
};

Glob.prototype._stat2 = function (f, abs, er, stat, cb) {
  if (er && (er.code === 'ENOENT' || er.code === 'ENOTDIR')) {
    this.statCache[abs] = false;
    return cb();
  }

  var needDir = f.slice(-1) === '/';
  this.statCache[abs] = stat;
  if (abs.slice(-1) === '/' && stat && !stat.isDirectory()) return cb(null, false, stat);
  var c = true;
  if (stat) c = stat.isDirectory() ? 'DIR' : 'FILE';
  this.cache[abs] = this.cache[abs] || c;
  if (needDir && c === 'FILE') return cb();
  return cb(null, c, stat);
};

/***/ }),

/***/ "./.yarn/cache/glob-npm-7.1.6-1ce3a5189a-789977b524.zip/node_modules/glob/sync.js":
/*!****************************************************************************************!*\
  !*** ./.yarn/cache/glob-npm-7.1.6-1ce3a5189a-789977b524.zip/node_modules/glob/sync.js ***!
  \****************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {



module.exports = globSync;
globSync.GlobSync = GlobSync;

var fs = __webpack_require__(/*! fs */ "fs");

var rp = __webpack_require__(/*! fs.realpath */ "./.yarn/cache/fs.realpath-npm-1.0.0-c8f05d8126-698a91b169.zip/node_modules/fs.realpath/index.js");

var minimatch = __webpack_require__(/*! minimatch */ "./.yarn/cache/minimatch-npm-3.0.4-6e76f51c23-47eab92639.zip/node_modules/minimatch/minimatch.js");

var Minimatch = minimatch.Minimatch;

var Glob = __webpack_require__(/*! ./glob.js */ "./.yarn/cache/glob-npm-7.1.6-1ce3a5189a-789977b524.zip/node_modules/glob/glob.js").Glob;

var util = __webpack_require__(/*! util */ "util");

var path = __webpack_require__(/*! path */ "path");

var assert = __webpack_require__(/*! assert */ "assert");

var isAbsolute = __webpack_require__(/*! path-is-absolute */ "./.yarn/cache/path-is-absolute-npm-1.0.1-31bc695ffd-907e1e3e6a.zip/node_modules/path-is-absolute/index.js");

var common = __webpack_require__(/*! ./common.js */ "./.yarn/cache/glob-npm-7.1.6-1ce3a5189a-789977b524.zip/node_modules/glob/common.js");

var alphasort = common.alphasort;
var alphasorti = common.alphasorti;
var setopts = common.setopts;
var ownProp = common.ownProp;
var childrenIgnored = common.childrenIgnored;
var isIgnored = common.isIgnored;

function globSync(pattern, options) {
  if (typeof options === 'function' || arguments.length === 3) throw new TypeError('callback provided to sync glob\n' + 'See: https://github.com/isaacs/node-glob/issues/167');
  return new GlobSync(pattern, options).found;
}

function GlobSync(pattern, options) {
  if (!pattern) throw new Error('must provide pattern');
  if (typeof options === 'function' || arguments.length === 3) throw new TypeError('callback provided to sync glob\n' + 'See: https://github.com/isaacs/node-glob/issues/167');
  if (!(this instanceof GlobSync)) return new GlobSync(pattern, options);
  setopts(this, pattern, options);
  if (this.noprocess) return this;
  var n = this.minimatch.set.length;
  this.matches = new Array(n);

  for (var i = 0; i < n; i++) {
    this._process(this.minimatch.set[i], i, false);
  }

  this._finish();
}

GlobSync.prototype._finish = function () {
  assert(this instanceof GlobSync);

  if (this.realpath) {
    var self = this;
    this.matches.forEach(function (matchset, index) {
      var set = self.matches[index] = Object.create(null);

      for (var p in matchset) {
        try {
          p = self._makeAbs(p);
          var real = rp.realpathSync(p, self.realpathCache);
          set[real] = true;
        } catch (er) {
          if (er.syscall === 'stat') set[self._makeAbs(p)] = true;else throw er;
        }
      }
    });
  }

  common.finish(this);
};

GlobSync.prototype._process = function (pattern, index, inGlobStar) {
  assert(this instanceof GlobSync); // Get the first [n] parts of pattern that are all strings.

  var n = 0;

  while (typeof pattern[n] === 'string') {
    n++;
  } // now n is the index of the first one that is *not* a string.
  // See if there's anything else


  var prefix;

  switch (n) {
    // if not, then this is rather simple
    case pattern.length:
      this._processSimple(pattern.join('/'), index);

      return;

    case 0:
      // pattern *starts* with some non-trivial item.
      // going to readdir(cwd), but not include the prefix in matches.
      prefix = null;
      break;

    default:
      // pattern has some string bits in the front.
      // whatever it starts with, whether that's 'absolute' like /foo/bar,
      // or 'relative' like '../baz'
      prefix = pattern.slice(0, n).join('/');
      break;
  }

  var remain = pattern.slice(n); // get the list of entries.

  var read;
  if (prefix === null) read = '.';else if (isAbsolute(prefix) || isAbsolute(pattern.join('/'))) {
    if (!prefix || !isAbsolute(prefix)) prefix = '/' + prefix;
    read = prefix;
  } else read = prefix;

  var abs = this._makeAbs(read); //if ignored, skip processing


  if (childrenIgnored(this, read)) return;
  var isGlobStar = remain[0] === minimatch.GLOBSTAR;
  if (isGlobStar) this._processGlobStar(prefix, read, abs, remain, index, inGlobStar);else this._processReaddir(prefix, read, abs, remain, index, inGlobStar);
};

GlobSync.prototype._processReaddir = function (prefix, read, abs, remain, index, inGlobStar) {
  var entries = this._readdir(abs, inGlobStar); // if the abs isn't a dir, then nothing can match!


  if (!entries) return; // It will only match dot entries if it starts with a dot, or if
  // dot is set.  Stuff like @(.foo|.bar) isn't allowed.

  var pn = remain[0];
  var negate = !!this.minimatch.negate;
  var rawGlob = pn._glob;
  var dotOk = this.dot || rawGlob.charAt(0) === '.';
  var matchedEntries = [];

  for (var i = 0; i < entries.length; i++) {
    var e = entries[i];

    if (e.charAt(0) !== '.' || dotOk) {
      var m;

      if (negate && !prefix) {
        m = !e.match(pn);
      } else {
        m = e.match(pn);
      }

      if (m) matchedEntries.push(e);
    }
  }

  var len = matchedEntries.length; // If there are no matched entries, then nothing matches.

  if (len === 0) return; // if this is the last remaining pattern bit, then no need for
  // an additional stat *unless* the user has specified mark or
  // stat explicitly.  We know they exist, since readdir returned
  // them.

  if (remain.length === 1 && !this.mark && !this.stat) {
    if (!this.matches[index]) this.matches[index] = Object.create(null);

    for (var i = 0; i < len; i++) {
      var e = matchedEntries[i];

      if (prefix) {
        if (prefix.slice(-1) !== '/') e = prefix + '/' + e;else e = prefix + e;
      }

      if (e.charAt(0) === '/' && !this.nomount) {
        e = path.join(this.root, e);
      }

      this._emitMatch(index, e);
    } // This was the last one, and no stats were needed


    return;
  } // now test all matched entries as stand-ins for that part
  // of the pattern.


  remain.shift();

  for (var i = 0; i < len; i++) {
    var e = matchedEntries[i];
    var newPattern;
    if (prefix) newPattern = [prefix, e];else newPattern = [e];

    this._process(newPattern.concat(remain), index, inGlobStar);
  }
};

GlobSync.prototype._emitMatch = function (index, e) {
  if (isIgnored(this, e)) return;

  var abs = this._makeAbs(e);

  if (this.mark) e = this._mark(e);

  if (this.absolute) {
    e = abs;
  }

  if (this.matches[index][e]) return;

  if (this.nodir) {
    var c = this.cache[abs];
    if (c === 'DIR' || Array.isArray(c)) return;
  }

  this.matches[index][e] = true;
  if (this.stat) this._stat(e);
};

GlobSync.prototype._readdirInGlobStar = function (abs) {
  // follow all symlinked directories forever
  // just proceed as if this is a non-globstar situation
  if (this.follow) return this._readdir(abs, false);
  var entries;
  var lstat;
  var stat;

  try {
    lstat = fs.lstatSync(abs);
  } catch (er) {
    if (er.code === 'ENOENT') {
      // lstat failed, doesn't exist
      return null;
    }
  }

  var isSym = lstat && lstat.isSymbolicLink();
  this.symlinks[abs] = isSym; // If it's not a symlink or a dir, then it's definitely a regular file.
  // don't bother doing a readdir in that case.

  if (!isSym && lstat && !lstat.isDirectory()) this.cache[abs] = 'FILE';else entries = this._readdir(abs, false);
  return entries;
};

GlobSync.prototype._readdir = function (abs, inGlobStar) {
  var entries;
  if (inGlobStar && !ownProp(this.symlinks, abs)) return this._readdirInGlobStar(abs);

  if (ownProp(this.cache, abs)) {
    var c = this.cache[abs];
    if (!c || c === 'FILE') return null;
    if (Array.isArray(c)) return c;
  }

  try {
    return this._readdirEntries(abs, fs.readdirSync(abs));
  } catch (er) {
    this._readdirError(abs, er);

    return null;
  }
};

GlobSync.prototype._readdirEntries = function (abs, entries) {
  // if we haven't asked to stat everything, then just
  // assume that everything in there exists, so we can avoid
  // having to stat it a second time.
  if (!this.mark && !this.stat) {
    for (var i = 0; i < entries.length; i++) {
      var e = entries[i];
      if (abs === '/') e = abs + e;else e = abs + '/' + e;
      this.cache[e] = true;
    }
  }

  this.cache[abs] = entries; // mark and cache dir-ness

  return entries;
};

GlobSync.prototype._readdirError = function (f, er) {
  // handle errors, and cache the information
  switch (er.code) {
    case 'ENOTSUP': // https://github.com/isaacs/node-glob/issues/205

    case 'ENOTDIR':
      // totally normal. means it *does* exist.
      var abs = this._makeAbs(f);

      this.cache[abs] = 'FILE';

      if (abs === this.cwdAbs) {
        var error = new Error(er.code + ' invalid cwd ' + this.cwd);
        error.path = this.cwd;
        error.code = er.code;
        throw error;
      }

      break;

    case 'ENOENT': // not terribly unusual

    case 'ELOOP':
    case 'ENAMETOOLONG':
    case 'UNKNOWN':
      this.cache[this._makeAbs(f)] = false;
      break;

    default:
      // some unusual error.  Treat as failure.
      this.cache[this._makeAbs(f)] = false;
      if (this.strict) throw er;
      if (!this.silent) console.error('glob error', er);
      break;
  }
};

GlobSync.prototype._processGlobStar = function (prefix, read, abs, remain, index, inGlobStar) {
  var entries = this._readdir(abs, inGlobStar); // no entries means not a dir, so it can never have matches
  // foo.txt/** doesn't match foo.txt


  if (!entries) return; // test without the globstar, and with every child both below
  // and replacing the globstar.

  var remainWithoutGlobStar = remain.slice(1);
  var gspref = prefix ? [prefix] : [];
  var noGlobStar = gspref.concat(remainWithoutGlobStar); // the noGlobStar pattern exits the inGlobStar state

  this._process(noGlobStar, index, false);

  var len = entries.length;
  var isSym = this.symlinks[abs]; // If it's a symlink, and we're in a globstar, then stop

  if (isSym && inGlobStar) return;

  for (var i = 0; i < len; i++) {
    var e = entries[i];
    if (e.charAt(0) === '.' && !this.dot) continue; // these two cases enter the inGlobStar state

    var instead = gspref.concat(entries[i], remainWithoutGlobStar);

    this._process(instead, index, true);

    var below = gspref.concat(entries[i], remain);

    this._process(below, index, true);
  }
};

GlobSync.prototype._processSimple = function (prefix, index) {
  // XXX review this.  Shouldn't it be doing the mounting etc
  // before doing stat?  kinda weird?
  var exists = this._stat(prefix);

  if (!this.matches[index]) this.matches[index] = Object.create(null); // If it doesn't exist, then just mark the lack of results

  if (!exists) return;

  if (prefix && isAbsolute(prefix) && !this.nomount) {
    var trail = /[\/\\]$/.test(prefix);

    if (prefix.charAt(0) === '/') {
      prefix = path.join(this.root, prefix);
    } else {
      prefix = path.resolve(this.root, prefix);
      if (trail) prefix += '/';
    }
  }

  if (process.platform === 'win32') prefix = prefix.replace(/\\/g, '/'); // Mark this as a match

  this._emitMatch(index, prefix);
}; // Returns either 'DIR', 'FILE', or false


GlobSync.prototype._stat = function (f) {
  var abs = this._makeAbs(f);

  var needDir = f.slice(-1) === '/';
  if (f.length > this.maxLength) return false;

  if (!this.stat && ownProp(this.cache, abs)) {
    var c = this.cache[abs];
    if (Array.isArray(c)) c = 'DIR'; // It exists, but maybe not how we need it

    if (!needDir || c === 'DIR') return c;
    if (needDir && c === 'FILE') return false; // otherwise we have to stat, because maybe c=true
    // if we know it exists, but not what it is.
  }

  var exists;
  var stat = this.statCache[abs];

  if (!stat) {
    var lstat;

    try {
      lstat = fs.lstatSync(abs);
    } catch (er) {
      if (er && (er.code === 'ENOENT' || er.code === 'ENOTDIR')) {
        this.statCache[abs] = false;
        return false;
      }
    }

    if (lstat && lstat.isSymbolicLink()) {
      try {
        stat = fs.statSync(abs);
      } catch (er) {
        stat = lstat;
      }
    } else {
      stat = lstat;
    }
  }

  this.statCache[abs] = stat;
  var c = true;
  if (stat) c = stat.isDirectory() ? 'DIR' : 'FILE';
  this.cache[abs] = this.cache[abs] || c;
  if (needDir && c === 'FILE') return false;
  return c;
};

GlobSync.prototype._mark = function (p) {
  return common.mark(this, p);
};

GlobSync.prototype._makeAbs = function (f) {
  return common.makeAbs(this, f);
};

/***/ }),

/***/ "./.yarn/cache/has-flag-npm-4.0.0-32af9f0536-2e5391139d.zip/node_modules/has-flag/index.js":
/*!*************************************************************************************************!*\
  !*** ./.yarn/cache/has-flag-npm-4.0.0-32af9f0536-2e5391139d.zip/node_modules/has-flag/index.js ***!
  \*************************************************************************************************/
/***/ ((module) => {



module.exports = (flag, argv = process.argv) => {
  const prefix = flag.startsWith('-') ? '' : flag.length === 1 ? '-' : '--';
  const position = argv.indexOf(prefix + flag);
  const terminatorPosition = argv.indexOf('--');
  return position !== -1 && (terminatorPosition === -1 || position < terminatorPosition);
};

/***/ }),

/***/ "./.yarn/cache/inflight-npm-1.0.6-ccedb4b908-17c53fc42c.zip/node_modules/inflight/inflight.js":
/*!****************************************************************************************************!*\
  !*** ./.yarn/cache/inflight-npm-1.0.6-ccedb4b908-17c53fc42c.zip/node_modules/inflight/inflight.js ***!
  \****************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {



var wrappy = __webpack_require__(/*! wrappy */ "./.yarn/cache/wrappy-npm-1.0.2-916de4d4b3-519fcda0fc.zip/node_modules/wrappy/wrappy.js");

var reqs = Object.create(null);

var once = __webpack_require__(/*! once */ "./.yarn/cache/once-npm-1.4.0-ccf03ef07a-57afc24653.zip/node_modules/once/once.js");

module.exports = wrappy(inflight);

function inflight(key, cb) {
  if (reqs[key]) {
    reqs[key].push(cb);
    return null;
  } else {
    reqs[key] = [cb];
    return makeres(key);
  }
}

function makeres(key) {
  return once(function RES() {
    var cbs = reqs[key];
    var len = cbs.length;
    var args = slice(arguments); // XXX It's somewhat ambiguous whether a new callback added in this
    // pass should be queued for later execution if something in the
    // list of callbacks throws, or if it should just be discarded.
    // However, it's such an edge case that it hardly matters, and either
    // choice is likely as surprising as the other.
    // As it happens, we do go ahead and schedule it for later execution.

    try {
      for (var i = 0; i < len; i++) {
        cbs[i].apply(null, args);
      }
    } finally {
      if (cbs.length > len) {
        // added more in the interim.
        // de-zalgo, just in case, but don't call again.
        cbs.splice(0, len);
        process.nextTick(function () {
          RES.apply(null, args);
        });
      } else {
        delete reqs[key];
      }
    }
  });
}

function slice(args) {
  var length = args.length;
  var array = [];

  for (var i = 0; i < length; i++) array[i] = args[i];

  return array;
}

/***/ }),

/***/ "./.yarn/cache/inherits-npm-2.0.4-c66b3957a0-98426da247.zip/node_modules/inherits/inherits.js":
/*!****************************************************************************************************!*\
  !*** ./.yarn/cache/inherits-npm-2.0.4-c66b3957a0-98426da247.zip/node_modules/inherits/inherits.js ***!
  \****************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {



try {
  var util = __webpack_require__(/*! util */ "util");
  /* istanbul ignore next */


  if (typeof util.inherits !== 'function') throw '';
  module.exports = util.inherits;
} catch (e) {
  /* istanbul ignore next */
  module.exports = __webpack_require__(/*! ./inherits_browser.js */ "./.yarn/cache/inherits-npm-2.0.4-c66b3957a0-98426da247.zip/node_modules/inherits/inherits_browser.js");
}

/***/ }),

/***/ "./.yarn/cache/inherits-npm-2.0.4-c66b3957a0-98426da247.zip/node_modules/inherits/inherits_browser.js":
/*!************************************************************************************************************!*\
  !*** ./.yarn/cache/inherits-npm-2.0.4-c66b3957a0-98426da247.zip/node_modules/inherits/inherits_browser.js ***!
  \************************************************************************************************************/
/***/ ((module) => {



if (typeof Object.create === 'function') {
  // implementation from standard node.js 'util' module
  module.exports = function inherits(ctor, superCtor) {
    if (superCtor) {
      ctor.super_ = superCtor;
      ctor.prototype = Object.create(superCtor.prototype, {
        constructor: {
          value: ctor,
          enumerable: false,
          writable: true,
          configurable: true
        }
      });
    }
  };
} else {
  // old school shim for old browsers
  module.exports = function inherits(ctor, superCtor) {
    if (superCtor) {
      ctor.super_ = superCtor;

      var TempCtor = function () {};

      TempCtor.prototype = superCtor.prototype;
      ctor.prototype = new TempCtor();
      ctor.prototype.constructor = ctor;
    }
  };
}

/***/ }),

/***/ "./.yarn/cache/minimatch-npm-3.0.4-6e76f51c23-47eab92639.zip/node_modules/minimatch/minimatch.js":
/*!*******************************************************************************************************!*\
  !*** ./.yarn/cache/minimatch-npm-3.0.4-6e76f51c23-47eab92639.zip/node_modules/minimatch/minimatch.js ***!
  \*******************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {



module.exports = minimatch;
minimatch.Minimatch = Minimatch;
var path = {
  sep: '/'
};

try {
  path = __webpack_require__(/*! path */ "path");
} catch (er) {}

var GLOBSTAR = minimatch.GLOBSTAR = Minimatch.GLOBSTAR = {};

var expand = __webpack_require__(/*! brace-expansion */ "./.yarn/cache/brace-expansion-npm-1.1.11-fb95eb05ad-4c878e25e4.zip/node_modules/brace-expansion/index.js");

var plTypes = {
  '!': {
    open: '(?:(?!(?:',
    close: '))[^/]*?)'
  },
  '?': {
    open: '(?:',
    close: ')?'
  },
  '+': {
    open: '(?:',
    close: ')+'
  },
  '*': {
    open: '(?:',
    close: ')*'
  },
  '@': {
    open: '(?:',
    close: ')'
  }
}; // any single thing other than /
// don't need to escape / when using new RegExp()

var qmark = '[^/]'; // * => any number of characters

var star = qmark + '*?'; // ** when dots are allowed.  Anything goes, except .. and .
// not (^ or / followed by one or two dots followed by $ or /),
// followed by anything, any number of times.

var twoStarDot = '(?:(?!(?:\\\/|^)(?:\\.{1,2})($|\\\/)).)*?'; // not a ^ or / followed by a dot,
// followed by anything, any number of times.

var twoStarNoDot = '(?:(?!(?:\\\/|^)\\.).)*?'; // characters that need to be escaped in RegExp.

var reSpecials = charSet('().*{}+?[]^$\\!'); // "abc" -> { a:true, b:true, c:true }

function charSet(s) {
  return s.split('').reduce(function (set, c) {
    set[c] = true;
    return set;
  }, {});
} // normalizes slashes.


var slashSplit = /\/+/;
minimatch.filter = filter;

function filter(pattern, options) {
  options = options || {};
  return function (p, i, list) {
    return minimatch(p, pattern, options);
  };
}

function ext(a, b) {
  a = a || {};
  b = b || {};
  var t = {};
  Object.keys(b).forEach(function (k) {
    t[k] = b[k];
  });
  Object.keys(a).forEach(function (k) {
    t[k] = a[k];
  });
  return t;
}

minimatch.defaults = function (def) {
  if (!def || !Object.keys(def).length) return minimatch;
  var orig = minimatch;

  var m = function minimatch(p, pattern, options) {
    return orig.minimatch(p, pattern, ext(def, options));
  };

  m.Minimatch = function Minimatch(pattern, options) {
    return new orig.Minimatch(pattern, ext(def, options));
  };

  return m;
};

Minimatch.defaults = function (def) {
  if (!def || !Object.keys(def).length) return Minimatch;
  return minimatch.defaults(def).Minimatch;
};

function minimatch(p, pattern, options) {
  if (typeof pattern !== 'string') {
    throw new TypeError('glob pattern string required');
  }

  if (!options) options = {}; // shortcut: comments match nothing.

  if (!options.nocomment && pattern.charAt(0) === '#') {
    return false;
  } // "" only matches ""


  if (pattern.trim() === '') return p === '';
  return new Minimatch(pattern, options).match(p);
}

function Minimatch(pattern, options) {
  if (!(this instanceof Minimatch)) {
    return new Minimatch(pattern, options);
  }

  if (typeof pattern !== 'string') {
    throw new TypeError('glob pattern string required');
  }

  if (!options) options = {};
  pattern = pattern.trim(); // windows support: need to use /, not \

  if (path.sep !== '/') {
    pattern = pattern.split(path.sep).join('/');
  }

  this.options = options;
  this.set = [];
  this.pattern = pattern;
  this.regexp = null;
  this.negate = false;
  this.comment = false;
  this.empty = false; // make the set of regexps etc.

  this.make();
}

Minimatch.prototype.debug = function () {};

Minimatch.prototype.make = make;

function make() {
  // don't do it more than once.
  if (this._made) return;
  var pattern = this.pattern;
  var options = this.options; // empty patterns and comments match nothing.

  if (!options.nocomment && pattern.charAt(0) === '#') {
    this.comment = true;
    return;
  }

  if (!pattern) {
    this.empty = true;
    return;
  } // step 1: figure out negation, etc.


  this.parseNegate(); // step 2: expand braces

  var set = this.globSet = this.braceExpand();
  if (options.debug) this.debug = console.error;
  this.debug(this.pattern, set); // step 3: now we have a set, so turn each one into a series of path-portion
  // matching patterns.
  // These will be regexps, except in the case of "**", which is
  // set to the GLOBSTAR object for globstar behavior,
  // and will not contain any / characters

  set = this.globParts = set.map(function (s) {
    return s.split(slashSplit);
  });
  this.debug(this.pattern, set); // glob --> regexps

  set = set.map(function (s, si, set) {
    return s.map(this.parse, this);
  }, this);
  this.debug(this.pattern, set); // filter out everything that didn't compile properly.

  set = set.filter(function (s) {
    return s.indexOf(false) === -1;
  });
  this.debug(this.pattern, set);
  this.set = set;
}

Minimatch.prototype.parseNegate = parseNegate;

function parseNegate() {
  var pattern = this.pattern;
  var negate = false;
  var options = this.options;
  var negateOffset = 0;
  if (options.nonegate) return;

  for (var i = 0, l = pattern.length; i < l && pattern.charAt(i) === '!'; i++) {
    negate = !negate;
    negateOffset++;
  }

  if (negateOffset) this.pattern = pattern.substr(negateOffset);
  this.negate = negate;
} // Brace expansion:
// a{b,c}d -> abd acd
// a{b,}c -> abc ac
// a{0..3}d -> a0d a1d a2d a3d
// a{b,c{d,e}f}g -> abg acdfg acefg
// a{b,c}d{e,f}g -> abdeg acdeg abdeg abdfg
//
// Invalid sets are not expanded.
// a{2..}b -> a{2..}b
// a{b}c -> a{b}c


minimatch.braceExpand = function (pattern, options) {
  return braceExpand(pattern, options);
};

Minimatch.prototype.braceExpand = braceExpand;

function braceExpand(pattern, options) {
  if (!options) {
    if (this instanceof Minimatch) {
      options = this.options;
    } else {
      options = {};
    }
  }

  pattern = typeof pattern === 'undefined' ? this.pattern : pattern;

  if (typeof pattern === 'undefined') {
    throw new TypeError('undefined pattern');
  }

  if (options.nobrace || !pattern.match(/\{.*\}/)) {
    // shortcut. no need to expand.
    return [pattern];
  }

  return expand(pattern);
} // parse a component of the expanded set.
// At this point, no pattern may contain "/" in it
// so we're going to return a 2d array, where each entry is the full
// pattern, split on '/', and then turned into a regular expression.
// A regexp is made at the end which joins each array with an
// escaped /, and another full one which joins each regexp with |.
//
// Following the lead of Bash 4.1, note that "**" only has special meaning
// when it is the *only* thing in a path portion.  Otherwise, any series
// of * is equivalent to a single *.  Globstar behavior is enabled by
// default, and can be disabled by setting options.noglobstar.


Minimatch.prototype.parse = parse;
var SUBPARSE = {};

function parse(pattern, isSub) {
  if (pattern.length > 1024 * 64) {
    throw new TypeError('pattern is too long');
  }

  var options = this.options; // shortcuts

  if (!options.noglobstar && pattern === '**') return GLOBSTAR;
  if (pattern === '') return '';
  var re = '';
  var hasMagic = !!options.nocase;
  var escaping = false; // ? => one single character

  var patternListStack = [];
  var negativeLists = [];
  var stateChar;
  var inClass = false;
  var reClassStart = -1;
  var classStart = -1; // . and .. never match anything that doesn't start with .,
  // even when options.dot is set.

  var patternStart = pattern.charAt(0) === '.' ? '' // anything
  // not (start or / followed by . or .. followed by / or end)
  : options.dot ? '(?!(?:^|\\\/)\\.{1,2}(?:$|\\\/))' : '(?!\\.)';
  var self = this;

  function clearStateChar() {
    if (stateChar) {
      // we had some state-tracking character
      // that wasn't consumed by this pass.
      switch (stateChar) {
        case '*':
          re += star;
          hasMagic = true;
          break;

        case '?':
          re += qmark;
          hasMagic = true;
          break;

        default:
          re += '\\' + stateChar;
          break;
      }

      self.debug('clearStateChar %j %j', stateChar, re);
      stateChar = false;
    }
  }

  for (var i = 0, len = pattern.length, c; i < len && (c = pattern.charAt(i)); i++) {
    this.debug('%s\t%s %s %j', pattern, i, re, c); // skip over any that are escaped.

    if (escaping && reSpecials[c]) {
      re += '\\' + c;
      escaping = false;
      continue;
    }

    switch (c) {
      case '/':
        // completely not allowed, even escaped.
        // Should already be path-split by now.
        return false;

      case '\\':
        clearStateChar();
        escaping = true;
        continue;
      // the various stateChar values
      // for the "extglob" stuff.

      case '?':
      case '*':
      case '+':
      case '@':
      case '!':
        this.debug('%s\t%s %s %j <-- stateChar', pattern, i, re, c); // all of those are literals inside a class, except that
        // the glob [!a] means [^a] in regexp

        if (inClass) {
          this.debug('  in class');
          if (c === '!' && i === classStart + 1) c = '^';
          re += c;
          continue;
        } // if we already have a stateChar, then it means
        // that there was something like ** or +? in there.
        // Handle the stateChar, then proceed with this one.


        self.debug('call clearStateChar %j', stateChar);
        clearStateChar();
        stateChar = c; // if extglob is disabled, then +(asdf|foo) isn't a thing.
        // just clear the statechar *now*, rather than even diving into
        // the patternList stuff.

        if (options.noext) clearStateChar();
        continue;

      case '(':
        if (inClass) {
          re += '(';
          continue;
        }

        if (!stateChar) {
          re += '\\(';
          continue;
        }

        patternListStack.push({
          type: stateChar,
          start: i - 1,
          reStart: re.length,
          open: plTypes[stateChar].open,
          close: plTypes[stateChar].close
        }); // negation is (?:(?!js)[^/]*)

        re += stateChar === '!' ? '(?:(?!(?:' : '(?:';
        this.debug('plType %j %j', stateChar, re);
        stateChar = false;
        continue;

      case ')':
        if (inClass || !patternListStack.length) {
          re += '\\)';
          continue;
        }

        clearStateChar();
        hasMagic = true;
        var pl = patternListStack.pop(); // negation is (?:(?!js)[^/]*)
        // The others are (?:<pattern>)<type>

        re += pl.close;

        if (pl.type === '!') {
          negativeLists.push(pl);
        }

        pl.reEnd = re.length;
        continue;

      case '|':
        if (inClass || !patternListStack.length || escaping) {
          re += '\\|';
          escaping = false;
          continue;
        }

        clearStateChar();
        re += '|';
        continue;
      // these are mostly the same in regexp and glob

      case '[':
        // swallow any state-tracking char before the [
        clearStateChar();

        if (inClass) {
          re += '\\' + c;
          continue;
        }

        inClass = true;
        classStart = i;
        reClassStart = re.length;
        re += c;
        continue;

      case ']':
        //  a right bracket shall lose its special
        //  meaning and represent itself in
        //  a bracket expression if it occurs
        //  first in the list.  -- POSIX.2 2.8.3.2
        if (i === classStart + 1 || !inClass) {
          re += '\\' + c;
          escaping = false;
          continue;
        } // handle the case where we left a class open.
        // "[z-a]" is valid, equivalent to "\[z-a\]"


        if (inClass) {
          // split where the last [ was, make sure we don't have
          // an invalid re. if so, re-walk the contents of the
          // would-be class to re-translate any characters that
          // were passed through as-is
          // TODO: It would probably be faster to determine this
          // without a try/catch and a new RegExp, but it's tricky
          // to do safely.  For now, this is safe and works.
          var cs = pattern.substring(classStart + 1, i);

          try {
            RegExp('[' + cs + ']');
          } catch (er) {
            // not a valid class!
            var sp = this.parse(cs, SUBPARSE);
            re = re.substr(0, reClassStart) + '\\[' + sp[0] + '\\]';
            hasMagic = hasMagic || sp[1];
            inClass = false;
            continue;
          }
        } // finish up the class.


        hasMagic = true;
        inClass = false;
        re += c;
        continue;

      default:
        // swallow any state char that wasn't consumed
        clearStateChar();

        if (escaping) {
          // no need
          escaping = false;
        } else if (reSpecials[c] && !(c === '^' && inClass)) {
          re += '\\';
        }

        re += c;
    } // switch

  } // for
  // handle the case where we left a class open.
  // "[abc" is valid, equivalent to "\[abc"


  if (inClass) {
    // split where the last [ was, and escape it
    // this is a huge pita.  We now have to re-walk
    // the contents of the would-be class to re-translate
    // any characters that were passed through as-is
    cs = pattern.substr(classStart + 1);
    sp = this.parse(cs, SUBPARSE);
    re = re.substr(0, reClassStart) + '\\[' + sp[0];
    hasMagic = hasMagic || sp[1];
  } // handle the case where we had a +( thing at the *end*
  // of the pattern.
  // each pattern list stack adds 3 chars, and we need to go through
  // and escape any | chars that were passed through as-is for the regexp.
  // Go through and escape them, taking care not to double-escape any
  // | chars that were already escaped.


  for (pl = patternListStack.pop(); pl; pl = patternListStack.pop()) {
    var tail = re.slice(pl.reStart + pl.open.length);
    this.debug('setting tail', re, pl); // maybe some even number of \, then maybe 1 \, followed by a |

    tail = tail.replace(/((?:\\{2}){0,64})(\\?)\|/g, function (_, $1, $2) {
      if (!$2) {
        // the | isn't already escaped, so escape it.
        $2 = '\\';
      } // need to escape all those slashes *again*, without escaping the
      // one that we need for escaping the | character.  As it works out,
      // escaping an even number of slashes can be done by simply repeating
      // it exactly after itself.  That's why this trick works.
      //
      // I am sorry that you have to see this.


      return $1 + $1 + $2 + '|';
    });
    this.debug('tail=%j\n   %s', tail, tail, pl, re);
    var t = pl.type === '*' ? star : pl.type === '?' ? qmark : '\\' + pl.type;
    hasMagic = true;
    re = re.slice(0, pl.reStart) + t + '\\(' + tail;
  } // handle trailing things that only matter at the very end.


  clearStateChar();

  if (escaping) {
    // trailing \\
    re += '\\\\';
  } // only need to apply the nodot start if the re starts with
  // something that could conceivably capture a dot


  var addPatternStart = false;

  switch (re.charAt(0)) {
    case '.':
    case '[':
    case '(':
      addPatternStart = true;
  } // Hack to work around lack of negative lookbehind in JS
  // A pattern like: *.!(x).!(y|z) needs to ensure that a name
  // like 'a.xyz.yz' doesn't match.  So, the first negative
  // lookahead, has to look ALL the way ahead, to the end of
  // the pattern.


  for (var n = negativeLists.length - 1; n > -1; n--) {
    var nl = negativeLists[n];
    var nlBefore = re.slice(0, nl.reStart);
    var nlFirst = re.slice(nl.reStart, nl.reEnd - 8);
    var nlLast = re.slice(nl.reEnd - 8, nl.reEnd);
    var nlAfter = re.slice(nl.reEnd);
    nlLast += nlAfter; // Handle nested stuff like *(*.js|!(*.json)), where open parens
    // mean that we should *not* include the ) in the bit that is considered
    // "after" the negated section.

    var openParensBefore = nlBefore.split('(').length - 1;
    var cleanAfter = nlAfter;

    for (i = 0; i < openParensBefore; i++) {
      cleanAfter = cleanAfter.replace(/\)[+*?]?/, '');
    }

    nlAfter = cleanAfter;
    var dollar = '';

    if (nlAfter === '' && isSub !== SUBPARSE) {
      dollar = '$';
    }

    var newRe = nlBefore + nlFirst + nlAfter + dollar + nlLast;
    re = newRe;
  } // if the re is not "" at this point, then we need to make sure
  // it doesn't match against an empty path part.
  // Otherwise a/* will match a/, which it should not.


  if (re !== '' && hasMagic) {
    re = '(?=.)' + re;
  }

  if (addPatternStart) {
    re = patternStart + re;
  } // parsing just a piece of a larger pattern.


  if (isSub === SUBPARSE) {
    return [re, hasMagic];
  } // skip the regexp for non-magical patterns
  // unescape anything in it, though, so that it'll be
  // an exact match against a file etc.


  if (!hasMagic) {
    return globUnescape(pattern);
  }

  var flags = options.nocase ? 'i' : '';

  try {
    var regExp = new RegExp('^' + re + '$', flags);
  } catch (er) {
    // If it was an invalid regular expression, then it can't match
    // anything.  This trick looks for a character after the end of
    // the string, which is of course impossible, except in multi-line
    // mode, but it's not a /m regex.
    return new RegExp('$.');
  }

  regExp._glob = pattern;
  regExp._src = re;
  return regExp;
}

minimatch.makeRe = function (pattern, options) {
  return new Minimatch(pattern, options || {}).makeRe();
};

Minimatch.prototype.makeRe = makeRe;

function makeRe() {
  if (this.regexp || this.regexp === false) return this.regexp; // at this point, this.set is a 2d array of partial
  // pattern strings, or "**".
  //
  // It's better to use .match().  This function shouldn't
  // be used, really, but it's pretty convenient sometimes,
  // when you just want to work with a regex.

  var set = this.set;

  if (!set.length) {
    this.regexp = false;
    return this.regexp;
  }

  var options = this.options;
  var twoStar = options.noglobstar ? star : options.dot ? twoStarDot : twoStarNoDot;
  var flags = options.nocase ? 'i' : '';
  var re = set.map(function (pattern) {
    return pattern.map(function (p) {
      return p === GLOBSTAR ? twoStar : typeof p === 'string' ? regExpEscape(p) : p._src;
    }).join('\\\/');
  }).join('|'); // must match entire pattern
  // ending in a * or ** will make it less strict.

  re = '^(?:' + re + ')$'; // can match anything, as long as it's not this.

  if (this.negate) re = '^(?!' + re + ').*$';

  try {
    this.regexp = new RegExp(re, flags);
  } catch (ex) {
    this.regexp = false;
  }

  return this.regexp;
}

minimatch.match = function (list, pattern, options) {
  options = options || {};
  var mm = new Minimatch(pattern, options);
  list = list.filter(function (f) {
    return mm.match(f);
  });

  if (mm.options.nonull && !list.length) {
    list.push(pattern);
  }

  return list;
};

Minimatch.prototype.match = match;

function match(f, partial) {
  this.debug('match', f, this.pattern); // short-circuit in the case of busted things.
  // comments, etc.

  if (this.comment) return false;
  if (this.empty) return f === '';
  if (f === '/' && partial) return true;
  var options = this.options; // windows: need to use /, not \

  if (path.sep !== '/') {
    f = f.split(path.sep).join('/');
  } // treat the test path as a set of pathparts.


  f = f.split(slashSplit);
  this.debug(this.pattern, 'split', f); // just ONE of the pattern sets in this.set needs to match
  // in order for it to be valid.  If negating, then just one
  // match means that we have failed.
  // Either way, return on the first hit.

  var set = this.set;
  this.debug(this.pattern, 'set', set); // Find the basename of the path by looking for the last non-empty segment

  var filename;
  var i;

  for (i = f.length - 1; i >= 0; i--) {
    filename = f[i];
    if (filename) break;
  }

  for (i = 0; i < set.length; i++) {
    var pattern = set[i];
    var file = f;

    if (options.matchBase && pattern.length === 1) {
      file = [filename];
    }

    var hit = this.matchOne(file, pattern, partial);

    if (hit) {
      if (options.flipNegate) return true;
      return !this.negate;
    }
  } // didn't get any hits.  this is success if it's a negative
  // pattern, failure otherwise.


  if (options.flipNegate) return false;
  return this.negate;
} // set partial to true to test if, for example,
// "/a/b" matches the start of "/*/b/*/d"
// Partial means, if you run out of file before you run
// out of pattern, then that's fine, as long as all
// the parts match.


Minimatch.prototype.matchOne = function (file, pattern, partial) {
  var options = this.options;
  this.debug('matchOne', {
    'this': this,
    file: file,
    pattern: pattern
  });
  this.debug('matchOne', file.length, pattern.length);

  for (var fi = 0, pi = 0, fl = file.length, pl = pattern.length; fi < fl && pi < pl; fi++, pi++) {
    this.debug('matchOne loop');
    var p = pattern[pi];
    var f = file[fi];
    this.debug(pattern, p, f); // should be impossible.
    // some invalid regexp stuff in the set.

    if (p === false) return false;

    if (p === GLOBSTAR) {
      this.debug('GLOBSTAR', [pattern, p, f]); // "**"
      // a/**/b/**/c would match the following:
      // a/b/x/y/z/c
      // a/x/y/z/b/c
      // a/b/x/b/x/c
      // a/b/c
      // To do this, take the rest of the pattern after
      // the **, and see if it would match the file remainder.
      // If so, return success.
      // If not, the ** "swallows" a segment, and try again.
      // This is recursively awful.
      //
      // a/**/b/**/c matching a/b/x/y/z/c
      // - a matches a
      // - doublestar
      //   - matchOne(b/x/y/z/c, b/**/c)
      //     - b matches b
      //     - doublestar
      //       - matchOne(x/y/z/c, c) -> no
      //       - matchOne(y/z/c, c) -> no
      //       - matchOne(z/c, c) -> no
      //       - matchOne(c, c) yes, hit

      var fr = fi;
      var pr = pi + 1;

      if (pr === pl) {
        this.debug('** at the end'); // a ** at the end will just swallow the rest.
        // We have found a match.
        // however, it will not swallow /.x, unless
        // options.dot is set.
        // . and .. are *never* matched by **, for explosively
        // exponential reasons.

        for (; fi < fl; fi++) {
          if (file[fi] === '.' || file[fi] === '..' || !options.dot && file[fi].charAt(0) === '.') return false;
        }

        return true;
      } // ok, let's see if we can swallow whatever we can.


      while (fr < fl) {
        var swallowee = file[fr];
        this.debug('\nglobstar while', file, fr, pattern, pr, swallowee); // XXX remove this slice.  Just pass the start index.

        if (this.matchOne(file.slice(fr), pattern.slice(pr), partial)) {
          this.debug('globstar found match!', fr, fl, swallowee); // found a match.

          return true;
        } else {
          // can't swallow "." or ".." ever.
          // can only swallow ".foo" when explicitly asked.
          if (swallowee === '.' || swallowee === '..' || !options.dot && swallowee.charAt(0) === '.') {
            this.debug('dot detected!', file, fr, pattern, pr);
            break;
          } // ** swallows a segment, and continue.


          this.debug('globstar swallow a segment, and continue');
          fr++;
        }
      } // no match was found.
      // However, in partial mode, we can't say this is necessarily over.
      // If there's more *pattern* left, then


      if (partial) {
        // ran out of file
        this.debug('\n>>> no match, partial?', file, fr, pattern, pr);
        if (fr === fl) return true;
      }

      return false;
    } // something other than **
    // non-magic patterns just have to match exactly
    // patterns with magic have been turned into regexps.


    var hit;

    if (typeof p === 'string') {
      if (options.nocase) {
        hit = f.toLowerCase() === p.toLowerCase();
      } else {
        hit = f === p;
      }

      this.debug('string match', p, f, hit);
    } else {
      hit = f.match(p);
      this.debug('pattern match', p, f, hit);
    }

    if (!hit) return false;
  } // Note: ending in / means that we'll get a final ""
  // at the end of the pattern.  This can only match a
  // corresponding "" at the end of the file.
  // If the file ends in /, then it can only match a
  // a pattern that ends in /, unless the pattern just
  // doesn't have any more for it. But, a/b/ should *not*
  // match "a/b/*", even though "" matches against the
  // [^/]*? pattern, except in partial mode, where it might
  // simply not be reached yet.
  // However, a/b/ should still satisfy a/*
  // now either we fell off the end of the pattern, or we're done.


  if (fi === fl && pi === pl) {
    // ran out of pattern and filename at the same time.
    // an exact hit!
    return true;
  } else if (fi === fl) {
    // ran out of file, but still had pattern left.
    // this is ok if we're doing the match as part of
    // a glob fs traversal.
    return partial;
  } else if (pi === pl) {
    // ran out of pattern, still have file left.
    // this is only acceptable if we're on the very last
    // empty segment of a file with a trailing slash.
    // a/* should match a/b/
    var emptyFileEnd = fi === fl - 1 && file[fi] === '';
    return emptyFileEnd;
  } // should be unreachable.


  throw new Error('wtf?');
}; // replace stuff like \* with *


function globUnescape(s) {
  return s.replace(/\\(.)/g, '$1');
}

function regExpEscape(s) {
  return s.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&');
}

/***/ }),

/***/ "./.yarn/cache/once-npm-1.4.0-ccf03ef07a-57afc24653.zip/node_modules/once/once.js":
/*!****************************************************************************************!*\
  !*** ./.yarn/cache/once-npm-1.4.0-ccf03ef07a-57afc24653.zip/node_modules/once/once.js ***!
  \****************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {



var wrappy = __webpack_require__(/*! wrappy */ "./.yarn/cache/wrappy-npm-1.0.2-916de4d4b3-519fcda0fc.zip/node_modules/wrappy/wrappy.js");

module.exports = wrappy(once);
module.exports.strict = wrappy(onceStrict);
once.proto = once(function () {
  Object.defineProperty(Function.prototype, 'once', {
    value: function () {
      return once(this);
    },
    configurable: true
  });
  Object.defineProperty(Function.prototype, 'onceStrict', {
    value: function () {
      return onceStrict(this);
    },
    configurable: true
  });
});

function once(fn) {
  var f = function () {
    if (f.called) return f.value;
    f.called = true;
    return f.value = fn.apply(this, arguments);
  };

  f.called = false;
  return f;
}

function onceStrict(fn) {
  var f = function () {
    if (f.called) throw new Error(f.onceError);
    f.called = true;
    return f.value = fn.apply(this, arguments);
  };

  var name = fn.name || 'Function wrapped with `once`';
  f.onceError = name + " shouldn't be called more than once";
  f.called = false;
  return f;
}

/***/ }),

/***/ "./.yarn/cache/path-is-absolute-npm-1.0.1-31bc695ffd-907e1e3e6a.zip/node_modules/path-is-absolute/index.js":
/*!*****************************************************************************************************************!*\
  !*** ./.yarn/cache/path-is-absolute-npm-1.0.1-31bc695ffd-907e1e3e6a.zip/node_modules/path-is-absolute/index.js ***!
  \*****************************************************************************************************************/
/***/ ((module) => {



function posix(path) {
  return path.charAt(0) === '/';
}

function win32(path) {
  // https://github.com/nodejs/node/blob/b3fcc245fb25539909ef1d5eaa01dbf92e168633/lib/path.js#L56
  var splitDeviceRe = /^([a-zA-Z]:|[\\\/]{2}[^\\\/]+[\\\/]+[^\\\/]+)?([\\\/])?([\s\S]*?)$/;
  var result = splitDeviceRe.exec(path);
  var device = result[1] || '';
  var isUnc = Boolean(device && device.charAt(1) !== ':'); // UNC paths are always absolute

  return Boolean(result[2] || isUnc);
}

module.exports = process.platform === 'win32' ? win32 : posix;
module.exports.posix = posix;
module.exports.win32 = win32;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/camelcase.js":
/*!*************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/camelcase.js ***!
  \*************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into camel case.
 * @memberof module:stringcase/lib
 * @function camelcase
 * @param {string} str - String to convert.
 * @returns {string} Camel case string.
 */


const lowercase = __webpack_require__(/*! ./lowercase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/lowercase.js");

const uppercase = __webpack_require__(/*! ./uppercase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/uppercase.js");

const replacing = {
  from: /[\-_:\.\s]([a-zA-Z])([a-zA-Z]*)/g,
  to: function (match, $1, $2, offset, src) {
    const len = $1.length;
    return uppercase($1) + $2;
  }
};
/** @lends camelcase */

function camelcase(str) {
  if (camelcase.isCamelcase(str)) {
    return str;
  }

  str = String(str).replace(/^[\-_:\.\s]/, '');

  if (!str) {
    return str;
  }

  if (uppercase.isUppercase(str)) {
    str = lowercase(str);
  }

  return lowercase(str[0]) + str.replace(replacing.from, replacing.to).slice(1).replace(/^([A-Z]+)([A-Z])/, (match, $1, $2) => lowercase($1) + $2);
}
/**
 * Checks whether the string are camelcase.
 * @memberof module:stringcase/lib
 * @function camelcase.isCamelcase
 * @param {string} str - String to check
 * @returns {boolean} - True if the string are camelcase.
 */


camelcase.isCamelcase = function (str) {
  return str && /^[a-zA-Z]+$/.test(str) && lowercase(str[0]) === str[0];
};

module.exports = camelcase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/capitalcase.js":
/*!***************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/capitalcase.js ***!
  \***************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into capital case.
 * First letters will be uppercase.
 * @memberof module:stringcase/lib
 * @function capitalcase
 * @param {string} str - String to convert.
 * @returns {string} Capital case string.
 */


const uppercase = __webpack_require__(/*! ./uppercase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/uppercase.js");
/** @lends capitalcase */


function capitalcase(str) {
  str = String(str);

  if (!str) {
    return str;
  }

  return uppercase(str[0]) + str.slice(1);
}

module.exports = capitalcase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/constcase.js":
/*!*************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/constcase.js ***!
  \*************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into upper snake case.
 * Join punctuation with underscore and convert letters into uppercase.
 * @memberof module:stringcase/lib
 * @function constcase
 * @param {string} str - String to convert.
 * @returns {string} Const cased string.
 */


const uppercase = __webpack_require__(/*! ./uppercase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/uppercase.js");

const snakecase = __webpack_require__(/*! ./snakecase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/snakecase.js");
/** @lends constcase */


function constcase(str) {
  if (constcase.isConstcase(str)) {
    return str;
  }

  return uppercase(snakecase(str));
}
/**
 * Checks whether the string are constcase.
 * @memberof module:stringcase/lib
 * @function constcase.isConstcase
 * @param {string} str - String to check.
 * @returns {boolean} - True if the string are constcase.
 */


constcase.isConstcase = function (str) {
  return str && /^[A-Z_]+$/.test(str);
};

module.exports = constcase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/cramcase.js":
/*!************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/cramcase.js ***!
  \************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into crammed case.
 * Join string into one.
 * @memberof module:stringcase/lib
 * @function cramcase
 * @param {string} str - String to convert.
 * @returns {string} Enum cased string.
 */


const snakecase = __webpack_require__(/*! ./snakecase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/snakecase.js");
/** @lends cramcase */


function cramcase(str) {
  return snakecase(str).replace(/_/g, '');
}

module.exports = cramcase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/decapitalcase.js":
/*!*****************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/decapitalcase.js ***!
  \*****************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into de-capitalized case.
 * First letters will be lowercase.
 * @memberof module:stringcase/lib
 * @function decapitalcase
 * @param {string} str - String to convert.
 * @returns {string} Capital case string.
 */


const lowercase = __webpack_require__(/*! ./lowercase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/lowercase.js");
/** @lends capitalcase */


function capitalcase(str) {
  str = String(str);

  if (!str) {
    return str;
  }

  return lowercase(str[0]) + str.slice(1);
}

module.exports = capitalcase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/dotcase.js":
/*!***********************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/dotcase.js ***!
  \***********************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into dot case.
 * Join punctuation with slash.
 * @memberof module:stringcase/lib
 * @function dotcase
 * @param {string} str - String to convert.
 * @returns {string} Path cased string.
 */


const snakecase = __webpack_require__(/*! ./snakecase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/snakecase.js");
/** @lends dotcase */


function dotcase(str) {
  return snakecase(str).replace(/_/g, '.');
}

module.exports = dotcase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/enumcase.js":
/*!************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/enumcase.js ***!
  \************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into enum case.
 * Join punctuation with slash.
 * @memberof module:stringcase/lib
 * @function enumcase
 * @param {string} str - String to convert.
 * @returns {string} Enum cased string.
 */


const snakecase = __webpack_require__(/*! ./snakecase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/snakecase.js");
/** @lends enumcase */


function enumcase(str) {
  return snakecase(str).replace(/_/g, ':');
}

module.exports = enumcase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/index.js":
/*!*********************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/index.js ***!
  \*********************************************************************************************************/
/***/ ((module, exports, __webpack_require__) => {

/**
 * Convert string cases between camel case, pascal case, snake case etc...
 * @module stringcase
 */


const camelcase = __webpack_require__(/*! ./camelcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/camelcase.js");

const capitalcase = __webpack_require__(/*! ./capitalcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/capitalcase.js");

const constcase = __webpack_require__(/*! ./constcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/constcase.js");

const cramcase = __webpack_require__(/*! ./cramcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/cramcase.js");

const decapitalcase = __webpack_require__(/*! ./decapitalcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/decapitalcase.js");

const dotcase = __webpack_require__(/*! ./dotcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/dotcase.js");

const enumcase = __webpack_require__(/*! ./enumcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/enumcase.js");

const lowercase = __webpack_require__(/*! ./lowercase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/lowercase.js");

const pascalcase = __webpack_require__(/*! ./pascalcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/pascalcase.js");

const pathcase = __webpack_require__(/*! ./pathcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/pathcase.js");

const sentencecase = __webpack_require__(/*! ./sentencecase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/sentencecase.js");

const snakecase = __webpack_require__(/*! ./snakecase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/snakecase.js");

const spacecase = __webpack_require__(/*! ./spacecase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/spacecase.js");

const spinalcase = __webpack_require__(/*! ./spinalcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/spinalcase.js");

const titlecase = __webpack_require__(/*! ./titlecase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/titlecase.js");

const trimcase = __webpack_require__(/*! ./trimcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/trimcase.js");

const uppercase = __webpack_require__(/*! ./uppercase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/uppercase.js");

exports.camelcase = camelcase;
exports.capitalcase = capitalcase;
exports.constcase = constcase;
exports.cramcase = cramcase;
exports.decapitalcase = decapitalcase;
exports.dotcase = dotcase;
exports.enumcase = enumcase;
exports.lowercase = lowercase;
exports.pascalcase = pascalcase;
exports.pathcase = pathcase;
exports.sentencecase = sentencecase;
exports.snakecase = snakecase;
exports.spacecase = spacecase;
exports.spinalcase = spinalcase;
exports.titlecase = titlecase;
exports.trimcase = trimcase;
exports.uppercase = uppercase;
module.exports = {
  camelcase,
  capitalcase,
  constcase,
  cramcase,
  decapitalcase,
  dotcase,
  enumcase,
  lowercase,
  pascalcase,
  pathcase,
  sentencecase,
  snakecase,
  spacecase,
  spinalcase,
  titlecase,
  trimcase,
  uppercase
};

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/lowercase.js":
/*!*************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/lowercase.js ***!
  \*************************************************************************************************************/
/***/ ((module) => {

/**
 * Convert string into lower case.
 * @memberof module:stringcase/lib
 * @function lowercase
 * @param {string} str - String to convert.
 * @returns {string} Lowercase case string.
 */

/** @lends lowercase */

function lowercase(str) {
  str = String(str);

  if (!str) {
    return str;
  }

  return str.toLowerCase();
}
/**
 * Checks whether the string are lowercase.
 * @memberof module:stringcase/lib
 * @function lowercase.isLowercase
 * @param {string} str - String to check
 * @returns {boolean} - True if the string are lowercase.
 */


lowercase.isLowercase = function (str) {
  return str && !/[A-Z]+/.test(str);
};

module.exports = lowercase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/pascalcase.js":
/*!**************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/pascalcase.js ***!
  \**************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into pascal case.
 * @memberof module:stringcase/lib
 * @function pascalcase
 * @param {string} str - String to convert.
 * @returns {string} Pascal case string.
 */


const camelcase = __webpack_require__(/*! ./camelcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/camelcase.js");

const capitalcase = __webpack_require__(/*! ./capitalcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/capitalcase.js");
/** @lends pascalcase */


function pascalcase(str) {
  return capitalcase(camelcase(str));
}

module.exports = pascalcase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/pathcase.js":
/*!************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/pathcase.js ***!
  \************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into path case.
 * Join punctuation with slash.
 * @memberof module:stringcase/lib
 * @function pathcase
 * @param {string} str - String to convert.
 * @returns {string} Path cased string.
 */


const snakecase = __webpack_require__(/*! ./snakecase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/snakecase.js");
/** @lends pathcase */


function pathcase(str) {
  return snakecase(str).replace(/_/g, '/');
}

module.exports = pathcase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/sentencecase.js":
/*!****************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/sentencecase.js ***!
  \****************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into sentence case.
 * First letter capped and each punctuations are joined with space.
 * @memberof module:stringcase/lib
 * @function sentencecase
 * @param {string} str - String to convert.
 * @returns {string} Sentence cased string.
 */


const lowercase = __webpack_require__(/*! ./lowercase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/lowercase.js");

const trimcase = __webpack_require__(/*! ./trimcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/trimcase.js");

const snakecase = __webpack_require__(/*! ./snakecase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/snakecase.js");

const capitalcase = __webpack_require__(/*! ./capitalcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/capitalcase.js");

const JOINER = ' ';
/** @lends sentencecase*/

function sentencecase(str) {
  str = String(str).replace(/^[\-_\.\s]/g, JOINER);

  if (!str) {
    return str;
  }

  return capitalcase(snakecase(trimcase(str)).replace(/_/g, JOINER));
}

module.exports = sentencecase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/snakecase.js":
/*!*************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/snakecase.js ***!
  \*************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into snake case.
 * Join punctuation with underscore.
 * @memberof module:stringcase/lib
 * @function snakecase
 * @param {string} str - String to convert.
 * @returns {string} Snake cased string.
 */


const lowercase = __webpack_require__(/*! ./lowercase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/lowercase.js");

const uppercase = __webpack_require__(/*! ./uppercase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/uppercase.js");

const JOINER = '_';
const replacing = {
  from: /([A-Z]+)/g,

  to(match, $1, offset, src) {
    const prefix = offset === 0 ? '' : JOINER;
    const len = $1.length;

    if (len === 1) {
      return prefix + lowercase($1);
    }

    const next = src.slice(offset + $1.length);
    const isOneWord = uppercase.isUppercase($1) && next[0] === JOINER;

    if (isOneWord) {
      return prefix + lowercase($1);
    }

    const replaced = lowercase($1.substr(0, len - 1)) + JOINER + lowercase($1[len - 1]);
    return prefix + replaced;
  }

};
/** @lends snakecase */

function snakecase(str) {
  if (snakecase.isSnakecase(str)) {
    return str;
  }

  str = String(str).replace(/[\-.:\s]/g, JOINER);

  if (!str) {
    return str;
  }

  if (uppercase.isUppercase(str)) {
    str = lowercase(str);
  }

  return str.replace(replacing.from, replacing.to).replace(/_+/g, '_');
}
/**
 * Checks whether the string are snakecase.
 * @memberof module:stringcase/lib
 * @function snakecase.isSnakecase
 * @param {string} str - String to check.
 * @returns {boolean} - True if the string are snakecase.
 */


snakecase.isSnakecase = function (str) {
  return str && /^[a-z_]+$/.test(str);
};

module.exports = snakecase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/spacecase.js":
/*!*************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/spacecase.js ***!
  \*************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into path case.
 * Join punctuation with space.
 * @memberof module:stringcase/lib
 * @function spacecase
 * @param {string} str - String to convert.
 * @returns {string} Path cased string.
 */


const snakecase = __webpack_require__(/*! ./snakecase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/snakecase.js");
/** @lends spacecase */


function spacecase(str) {
  return snakecase(str).replace(/_/g, ' ');
}

module.exports = spacecase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/spinalcase.js":
/*!**************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/spinalcase.js ***!
  \**************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into spinal case.
 * Join punctuation with hyphen.
 * @memberof module:stringcase/lib
 * @function spinalcase
 * @param {string} str - String to convert.
 * @returns {string} Spinal cased string.
 */


const snakecase = __webpack_require__(/*! ./snakecase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/snakecase.js");
/** @lends spinalcase */


function spinalcase(str) {
  return snakecase(str).replace(/_/g, '-');
}

module.exports = spinalcase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/titlecase.js":
/*!*************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/titlecase.js ***!
  \*************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

/**
 * Convert string into sentence case.
 * First letter capped and each punctuations is capitalcase and joined with space.
 * @memberof module:stringcase/lib
 * @function titlecase
 * @param {string} str - String to convert.
 * @returns {string} Title cased string.
 */


const snakecase = __webpack_require__(/*! ./snakecase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/snakecase.js");

const lowercase = __webpack_require__(/*! ./lowercase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/lowercase.js");

const trimcase = __webpack_require__(/*! ./trimcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/trimcase.js");

const capitalcase = __webpack_require__(/*! ./capitalcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/capitalcase.js");

const LOWERCASE_WORDS = 'a,the,and,or,not,but,for,of'.split(',');
/** @lends titlecase*/

function titlecase(str) {
  return snakecase(str).split(/_/g).map(trimcase).map(function (word) {
    var lower = !!~LOWERCASE_WORDS.indexOf(word);

    if (lower) {
      return lowercase(word);
    } else {
      return capitalcase(word);
    }
  }).join(' ');
}

module.exports = titlecase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/trimcase.js":
/*!************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/trimcase.js ***!
  \************************************************************************************************************/
/***/ ((module) => {

/**
 * Convert string into trimmed string.
 * @memberof module:stringcase/lib
 * @function trimcase
 * @param {string} str - String to convert.
 * @returns {string} Trimmed case string.
 */

/** @lends trimcase */

function trimcase(str) {
  return String(str).trim();
}

module.exports = trimcase;

/***/ }),

/***/ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/uppercase.js":
/*!*************************************************************************************************************!*\
  !*** ./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/uppercase.js ***!
  \*************************************************************************************************************/
/***/ ((module) => {

/**
 * Convert string into upper case.
 * @memberof module:stringcase/lib
 * @function uppercase
 * @param {string} str - String to convert.
 * @returns {string} Upper case string.
 */

/** @lends uppercase */

function uppercase(str) {
  str = String(str);

  if (!str) {
    return str;
  }

  return str.toUpperCase();
}
/**
 * Checks whether the string are uppercase.
 * @memberof module:stringcase/lib
 * @function uppercase.isUppercase
 * @param {string} str - String to check
 * @returns {boolean} - True if the string are uppercase.
 */


uppercase.isUppercase = function (str) {
  return str && !/[a-z]+/.test(str);
};

module.exports = uppercase;

/***/ }),

/***/ "./.yarn/cache/supports-color-npm-7.2.0-606bfcf7da-8e57067c39.zip/node_modules/supports-color/index.js":
/*!*************************************************************************************************************!*\
  !*** ./.yarn/cache/supports-color-npm-7.2.0-606bfcf7da-8e57067c39.zip/node_modules/supports-color/index.js ***!
  \*************************************************************************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {



const os = __webpack_require__(/*! os */ "os");

const tty = __webpack_require__(/*! tty */ "tty");

const hasFlag = __webpack_require__(/*! has-flag */ "./.yarn/cache/has-flag-npm-4.0.0-32af9f0536-2e5391139d.zip/node_modules/has-flag/index.js");

const {
  env
} = process;
let forceColor;

if (hasFlag('no-color') || hasFlag('no-colors') || hasFlag('color=false') || hasFlag('color=never')) {
  forceColor = 0;
} else if (hasFlag('color') || hasFlag('colors') || hasFlag('color=true') || hasFlag('color=always')) {
  forceColor = 1;
}

if ('FORCE_COLOR' in env) {
  if (env.FORCE_COLOR === 'true') {
    forceColor = 1;
  } else if (env.FORCE_COLOR === 'false') {
    forceColor = 0;
  } else {
    forceColor = env.FORCE_COLOR.length === 0 ? 1 : Math.min(parseInt(env.FORCE_COLOR, 10), 3);
  }
}

function translateLevel(level) {
  if (level === 0) {
    return false;
  }

  return {
    level,
    hasBasic: true,
    has256: level >= 2,
    has16m: level >= 3
  };
}

function supportsColor(haveStream, streamIsTTY) {
  if (forceColor === 0) {
    return 0;
  }

  if (hasFlag('color=16m') || hasFlag('color=full') || hasFlag('color=truecolor')) {
    return 3;
  }

  if (hasFlag('color=256')) {
    return 2;
  }

  if (haveStream && !streamIsTTY && forceColor === undefined) {
    return 0;
  }

  const min = forceColor || 0;

  if (env.TERM === 'dumb') {
    return min;
  }

  if (process.platform === 'win32') {
    // Windows 10 build 10586 is the first Windows release that supports 256 colors.
    // Windows 10 build 14931 is the first release that supports 16m/TrueColor.
    const osRelease = os.release().split('.');

    if (Number(osRelease[0]) >= 10 && Number(osRelease[2]) >= 10586) {
      return Number(osRelease[2]) >= 14931 ? 3 : 2;
    }

    return 1;
  }

  if ('CI' in env) {
    if (['TRAVIS', 'CIRCLECI', 'APPVEYOR', 'GITLAB_CI', 'GITHUB_ACTIONS', 'BUILDKITE'].some(sign => sign in env) || env.CI_NAME === 'codeship') {
      return 1;
    }

    return min;
  }

  if ('TEAMCITY_VERSION' in env) {
    return /^(9\.(0*[1-9]\d*)\.|\d{2,}\.)/.test(env.TEAMCITY_VERSION) ? 1 : 0;
  }

  if (env.COLORTERM === 'truecolor') {
    return 3;
  }

  if ('TERM_PROGRAM' in env) {
    const version = parseInt((env.TERM_PROGRAM_VERSION || '').split('.')[0], 10);

    switch (env.TERM_PROGRAM) {
      case 'iTerm.app':
        return version >= 3 ? 3 : 2;

      case 'Apple_Terminal':
        return 2;
      // No default
    }
  }

  if (/-256(color)?$/i.test(env.TERM)) {
    return 2;
  }

  if (/^screen|^xterm|^vt100|^vt220|^rxvt|color|ansi|cygwin|linux/i.test(env.TERM)) {
    return 1;
  }

  if ('COLORTERM' in env) {
    return 1;
  }

  return min;
}

function getSupportLevel(stream) {
  const level = supportsColor(stream, stream && stream.isTTY);
  return translateLevel(level);
}

module.exports = {
  supportsColor: getSupportLevel,
  stdout: translateLevel(supportsColor(true, tty.isatty(1))),
  stderr: translateLevel(supportsColor(true, tty.isatty(2)))
};

/***/ }),

/***/ "./.yarn/cache/wrappy-npm-1.0.2-916de4d4b3-519fcda0fc.zip/node_modules/wrappy/wrappy.js":
/*!**********************************************************************************************!*\
  !*** ./.yarn/cache/wrappy-npm-1.0.2-916de4d4b3-519fcda0fc.zip/node_modules/wrappy/wrappy.js ***!
  \**********************************************************************************************/
/***/ ((module) => {



// Returns a wrapper function that returns a wrapped callback
// The wrapper function should do some stuff, and return a
// presumably different callback function.
// This makes sure that own properties are retained, so that
// decorations and such are not lost along the way.
module.exports = wrappy;

function wrappy(fn, cb) {
  if (fn && cb) return wrappy(fn)(cb);
  if (typeof fn !== 'function') throw new TypeError('need wrapper function');
  Object.keys(fn).forEach(function (k) {
    wrapper[k] = fn[k];
  });
  return wrapper;

  function wrapper() {
    var args = new Array(arguments.length);

    for (var i = 0; i < args.length; i++) {
      args[i] = arguments[i];
    }

    var ret = fn.apply(this, args);
    var cb = args[args.length - 1];

    if (typeof ret === 'function' && ret !== cb) {
      Object.keys(cb).forEach(function (k) {
        ret[k] = cb[k];
      });
    }

    return ret;
  }
}

/***/ }),

/***/ "./src/argparse.ts":
/*!*************************!*\
  !*** ./src/argparse.ts ***!
  \*************************/
/***/ ((__unused_webpack_module, exports) => {



exports.__esModule = true;
exports.parseArgs = exports.prepareArgs = void 0;

const stringToBoolean = str => str !== undefined && str !== null && str !== 'false' && str !== '0' && str !== 'null';
/**
 * Returns global flags and tasks, which is an array of this format:
 * `[[taskName, ...taskArgs], ...]`
 * @param args List of command line arguments
 */


const prepareArgs = args => {
  let inGlobalContext = true;
  const globalFlags = [];
  const taskArgs = [];
  let currentTaskArgs;

  while (args.length !== 0) {
    const arg = args.shift();

    if (!arg) {
      continue;
    }

    if (arg === '--') {
      inGlobalContext = false;
      continue;
    }

    if (arg.startsWith('-')) {
      if (inGlobalContext) {
        globalFlags.push(arg);
      } else if (currentTaskArgs) {
        currentTaskArgs.push(arg);
      }
    } else {
      inGlobalContext = false;

      if (currentTaskArgs) {
        taskArgs.push(currentTaskArgs);
      }

      currentTaskArgs = [arg];
    }
  }

  if (currentTaskArgs) {
    taskArgs.push(currentTaskArgs);
  }

  return {
    globalFlags,
    taskArgs
  };
};

exports.prepareArgs = prepareArgs;

const parseArgs = (args, parameters) => {
  args = [...args];
  const parameterMap = new Map();

  const pushValue = (key, value) => {
    const values = parameterMap.get(key);

    if (!values) {
      parameterMap.set(key, [value]);
      return;
    }

    values.push(value);
  };

  let currentSet = [];
  let currentSetType;

  while (true) {
    if (currentSet.length === 0) {
      const arg = args.shift();

      if (!arg) {
        break;
      }

      if (arg.startsWith('--')) {
        currentSet = [arg.substr(2)];
        currentSetType = 'long';
      } else if (arg.startsWith('-')) {
        currentSet = Array.from(arg);
        currentSetType = 'short';
      }
    }

    const arg = currentSet.shift(); // Parsing of short flags
    // ----------------------------------------------------

    if (currentSetType === 'short') {
      const parameter = parameters.find(p => p.alias === arg); // Parameter not found

      if (!parameter) {
        continue;
      }

      if (parameter.isBoolean()) {
        pushValue(parameter, true);
        continue;
      } // Rest of parameter types expect a value in the current set


      if (currentSet.length === 0) {
        continue;
      }

      const string = currentSet.join('');
      currentSet = [];

      if (parameter.isNumber()) {
        pushValue(parameter, parseFloat(string));
        continue;
      }

      pushValue(parameter, string);
      continue;
    } // Parsing of long flags
    // ----------------------------------------------------
    // Try to break the long flag into name/value


    const equalsIndex = arg.indexOf('=');
    let name = arg;
    let value = null;

    if (equalsIndex >= 0) {
      name = arg.substr(0, equalsIndex);
      value = arg.substr(equalsIndex + 1);

      if (value === '') {
        value = null;
      }
    }

    const parameter = parameters.find(p => p.name === name || p.toKebabCase() === name || p.toCamelCase() === name);

    if (!parameter) {
      continue;
    }

    if (parameter.isBoolean()) {
      const noEqualsSign = equalsIndex < 0;
      pushValue(parameter, noEqualsSign || stringToBoolean(value));
      continue;
    } // Rest of parameter types expect a value


    if (value === null) {
      continue;
    }

    if (parameter.isNumber()) {
      pushValue(parameter, parseFloat(value));
      continue;
    }

    pushValue(parameter, value);
    continue;
  } // Go over the env vars and fill in the gaps
  // ------------------------------------------------------


  for (const [key, value] of Object.entries(process.env)) {
    const parameter = parameters.find(p => p.name === key || p.toConstCase() === key);

    if (!parameter || parameterMap.has(parameter)) {
      continue;
    }

    let values = [];

    if (value !== undefined) {
      if (parameter.isArray()) {
        values = value.split(',');
      } else {
        values = [value];
      }
    }

    for (const value of values) {
      if (parameter.isBoolean()) {
        pushValue(parameter, stringToBoolean(value));
        continue;
      } // Rest of parameter types expect a value


      if (value === '') {
        continue;
      }

      if (parameter.isNumber()) {
        pushValue(parameter, parseFloat(value));
        continue;
      }

      pushValue(parameter, value);
      continue;
    }
  }

  return parameterMap;
};

exports.parseArgs = parseArgs;

/***/ }),

/***/ "./src/exec.ts":
/*!*********************!*\
  !*** ./src/exec.ts ***!
  \*********************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {



exports.__esModule = true;
exports.exec = exports.ExitError = void 0;

var _child_process = __webpack_require__(/*! child_process */ "child_process");

var _path = __webpack_require__(/*! path */ "path");

var _fs = __webpack_require__(/*! ./fs */ "./src/fs.ts");

const children = new Set();

const killChildren = () => {
  for (const child of children) {
    child.kill('SIGTERM');
    children.delete(child);
    console.log('killed child process');
  }
};

const trap = (signals, handler) => {
  let readline;

  if (process.platform === 'win32') {
    readline = __webpack_require__(/*! readline */ "readline").createInterface({
      input: process.stdin,
      output: process.stdout
    });
  }

  for (const signal of signals) {
    const handleSignal = () => handler(signal);

    if (signal === 'EXIT') {
      process.on('exit', handleSignal);
      continue;
    }

    if (readline) {
      readline.on('SIG' + signal, handleSignal);
    }

    process.on('SIG' + signal, handleSignal);
  }
};

trap(['EXIT', 'BREAK', 'HUP', 'INT', 'TERM'], signal => {
  if (signal !== 'EXIT') {
    console.log('Received', signal);
  }

  killChildren();

  if (signal !== 'EXIT') {
    process.exit(1);
  }
});

const exceptionHandler = err => {
  console.log(err);
  killChildren();
  process.exit(1);
};

process.on('unhandledRejection', exceptionHandler);
process.on('uncaughtException', exceptionHandler);

class ExitError extends Error {
  constructor(...args) {
    super(...args);
    this.code = null;
    this.signal = null;
  }

}

exports.ExitError = ExitError;

const exec = (executable, args = [], options = {}) => {
  return new Promise((resolve, reject) => {
    // If executable exists relative to the current directory,
    // use that executable, otherwise spawn should fall back to
    // running it from PATH.
    if ((0, _fs.stat)(executable)) {
      executable = (0, _path.resolve)(executable);
    }

    const child = (0, _child_process.spawn)(executable, args, options);
    children.add(child);
    child.stdout.pipe(process.stdout, {
      end: false
    });
    child.stderr.pipe(process.stderr, {
      end: false
    });
    child.stdin.end();
    child.on('error', err => reject(err));
    child.on('exit', (code, signal) => {
      children.delete(child);

      if (code !== 0) {
        const error = new ExitError('Process exited with code: ' + code);
        error.code = code;
        error.signal = signal;
        reject(error);
      } else {
        resolve();
      }
    });
  });
};

exports.exec = exec;

/***/ }),

/***/ "./src/fs.ts":
/*!*******************!*\
  !*** ./src/fs.ts ***!
  \*******************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {



exports.__esModule = true;
exports.resolveGlob = exports.stat = exports.compareFiles = exports.Glob = exports.File = void 0;

var _fs = _interopRequireDefault(__webpack_require__(/*! fs */ "fs"));

var _glob = __webpack_require__(/*! glob */ "./.yarn/cache/glob-npm-7.1.6-1ce3a5189a-789977b524.zip/node_modules/glob/glob.js");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

class File {
  constructor(path) {
    this.path = path;
  }

  get stat() {
    if (this._stat === undefined) {
      this._stat = stat(this.path);
    }

    return this._stat;
  }

  exists() {
    return this.stat !== null;
  }

  get mtime() {
    return this.stat && this.stat.mtime;
  }

  touch() {
    const time = new Date();

    try {
      _fs.default.utimesSync(this.path, time, time);
    } catch (err) {
      _fs.default.closeSync(_fs.default.openSync(this.path, 'w'));
    }
  }

}

exports.File = File;

class Glob {
  constructor(path) {
    this.path = path;
    this.path = path;
  }

  toFiles() {
    const paths = _glob.glob.sync(this.path, {
      strict: false,
      silent: true
    });

    return paths.map(path => new File(path)).filter(file => file.exists());
  }

}
/**
 * If true, source is newer than target.
 */


exports.Glob = Glob;

const compareFiles = (sources, targets) => {
  let bestSource = null;
  let bestTarget = null;

  for (const file of sources) {
    if (!bestSource || file.mtime > bestSource.mtime) {
      bestSource = file;
    }
  }

  for (const file of targets) {
    if (!file.exists()) {
      return `target '${file.path}' is missing`;
    }

    if (!bestTarget || file.mtime < bestTarget.mtime) {
      bestTarget = file;
    }
  } // Doesn't need rebuild if there is no source, but target exists.


  if (!bestSource) {
    if (bestTarget) {
      return false;
    }

    return 'no known sources or targets';
  } // Always needs a rebuild if no targets were specified (e.g. due to GLOB).


  if (!bestTarget) {
    return 'no targets were specified';
  } // Needs rebuild if source is newer than target


  if (bestSource.mtime > bestTarget.mtime) {
    return `source '${bestSource.path}' is newer than target '${bestTarget.path}'`;
  }

  return false;
};
/**
 * Returns file stats for the provided path, or null if file is
 * not accessible.
 */


exports.compareFiles = compareFiles;

const stat = path => {
  try {
    return _fs.default.statSync(path);
  } catch {
    return null;
  }
};
/**
 * Resolves a glob pattern and returns files that are safe
 * to call `stat` on.
 */


exports.stat = stat;

const resolveGlob = globPath => {
  const unsafePaths = _glob.glob.sync(globPath, {
    strict: false,
    silent: true
  });

  const safePaths = [];

  for (let path of unsafePaths) {
    try {
      _fs.default.statSync(path);

      safePaths.push(path);
    } catch {}
  }

  return safePaths;
};

exports.resolveGlob = resolveGlob;

/***/ }),

/***/ "./src/logger.ts":
/*!***********************!*\
  !*** ./src/logger.ts ***!
  \***********************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {



exports.__esModule = true;
exports.logger = void 0;

var _chalk = _interopRequireDefault(__webpack_require__(/*! chalk */ "./.yarn/cache/chalk-npm-4.1.1-f1ce6bae57-445c12db7a.zip/node_modules/chalk/source/index.js"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

const logger = {
  log: (...args) => {
    console.log(...args);
  },
  error: (...args) => {
    console.log(_chalk.default.bold(_chalk.default.redBright('=>'), _chalk.default.whiteBright(...args)));
  },
  action: (...args) => {
    console.log(_chalk.default.bold(_chalk.default.greenBright('=>'), _chalk.default.whiteBright(...args)));
  },
  warn: (...args) => {
    console.log(_chalk.default.bold(_chalk.default.yellowBright('=>'), _chalk.default.whiteBright(...args)));
  },
  info: (...args) => {
    console.log(_chalk.default.bold(_chalk.default.blueBright('::'), _chalk.default.whiteBright(...args)));
  },
  debug: (...args) => {
    if (process.env.DEBUG) {
      console.log(_chalk.default.gray(...args));
    }
  }
};
exports.logger = logger;

/***/ }),

/***/ "./src/parameter.ts":
/*!**************************!*\
  !*** ./src/parameter.ts ***!
  \**************************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {



exports.__esModule = true;
exports.Parameter = exports.createParameter = void 0;

var _stringcase = __webpack_require__(/*! stringcase */ "./.yarn/cache/stringcase-npm-4.3.1-2f1c329337-c81a3a4ab4.zip/node_modules/stringcase/lib/index.js");

const createParameter = options => new Parameter(options.name, options.type, options.alias);

exports.createParameter = createParameter;

class Parameter {
  constructor(name, type, alias) {
    this.name = name;
    this.type = type;
    this.alias = alias;
  }

  isString() {
    return this.type === 'string' || this.type === 'string[]';
  }

  isNumber() {
    return this.type === 'number' || this.type === 'number[]';
  }

  isBoolean() {
    return this.type === 'boolean' || this.type === 'boolean[]';
  }

  isArray() {
    return this.type.endsWith('[]');
  }

  toKebabCase() {
    return (0, _stringcase.spinalcase)(this.name);
  }

  toConstCase() {
    return (0, _stringcase.constcase)(this.name);
  }

  toCamelCase() {
    return (0, _stringcase.camelcase)(this.name);
  }

}

exports.Parameter = Parameter;

/***/ }),

/***/ "./src/runner.ts":
/*!***********************!*\
  !*** ./src/runner.ts ***!
  \***********************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {



exports.__esModule = true;
exports.runner = void 0;

var _chalk = _interopRequireDefault(__webpack_require__(/*! chalk */ "./.yarn/cache/chalk-npm-4.1.1-f1ce6bae57-445c12db7a.zip/node_modules/chalk/source/index.js"));

var _events = _interopRequireDefault(__webpack_require__(/*! events */ "events"));

var _argparse = __webpack_require__(/*! ./argparse */ "./src/argparse.ts");

var _exec = __webpack_require__(/*! ./exec */ "./src/exec.ts");

var _fs = __webpack_require__(/*! ./fs */ "./src/fs.ts");

var _logger = __webpack_require__(/*! ./logger */ "./src/logger.ts");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

const runner = new class Runner {
  constructor() {
    this.targets = [];
    this.parameters = [];
    this.workers = [];
  }

  configure(config) {
    var _config$targets, _config$parameters;

    this.targets = (_config$targets = config.targets) != null ? _config$targets : [];
    this.parameters = (_config$parameters = config.parameters) != null ? _config$parameters : [];
    this.defaultTarget = config.default;
  }

  async start() {
    const startedAt = Date.now(); // Parse arguments
    // ----------------------------------------------------

    const {
      globalFlags,
      taskArgs
    } = (0, _argparse.prepareArgs)(process.argv.slice(2));
    const globalParameterMap = (0, _argparse.parseArgs)(globalFlags, this.parameters);
    const targetsToRun = new Map();

    for (const [taskName, ...args] of taskArgs) {
      const target = this.targets.find(t => t.name === taskName);

      if (!target) {
        const nameStr = _chalk.default.cyan(taskName);

        _logger.logger.error(`Task '${nameStr}' was not found.`);

        _logger.logger.log('Available tasks:', ...this.targets.map(t => t.name));

        process.exit(1);
      }

      targetsToRun.set(target, {
        target,
        args
      });
    }

    if (targetsToRun.size === 0) {
      if (!this.defaultTarget) {
        _logger.logger.error(`No task was provided in arguments.`);

        _logger.logger.log('Available tasks:', ...this.targets.map(t => t.name));

        process.exit(1);
      }

      targetsToRun.set(this.defaultTarget, {
        target: this.defaultTarget,
        args: []
      });
    } // Walk over the dependency graph
    // ----------------------------------------------------


    let toVisit = Array.from(targetsToRun.values());

    while (true) {
      const node = toVisit.shift();

      if (!node) {
        break;
      }

      const {
        target,
        args
      } = node;

      for (const dependency of target.dependsOn) {
        if (!targetsToRun.has(dependency)) {
          const node = {
            target: dependency,
            args
          };
          targetsToRun.set(dependency, node);
          toVisit.push(node);
        }
      }
    } // Spawn workers
    // ----------------------------------------------------


    for (const {
      target,
      args
    } of targetsToRun.values()) {
      const localParameterMap = (0, _argparse.parseArgs)(args, target.parameters);
      const context = {
        get: parameter => {
          var _localParameterMap$ge;

          const value = (_localParameterMap$ge = localParameterMap.get(parameter)) != null ? _localParameterMap$ge : globalParameterMap.get(parameter);

          if (parameter.isArray()) {
            return value != null ? value : [];
          } else {
            var _value$;

            return (_value$ = value == null ? void 0 : value[0]) != null ? _value$ : null;
          }
        }
      };
      const spawnedWorker = new Worker(target, context);
      this.workers.push(spawnedWorker);
      spawnedWorker.onFinish(() => {
        for (const worker of this.workers) {
          if (worker === spawnedWorker) {
            continue;
          }

          worker.resolveDependency(target);
        }
      });
      spawnedWorker.onFail(() => {
        for (const worker of this.workers) {
          if (worker === spawnedWorker) {
            continue;
          }

          worker.rejectDependency(target);
        }
      });
    }

    const resolutions = await Promise.all(this.workers.map(worker => new Promise(resolve => {
      worker.onFinish(() => resolve(true));
      worker.onFail(() => resolve(false));
      worker.start();
    })));
    const hasFailedWorkers = resolutions.includes(false); // Show done only in happy path

    if (!hasFailedWorkers) {
      const time = (Date.now() - startedAt) / 1000 + 's';

      const timeStr = _chalk.default.magenta(time);

      _logger.logger.action(`Done in ${timeStr}`);
    } // Exit code 0 or 1 depdending on the fail state.


    return Number(hasFailedWorkers);
  }

}();
exports.runner = runner;

class Worker {
  constructor(target, context) {
    this.emitter = new _events.default();
    this.hasFailed = false;
    this.target = target;
    this.context = context;
    this.dependencies = new Set(target.dependsOn);
    this.debugLog('ready');
  }

  resolveDependency(target) {
    var _this$generator;

    this.dependencies.delete(target);
    (_this$generator = this.generator) == null ? void 0 : _this$generator.next();
  }

  rejectDependency(target) {
    var _this$generator2;

    this.dependencies.delete(target);
    this.hasFailed = true;
    (_this$generator2 = this.generator) == null ? void 0 : _this$generator2.next();
  }

  start() {
    this.generator = this.process();
    this.generator.next();
  }

  onFinish(fn) {
    this.emitter.once('finish', fn);
  }

  onFail(fn) {
    this.emitter.once('fail', fn);
  }

  debugLog(...args) {
    _logger.logger.debug(`${this.target.name}:`, ...args);
  }

  async *process() {
    const nameStr = _chalk.default.cyan(this.target.name); // Wait for dependencies to resolve


    this.debugLog('Waiting for dependencies');

    while (true) {
      if (this.dependencies.size === 0) {
        break;
      }

      yield;
    } // Check if we have errored until this point


    if (this.hasFailed) {
      const nameStr = _chalk.default.cyan(this.target.name);

      _logger.logger.error(`Target '${nameStr}' failed`);

      this.emitter.emit('fail');
      return;
    } // Compare inputs and outputs


    this.debugLog('Comparing inputs and outputs');
    const inputs = this.target.inputs.flatMap(path => path.includes('*') ? new _fs.Glob(path).toFiles() : new _fs.File(path));
    const outputs = this.target.outputs.flatMap(path => path.includes('*') ? new _fs.Glob(path).toFiles() : new _fs.File(path));

    if (inputs.length > 0) {
      const needsRebuild = (0, _fs.compareFiles)(inputs, outputs);

      if (!needsRebuild) {
        _logger.logger.info(`Skipping '${nameStr}' (up to date)`);

        this.emitter.emit('finish');
        return;
      } else {
        this.debugLog('Needs rebuild, reason:', needsRebuild);
      }
    } else {
      this.debugLog('Nothing to compare');
    } // Check if we have errored until this point


    if (this.hasFailed) {
      const nameStr = _chalk.default.cyan(this.target.name);

      _logger.logger.error(`Target '${nameStr}' failed (at file comparison stage)`);

      this.emitter.emit('fail');
      return;
    } // Execute the task


    if (this.target.executes.length > 0) {
      _logger.logger.action(`Starting '${nameStr}'`);

      const startedAt = Date.now();

      for (const fn of this.target.executes) {
        try {
          await fn(this.context);
        } catch (err) {
          const time = (Date.now() - startedAt) / 1000 + 's';

          const timeStr = _chalk.default.magenta(time);

          if (err instanceof _exec.ExitError) {
            const codeStr = _chalk.default.red(err.code);

            _logger.logger.error(`Target '${nameStr}' failed in ${timeStr}, exit code: ${codeStr}`);
          } else {
            _logger.logger.error(`Target '${nameStr}' failed in ${timeStr}, unhandled exception:`);

            console.error(err);
          }

          this.emitter.emit('fail');
          return;
        }
      }

      const time = (Date.now() - startedAt) / 1000 + 's';

      const timeStr = _chalk.default.magenta(time);

      _logger.logger.action(`Finished '${nameStr}' in ${timeStr}`);
    } // Touch all targets so that they don't rebuild again


    if (outputs.length > 0) {
      for (const file of outputs) {
        file.touch();
      }
    }

    this.emitter.emit('finish');
  }

}

/***/ }),

/***/ "./src/target.ts":
/*!***********************!*\
  !*** ./src/target.ts ***!
  \***********************/
/***/ ((__unused_webpack_module, exports) => {



exports.__esModule = true;
exports.createTarget = void 0;

const createTarget = target => {
  var _target$dependsOn, _target$inputs, _target$outputs, _target$parameters;

  let executes = [];

  if (target.executes) {
    if (Array.isArray(target.executes)) {
      executes = target.executes;
    } else {
      executes = [target.executes];
    }
  }

  return {
    name: target.name,
    dependsOn: (_target$dependsOn = target.dependsOn) != null ? _target$dependsOn : [],
    executes,
    inputs: (_target$inputs = target.inputs) != null ? _target$inputs : [],
    outputs: (_target$outputs = target.outputs) != null ? _target$outputs : [],
    parameters: (_target$parameters = target.parameters) != null ? _target$parameters : []
  };
};

exports.createTarget = createTarget;

/***/ }),

/***/ "assert":
/*!*************************!*\
  !*** external "assert" ***!
  \*************************/
/***/ ((module) => {

module.exports = require("assert");;

/***/ }),

/***/ "child_process":
/*!********************************!*\
  !*** external "child_process" ***!
  \********************************/
/***/ ((module) => {

module.exports = require("child_process");;

/***/ }),

/***/ "events":
/*!*************************!*\
  !*** external "events" ***!
  \*************************/
/***/ ((module) => {

module.exports = require("events");;

/***/ }),

/***/ "fs":
/*!*********************!*\
  !*** external "fs" ***!
  \*********************/
/***/ ((module) => {

module.exports = require("fs");;

/***/ }),

/***/ "os":
/*!*********************!*\
  !*** external "os" ***!
  \*********************/
/***/ ((module) => {

module.exports = require("os");;

/***/ }),

/***/ "path":
/*!***********************!*\
  !*** external "path" ***!
  \***********************/
/***/ ((module) => {

module.exports = require("path");;

/***/ }),

/***/ "readline":
/*!***************************!*\
  !*** external "readline" ***!
  \***************************/
/***/ ((module) => {

module.exports = require("readline");;

/***/ }),

/***/ "tty":
/*!**********************!*\
  !*** external "tty" ***!
  \**********************/
/***/ ((module) => {

module.exports = require("tty");;

/***/ }),

/***/ "util":
/*!***********************!*\
  !*** external "util" ***!
  \***********************/
/***/ ((module) => {

module.exports = require("util");;

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			id: moduleId,
/******/ 			loaded: false,
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/node module decorator */
/******/ 	(() => {
/******/ 		__webpack_require__.nmd = (module) => {
/******/ 			module.paths = [];
/******/ 			if (!module.children) module.children = [];
/******/ 			return module;
/******/ 		};
/******/ 	})();
/******/ 	
/************************************************************************/
var __webpack_exports__ = {};
// This entry need to be wrapped in an IIFE because it need to be isolated against other modules in the chunk.
(() => {
var exports = __webpack_exports__;
/*!**********************!*\
  !*** ./src/index.ts ***!
  \**********************/


exports.__esModule = true;
exports.resolveGlob = exports.sleep = exports.createParameter = exports.createTarget = exports.setup = void 0;

var _chalk = _interopRequireDefault(__webpack_require__(/*! chalk */ "./.yarn/cache/chalk-npm-4.1.1-f1ce6bae57-445c12db7a.zip/node_modules/chalk/source/index.js"));

exports.chalk = _chalk.default;

var _fs = _interopRequireDefault(__webpack_require__(/*! fs */ "fs"));

var _glob = _interopRequireDefault(__webpack_require__(/*! glob */ "./.yarn/cache/glob-npm-7.1.6-1ce3a5189a-789977b524.zip/node_modules/glob/glob.js"));

exports.glob = _glob.default;

var _exec = __webpack_require__(/*! ./exec */ "./src/exec.ts");

exports.exec = _exec.exec;

var _logger = __webpack_require__(/*! ./logger */ "./src/logger.ts");

exports.logger = _logger.logger;

var _parameter = __webpack_require__(/*! ./parameter */ "./src/parameter.ts");

var _runner = __webpack_require__(/*! ./runner */ "./src/runner.ts");

var _target = __webpack_require__(/*! ./target */ "./src/target.ts");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

const autoParameters = [];
const autoTargets = [];
/**
 * Configures Juke Build and starts executing targets.
 *
 * @param config Juke Build configuration.
 * @returns Exit code of the whole runner process.
 */

const setup = (config = {}) => {
  config = { ...config
  };

  if (!config.parameters) {
    config.parameters = autoParameters;
  }

  if (!config.targets) {
    config.targets = autoTargets;
  }

  _runner.runner.configure(config);

  return _runner.runner.start();
};

exports.setup = setup;

const createTarget = config => {
  const target = (0, _target.createTarget)(config);
  autoTargets.push(target);
  return target;
};

exports.createTarget = createTarget;

const createParameter = config => {
  const parameter = (0, _parameter.createParameter)(config);
  autoParameters.push(parameter);
  return parameter;
};

exports.createParameter = createParameter;

const sleep = time => new Promise(resolve => setTimeout(resolve, time));
/**
 * Resolves a glob pattern and returns files that are safe
 * to call `stat` on.
 */


exports.sleep = sleep;

const resolveGlob = globPath => {
  const unsafePaths = _glob.default.sync(globPath, {
    strict: false,
    silent: true
  });

  const safePaths = [];

  for (let path of unsafePaths) {
    try {
      _fs.default.statSync(path);

      safePaths.push(path);
    } catch {}
  }

  return safePaths;
};

exports.resolveGlob = resolveGlob;
})();

/******/ 	return __webpack_exports__;
/******/ })()
;
});