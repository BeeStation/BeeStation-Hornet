var mocha = require('mocha');
var describe = mocha.describe;
var it = mocha.it;
var chai = require('chai');
var plugin = require('./lib/index.js');
var expect = chai.expect;
var babel = require('@babel/core');
var babelSettings = {
    presets: [['@babel/preset-env', {modules: false, loose: true, targets: {browsers:"last 1 Chrome versions"}}]],
    plugins: [
        [plugin, {imports: true, defineAllArguments: false}],
        '@babel/plugin-syntax-jsx'
    ]
};

describe('Transforms', function () {

    function pluginTransform(input) {
        return babel.transform(input, babelSettings).code;
    }

    function transform(input) {
        return pluginTransform(input).replace(new RegExp('import.*"inferno";\\n'), '');
    }

    describe('Dynamic children', function () {
        it('Should add normalize call when there is dynamic children', function () {
            expect(transform('<div>{a}</div>')).to.equal('createVNode(1, "div", null, a, 0);');
        });

        it('Should add normalize call when there is dynamic and static children mixed', function () {
            expect(transform('<div>{a}<div>1</div></div>')).to.equal('createVNode(1, "div", null, [a, createVNode(1, "div", null, "1", 16)], 0);');
        });

        it('Should not add normalize call when all children are known', function () {
            expect(transform('<div><FooBar/><div>1</div></div>')).to.equal('createVNode(1, "div", null, [createComponentVNode(2, FooBar), createVNode(1, "div", null, "1", 16)], 4);');
        });

        it('Should create textVNodes when there is no normalization needed and its multiple children', function () {
            expect(transform('<div><FooBar/>foobar</div>')).to.equal('createVNode(1, "div", null, [createComponentVNode(2, FooBar), createTextVNode("foobar")], 4);');
        });

        it('Should create textVNodes when there is single children', function () {
            expect(transform('<div>foobar</div>')).to.equal('createVNode(1, "div", null, "foobar", 16);');
        });

        it('Should create textVNodes when there is single children', function () {
            expect(transform('<div>1</div>')).to.equal('createVNode(1, "div", null, "1", 16);');
        });

        it('Should not normalize Component prop children', function () {
            expect(transform('<Com>{a}</Com>')).to.equal('createComponentVNode(2, Com, {\n  children: a\n});');
        });

        it('Should not normalize component children as they are in props', function () {
            expect(transform('<Com>{a}{b}{c}</Com>')).to.equal('createComponentVNode(2, Com, {\n  children: [a, b, c]\n});');
        });

        it('Should mark parent vNode with $HasNonKeyedChildren if no normalize is needed and all children are non keyed', function () {
            expect(transform('<div><FooBar/><div>1</div></div>')).to.equal('createVNode(1, "div", null, [createComponentVNode(2, FooBar), createVNode(1, "div", null, "1", 16)], 4);');
        });

        it('Should mark parent vNode with $HasKeyedChildren if no normalize is needed and all children are keyed', function () {
            expect(transform('<div><FooBar key="foo"/><div key="1">1</div></div>')).to.equal('createVNode(1, "div", null, [createComponentVNode(2, FooBar, null, "foo"), createVNode(1, "div", null, "1", 16, null, "1")], 8);');
        });
    });

    describe('Dynamic ChildFlags', function () {
        it('Should be possible to define override childFlags runtime for dynamic children', function () {
            expect(transform('<img $ChildFlag={bool ? 1 : 2}>{expression}</img>')).to.equal('createVNode(1, "img", null, expression, bool ? 1 : 2);');
        });

        it('Should be possible to define override childFlags runtime', function () {
            expect(transform('<img $ChildFlag={1}>foobar</img>')).to.equal('createVNode(1, "img", null, "foobar", 1);');
        });

        it('Should be possible to use expression for childFlags', function () {
            expect(transform('<img $ChildFlag={magic}>foobar</img>')).to.equal('createVNode(1, "img", null, "foobar", magic);');
        });
    });

    describe('different types', function () {
        it('Should transform img', function () {
            expect(transform('<img>foobar</img>')).to.equal('createVNode(1, "img", null, "foobar", 16);');
        });

        it('Should transform br', function () {
            expect(transform('<br>foobar</br>')).to.equal('createVNode(1, "br", null, "foobar", 16);');
        });

        it('Should transform media', function () {
            expect(transform('<media>foobar</media>')).to.equal('createVNode(1, "media", null, "foobar", 16);');
        });

        it('Should transform textarea', function () {
            expect(transform('<textarea>foobar</textarea>')).to.equal('createVNode(128, "textarea", null, "foobar", 16);');
        });
    });

    describe('Special flags', function () {
        it('Should add keyed children flag', function () {
            expect(transform('<div $HasKeyedChildren>{magic}</div>')).to.equal('createVNode(1, "div", null, magic, 8);');
        });

        it('Should not normalize if noNormalize set', function () {
            expect(transform('<div $HasVNodeChildren>{magic}</div>')).to.equal('createVNode(1, "div", null, magic, 2);');
        });

        it('Should set hasTextChildren flag and not create textVNode when $HasTextChildren is used ( dynamic )', function () {
            expect(transform('<div $HasTextChildren>{foobar}</div>')).to.equal('createVNode(1, "div", null, foobar, 16);');
        });

        it('Should set hasTextChildren flag and not create textVNode when $HasTextChildren is used ( hardcoded )', function () {
            expect(transform('<div $HasTextChildren>text</div>')).to.equal('createVNode(1, "div", null, "text", 16);');
        });

        it('Should set hasTextChildren flag and not create textVNode when $HasTextChildren is used ( hardcoded ) #2', function () {
            expect(transform('<div $HasTextChildren>{"testing"}</div>')).to.equal('createVNode(1, "div", null, "testing", 16);');
        });

        it('Should use optimized text children instead createTextVNode for element single child', function () {
            expect(transform('<div>text</div>')).to.equal('createVNode(1, "div", null, "text", 16);');
        });

        it('Should add non keyed children flag', function () {
            expect(transform('<div $HasNonKeyedChildren>{test}</div>')).to.equal('createVNode(1, "div", null, test, 4);');
        });

        it('Should add re create flag', function () {
            expect(transform('<div $ReCreate/>')).to.equal('createVNode(2049, "div");');
        });

        it('Should be possible to define override flags runtime', function () {
          expect(transform('<img $Flags={bool ? 1 : 2}>{expression}</img>')).to.equal('createVNode(bool ? 1 : 2, "img", null, expression, 0);');
        });

        it('Should be possible to define override flags with constant', function () {
          expect(transform('<img $Flags={120}>foobar</img>')).to.equal('createVNode(120, "img", null, "foobar", 16);');
        });

        it('Should be possible to use expression for flags', function () {
          expect(transform('<ComponentA $Flags={magic}/>')).to.equal('createComponentVNode(magic, ComponentA);');
        });
    });

    describe('spreadOperator', function () {
        it('Should add call to normalizeProps when spread operator is used', function () {
            expect(transform('<div {...props}>1</div>')).to.equal('normalizeProps(createVNode(1, "div", null, "1", 16, { ...props\n}));');
        });

        it('Should add call to normalizeProps when spread operator is used #2', function () {
            expect(transform('<div foo="bar" className="test" {...props}/>')).to.equal('normalizeProps(createVNode(1, "div", "test", null, 1, {\n  "foo": "bar",\n  ...props\n}));');
        });

        it('Should add call to normalizeProps when spread operator is used inside children for Component', function () {
            expect(transform('<FooBar><BarFoo {...props}/><NoNormalize/></FooBar>')).to.equal('createComponentVNode(2, FooBar, {\n  children: [normalizeProps(createComponentVNode(2, BarFoo, { ...props\n  })), createComponentVNode(2, NoNormalize)]\n});');
        });

        it('Should do single normalization when multiple spread operators are used', function () {
            expect(transform('<FooBar><BarFoo {...magics} {...foobars} {...props}/><NoNormalize/></FooBar>')).to.equal('createComponentVNode(2, FooBar, {\n  children: [normalizeProps(createComponentVNode(2, BarFoo, { ...magics,\n    ...foobars,\n    ...props\n  })), createComponentVNode(2, NoNormalize)]\n});');
        });
    });

    describe('Basic scenarios', function () {
        it('Should transform div', function () {
            expect(transform('<div></div>')).to.equal('createVNode(1, "div");');
        });

        it('Should transform single div', function () {
            expect(transform('<div>1</div>')).to.equal('createVNode(1, "div", null, "1", 16);');
        });

        it('#Test to verify stripping imports work#', function () {
            expect(transform('<div>1</div>')).to.equal('createVNode(1, "div", null, "1", 16);');
        });

        it('className should be in third parameter as string when its element', function () {
            expect(transform('<div className="first second">1</div>')).to.equal('createVNode(1, "div", "first second", "1", 16);');
        });

        it('className should be in fifth parameter as string when its component', function () {
            expect(transform('<UnknownClass className="first second">1</UnknownClass>')).to.equal('createComponentVNode(2, UnknownClass, {\n  "className": "first second",\n  children: "1"\n});');
        });

        it('JSXMemberExpressions should work', function () {
            expect(transform('<Components.Unknown>1</Components.Unknown>')).to.equal('createComponentVNode(2, Components.Unknown, {\n  children: "1"\n});');
        });

        it('class should be in third parameter as variable', function () {
            expect(transform('<div class={variable}>1</div>')).to.equal('createVNode(1, "div", variable, "1", 16);');
        });

        it('Should call createVNode twice and text children', function () {
            expect(transform(`<div>
          <div>single</div>
        </div>`)).to.equal('createVNode(1, "div", null, createVNode(1, "div", null, "single", 16), 2);');
        });

        it('Events should be in props', function () {
            expect(transform('<div id="test" onClick={func} class={variable}>1</div>')).to.equal('createVNode(1, "div", variable, "1", 16, {\n  "id": "test",\n  "onClick": func\n});');
        });

        it('Should transform input and htmlFor correctly', function () {
            var result = transform('<label htmlFor={id}><input id={id} name={name} value={value} onChange={onChange} onInput={onInput} onKeyup={onKeyup} onFocus={onFocus} onClick={onClick} type="number" pattern="[0-9]+([,\.][0-9]+)?" inputMode="numeric" min={minimum}/></label>');
            var expected = 'createVNode(1, "label", null, createVNode(64, "input", null, null, 1, {\n  "id": id,\n  "name": name,\n  "value": value,\n  "onChange": onChange,\n  "onInput": onInput,\n  "onKeyup": onKeyup,\n  "onFocus": onFocus,\n  "onClick": onClick,\n  "type": "number",\n  "pattern": "[0-9]+([,.][0-9]+)?",\n  "inputMode": "numeric",\n  "min": minimum\n}), 2, {\n  "for": id\n});';
            expect(result).to.equal(expected);
        });

        it('Should transform onDoubleClick to native html event', function () {
            expect(transform('<div onDoubleClick={foobar}></div>')).to.eql('createVNode(1, "div", null, null, 1, {\n  "onDblClick": foobar\n});');
        });
    });

    describe('contenteditbale', function () {
      it('Should set additional byte on when contenteditbale attribute is found', function () {
        expect(transform('<div contentEditable></div>')).to.eql('createVNode(4097, "div", null, null, 1, {\n  "contentEditable": true\n});');
        expect(transform('<span contenteditable="false"></span>')).to.eql('createVNode(4097, "span", null, null, 1, {\n  "contenteditable": "false"\n});');
        expect(transform('<div contenteditable></div>')).to.eql('createVNode(4097, "div", null, null, 1, {\n  "contenteditable": true\n});');
        expect(transform('<div contentEditable={logic}></div>')).to.eql('createVNode(4097, "div", null, null, 1, {\n  "contentEditable": logic\n});');
        expect(transform('<div contentEditable="true"></div>')).to.eql('createVNode(4097, "div", null, null, 1, {\n  "contentEditable": "true"\n});');
      });
    });

    describe('Pragma option', function () {
        var babelSettingsPragma = {
            presets: [['@babel/preset-env', {modules: false, loose: true, targets: {browsers:"last 1 Chrome versions"}}]],
            plugins: [
              [plugin, {imports: false, pragma: 't.some'}],
              '@babel/plugin-syntax-jsx'
            ]
        };

        function pluginTransformPragma(input) {
            return babel.transform(input, babelSettingsPragma).code;
        }

        it('Should replace createVNode to pragma option value', function () {
            expect(pluginTransformPragma('<div></div>')).to.equal('t.some(1, "div");');
        });
    });

  describe('defineAllArguments option', function () {
    var babelSettingsPragma = {
      presets: [['@babel/preset-env', {modules: false, loose: true, targets: {browsers:"last 1 Chrome versions"}}]],
      plugins: [
        [plugin, {imports: false, defineAllArguments: true}],
        '@babel/plugin-syntax-jsx'
      ]
    };

    function pluginTransformAllArgs(input) {
      return babel.transform(input, babelSettingsPragma).code;
    }

    it('Should replace createVNode to pragma option value', function () {
      expect(pluginTransformAllArgs('<div></div>')).to.equal('var createVNode = Inferno.createVNode;\ncreateVNode(1, "div", null, null, 1, null, null, null);');
    });
  });

    /**
     * In Inferno all SVG attributes are written as in DOM standard
     * however for compatibility reasons we want to support React like syntax
     *
     */
    describe('SVG attributes React syntax support', function () {
        it('Should transform xlinkHref to xlink:href', function () {
            expect(transform('<svg><use xlinkHref="#tester"></use></svg>')).to.equal('createVNode(32, "svg", null, createVNode(32, "use", null, null, 1, {\n  "xlink:href": "#tester"\n}), 2);');
        });

        it('Should transform strokeWidth to stroke-width', function () {
            expect(transform('<svg><rect strokeWidth="1px"></rect></svg>')).to.equal('createVNode(32, "svg", null, createVNode(32, "rect", null, null, 1, {\n  "stroke-width": "1px"\n}), 2);');
        });

        it('Should transform strokeWidth to stroke-width', function () {
            expect(transform('<svg><rect fillOpacity="1"></rect></svg>')).to.equal('createVNode(32, "svg", null, createVNode(32, "rect", null, null, 1, {\n  "fill-opacity": "1"\n}), 2);');
        });
    });

    describe('text node and elements mixed', () => {
      it('Should createTextVNode when there are siblings', () => {
        expect(transform('<div>Okay<span>foo</span></div>')).to.eql('createVNode(1, "div", null, [createTextVNode("Okay"), createVNode(1, "span", null, "foo", 16)], 4);');
      });

      // SHORT SYNTAX

      it('Should createTextVNode when text node is under short syntax fragment', () => {
        expect(transform('<>Okay<span>foo</span></>')).to.eql('createFragment([createTextVNode("Okay"), createVNode(1, "span", null, "foo", 16)], 4);');
      });

      it('Should not wrap dynamic value', () => {
        expect(transform('<>{magic}</>')).to.eql('createFragment(magic, 0);')
      });

      it('Should always keep text node as children even if there is one when parent is short syntax Fragment', () => {
        expect(transform('<><>Text</></>')).to.eql('createFragment([createFragment([createTextVNode("Text")], 4)], 4);');
      });

      it('Should always short syntax Fragment', () => {
        expect(transform('<><><div>Text</div></></>')).to.eql('createFragment([createFragment([createVNode(1, "div", null, "Text", 16)], 4)], 4);');
      });

      it('Should handle many dynamic children short syntax', () => {
        expect(transform('<><>{Frag}Text{Wohoo}</></>')).to.eql('createFragment([createFragment([Frag, createTextVNode("Text"), Wohoo], 0)], 4);');
      });

      it('Should handle many dynamic and non dynamic children short syntax', () => {
        expect(transform('<><><span></span>Text{Wohoo}</></>')).to.eql('createFragment([createFragment([createVNode(1, "span"), createTextVNode("Text"), Wohoo], 0)], 4);');
      });


      // LONG SYNTAX

      it('Should always keep text node as children even if there is one when parent is long syntax Fragment', () => {
        expect(transform('<Fragment><Fragment>Text</Fragment></Fragment>')).to.eql('createFragment([createFragment([createTextVNode("Text")], 4)], 4);');
      });

      it('Should createTextVNode when text node is under large syntax fragment', () => {
        expect(transform('<Fragment>Okay<span>foo</span></Fragment>')).to.eql('createFragment([createTextVNode("Okay"), createVNode(1, "span", null, "foo", 16)], 4);');
      });

      it('Should always keep text node as children even if there is one when parent is long syntax Fragment', () => {
        expect(transform('<Fragment><Fragment>Text</Fragment></Fragment>')).to.eql('createFragment([createFragment([createTextVNode("Text")], 4)], 4);');
      });

      it('Should always long syntax Fragment', () => {
        expect(transform('<Fragment><Fragment><div>Text</div></Fragment></Fragment>')).to.eql('createFragment([createFragment([createVNode(1, "div", null, "Text", 16)], 4)], 4);');
      });

      it('Should handle many dynamic children long syntax', () => {
        expect(transform('<Fragment><Fragment>{Frag}Text{Wohoo}</Fragment></Fragment>')).to.eql('createFragment([createFragment([Frag, createTextVNode("Text"), Wohoo], 0)], 4);');
      });

      it('Should handle many dynamic and non dynamic children long syntax', () => {
        expect(transform('<Fragment><Fragment><span></span>Text{Wohoo}</Fragment></Fragment>')).to.eql('createFragment([createFragment([createVNode(1, "span"), createTextVNode("Text"), Wohoo], 0)], 4);');
      });
    });

    // TODO: This would be neat feature, implement it if solid way to detect shape is found
    // describe('detection', function () {
    //     it('Should use Functional Component and class Component flags if type is known', function () {
    //         var expectedResult = '\nfunction Terve() {}\n\nclass FooComponent extends Component {}\n\nvar tester = createComponentVNode(4, FooComponent);\nvar foo = createVNode(1, "div");\nvar b = createComponentVNode(8, Terve);';
    //         expect(transform('function Terve() {} class FooComponent extends Component {} var tester = <FooComponent/>; var foo = <div/>; var b = <Terve/>')).to.equal(expectedResult);
    //     });
    // });

    describe('Imports', function () {
        it('Should not fail if createVNode is already imported', function () {
            expect(pluginTransform('import {createVNode} from "inferno"; var foo = <div/>;')).to.equal('import { createVNode } from "inferno";\nvar foo = createVNode(1, "div");');
        });

        it('Should add import to createVNodeComponent but not to createVNode if createVNode is already delcared', function () {
            expect(pluginTransform('import {createVNode} from "inferno"; var foo = <FooBar/>;')).to.equal('import { createComponentVNode } from "inferno";\nimport { createVNode } from "inferno";\nvar foo = createComponentVNode(2, FooBar);');
        });
    });

    describe('Children', function () {
        it('Element Should prefer child element over children props', function () {
            expect(transform('<div children="ab">test</div>')).to.eql('createVNode(1, "div", null, "test", 16);');
        });

        it('Element Should prefer prop over empty children', function () {
            expect(transform('<div children="ab"></div>')).to.eql('createVNode(1, "div", null, "ab", 16);');
        });

        it('Element Should use prop if no children exists', function () {
            expect(transform('<div children="ab"/>')).to.eql('createVNode(1, "div", null, "ab", 16);');
        });


        it('Component Should prefer child element over children props', function () {
            expect(transform('<Com children="ab">test</Com>')).to.eql('createComponentVNode(2, Com, {\n  children: "test"\n});');
        });

        it('Component Should prefer prop over empty children', function () {
            expect(transform('<Com children="ab"></Com>')).to.eql('createComponentVNode(2, Com, {\n  "children": "ab"\n});');
        });

        it('Component Should use prop if no children exists', function () {
            expect(transform('<Com children="ab"/>')).to.eql('createComponentVNode(2, Com, {\n  "children": "ab"\n});');
        });

        it('Component Array empty children', function () {
            expect(transform('<Com>{[]}</Com>')).to.eql('createComponentVNode(2, Com);');
        });

        it('Component should create vNode for children', function () {
            expect(transform('<Com children={<div>1</div>}/>')).to.eql('createComponentVNode(2, Com, {\n  "children": createVNode(1, "div", null, "1", 16)\n});');
        });

        it('Should prefer xml children over props', function () {
            expect(transform('<foo children={<span>b</span>}></foo>')).to.eql('createVNode(1, "foo", null, createVNode(1, "span", null, "b", 16), 2);')
        });

        it('Should prefer xml children over props (null)', function () {
            expect(transform('<foo children={null}></foo>')).to.eql('createVNode(1, "foo");')
        });
    });

    describe('Fragments', function () {
        describe('Short syntax', function () {
          it('Should create empty createFragment', function () {
            expect(transform('<></>')).to.eql('createFragment();');
          });

          it('Should createFragment', function () {
            expect(transform('<>Test</>')).to.eql('createFragment([createTextVNode("Test")], 4);');
          });

          it('Should createFragment dynamic children', function () {
            expect(transform('<>{dynamic}</>')).to.eql('createFragment(dynamic, 0);');
          });

          it('Should createFragment keyed children', function () {
            expect(transform('<><span key="ok">kk</span><div key="ok2">ok</div></>')).to.eql('createFragment([createVNode(1, "span", null, "kk", 16, null, "ok"), createVNode(1, "div", null, "ok", 16, null, "ok2")], 8);');
          });

          it('Should createFragment non keyed children', function () {
            expect(transform('<><div>1</div><span>foo</span></>')).to.eql('createFragment([createVNode(1, "div", null, "1", 16), createVNode(1, "span", null, "foo", 16)], 4);');
          });
        });

        describe('Long syntax', function () {
            describe('Fragment', function () {
              it('Should create empty createFragment', function () {
                expect(transform('<Fragment></Fragment>')).to.eql('createFragment();');
                expect(transform('<Fragment/>')).to.eql('createFragment();');
              });

              it('Should createFragment', function () {
                expect(transform('<Fragment>Test</Fragment>')).to.eql('createFragment([createTextVNode("Test")], 4);');
              });

              it('Should createFragment dynamic children', function () {
                expect(transform('<Fragment>{dynamic}</Fragment>')).to.eql('createFragment(dynamic, 0);');
              });

              it('Should createFragment keyed children', function () {
                expect(transform('<Fragment><span key="ok">kk</span><div key="ok2">ok</div></Fragment>')).to.eql('createFragment([createVNode(1, "span", null, "kk", 16, null, "ok"), createVNode(1, "div", null, "ok", 16, null, "ok2")], 8);');
              });

              it('Should createFragment non keyed children', function () {
                expect(transform('<Fragment><div>1</div><span>foo</span></Fragment>')).to.eql('createFragment([createVNode(1, "div", null, "1", 16), createVNode(1, "span", null, "foo", 16)], 4);');
              });

              // Long syntax specials
              it('Should createFragment non keyed children', function () {
                expect(transform('<Fragment key="foo"><div>1</div><span>foo</span></Fragment>')).to.eql('createFragment([createVNode(1, "div", null, "1", 16), createVNode(1, "span", null, "foo", 16)], 4, "foo");');
              });

              // Optimization flags
              it('Should createFragment non keyed children', function () {
                expect(transform('<Fragment key="foo" $HasKeyedChildren>{magic}</Fragment>')).to.eql('createFragment(magic, 8, "foo");');
              });

              it('Should createFragment non keyed children', function () {
                expect(transform('<Fragment key="foo" $HasNonKeyedChildren>{magic}</Fragment>')).to.eql('createFragment(magic, 4, "foo");');
              });
            });

            describe('Inferno.Fragment', function () {
              it('Should createFragment', function () {
                expect(transform('<Inferno.Fragment>Test</Inferno.Fragment>')).to.eql('createFragment([createTextVNode("Test")], 4);');
              });

              it('Should createFragment dynamic children', function () {
                expect(transform('<Inferno.Fragment>{dynamic}</Inferno.Fragment>')).to.eql('createFragment(dynamic, 0);');
              });

              it('Should createFragment keyed children', function () {
                expect(transform('<Inferno.Fragment><span key="ok">kk</span><div key="ok2">ok</div></Inferno.Fragment>')).to.eql('createFragment([createVNode(1, "span", null, "kk", 16, null, "ok"), createVNode(1, "div", null, "ok", 16, null, "ok2")], 8);');
              });

              it('Should createFragment non keyed children', function () {
                expect(transform('<Inferno.Fragment><div>1</div><span>foo</span></Inferno.Fragment>')).to.eql('createFragment([createVNode(1, "div", null, "1", 16), createVNode(1, "span", null, "foo", 16)], 4);');
              });

              // Long syntax specials
              it('Should createFragment non keyed children', function () {
                expect(transform('<Inferno.Fragment key="foo"><div>1</div><span>foo</span></Inferno.Fragment>')).to.eql('createFragment([createVNode(1, "div", null, "1", 16), createVNode(1, "span", null, "foo", 16)], 4, "foo");');
              });
              
              it('Should ignore all other props', function () {
                expect(transform('<Inferno.Fragment abc="foobar" id="test" key="foo"><div>1</div><span>foo</span></Inferno.Fragment>')).to.eql('createFragment([createVNode(1, "div", null, "1", 16), createVNode(1, "span", null, "foo", 16)], 4, "foo");');
              });

              // Optimization flags
              it('Should createFragment non keyed children', function () {
                expect(transform('<Inferno.Fragment key="foo" $HasKeyedChildren>{magic}</Inferno.Fragment>')).to.eql('createFragment(magic, 8, "foo");');
              });

              it('Should createFragment non keyed children', function () {
                expect(transform('<Inferno.Fragment key="foo" $HasNonKeyedChildren>{magic}</Inferno.Fragment>')).to.eql('createFragment(magic, 4, "foo");');
              });
            });
        });
    });

});

