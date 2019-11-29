import resolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';
import { uglify } from "rollup-plugin-uglify";
import babel from 'rollup-plugin-babel';

export default [
  // browser-friendly UMD build
  {
    input: 'lib/index.js',
    output: {
      name: 'babel-plugin-inferno',
      file: 'dist/index.umd.js',
      format: 'umd'
    },
    plugins: [
      resolve(),  // so Rollup can find `ms`
      commonjs(), // so Rollup can convert `ms` to an ES module
      babel({
        "presets": [
          [
            "@babel/preset-env",
            {
              "targets": {
                "ie": "11"
              }
            }
          ]
        ]
      }),
      uglify()
    ]
  }
];
