# rewrite-imports [![Build Status](https://travis-ci.org/lukeed/rewrite-imports.svg?branch=master)](https://travis-ci.org/lukeed/rewrite-imports)

Transforms various `import` statements into `require()` calls, using regular expressions.

> ***Looking for something _more_ backwards compatible?*** <br>
> Check out [`v1.4.0`](https://github.com/lukeed/rewrite-imports/tree/v1.4.0) which does not rely on destructured assignment!


## Caveats

This module returns a string and **does not** provide a runtime nor does it evaluate the output.

> :bulb: For this behavior, use [`rewrite-module`](https://github.com/lukeed/rewrite-module) or check out [`@taskr/esnext`](https://github.com/lukeed/taskr/tree/master/packages/esnext) for an example.

The output requires a JavaScript runtime that supports `require` calls and [destructuring assignments](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment#Object_destructuring) with Objects.

  * At least `Node 6.x` is required

  * Or, for browsers:
    * A `require` shim is always needed – see [`fn`](#fn)
    * Ensure your target browsers support destructuring – see [chart](https://kangax.github.io/compat-table/es6/#test-destructuring,_assignment)

If you have [false positives](https://github.com/lukeed/rewrite-imports/issues/8), you may want to use an AST to find actual `import` statements before transformation.

> Check out an [example implementation](https://github.com/styleguidist/react-styleguidist/blob/82f22d217044dee6215e60696c39791ee168fc14/src/client/utils/transpileImports.js).


## Install

```
$ npm install --save rewrite-imports
```


## Usage

```js
const rImports = require('rewrite-imports');

rImports(`import foo from '../bar'`);
//=> const foo = require('../bar');

rImports(`import { foo } from 'bar'`);
//=> const { foo } = require('bar');

rImports(`import * as path from 'path';`);
//=> const path = require('path');

rImports(`import { foo as bar, baz as bat, lol } from 'quz';`);
//=> const { foo:bar, baz:bat, lol } = require('quz');

rImports(`import foobar, { foo as FOO, bar } from 'foobar';`);
//=> const foobar = require('foobar');
//=> const { foo:FOO, bar } = foobar;
```


## API

### rImports(input, fn)

#### input
Type: `String`

The `import` statement(s) or the code containing `import` statement(s).

> See [MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import) for valid `import` statement syntax.

#### fn
Type: `String`<br>
Default: `'require'`

The `require`-like function name to use. Defaults to `require` but you may choose to pass the name of a custom shim function; for example, `__webpack_require__` may work for webpack in the browser.

## License

MIT © [Luke Edwards](https://lukeed.com)
