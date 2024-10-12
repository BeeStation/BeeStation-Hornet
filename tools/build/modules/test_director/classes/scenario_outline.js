import { Scenario } from "./scenario.js";

export class ScenarioOutline extends Scenario {

  /**
   * An array of examples for the scenario outline.
   * @type {Examples[]}
   */
  examples;

  constructor(outlineName) {
    super(outlineName);
    this.examples = []; // Initialize examples as an empty array
  }

  /**
   * Adds an example to the scenario outline.
   * @param {Examples[]} example - An object representing an example.
   */
  addExamples(example) {
    this.examples.push(example);
  }
}
