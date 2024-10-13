// @ts-check

import { Rule } from "./rule.js";

export class Feature extends Rule {

  /**
   * An array of rules associated with the feature.
   * @type {Rule[]}
   */
  rules;

  /**
   * Constructor for the Feature class.
   * @param {string} name - The name of the feature.
   * @param {string} description - A description of what the feature tests.
   */
  constructor(name, description) {
    // Call the parent constructor
    super(name, description);

    // Initialize the rules array
    this.rules = [];
  }

  /**
   * Adds a rule to the feature's rules.
   * @param {Rule} rule
   */
  addRule(rule) {
    this.rules.push(rule);
  }
}
