// @ts-check

import fs from 'fs';
import Juke from '../../juke/index.js';
import { parse_features } from './parse_test.js';

export function check_tests(config_directory, test_directory, template_path) {
  // Generate test director files
  const test_directories = Juke.glob(`${test_directory}/**/*`);
  // Get all the features that we wish to build code for
  const results = test_directories.flatMap(test_file => parse_features(test_file));
  // Get all the actions
  const action_directories = Juke.glob(`${config_directory}/**/*.json`);
  const actions = action_directories.flatMap(file => parse_actions(file));
  // Load up the template file
  const test_template = fs.readFileSync(template_path, 'utf-8');
  // Create the tests
  for (const test of results) {
    const indent_match = /^(\s*).*TEST_CODE/gmi.exec(test_template);
    if (indent_match === null)
      throw new Error(`${template_path} does not contain TEST_CODE, meaning that no test code is being injected.`);
    // Run the code generator, ensure that the test config is valid
    test.generate_code(actions, test_template);
  }
}

/**
 * Compile the test config files and generate DM files
 * @param {string} dm_path
 * @param {string} config_directory
 * @param {string} test_directory
 * @param {string} template_path
 */
export function compile_tests(dm_path, config_directory, test_directory, template_path) {
  // Generate test director files
  const test_directories = Juke.glob(`${test_directory}/**/*`);
  // Get all the features that we wish to build code for
  const results = test_directories.flatMap(test_file => parse_features(test_file));
  // Get all the actions
  const action_directories = Juke.glob(`${config_directory}/**/*.json`);
  const actions = action_directories.flatMap(file => parse_actions(file));
  // Load up the template file
  const test_template = fs.readFileSync(template_path, 'utf-8');
  fs.writeFileSync(dm_path, '', {
    encoding: 'utf-8'
  });
  // Create the tests
  for (const test of results) {
    const indent_match = /^(\s*).*TEST_CODE/gmi.exec(test_template);
    if (indent_match === null)
      throw new Error(`${template_path} does not contain TEST_CODE, meaning that no test code is being injected.`);
    const code_indentation = indent_match[1];
    const desired_code = test.generate_code(actions, test_template);
    const test_code = desired_code.inline_text.map(x => `${code_indentation}${x}`).join('\n');
    const pre_text = desired_code.pre_text.join('\n');
    const test_file = test_template
      .replaceAll(/[\t ]*TEST_INJECTION/gm, pre_text)
      .replaceAll(/[\t ]*TEST_CODE/gm, test_code)
      .replaceAll('TEST_NAME', test.name.toLowerCase().replace(/\W/gmi, '').replace(' ', '_'));
    fs.appendFileSync(dm_path, test_file, {
      encoding: 'utf-8'
    });
  }
}

/**
 * Parses the provided actions file
 * @param {string} file_path
 * @returns {{match: RegExp, code: string, code_injection: boolean}[]}
 */
function parse_actions(file_path) {
  const action_file = fs.readFileSync(file_path, 'utf-8');
  const action_object = JSON.parse(action_file);

  // Convert the 'match' pattern strings to regular expressions
  return action_object.patterns.map(pattern => ({
    match: new RegExp('^' + pattern.match
      .replaceAll(/\b(?:a|an|the)\b/gi, '')
      .replaceAll('%NAME%', '(?:[\\w_]+)')
      .replaceAll('%TYPE%', '(?:(?:\\/(?:\\w|\\_)+)+)')
      .replaceAll('%PROC%', '(?:[\\w_]+\\(.*\\))')
      .replaceAll('%VALUE%', '(?:\\S+|".*")')
      + '$', 'gi'),
    code: pattern.code,
    code_injection: pattern.code_injection,
  }));
}
