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
}
