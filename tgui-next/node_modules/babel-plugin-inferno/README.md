<p align="center"><a href="https://infernojs.org/" target="_blank"><img width="400" alt="Inferno" title="Inferno" src="https://user-images.githubusercontent.com/2021355/36073166-a47d4a8e-0f34-11e8-959c-860ea836d79d.png"></p>

<p align="center">
  <a href="https://www.npmjs.com/package/babel-plugin-inferno"><img src="https://img.shields.io/npm/dm/babel-plugin-inferno.svg" alt="Downloads"></a>
  <a href="https://www.npmjs.com/package/babel-plugin-inferno"><img src="https://img.shields.io/npm/v/babel-plugin-inferno.svg" alt="Version"></a>
  <a href="https://www.npmjs.com/package/babel-plugin-inferno"><img src="https://img.shields.io/npm/l/babel-plugin-inferno.svg" alt="License"></a>
</p>

# InfernoJS Babel Plugin

> Plugin for babel 6+ to enable JSX for Inferno

This plugin transforms JSX code in your projects to [Inferno](https://github.com/trueadm/inferno) compatible virtual DOM.
It is recommended to use this plugin for compiling JSX for inferno. It is different to other JSX plugins, because it outputs highly optimized inferno specific `createVNode` calls. This plugin also checks children shape during compilation stage to reduce overhead from runtime application. 

## How to install

**Note!** Make sure babel-plugin has same **major** version as the inferno you are using!

```bash
npm i --save-dev babel-plugin-inferno
```

## How to use

Add the plugin to your `package.json` and update the plugin section in your `.babelrc` file. Or if your Babel settings are located inside the `package.json` - update the plugin section there.

It's important that you also include the `babel-plugin-syntax-jsx`plugin.

Example on a `.babelrc` file that will work with Inferno:

Make sure inferno plugin is added before babel module transformers

```js
{   
    "presets": [ "es2015" ],
    "plugins": [["babel-plugin-inferno", {"imports": true}]]
}
```

## Examples    

```js

// Render a simple div
Inferno.render(<div></div>, container);

// Render a div with text
Inferno.render(<div>Hello world</div>, container);

// Render a div with a boolean attribute
Inferno.render(<div autoFocus='true' />, container);

```

## Fragments

All of the following syntaxes are **reserved** for createFragment call

```js
<>
    <div>Foo</div>
    <div>Bar</div>
</>


<Fragment>
    <div>Foo</div>
    <div>Bar</div>
</Fragment>

<Inferno.Fragment>
    <div>Foo</div>
    <div>Bar</div>
</Inferno.Fragment>

```

## Special flags

This plugin provides few special compile time flags that can be used to optimize an inferno application.

```js
// ChildFlags:
<div $HasVNodeChildren /> - Children is another vNode (Element or Component)
<div $HasNonKeyedChildren /> - Children is always array without keys
<div $HasKeyedChildren /> - Children is array of vNodes having unique keys
<div $ChildFlag={expression} /> - This attribute is used for defining children shpae runtime. See inferno-vnode-flags (ChildFlags) for possibe values

// Functional flags
<div $ReCreate /> - This flag tells inferno to always remove and add the node. It can be used to replace key={Math.random()}
```

Flag called `noNormalize` has been removed in v4, and is replaced by `$HasVNodeChildren`

## Options


Change in v4:


#### Imports (boolean)
By default babel-plugin-inferno uses imports. That means you no longer need to import inferno globally.
Just import the inferno specific code YOUR code uses.

example:
```js
import {render} from 'inferno'; // Just import what you need, (render in this case)

// The plugin will automatically import, createVNode
render(<div>1</div>, document.getElementById('root'));
```

You need to have support for ES6 modules for this to work. If you are using legacy build system or outdated version of webpack, you can revert this change by using `imports: false`

```js
{
    "presets": [ "es2015" ],
    "plugins": [["inferno", {
        "imports": false
    }]]
}
```


#### Pragma

Each method that is used from inferno can be replaced by custom name.

``` pragma ``` (string) defaults to createVNode.

``` pragmaCreateComponentVNode ``` (string) defaults to createComponentVNode.
 
``` pragmaNormalizeProps ``` (string) defaults to normalizeProps.
 
``` pragmaTextVNode ``` (string) defaults to createTextVNode.

``` pragmaFragmentVNode ``` (string) defaults to createFragment.
 

```js
{
    "presets": [ "es2015" ],
    "plugins": [["inferno", {
        "imports": true,
        "pragma": "",
        "pragmaCreateComponentVNode": "",
        "pragmaNormalizeProps": "",
        "pragmaTextVNode": ""
    }]]
}
```

### Troubleshoot

You can verify `babel-plugin-inferno` is used by looking at the compiled output.
This plugin does not generate calls to `createElement` or `h`, but instead it uses low level InfernoJS API
`createVNode`, `createComponentVNode`, `createFragment` etc. If you see your JSX being transpiled into `createElement` calls
its good indication that your babel configuration is not correct.
