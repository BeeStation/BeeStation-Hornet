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
}
