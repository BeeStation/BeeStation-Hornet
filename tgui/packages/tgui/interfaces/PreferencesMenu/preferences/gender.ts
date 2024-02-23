export enum Gender {
  Male = 'male',
  Female = 'female',
  Other = 'plural',
  FuckYouByondYouMadeNeuterTerribleToUseAndNowIGottaSufferBecauseOfItIHateItSoMuchInHere = 'neuter',
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

  [Gender.Other2]: {
    icon: 'bullseye',
    text: 'It/Its',
  },
};
