/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

type Gas = {
  id: string;
  path: string;
  name: string;
  label: string;
  color: string;
};

// UI states, which are mirrored from the BYOND code.
export const UI_INTERACTIVE = 2;
export const UI_UPDATE = 1;
export const UI_DISABLED = 0;
export const UI_CLOSE = -1;

// All game related colors are stored here
export const COLORS = {
  // Department colors
  department: {
    captain: '#c06616',
    security: '#e74c3c',
    medbay: '#3498db',
    science: '#9b59b6',
    engineering: '#f1c40f',
    cargo: '#f39c12',
    service: '#7cc46a',
    centcom: '#00c100',
    other: '#c38312',
  },
  // Damage type colors
  damageType: {
    oxy: '#3498db',
    toxin: '#2ecc71',
    burn: '#e67e22',
    brute: '#e74c3c',
  },
  // reagent / chemistry related colours
  reagent: {
    acidicbuffer: '#fbc314',
    basicbuffer: '#3853a4',
  },
} as const;

// Colors defined in CSS
export const CSS_COLORS = [
  'black',
  'white',
  'red',
  'orange',
  'yellow',
  'olive',
  'green',
  'teal',
  'blue',
  'violet',
  'purple',
  'pink',
  'brown',
  'grey',
  'good',
  'average',
  'bad',
  'label',
];

export const RADIO_CHANNELS = [
  {
    name: 'Syndicate',
    freq: 121,
    color: '#a52a2a',
  },
  {
    name: 'Red Team',
    freq: 130,
    color: '#ff4444',
  },
  {
    name: 'Blue Team',
    freq: 131,
    color: '#3434fd',
  },
  {
    name: 'Common',
    freq: 85,
    color: '#1ecc43',
  },
  {
    name: 'Supply',
    freq: 86,
    color: '#b88646',
  },
  {
    name: 'Service',
    freq: 87,
    color: '#6ca729',
  },
  {
    name: 'Science',
    freq: 88,
    color: '#c68cfa',
  },
  {
    name: 'Command',
    freq: 89,
    color: '#5177ff',
  },
  {
    name: 'Medical',
    freq: 90,
    color: '#57b8f0',
  },
  {
    name: 'Engineering',
    freq: 91,
    color: '#f37746',
  },
  {
    name: 'Security',
    freq: 92,
    color: '#dd3535',
  },
  {
    name: 'Exploration',
    freq: 93,
    color: '#7ed4c2',
  },
  {
    name: 'AI Private',
    freq: 94,
    color: '#d65d95',
  },
  {
    name: 'CentCom',
    freq: 95,
    color: '#2681a5',
  },
] as const;

const GASES = [
  {
    id: 'o2',
    name: 'Oxygen',
    label: 'O₂',
    color: 'blue',
  },
  {
    id: 'n2',
    name: 'Nitrogen',
    label: 'N₂',
    color: 'yellow',
  },
  {
    id: 'co2',
    name: 'Carbon Dioxide',
    label: 'CO₂',
    color: 'grey',
  },
  {
    id: 'plasma',
    name: 'Plasma',
    label: 'Plasma',
    color: 'pink',
  },
  {
    id: 'water_vapor',
    name: 'Water Vapor',
    label: 'H₂O',
    color: 'lightsteelblue',
  },
  {
    id: 'nob',
    name: 'Hyper-noblium',
    label: 'Hyper-nob',
    color: 'teal',
  },
  {
    id: 'n2o',
    name: 'Nitrous Oxide',
    label: 'N₂O',
    color: 'bisque',
  },
  {
    id: 'no2',
    name: 'Nitrium',
    label: 'Nitrium',
    color: 'brown',
  },
  {
    id: 'tritium',
    name: 'Tritium',
    label: 'Tritium',
    color: 'limegreen',
  },
  {
    id: 'bz',
    name: 'BZ',
    label: 'BZ',
    color: 'mediumpurple',
  },
  {
    id: 'pluox',
    name: 'Pluoxium',
    label: 'Pluoxium',
    color: 'mediumslateblue',
  },
  {
    id: 'miasma',
    name: 'Miasma',
    label: 'Miasma',
    color: 'olive',
  },
  {
    id: 'Freon',
    name: 'Freon',
    label: 'Freon',
    color: 'paleturquoise',
  },
  {
    id: 'hydrogen',
    name: 'Hydrogen',
    label: 'H₂',
    color: 'white',
  },
  // Bee doesn't have most of these \/ - but having them for future proofing is useful. Nothing iterates this list.
  {
    id: 'healium',
    name: 'Healium',
    label: 'Healium',
    color: 'salmon',
  },
  {
    id: 'proto_nitrate',
    name: 'Proto Nitrate',
    label: 'Proto-Nitrate',
    color: 'greenyellow',
  },
  {
    id: 'zauker',
    name: 'Zauker',
    label: 'Zauker',
    color: 'darkgreen',
  },
  {
    id: 'halon',
    name: 'Halon',
    label: 'Halon',
    color: 'purple',
  },
  {
    id: 'helium',
    name: 'Helium',
    label: 'He',
    color: 'aliceblue',
  },
  {
    id: 'antinoblium',
    name: 'Antinoblium',
    label: 'Anti-Noblium',
    color: 'maroon',
  },
] as const;

// Returns gas label based on gasId
export const getGasLabel = (gasId: string, fallbackValue?: string) => {
  const gasSearchString = gasId.toLowerCase();
  const gas = GASES.find(
    (gas) =>
      gas.id === gasSearchString || gas.name.toLowerCase() === gasSearchString,
  );
  return gas?.label || fallbackValue || gasId;
};

// Returns gas color based on gasId
export const getGasColor = (gasId: string) => {
  const gasSearchString = gasId.toLowerCase();
  const gas = GASES.find(
    (gas) =>
      gas.id === gasSearchString || gas.name.toLowerCase() === gasSearchString,
  );
  return gas?.color;
};

/*
From https://github.com/tgstation/tgstation/pull/69240

PLEASE enable the tests in constants.test.ts if you port this

// Returns gas object based on gasId
export const getGasFromId = (gasId: string): Gas | undefined => {
  const gasSearchString = gasId.toLowerCase();
  const gas = GASES.find(
    (gas) =>
      gas.id === gasSearchString || gas.name.toLowerCase() === gasSearchString
  );
  return gas;
};

// Returns gas object based on gasPath
export const getGasFromPath = (gasPath: string): Gas | undefined => {
  return GASES.find((gas) => gas.path === gasPath);
};
*/
