// File Labels
//
// Add a label based on if a file is modified in the diff
//
// You can optionally set add_only to make the label one-way -
// if the edit to the file is removed in a later commit,
// the label will not be removed
export const file_labels = {
  GitHub: {
    filepaths: ['.github/'],
  },
  SQL: {
    filepaths: ['SQL/'],
  },
  'Mapping': {
    filepaths: ['_maps/'],
    file_extensions: ['.dmm'],
  },
  Tools: {
    filepaths: ['tools/'],
  },
  'Config Update': {
    filepaths: ['config/', 'code/controllers/configuration/entries/'],
    add_only: true,
  },
  Sprites: {
    filepaths: ['icons/'],
    file_extensions: ['.dmi'],
    add_only: true,
  },
  Sound: {
    filepaths: ['sound/'],
    file_extensions: ['.ogg'],
    add_only: true,
  },
  'TGUI-Changes': {
    filepaths: ['tgui/'],
    add_only: true,
  },
  Administration: {
    filepaths: ['code/modules/admin/'],
    add_only: true,
  },
};

// Title Labels
//
// Add a label based on keywords in the title
export const title_labels = {
  Logging: {
    keywords: ['log', 'logging'],
  },
  Removal: {
    keywords: ['remove', 'delete'],
  },
  Refactor: {
    keywords: ['refactor'],
  },
  'Unit Tests': {
    keywords: ['unit test'],
  },
  'DO NOT MERGE': {
    keywords: ['[dnm]', '[do not merge]'],
  },
  'Testmerge Only': {
    keywords: ['[tm only]', '[test merge only]'],
  },
};

// Changelog Labels
//
// Adds labels based on keywords in the changelog
// TODO use the existing changelog parser
export const changelog_labels = {
  Fix: {
    default_text: 'fixed a few things',
    keywords: ['fix', 'fixes', 'bugfix'],
  },
  'Quality of Life': {
    default_text: 'made something easier to use',
    keywords: ['qol'],
  },
  'Tweak': {
    default_text: 'tweaked a few things',
    keywords: ['tweak'],
  },
  Sound: {
    default_text: 'added/modified/removed audio or sound effects',
    keywords: ['sound'],
  },
  Feature: {
    default_text: 'Added new mechanics or gameplay changes',
    alt_default_text: 'Added more things',
    keywords: ['add', 'adds', 'rscadd'],
  },
  Removal: {
    default_text: 'Removed old things',
    keywords: ['del', 'dels', 'rscdel'],
  },
  Sprites: {
    default_text: 'added/modified/removed some icons or images',
    keywords: ['image'],
  },
  'Grammar and Formatting': {
    default_text: 'fixed a few typos',
    keywords: ['typo', 'spellcheck'],
  },
  'Balance/Rebalance': {
    default_text: 'rebalanced something',
    keywords: ['balance'],
  },
  'Code Improvement': {
    default_text: 'changed some code',
    keywords: ['code_imp', 'code'],
  },
  Refactor: {
    default_text: 'refactored some code',
    keywords: ['refactor'],
  },
  'Config Update': {
    default_text: 'changed some config setting',
    keywords: ['config'],
  },
  Administration: {
    default_text: 'messed with admin stuff',
    keywords: ['admin'],
  },
};
