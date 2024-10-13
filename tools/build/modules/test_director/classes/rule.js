// @ts-check

import { Scenario } from "./scenario.js";

export class Rule {
  /**
   * The name of the feature.
   * @type {string}
   */
  name;

  /**
   * A description about what the test is testing for.
   * @type {string}
   */
  description;

  /**
   * The background steps for the feature.
   * @type {Scenario|null}
   */
  background;

  /**
   * An array of scenarios in the feature.
   * @type {Scenario[]}
   */
  scenarios;

  constructor(name, description) {
    this.name = name;
    this.description = description;
    this.scenarios = [];
    this.background = null;
  }

  /**
   * Adds a scenario to the feature.
   * @param {Scenario} scenario
   */
  addScenario(scenario) {
    this.scenarios.push(scenario);
  }

  /**
   * Sets the background for the feature.
   * @param {Scenario} background
   */
  setBackground(background) {
    this.background = background;
  }

  /**
   * @param {{match: RegExp, code: string, code_injection: boolean}[]} actions
   * @param {string} test_template
   * @returns {string}
   */
  generate_code(actions, test_template) {
    let lines = [];
    if (this.background !== null) {
      lines.push(this.background.generate_code(actions));
    }
    for (const step of this.scenarios) {
      lines.push(step.generate_code(actions));
    }
    return lines.join('\n');
  }

}
