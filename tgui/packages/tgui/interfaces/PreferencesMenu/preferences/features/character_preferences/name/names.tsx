import { Feature, TextButtonInput } from '../../base';

export const real_name: Feature<string> = {
  name: 'Real name',
  tooltip: "Your character's name.",
  component: TextButtonInput,
};

export const human_name: Feature<string> = {
  name: "Alt' Human name",
  tooltip: 'In specific cases, this name is used instead of your real name.',
  component: TextButtonInput,
};

export const clown_name: Feature<string> = {
  name: 'Clown name',
  tooltip: "Clown's stage name. Overrides over real name when you get a clown job.",
  component: TextButtonInput,
};

export const mime_name: Feature<string> = {
  name: 'Mime name',
  tooltip: "Mime's stage name. Overrides over real name when you get a mime job.",
  component: TextButtonInput,
};

export const cyborg_name: Feature<string> = {
  name: 'Cyborg name',
  tooltip: 'Used when you are a cyborg rather than a human.',
  component: TextButtonInput,
};

export const ai_name: Feature<string> = {
  name: 'AI name',
  tooltip: 'Same as the cyborg name, but when you are an AI.',
  component: TextButtonInput,
};

export const religion_name: Feature<string> = {
  name: 'Religion name',
  tooltip: "The name of your religion. This does nothing ingame, thus it's mostly flavourful.",
  component: TextButtonInput,
};

export const deity_name: Feature<string> = {
  name: 'Deity name',
  tooltip: "The deity's name of your religion. This does nothing ingame, thus it's mostly flavourful.",
  component: TextButtonInput,
};

export const bible_name: Feature<string> = {
  name: 'Bible name',
  tooltip: "The deity's name of your religion. This does nothing ingame, thus it's mostly flavourful.",
  component: TextButtonInput,
};
