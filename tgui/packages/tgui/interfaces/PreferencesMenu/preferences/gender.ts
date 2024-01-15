export enum Gender {
  Male = 'male',
  Female = 'female',
  Other = 'plural',
  Neutral = 'neutral',
}

export const GENDERS = {
  [Gender.Male]: {
    icon: 'male',
    text: 'Male',
  },

  [Gender.Female]: {
    icon: 'female',
    text: 'Female',
  },

  [Gender.Other]: {
    icon: 'tg-non-binary',
    text: 'They/Them',
  },

  [Gender.Neutral]: {
    icon: 'bullseye',
    text: 'It/Its',
  },
};
