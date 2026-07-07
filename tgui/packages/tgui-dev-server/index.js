/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import fs from 'node:fs';

import { reloadByondCache } from './reloader.js';
import { createCompiler } from './webpack.js';

const noTmp = process.argv.includes('--no-tmp');
const reloadOnce = process.argv.includes('--reload');

async function setupServer() {
  fs.mkdirSync('./public/.tmp', { recursive: true });

  const compiler = await createCompiler({
    mode: 'development',
    devServer: true,
    useTmpFolder: !noTmp,
  });

  // Reload cache once
  if (reloadOnce) {
    await reloadByondCache(compiler.bundleDir);
    return;
  }

  // Run a development server
  await compiler.watch();
}

setupServer();
