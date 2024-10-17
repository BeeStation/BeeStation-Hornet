
export class CodeInjection
{

  /**
   * @type {string[]}
   */
  pre_text;

  /**
   * @type {string[]}
   */
  inline_text;

  constructor() {
    this.pre_text = [];
    this.inline_text = [];
  }

  /**
   *
   * @param {CodeInjection} other
   */
  merge(other) {
    other.pre_text.forEach(x => this.pre_text.push(x));
    other.inline_text.forEach(x => this.inline_text.push(x));
  }

}
