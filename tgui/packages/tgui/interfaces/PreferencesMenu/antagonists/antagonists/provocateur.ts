import { Antagonist, Category } from '../base';
import { multiline } from 'common/string';
import { REVOLUTIONARY_MECHANICAL_DESCRIPTION } from './headrevolutionary';

const Provocateur: Antagonist = {
  key: 'provocateur',
  name: 'Provocateur',
  description: [
    multiline`
      A form of head revolutionary that can activate when joining an ongoing
      shift.
    `,

    REVOLUTIONARY_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Latejoin,
};

export default Provocateur;
