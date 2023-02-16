/**
 * This helps to let players have different settings upto each codebase.
 * The path is determined by a value declared here
 *
 * @file
 * @copyright 2023 EvilDragonfiend
 * @license MIT
 */

export const PREF_ADDITION_KEY = 'beestation';
// players will not have the same setting on different codebase as long as this key isn't the same

export const get_pref_addition_key = () => {
  return PREF_ADDITION_KEY;
};
