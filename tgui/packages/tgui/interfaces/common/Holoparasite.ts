import { sortBy } from 'common/collections';
import { BooleanLike } from 'common/react';

export type StatThreshold = {
  /**
   * The name of the stat.
   */
  name: string;
  /**
   * The minimum value of the stat for the threshold to be met.
   * If not set, this is assumed to be a description of how a stat affects an ability in general,
   * rather than a specific threshold.
   */
  minimum?: number;
};

export type AbilityThreshold = {
  /**
   * Description of the stat(s) that the threshold applies to.
   */
  stats: StatThreshold[];
  /**
   * A description of what the threshold does.
   */
  desc: string;
};

export type Ability = {
  /**
   * The name of the ability.
   */
  name: string;
  /**
   * A description describing the ability.
   */
  desc: string;
  /**
   * The UI icon to be displayed alongside the ability, if any.
   */
  icon?: string;
  /**
   * The typepath of the ability.
   */
  path: string;
  /**
   * The point cost of the ability.
   */
  cost: number;
  /**
   * Whether the ability is normally hidden from the UI (unless selected) or not.
   */
  hidden: BooleanLike;
  /**
   * A list of stat thresholds and interactions that the ability has, if any.
   */
  thresholds: AbilityThreshold[];
};

export type AvailableAbilities = {
  /**
   * A list of all available major abilities.
   */
  major: Ability[];
  /**
   * A list of all available lesser abilities.
   */
  lesser: Ability[];
  /**
   * A list of all available weapons.
   */
  weapons: Ability[];
};

export type GivenAbilities = {
  /**
   * The (optional) major ability that the holoparasite has.
   */
  major?: Ability;
  /**
   * A list of all lesser abilities that the holoparasite has.
   */
  lesser?: Ability[];
  /**
   * The weapon that the holoparasite has.
   */
  weapon: Ability;
};

export const is_actually_a_threshold = (ability: AbilityThreshold): boolean =>
  ability.stats.some((stat: StatThreshold) => stat.minimum !== undefined);

export const threshold_title = (thresholds: StatThreshold[]): string => {
  let result: string[] = [];
  for (const threshold of thresholds) {
    if (threshold.minimum === undefined) {
      result.push(threshold.name);
      continue;
    }
    result.push(`${threshold.name} ${threshold.minimum.toLocaleString()}`);
  }
  return result.join(', ');
};

export const sort_thresholds = (thresholds: AbilityThreshold[]) =>
  sortBy(
    thresholds,
    (threshold: AbilityThreshold) =>
      threshold.stats.map((stat: StatThreshold) => stat.name).join(', '),
    (threshold: AbilityThreshold) =>
      threshold.stats
        .map((stat: StatThreshold) => stat.minimum)
        .reduce((sum: number, min: number) => (sum || 0) + min) || 0,
  );

export const sort_abilities = (abilities: Ability[]) =>
  sortBy(abilities, (ability: Ability) => ability.name);
