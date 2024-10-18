// @ts-check

export class Examples {
  /**
   * The name of the table.
   * @type {string[]}
   */
  names;

  /**
   * Contents of the table.
   * @type {Map<string, string>[]}
   */
  values;

  constructor() {
    this.names = [];
    this.values = [];
  }

  /**
   * Sets the headers of the example tab
   * @param {string[]} names
   */
  set_headers(names) {
    this.names = names;
  }

  /**
   *
   * @param {Map<string, string>} row
   */
  add_row_direct(row) {
    this.values.push(row);
  }

  /**
   *
   * @param {string[]} row
   */
  add_row(row) {
    const rowDict = new Map();

    // Loop over the row and match each value with the corresponding header
    for (let i = 0; i < row.length; i++) {
      // Ensure that there is a corresponding header for the row index
      if (i < this.names.length) {
        rowDict.set(this.names[i], row[i]);
      }
    }

    // Add the created Map to the values array
    this.values.push(rowDict);
  }

  /**
   * Converts the instance to a plain object for JSON serialization.
   */
  toJSON() {
    return {
      names: this.names,
      // Convert each Map in values to a plain object
      values: this.values.map(map => Object.fromEntries(map))
    };
  }

}
