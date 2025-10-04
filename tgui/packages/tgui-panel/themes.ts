/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const THEMES = ['light', 'dark'];

const COLOR_DARK_BG = '#202020';
const COLOR_DARK_BG_DARKER = '#171717';
const COLOR_DARK_TEXT = '#a4bad6';

/**
 * Darkmode preference, originally by Kmc2000.
 *
 * This lets you switch client themes by using winset.
 *
 * If you change ANYTHING in interface/skin.dmf you need to change it here.
 *
 * There's no way round it. We're essentially changing the skin by hand.
 * It's painful but it works, and is the way Lummox suggested.
 */
export const setClientTheme = (name) => {
  if (name === 'light') {
    return Byond.winset({
      // Main windows
      'infowindow.background-color': 'none',
      'infowindow.text-color': '#000000',
      'info.background-color': 'none',
      'info.text-color': '#000000',
      'browseroutput.background-color': 'none',
      'browseroutput.text-color': '#000000',
      'outputwindow.background-color': 'none',
      'outputwindow.text-color': '#000000',
      'mainwindow.background-color': 'none',
      'split.background-color': 'none',
      // Buttons
      'changelog.background-color': 'none',
      'changelog.text-color': '#000000',
      'rules.background-color': 'none',
      'rules.text-color': '#000000',
      'wiki.background-color': 'none',
      'wiki.text-color': '#000000',
      'forum.background-color': 'none',
      'forum.text-color': '#000000',
      'github.background-color': 'none',
      'github.text-color': '#000000',
      'report-issue.background-color': 'none',
      'report-issue.text-color': '#000000',
      // Status and verb tabs
      'output.background-color': 'none',
      'output.text-color': '#000000',
      // Say, OOC, me Buttons etc.
      'saybutton.background-color': 'none',
      'saybutton.text-color': '#000000',
      'oocbutton.background-color': 'none',
      'oocbutton.text-color': '#000000',
      'mebutton.background-color': 'none',
      'mebutton.text-color': '#000000',
      'asset_cache_browser.background-color': 'none',
      'asset_cache_browser.text-color': '#000000',
      'tooltip.background-color': 'none',
      'tooltip.text-color': '#000000',
    });
  }
  let desired_background = COLOR_DARK_BG;
  let desired_text = COLOR_DARK_TEXT;
  let desired_background_darker = COLOR_DARK_BG_DARKER;
  switch (name) {
    case 'dark':
      desired_background = COLOR_DARK_BG;
      desired_text = COLOR_DARK_TEXT;
      desired_background_darker = COLOR_DARK_BG_DARKER;
      break;
  }
  Byond.winset({
    // Main windows
    'infowindow.background-color': desired_background,
    'infowindow.text-color': desired_text,
    'info.background-color': desired_background,
    'info.text-color': desired_text,
    'browseroutput.background-color': desired_background,
    'browseroutput.text-color': desired_text,
    'outputwindow.background-color': desired_background,
    'outputwindow.text-color': desired_text,
    'mainwindow.background-color': desired_background,
    'split.background-color': desired_background,
    // Buttons
    'changelog.background-color': '#494949',
    'changelog.text-color': desired_text,
    'rules.background-color': '#494949',
    'rules.text-color': desired_text,
    'wiki.background-color': '#494949',
    'wiki.text-color': desired_text,
    'forum.background-color': '#494949',
    'forum.text-color': desired_text,
    'github.background-color': '#3a3a3a',
    'github.text-color': desired_text,
    'report-issue.background-color': '#492020',
    'report-issue.text-color': desired_text,
    // Status and verb tabs
    'output.background-color': desired_background_darker,
    'output.text-color': desired_text,
    // Say, OOC, me Buttons etc.
    'saybutton.background-color': desired_background,
    'saybutton.text-color': desired_text,
    'oocbutton.background-color': desired_background,
    'oocbutton.text-color': desired_text,
    'mebutton.background-color': desired_background,
    'mebutton.text-color': desired_text,
    'asset_cache_browser.background-color': desired_background,
    'asset_cache_browser.text-color': desired_text,
    'tooltip.background-color': desired_background,
    'tooltip.text-color': desired_text,
  });
};
