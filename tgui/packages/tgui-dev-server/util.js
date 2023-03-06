/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import fs from 'fs';
import path from 'path';
import { require } from './require.js';

const { globSync } = require('glob');

export const resolvePath = path.resolve;

/**
 * Combines path.resolve with glob patterns.
 */
export const resolveGlob = (...sections) => {
  const unsafePaths = globSync(path.resolve(...sections), {
    strict: false,
    silent: true,
  });
  const safePaths = [];
  for (let path of unsafePaths) {
    try {
      fs.statSync(path);
      safePaths.push(path);
    }
    catch {}
  }
  return safePaths;
};
