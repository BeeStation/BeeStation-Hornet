// @ts-check

import { CodeInjection } from "./injected_code.js";
import { Step } from "./step.js";

export class Scenario {
  /**
   * The name of the scenario.
   * @type {string}
   */
  name;

  /**
   * An array of steps in the scenario.
   * @type {Step[]}
   */
  steps;

  constructor(name) {
    this.name = name;
    this.steps = [];
  }

  /**
   * Adds a step to the scenario.
   * @param {Step} step
   */
  addStep(step) {
    this.steps.push(step);
  }

  /**
   * @param {{match: RegExp, code: string, code_injection: boolean}[]} actions
   * @returns {CodeInjection}
   */
  generate_code(actions) {
    let output = new CodeInjection();
    for (const step of this.steps) {
      const valid_matches = actions
        .map(action => {
          const executed_match = new RegExp(action.match).exec(step.text);
          return { regex_match: executed_match, mapped_action: action };
        })
        .filter(x => x.regex_match?.length);
      if (valid_matches.length === 0) {
        throw new Error(`Step '${step.text}' belonging to scenario '${this.name}' failed to match any actions.`);
      }
      const match = valid_matches[0];
      if (match.mapped_action.code_injection) {
        // Handle code injection
        if (step.parameter === null) {
          throw new Error(`Step '${step.text}' belonging to scenario '${this.name}' requires an action but none was provided.`);
        }
        if (match.mapped_action.code) {
          throw new Error(`Step '${step.text}' belonging to scenario '${this.name}' is marked as code injecting action but has code defined which will be ignored.`);
        }
        output.pre_text.push(step.parameter)
      } else {
        // Handle normal code generation
        let line = match.mapped_action.code;
        if (!line) {
          throw new Error(`Step '${step.text}' belonging to scenario '${this.name}' is invalidly setup, it has no code provided but is also not a code injection block.`);
        }
        if (match.regex_match !== null && match.regex_match.groups !== null) {
          for (let i = 1; i < match.regex_match.length; i++) {
            line = line.replaceAll(`$${i}`, match.regex_match[i]);
          }
        }
        if (!line) {
          throw new Error(`Step '${step.text}' belonging to scenario '${this.name}' failed to produce valid code.`);
        }
        for (const new_line of line.split('\n')) {
          output.inline_text.push(new_line);
        }
      }
    }
    return output;
  }

}
