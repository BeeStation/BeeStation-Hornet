export enum Gender {
  Male = 'male',
  Female = 'female',
  Other = 'plural',
}

export const GENDERS = {
  [Gender.Male]: {
    icon: 'male',
    text: 'He/Him',
  },

  [Gender.Female]: {
    icon: 'female',
    text: 'She/Her',
  },

  [Gender.Other]: {
    icon: 'tg-non-binary',
    text: 'They/Them',
  },
};
