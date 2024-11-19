// @ts-check

export class Step {
  /**
   * The description of the step.
   * @type {string}
   */
  text;

  /**
   * Parameter passed into the step
   * @type {string|null}
   */
  parameter;

  constructor(text) {
    this.text = text;
  }

  /**
   * Set the parameter of this step
   * @param {string} parameter
   */
  set_parameter(parameter) {
    this.parameter = parameter;
  }

}
