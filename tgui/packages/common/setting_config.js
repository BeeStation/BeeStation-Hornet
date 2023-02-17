/**
 * This helps to let players have different settings upto each codebase.
 * The key for backend (check storage.js) is determined by a value declared here
 *
 * @file
 * @copyright 2023 EvilDragonfiend
 * @license MIT
 */

export const PREF_ADDITION_KEY = 'beestation';
// players will not have the same setting on different codebase as long as this key isn't the same to the key from other codebases
// Currently, TG doesn't have this, so making it blank will let all players on Beestation codebase use TG setting (which is very default)
// Key as blank means:
//     PREF_ADDITION_KEY = '';


/* <comments for coders>

   Things you might need to know:
      I don't think we would ever get a system that should share across all codebases,
      but if that happens, Backend methods should have additional parameter which determines if it should refer a key to the backend
      For example:
      --------------------------------------
          set(key, value, ignore_config) {
            localStorage.setItem(key+(ignore_config ? "" : get_pref_addition_key()), JSON.stringify(value));
          }
      --------------------------------------
      ignore_config should be newly added to 9 methods that use key, and check if it's necessary
      
   Why does this work?:
      Let's say you get chat logs.
      `store["chat_log"] = "some chat logs"` will be where it is stored.
      Now we extended the key as "chat_logBeestation" which will not be shared across each codebases cache
      This is why emptifying will sync it to TG setting

   Which additional effect will be broght?:
      Everything that uses backend storage system will be affected.
      This is why I explained why the additional modification (ignore_config) might be needed in the future.
      Currently, other minor stuff (i.e. TGUI windows geometry) is only affected by this, so there won't be any unwanted effect of the change.
*/


export const get_pref_addition_key = () => {
  return PREF_ADDITION_KEY;
};
