// @ts-check

import { Scenario } from "./scenario.js";
import { Examples } from "./examples.js";
import { CodeInjection } from "./injected_code.js";

export class ScenarioOutline extends Scenario {

  /**
   * An array of examples for the scenario outline.
   * @type {Examples|undefined}
   */
  example;

  /**
   * Adds an example to the scenario outline.
   * @param {Examples} example - An object representing an example.
   */
  addExamples(example) {
    if (this.example) {
      for (var i = 0; i < this.example.names.length; i++) {
        if (example.names[i] != this.example.names[i]) {
          throw new Error(`The scenario outline with name ${this.name} has multiple examples that do not share the same names.`);
        }
      }
      for (var row of example.values) {
        this.example.add_row_direct(row);
      }
    } else {
      this.example = example;
    }
  }

  /**
   * @param {{match: RegExp, code: string, code_injection: boolean}[]} actions
   * @returns {CodeInjection}
   */
  generate_code(actions) {
    const var_match = /\<([\w_]+)\>/gm;
    // Convert our action texts to remove the variables
    for (const step of this.steps) {
      step.text = step.text.replaceAll(var_match, '_$1');
    }
    // Generate the baseline code
    const generated = super.generate_code(actions);
    // Add the for loops
    if (this.example) {
      generated.inline_text = generated.inline_text.map(original_line => `${'\t'.repeat(this.example ? this.example.names.length : 0)}${original_line}`);
      let indentation = 0;
      for (const example_name of this.example.names) {
        generated.inline_text.unshift(`${'\t'.repeat(indentation)}for (var/_${example_name} in list() + ${this.example.values.map(x => x.get(example_name)).join(' + ')})`);
        indentation ++;
      }
    }
    // Return generated code
    return generated;
  }
}
