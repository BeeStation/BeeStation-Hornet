import fs from 'fs';
import { Feature } from "./classes/feature.js";
import { Scenario } from "./classes/scenario.js";
import { ScenarioOutline } from "./classes/scenario_outline.js";
import Juke from '../../juke/index.js';
import { Step } from './classes/step.js';
import { Examples } from './classes/examples.js';

/**
 * Compile a single test and return the .dm file created
 * @param {string} test_path
 * @returns {Feature[]}
 */
export function parse_features(test_path) {
  // Read the content of the test file
  const test_file = fs.readFileSync(test_path, 'utf-8');

  // Split the test file into blocks for each feature
  const featureBlocks = test_file.split(/(?=^Feature:)/gm);

  // Create an array to hold the compiled Feature objects
  const features = featureBlocks.map(parse_feature);

  // Return the compiled Feature objects
  return features;
}

/**
 * Parses a feature from the given text.
 *
 * @param {string} parse_text - The text to parse for feature details.
 * @returns {Feature} - The constructed Feature object.
 */
function parse_feature(parse_text) {
  let feature_name;

  // Read the first line for the feature name
  const firstNewLineIndex = parse_text.indexOf('\n');
  if (firstNewLineIndex !== -1) {
    // Extract the feature name from the first line
    feature_name = parse_text.slice(0, firstNewLineIndex).trim();
    parse_text = parse_text.slice(firstNewLineIndex + 1);
  } else {
    throw new Error("Feature name cannot be empty. Please provide a valid feature name.");
  }

  // Decrement the indentation so that we can find code blocks effectively
  parse_text = decrement_indentation(parse_text);

  // Start reading code blocks, the first of which will always be the description
  const first_block = read_next_block(parse_text);
  const feature = new Feature(feature_name, first_block.codeBlock);

  // Start reading the remaining blocks
  let current_block = first_block;
  while (current_block.remainingText !== null && current_block.remainingText !== '') {
    // Get the keyword for the next block
    let keyword = current_block.keyword && current_block.keyword.toLowerCase(); // Make it case insensitive

    // Get the next block
    current_block = read_next_block(current_block.remainingText);

    // Parse the text inside the block
    switch (keyword) {
      case 'example':
      case 'scenario':
        feature.addScenario(parse_scenario(current_block.codeBlock));
        break;
      case 'background':
        feature.setBackground(parse_background(current_block.codeBlock));
        break;
      case 'scenario outline':
        feature.addScenario(parse_scenario_outline(current_block.codeBlock));
        break;
      case 'scenarios':
      case 'examples':
        throw new Error(`Encountered scenarios/examples inside of a feature. Examples must be indented inside of a scenario outline to be valid, as otherwise they have nothing to run against.`);
      case 'rule':
        feature.addRule(parse_rule(current_block.codeBlock));
        break;
      default:
        throw new Error(`Unexpected keyword encountered, ${keyword} is not a valid keyword.`);
    }
  }
  return feature;
}

/**
 * Parses a scenario block.
 *
 * @param {string} block - The block containing scenario details as a string.
 * @returns {Scenario} - The constructed Scenario object.
 */
function parse_scenario(block) {
  const block_name = block.split('\n').slice(0, 1)[0].trim();
  const createdScenario = new Scenario(block_name);
  // Complicated regex ensures we only move to a new line when that next line is a new step
  block.split(/^(.+$(?:\n\s+.+)*)/gm)
    .slice(1)
    .map(x => x.trim())
    .filter(x => !is_line_empty_or_comment(x))
    .map(x => x.replace(/^\s+(?:given|when|then|and|but|\*)\s+/igm, ''))
    .forEach(x => {
      createdScenario.addStep(new Step(x));
    });
  return createdScenario;
}

/**
 * Parses a background block.
 * Since backgrounds are just a scenario, this just parses the text like a scenario.
 *
 * @param {string} block - The block containing background details as a string.
 * @returns {Scenario} - The constructed Background object.
 */
function parse_background(block) {
  return parse_scenario(block);
}

/**
 * Parses a scenario outline block.
 *
 * @param {string} block - The block containing scenario outline details as a string.
 * @returns {ScenarioOutline} - The constructed ScenarioOutline object.
 */
function parse_scenario_outline(block) {
  const block_name = block.split('\n').slice(0, 1)[0].trim();
  const createdScenario = new ScenarioOutline(block_name);
  let split = block.split(/^(?:examples|scenarios):/igm);
  // Parse the scenario as normal
  split[0]
    .split('\n')
    .slice(1)
    .map(x => x.trim())
    .filter(x => !is_line_empty_or_comment(x))
    .map(x => x.replace(/^\s+(?:given|when|then|and|but|\*)\s+/igm, ''))
    .forEach(x => {
      createdScenario.addStep(new Step(x));
    });
  // Parse the examples/scenarios section
  split
    .slice(1)
    // Split into lines and ignore empty lines
    .map(block => block.split('\n').filter(line => !is_line_empty_or_comment(line)))
    .map(lines => {
      // Create the examples table
      const table = new Examples();
      // Read the header row
      table.set_headers(lines[0].split('|').map(x => x.trim()).filter(x => x !== ''));
      // Read the data rows
      lines.splice(1)
        .map(line => {
          table.add_row(line.split('|').map(x => x.trim()).filter(x => x !== ''));
        });
      return table;
    })
    .forEach(examples => {
      createdScenario.addExamples(examples);
    });
  return createdScenario;
}

/**
 * Parses a rule block.
 *
 * @param {string} block - The block containing rule details as a string.
 * @returns {Rule} - The constructed Rule object.
 */
function parse_rule(block) {
  throw new Error('Rules are not currently supported in .feature files.');
}

/**
 * Extracts the code block from a string up to the first occurrence of a keyword.
 *
 * @param {string} input - The input string containing code blocks.
 * @returns {CodeBlockInfo} - An instance of CodeBlockInfo with populated data.
 */
function read_next_block(input) {
  // Define the regex pattern to match the keywords at the start of a line (case insensitive)
  const keywordPattern = /^(scenario|background|scenario outline|example|examples|scenarios|rule):/im;

  // Use the regex to find the first match
  const match = input.match(keywordPattern);

  if (match) {
    const firstMatchIndex = match.index; // Get the index of the first match
    const keyword = match[1].trim(); // Get the matched keyword
    const codeBlock = input.slice(0, firstMatchIndex); // Extract the code block
    const remainingText = input.slice(firstMatchIndex + match[0].length); // Get the remaining text

    // Return a new instance of CodeBlockInfo with the extracted values
    return new CodeBlockInfo(decrement_indentation(codeBlock), keyword, remainingText);
  }

  // If no match is found, return an instance with the entire input as the code block
  return new CodeBlockInfo(decrement_indentation(input), null, ""); // No keyword found
}



/**
 * Decrement the indentation of each line in a string.
 * If a line starts with a tab, remove the tab.
 * If a line starts with spaces, remove the first two spaces.
 *
 * @param {string} input - The input string with multiple lines.
 * @returns {string} - The input string with decreased indentation.
 */
function decrement_indentation(input) {
  return input.split('\n')
              .map(line => {
                if (line.startsWith('\t')) {
                  return line.slice(1); // Remove the first tab
                } else if (line.startsWith('  ')) {
                  return line.slice(2); // Remove the first two spaces
                }
                return line; // Return the line unchanged if it doesn't start with a tab or two spaces
              })
              .join('\n'); // Join the modified lines back into a single string
}

/**
 * Class representing a code block and its associated information.
 */
class CodeBlockInfo {
  /**
   * @param {string} codeBlock - The code block string.
   * @param {string} keyword - The matched keyword string.
   * @param {string} remainingText - The remaining text outside of the block.
   */
  constructor(codeBlock, keyword, remainingText) {
    this.codeBlock = codeBlock;
    this.keyword = keyword;
    this.remainingText = remainingText;
  }
}

/**
 *
 * @param {string} line
 * @returns {boolean}
 */
function is_line_empty_or_comment(line) {
  return line === null || line.length === 0 || line.trim().startsWith('#')
}
