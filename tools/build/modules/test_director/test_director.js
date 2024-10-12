
import fs from 'fs';
import Juke from '../../juke/index.js';
import { parse_features } from './parse_test.js';

/**
 * Compile the test config files and generate DM files
 */
export function compile_tests(dm_directory, config_directory, test_directory) {
  // Generate test director files
  const directories = Juke.glob(`${test_directory}/**/*`);
  // Get all the features that we wish to build code for
  const results = directories.flatMap(test_file => parse_features(test_file));
  // Get all the actions
}

function parse_actions() {

}

