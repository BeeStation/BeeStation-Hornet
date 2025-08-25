import {
  contrast,
  hexToHsva,
  hexToRgba,
  HsvaColor,
  hsvaToHex,
  RgbColor,
} from 'common/color';
import { BooleanLike } from 'common/react';

import { useBackend, useLocalState } from '../backend';
import {
  Autofocus,
  Box,
  BufferedTextArea,
  Button,
  Collapsible,
  ColorBox,
  Dimmer,
  Flex,
  Icon,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
  Stack,
  Tabs,
  Tooltip,
} from '../components';
import { Window } from '../layouts';
import { ColorSelector } from './ColorPickerModal';
import {
  Ability,
  AbilityThreshold,
  AvailableAbilities,
  is_actually_a_threshold,
  sort_abilities,
  sort_thresholds,
  StatThreshold,
  threshold_title,
} from './common/Holoparasite';

/**
 * The validity of an input field.
 */
enum Validity {
  /**
   * The given input is valid.
   */
  Valid = 'valid',
  /**
   * The given input is invalid due to being blank.
   */
  Blank = 'blank',
  /**
   * The given input is invalid due to being too long.
   */
  TooLong = 'too long',
  /**
   * The given input is an invalid name.
   */
  Invalid = 'invalid',
  /**
   * The given input is invalid due to violating the server's filter.
   */
  FilterViolation = 'filtered',
  /**
   * The given color input is invalid due to being too dark.
   */
  TooDark = 'too dark',
}

/**
 * The current tab of the abilities section.
 */
enum AbilityTab {
  Major,
  Lesser,
  Weapons,
}

type Skill = {
  /**
   * The name of the skill.
   */
  name: string;
  /**
   * The description of the skill.
   */
  desc: string;
  /**
   * The UI icon to be displayed alongside the skill.
   */
  icon?: string;
  /**
   * The chosen level of the skill.
   */
  level: number;
};

type Validation = {
  /**
   * The validity of the holoparasite's accent color..
   */
  color: Validity;
  /**
   * The validity of the holoparasite's custom name.
   */
  name: Validity;
  /**
   * The validity of the holoparasite's notes.
   */
  notes: Validity;
};

type MaxLengths = {
  /**
   * The maximum length of the holoparasite's custom name.
   */
  name: number;
  /**
   * The maximum length of the holoparasite's notes.
   */
  notes: number;
};

type Info = {
  /**
   * The custom name of the holoparasite, chosen by the user.
   */
  custom_name: string;
  /**
   * The hex color of the accent color for the holoparasite, chosen by the user.
   */
  accent_color: string;
  /**
   * The "themed" name of the holoparasite.
   */
  themed_name: string;
  /**
   * The notes for the holoparasite, chosen by the user.
   */
  notes: string;
  /**
   * Whether the creator is currently waiting on something or not.
   */
  waiting: BooleanLike;
  /**
   * Whether the creator has been used or not.
   */
  used: BooleanLike;
  /**
   * The amount of points available to spend.
   */
  points: number;
  /**
   * The maximum amount of points that can be spent.
   */
  max_points: number;
  /**
   * The maximum level stats can be.
   */
  max_level: number;
  /**
   * Whether a major ability has been chosen or not.
   */
  no_ability: BooleanLike;
  /**
   * If a weapon is being forced, this is the path to said weapon.
   */
  forced_weapon?: string;
  /**
   * A list of all ability typepaths that have been selected.
   */
  selected_abilities: string[];
  /**
   * The skills available to choose, and their current level.
   */
  rated_skills: Skill[];
  /**
   * Data about what abilities are available to choose.
   */
  abilities: AvailableAbilities;
  /**
   * Validation checks for certain fields.
   */
  validation: Validation;
  /**
   * The maximum lengths of certain fields.
   */
  max_lengths: MaxLengths;
};

const is_threshold_met = (
  thresholds: StatThreshold[],
  skills: Skill[],
): boolean => {
  for (const threshold of thresholds) {
    if (threshold.minimum === undefined) {
      continue;
    }
    const stat = skills.find((skill: Skill) => skill.name === threshold.name);
    if (stat === undefined || stat.level < threshold.minimum) {
      return false;
    }
  }
  return true;
};

/**
 * The background colors for dark/light mode chat, used for calculating the contrast of the accent color.
 */
const chat_background_colors = {
  dark: { r: 23, g: 23, b: 23 } as RgbColor,
  light: { r: 255, g: 255, b: 255 } as RgbColor,
};
/**
 * The minimum recommended contrast for accent colors, to ensure that they are readable in chat (a value of 4.5:1).
 */
const minimum_recommended_contrast = 0.14285;

const InputValidity = (props: { field: string; validity: Validity }) => {
  const {
    data: { themed_name },
  } = useBackend<Info>();
  const is_are = props.field.endsWith('s') ? 'are' : 'is';
  switch (props.validity) {
    case Validity.Valid: {
      return (
        <Tooltip
          content={
            <>
              The chosen {props.field} {is_are} <b>valid</b>, and can be used
              for your {themed_name}.
            </>
          }
        >
          <Icon name="smile" color="green" />
        </Tooltip>
      );
    }
    case Validity.Blank: {
      return (
        <Tooltip
          content={
            <>
              The chosen {props.field} {is_are} <b>blank</b>, and you will not
              be able to summon your {themed_name} with this value!
            </>
          }
        >
          <Icon name="exclamation-triangle" color="yellow" />
        </Tooltip>
      );
    }
    case Validity.TooLong: {
      return (
        <Tooltip
          content={
            <>
              The chosen {props.field} {is_are} <b>too long</b>, and you will
              not be able to summon your {themed_name} with this value!
            </>
          }
        >
          <Icon name="exclamation-triangle" color="yellow" />
        </Tooltip>
      );
    }
    case Validity.Invalid: {
      return (
        <Tooltip
          content={
            <>
              The chosen {props.field} {is_are} <b>invalid</b>, and you will not
              be able to summon your {themed_name} with this value!
            </>
          }
        >
          <Icon name="exclamation-triangle" color="red" />
        </Tooltip>
      );
    }
    case Validity.FilterViolation: {
      return (
        <Tooltip
          content={
            <>
              The chosen {props.field} contains <b>filtered phrases</b>, and you
              will not be able to summon your {themed_name} with this value!
            </>
          }
        >
          <Icon name="exclamation-triangle" color="red" />
        </Tooltip>
      );
    }
    case Validity.TooDark: {
      return (
        <Tooltip content={<>The chosen {props.field} is too dark!</>}>
          <Icon name="exclamation-triangle" color="red" />
        </Tooltip>
      );
    }
    default: {
      return null;
    }
  }
};

const BasicNameInput = (_props) => {
  const {
    act,
    data: { custom_name, max_lengths, themed_name, validation },
  } = useBackend<Info>();
  const set_name = (_, name: string) => {
    act('set:name', { name: name });
  };
  return (
    <Stack
      style={{
        verticalAlign: 'middle',
      }}
    >
      <Stack.Item grow>
        <Input
          value={custom_name}
          maxLength={max_lengths.name}
          placeholder={`${themed_name} Name`}
          width="100%"
          onChange={set_name}
          onInput={set_name}
        />
      </Stack.Item>
      <Stack.Item>
        <InputValidity field="name" validity={validation.name} />
      </Stack.Item>
    </Stack>
  );
};

const BasicColorInput = (_props) => {
  const {
    data: { accent_color, validation },
  } = useBackend<Info>();
  const [_color_select, set_color_select] = useLocalState<HsvaColor | null>(
    'color_select',
    null,
  );
  const accent_color_rgb = hexToRgba(accent_color);
  // these are reversed and I'm too lazy to figure out why
  const light_mode_contrast = contrast(
    chat_background_colors.light,
    accent_color_rgb,
  );
  const dark_mode_contrast = contrast(
    chat_background_colors.dark,
    accent_color_rgb,
  );
  return (
    <Stack
      style={{
        verticalAlign: 'middle',
      }}
    >
      <Stack.Item grow>
        <ColorBox
          color={accent_color}
          onClick={() => set_color_select(hexToHsva(accent_color))}
        />
      </Stack.Item>
      <Stack.Item>
        <InputValidity field="accent color" validity={validation.color} />
      </Stack.Item>
      {dark_mode_contrast < minimum_recommended_contrast && (
        <Stack.Item>
          <Tooltip
            content={`This color may be difficult to read with light mode chat!`}
          >
            <Icon name="eye-slash" color="white" />
          </Tooltip>
        </Stack.Item>
      )}
      {light_mode_contrast < minimum_recommended_contrast && (
        <Stack.Item>
          <Tooltip
            content={`This color may be difficult to read with dark mode chat!`}
          >
            <Icon name="eye-slash" color="grey" />
          </Tooltip>
        </Stack.Item>
      )}
    </Stack>
  );
};

const BasicColorSelector = (_props) => {
  const {
    act,
    data: { accent_color },
  } = useBackend<Info>();
  const [color_select, set_color_select] = useLocalState<HsvaColor | null>(
    'color_select',
    hexToHsva(accent_color),
  );
  return (
    <Section fill title="Accent Color Selection">
      <Stack fill vertical>
        <Stack.Item grow>
          <Autofocus />
          <ColorSelector
            color={color_select!}
            setColor={set_color_select}
            defaultColor={accent_color}
          />
        </Stack.Item>
        <Stack.Item>
          <Flex align="center" direction="row" fill justify="space-around">
            <Flex.Item grow>
              <Button
                color="good"
                fluid
                height={2}
                onClick={() => {
                  act('set:color', { color: hsvaToHex(color_select!) });
                  set_color_select(null);
                }}
                m={0.5}
                pl={2}
                pr={2}
                pt={0.33}
                disabled={color_select!.v < 50}
                tooltip={color_select!.v < 50 && 'Selected color too dark!'}
                textAlign="center"
              >
                Submit
              </Button>
            </Flex.Item>
            <Flex.Item grow>
              <Button
                color="bad"
                fluid
                height={2}
                onClick={() => set_color_select(null)}
                m={0.5}
                pl={2}
                pr={2}
                pt={0.33}
                textAlign="center"
              >
                Cancel
              </Button>
            </Flex.Item>
          </Flex>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const BasicPointsInfo = (_props) => {
  const {
    data: { points, max_points, themed_name },
  } = useBackend<Info>();
  return (
    <Stack
      style={{
        verticalAlign: 'middle',
      }}
    >
      <Stack.Item grow>
        <ProgressBar
          value={points}
          maxValue={max_points}
          ranges={{
            bad: [-Infinity, -1],
            good: [0, 0],
            yellow: [1, max_points / 2],
            orange: [max_points / 2, max_points - 1],
            red: [max_points, Infinity],
          }}
        >
          {points.toLocaleString()} / {max_points.toLocaleString()} points
        </ProgressBar>
      </Stack.Item>
      {points < 0 && (
        <Stack.Item>
          <Tooltip
            content={
              <>
                You will not be able to summon your {themed_name} with{' '}
                <b>negative points</b>!
              </>
            }
          >
            <Icon name="exclamation-triangle" color="orange" />
          </Tooltip>
        </Stack.Item>
      )}
      {points > 0 && max_points < 99 && (
        <Stack.Item>
          <Tooltip
            content={
              <>
                You have not used all your points yet, you have{' '}
                <b>{points.toLocaleString()} points</b> left to spend!
              </>
            }
          >
            <Icon name="exclamation-triangle" color="yellow" />
          </Tooltip>
        </Stack.Item>
      )}
    </Stack>
  );
};

const BasicSection = (_props) => {
  const {
    act,
    data: { themed_name, points, max_points, validation },
  } = useBackend<Info>();
  const [_unused_points_dialog, set_unused_points_dialog] =
    useLocalState<boolean>('unused_points_dialog', false);
  const manifest_disabled =
    points < 0 ||
    validation.name !== Validity.Valid ||
    validation.notes !== Validity.Valid;
  return (
    <Section fill title="Basic Info">
      <Stack fill vertical p={0.5}>
        <Stack.Item grow>
          <LabeledList>
            <LabeledList.Item label="Theme" className="candystripe">
              <b>{themed_name}</b>
            </LabeledList.Item>
            <LabeledList.Item label="Name" className="candystripe">
              <BasicNameInput />
            </LabeledList.Item>
            <LabeledList.Item label="Accent Color" className="candystripe">
              <BasicColorInput />
            </LabeledList.Item>
            <LabeledList.Item label="Points" className="candystripe">
              <BasicPointsInfo />
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          <Flex.Item align="center">
            <Box align="center">
              <Button
                content={`Manifest ${themed_name}`}
                disabled={manifest_disabled}
                tooltip={
                  manifest_disabled &&
                  `Some of the fields for your ${themed_name} are invalid!`
                }
                onClick={() => {
                  if (points > 0 && max_points < 99) {
                    set_unused_points_dialog(true);
                  } else {
                    act('spawn');
                  }
                }}
              />
            </Box>
          </Flex.Item>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const NotesSection = (_props) => {
  const {
    act,
    data: { themed_name, notes, max_lengths, validation },
  } = useBackend<Info>();
  return (
    <Section fill title="Notes">
      <Stack fill vertical p={0.5}>
        <Stack.Item>
          <Stack
            style={{
              verticalAlign: 'middle',
            }}
          >
            <Stack.Item>
              <InputValidity field="notes" validity={validation.notes} />
            </Stack.Item>
            <Stack.Item>
              <Box textAlign="justify" textColor="label">
                Notes will be displayed to your {themed_name}, and can be
                anything from alerting them to any tasks you wish to accomplish,
                the identities of any allies or enemies you may have, or
                explaining a gimmick you are attempting to roleplay, and can be
                IC, OOC, or a mixture of both.
              </Box>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow>
          <BufferedTextArea
            scrollbar
            maxLength={max_lengths.notes}
            placeholder={`Enter any notes for your ${themed_name} here!`}
            textColor="white"
            fluid
            height="100%"
            value={notes}
            updateValue={(value: string) => {
              act('set:notes', { notes: value });
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AbilityThresholds = (props: {
  title: string;
  thresholds: AbilityThreshold[];
}) => {
  const {
    data: { rated_skills, themed_name },
  } = useBackend<Info>();
  return (
    <Collapsible title={props.title}>
      <Stack vertical>
        {sort_thresholds(props.thresholds || []).map(
          (threshold: AbilityThreshold, index: number) => {
            return (
              <Stack.Item key={index}>
                <Section
                  title={threshold_title(threshold.stats)}
                  buttons={
                    is_actually_a_threshold(threshold) &&
                    (is_threshold_met(threshold.stats, rated_skills) ? (
                      <Tooltip
                        content={
                          <>
                            This threshold is{' '}
                            <Box inline bold color="good">
                              met
                            </Box>{' '}
                            by your current stats!
                          </>
                        }
                      >
                        <Icon name="smile" color="green" />
                      </Tooltip>
                    ) : (
                      <Tooltip
                        content={
                          <>
                            This threshold is{' '}
                            <Box inline bold color="bad">
                              not met
                            </Box>{' '}
                            by your current stats!
                          </>
                        }
                      >
                        <Icon name="exclamation-triangle" color="orange" />
                      </Tooltip>
                    ))
                  }
                >
                  <Box textAlign="justify" textColor="label">
                    {threshold.desc.replace(
                      '$theme',
                      themed_name.toLocaleLowerCase(),
                    )}
                  </Box>
                </Section>
              </Stack.Item>
            );
          },
        )}
      </Stack>
    </Collapsible>
  );
};

const Abilities = (props: {
  abilities: Ability[];
  on_click: (ability: Ability, selected: boolean) => void;
  only_path?: string;
}) => {
  const {
    data: { selected_abilities, themed_name },
  } = useBackend<Info>();
  const abilities = props.only_path
    ? (props.abilities || []).filter(
        (ability: Ability) => ability.path === props.only_path,
      )
    : (props.abilities || []).filter(
        (ability: Ability) =>
          !ability.hidden || selected_abilities.includes(ability.path),
      );
  return (
    <Stack vertical>
      {sort_abilities(abilities).map((ability: Ability, _index: number) => {
        const selected = selected_abilities.includes(ability.path);
        const [stat_thresholds, stat_info] = ability.thresholds.reduce(
          ([p, f], e) =>
            is_actually_a_threshold(e) ? [[...p, e], f] : [p, [...f, e]],
          [[], []],
        ); // from https://stackoverflow.com/a/47225591
        return (
          <Stack.Item key={ability.path} px={1}>
            <Section
              title={
                <>
                  {ability.icon && <Icon name={ability.icon} />}
                  <Box mx={ability.icon && 1} inline>
                    {ability.name}
                  </Box>
                </>
              }
              buttons={
                !props.only_path && (
                  <Button
                    content={
                      ability.cost > 0
                        ? `${ability.cost.toLocaleString()} points`
                        : 'Free'
                    }
                    selected={selected}
                    onClick={() => props.on_click(ability, selected)}
                  />
                )
              }
            >
              <Stack vertical>
                <Stack.Item>
                  <Box textAlign="justify" textColor="label">
                    {ability.desc.replace(
                      '$theme',
                      themed_name.toLocaleLowerCase(),
                    )}
                  </Box>
                </Stack.Item>
                {stat_info.length > 0 && (
                  <Stack.Item>
                    <AbilityThresholds
                      title="Stat Interactions"
                      thresholds={stat_info}
                    />
                  </Stack.Item>
                )}
                {stat_thresholds.length > 0 && (
                  <Stack.Item>
                    <AbilityThresholds
                      title="Stat Thresholds"
                      thresholds={stat_thresholds}
                    />
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

const MajorAbilitiesTab = (_props) => {
  const {
    act,
    data: {
      themed_name,
      abilities: { major },
    },
  } = useBackend<Info>();
  return (
    <Section fill scrollable>
      <Stack vertical>
        <Stack.Item>
          <Box textColor="label">
            Abilities allow your {themed_name} to assist you in unique, powerful
            ways. You may only have a single ability (or none), however.
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Abilities
            abilities={major}
            on_click={(ability: Ability, selected: boolean) => {
              if (selected) {
                act('ability:major:take');
              } else {
                act('ability:major:set', { path: ability.path });
              }
            }}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const LesserAbilitiesTab = (_props) => {
  const {
    act,
    data: {
      abilities: { lesser },
    },
  } = useBackend<Info>();
  return (
    <Section fill scrollable>
      <Stack vertical>
        <Stack.Item>
          <Box textColor="label">
            Lesser abilities are abilities that, while less powerful than major
            abilities, are typically cheaper. You can have multiple lesser
            abilities, in addition to being able to use them alongside a full
            ability.
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Abilities
            abilities={lesser}
            on_click={(ability: Ability, selected: boolean) =>
              act(`ability:lesser:${selected ? 'take' : 'add'}`, {
                path: ability.path,
              })
            }
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const WeaponsTab = (_props) => {
  const {
    act,
    data: {
      abilities: { weapons },
      forced_weapon,
      themed_name,
    },
  } = useBackend<Info>();
  return (
    <Section fill scrollable>
      <Stack vertical>
        <Stack.Item>
          <Box textColor="label">
            Weapons are abilities determine through what method your{' '}
            {themed_name} will attack people. You may only have a single weapon
            at any given time.
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Abilities
            abilities={weapons}
            on_click={(ability: Ability, _selected: boolean) =>
              act('ability:weapon:set', { path: ability.path })
            }
            only_path={forced_weapon}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const StatsSection = (_props) => {
  const { act, data } = useBackend<Info>();
  return (
    <Section fill title="Stats">
      <Stack fill vertical>
        <Stack.Item grow>
          {(data.rated_skills || []).map((skill: Skill, _index: number) => {
            const set_skill = (_, value: number) => {
              act('set:stat', {
                stat: skill.name,
                level: value,
              });
            };
            return (
              <Flex inline width="300px" key={skill.name} mx={0.25} px={1}>
                <Flex.Item>
                  <Box>
                    <Section
                      width="300px"
                      title={skill.name}
                      className="candystripe"
                    >
                      <Stack fill vertical>
                        <Stack.Item>
                          <Box textAlign="justify" textColor="label">
                            {skill.desc.replace(
                              '$theme',
                              data.themed_name.toLocaleLowerCase(),
                            )}
                          </Box>
                        </Stack.Item>
                        <Stack.Item textAlign="center">
                          <Slider
                            value={skill.level}
                            step={1}
                            maxValue={data.max_level}
                            minValue={1}
                            stepPixelSize={150 / data.max_level}
                            width="150px"
                            ranges={{
                              red: [-Infinity, 2],
                              yellow: [2, 3],
                              green: [4, Infinity],
                            }}
                            onChange={set_skill}
                            onDrag={set_skill}
                          />
                        </Stack.Item>
                      </Stack>
                    </Section>
                  </Box>
                </Flex.Item>
              </Flex>
            );
          })}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AbilitiesTabs = (_props) => {
  const [tab, set_tab] = useLocalState<AbilityTab>('tab', AbilityTab.Major);
  return (
    <Section fill pb={6}>
      <Tabs>
        <Tabs.Tab
          icon="magic"
          selected={tab === AbilityTab.Major}
          onClick={() => set_tab(AbilityTab.Major)}
        >
          Abilities
        </Tabs.Tab>
        <Tabs.Tab
          icon="cog"
          selected={tab === AbilityTab.Lesser}
          onClick={() => set_tab(AbilityTab.Lesser)}
        >
          Lesser Abilities
        </Tabs.Tab>
        <Tabs.Tab
          icon="bolt"
          selected={tab === AbilityTab.Weapons}
          onClick={() => set_tab(AbilityTab.Weapons)}
        >
          Weapons
        </Tabs.Tab>
      </Tabs>
      {tab === AbilityTab.Major && <MajorAbilitiesTab />}
      {tab === AbilityTab.Lesser && <LesserAbilitiesTab />}
      {tab === AbilityTab.Weapons && <WeaponsTab />}
    </Section>
  );
};

const ResetButton = (_props) => {
  const {
    data: { used, waiting, themed_name },
  } = useBackend<Info>();
  const [unused_points_dialog] = useLocalState<boolean>(
    'unused_points_dialog',
    false,
  );
  const [reset_dialog, set_reset_dialog] = useLocalState<boolean>(
    'reset_dialog',
    false,
  );
  return (
    <Button
      icon="undo"
      content="Reset"
      tooltip={`Reset the stats and abilities you have chosen for your ${themed_name}, allowing you to work from a blank slate again.`}
      tooltipPosition="bottom"
      disabled={reset_dialog || unused_points_dialog || !!used || !!waiting}
      onClick={() => set_reset_dialog(true)}
    />
  );
};

const WaitingDialog = (_props) => {
  const {
    data: { themed_name, waiting },
  } = useBackend<Info>();
  return waiting ? (
    <Dimmer fontSize="32px">
      <Stack align="center" fill justify="center" vertical>
        <Stack.Item>
          <Icon name="cog" spin />
        </Stack.Item>
        <Stack.Item>{`Attempting to manifest your ${themed_name}. Please wait...`}</Stack.Item>
      </Stack>
    </Dimmer>
  ) : null;
};

const UsedDialog = (_props) => {
  const {
    data: { used, themed_name },
  } = useBackend<Info>();
  return used ? (
    <Dimmer fontSize="32px">
      <Stack align="center" fill justify="center" vertical>
        <Stack.Item>
          <Icon name="exclamation-triangle" color="orange" />
        </Stack.Item>
        <Stack.Item>{`This ${themed_name} manifestation apparatus has already been used.`}</Stack.Item>
      </Stack>
    </Dimmer>
  ) : null;
};

const ResetDialog = (_props) => {
  const { act } = useBackend<Info>();
  const [reset_dialog, set_reset_dialog] = useLocalState<boolean>(
    'reset_dialog',
    false,
  );
  return reset_dialog ? (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack.Item>
          <Stack ml={-2}>
            <Stack.Item>
              <Icon color="red" name="trash" size={10} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item fontSize="18px" textAlign="center">
          Are you sure you want to reset{' '}
          <b>all of your chosen stats and abilities</b>?
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Button
                color="good"
                content="Keep"
                onClick={() => {
                  set_reset_dialog(false);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                color="bad"
                content="Reset"
                onClick={() => {
                  act('reset');
                  set_reset_dialog(false);
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Dimmer>
  ) : null;
};

const UnusedPointsDialog = (_props) => {
  const {
    act,
    data: { points, themed_name },
  } = useBackend<Info>();
  const [unused_points_dialog, set_unused_points_dialog] =
    useLocalState<boolean>('unused_points_dialog', false);
  return unused_points_dialog ? (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack.Item>
          <Stack ml={-2}>
            <Stack.Item>
              <Icon color="yellow" name="exclamation-triangle" size={10} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item fontSize="18px">
          <Stack vertical textAlign="center">
            <Stack.Item>
              You have <b>{points.toLocaleString()} unused points</b>!
            </Stack.Item>
            <Stack.Item>
              Are you <i>sure</i> you would like to summon your {themed_name}{' '}
              without having allocated all of your points?
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Button
                color="good"
                content="Go Back"
                onClick={() => {
                  set_unused_points_dialog(false);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                color="bad"
                content="Continue Anyways"
                onClick={() => {
                  act('spawn');
                  set_unused_points_dialog(false);
                }}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Dimmer>
  ) : null;
};

export const HoloparasiteBuilder = (_props) => {
  const [color_select] = useLocalState<HsvaColor | null>('color_select', null);
  return (
    <Window theme="generic" width={1000} height={960} buttons={<ResetButton />}>
      <Window.Content>
        <WaitingDialog />
        <UsedDialog />
        <ResetDialog />
        <UnusedPointsDialog />
        <Stack fill vertical>
          <Stack.Item height={color_select ? '340px' : '200px'}>
            <Stack fill grow>
              <Stack.Item grow width="40%">
                {color_select ? <BasicColorSelector /> : <BasicSection />}
              </Stack.Item>
              <Stack.Item grow width="60%">
                <NotesSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item height="30%">
            <StatsSection />
          </Stack.Item>
          <Stack.Item grow>
            <AbilitiesTabs />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
