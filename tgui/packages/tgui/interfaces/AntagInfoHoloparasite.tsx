import { BooleanLike } from 'common/react';
import { sanitizeText } from 'tgui/sanitize';

import { useBackend, useLocalState } from '../backend';
import {
  BlockQuote,
  Box,
  Collapsible,
  ColorBox,
  Flex,
  Icon,
  LabeledList,
  RadarChart,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';
import {
  Ability,
  AbilityThreshold,
  GivenAbilities,
  is_actually_a_threshold,
  sort_abilities,
  sort_thresholds,
  threshold_title,
} from './common/Holoparasite';

/**
 * The current tab of the summoner info section.
 */
enum SummonerTab {
  Notes,
  Objectives,
  Allies,
  ExtraInfo,
}

type Objective = {
  /**
   * The number objective this is (in order of the objectives list).
   */
  count: number;
  /**
   * The name of the objective.
   */
  name: string;
  /**
   * The explanation text of the objective.
   */
  explanation: string;
  /**
   * Whether the objective is complete or not.
   */
  complete: BooleanLike;
  /**
   * Whether the objective is optional or not.
   */
  optional: BooleanLike;
};

/**
 * A list of teams that the summoner is on, and the allies on each team.
 */
type SummonerAntagAllies = {
  readonly [index: string]: string[];
};

/**
 * "Extra info" about the summoner's antagonist status.
 */
type SummonerAntagExtraInfo = {
  readonly [index: string]: string;
};

/**
 * Information about the summoner's antagonist status.
 */
type SummonerAntag = {
  /**
   * "Extra info" about the summoner's antagonist status.
   */
  extra_info?: SummonerAntagExtraInfo;
  /**
   * A list of any antagonist allies that are on the same team as the summoner.
   */
  allies?: SummonerAntagAllies;
  /**
   * The summoner's objectives, if there are any.
   */
  objectives?: Objective[];
};

type Summoner = {
  /**
   * The summoner's name.
   */
  name: string;
  /**
   * The summoner's "special role", set in their mind.
   */
  special_role?: string;
  /**
   * Information about the summoner's antagonist status.
   */
  antag_info?: SummonerAntag;
};

type Stats = {
  /**
   * The Damage stat of the holoparasite, which affects the damage of the holoparasite's attacks.
   */
  damage: number;
  /**
   * The Defense stat of the holoparasite, which affects the damage the holoparasite absorbs vs how much it transfers to the summoner.
   */
  defense: number;
  /**
   * The Speed stat of the holoparasite, which affects the speed of the holoparasite's attacks.
   */
  speed: number;
  /**
   * The Potential stat of the holoparasite, which affects various aspects of the holoparasite's abilities.
   */
  potential: number;
  /**
   * The Range stat of the holoparasite, which affects how far the holoparasite can be from the summoner before it is recalled.
   */
  range: number;
};

type Info = {
  /**
   * Information about the summoner.
   */
  summoner: Summoner;
  /**
   * Notes for the holoparasite, set by the summoner.
   */
  notes?: string;
  /**
   * The battlecry of the holoparasite.
   */
  battlecry?: string;
  /**
   * The holoparasite's stats.
   */
  stats: Stats;
  /**
   * The name of the holoparasite.
   */
  name: string;
  /**
   * The name of the holoparasite's theme.
   */
  themed_name: string;
  /**
   * The accent color of the holoparasite, in RGB hex format.
   */
  accent_color: string;
  /**
   * The abilities given to the holoparasite.
   */
  abilities: GivenAbilities;
};

const BasicInfo = (_props) => {
  const { data } = useBackend<Info>();
  return (
    <Section fill title="Basic Info">
      <LabeledList>
        <LabeledList.Item label="Theme">{data.themed_name}</LabeledList.Item>
        <LabeledList.Item label="Name">{data.name}</LabeledList.Item>
        <LabeledList.Item label="Battlecry">
          {data.battlecry || '(none)'}
        </LabeledList.Item>
        <LabeledList.Item label="Accent Color">
          <ColorBox color={data.accent_color} />
        </LabeledList.Item>
        <LabeledList.Item label="Summoner">
          {data.summoner.name}
        </LabeledList.Item>
        {!!data.summoner.special_role && (
          <LabeledList.Item label="Summoner Role">
            {data.summoner.special_role}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

const ObjectiveInfo = (_props) => {
  const { data } = useBackend<Info>();
  const objectives = data.summoner.antag_info?.objectives;
  if (!objectives) {
    return null;
  }
  return (
    <Section scrollable>
      <Stack vertical height="115px">
        <Stack.Item bold>Your summoner&apos;s current objectives:</Stack.Item>
        {objectives.map((objective) => (
          <Stack.Item key={objective.count}>
            #{objective.count}:{' '}
            {!!objective.optional && (
              <Box inline textColor="green">
                Optional:
              </Box>
            )}{' '}
            <span
              // eslint-disable-next-line react/no-danger
              dangerouslySetInnerHTML={{
                __html: sanitizeText(objective.explanation, false),
              }}
            />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const ExtraInfo = (_props) => {
  const { data } = useBackend<Info>();
  const extra_info = data.summoner.antag_info?.extra_info;
  if (!extra_info) {
    return null;
  }
  return (
    <Section scrollable>
      <LabeledList>
        {Object.keys(extra_info).map((key) => {
          const value = extra_info[key];
          return (
            <LabeledList.Item key={key} label={key}>
              {value}
            </LabeledList.Item>
          );
        })}
      </LabeledList>
    </Section>
  );
};

const Notes = (_props) => {
  const {
    data: { notes },
  } = useBackend<Info>();
  if (!notes || notes.length === 0) {
    return (
      <Section>
        <Box color="label" textAlign="center">
          Your summoner hasn&apos;t left any notes for you.
        </Box>
      </Section>
    );
  }
  return (
    <Section fill height="90%" scrollable>
      <Stack vertical>
        <Stack.Item>
          <Box color="label" textAlign="center">
            Your summoner has left these notes for you:
          </Box>
        </Stack.Item>
        <Stack.Item>
          <BlockQuote style={{ textOverflow: 'wrap' }} width="100%">
            {notes}
          </BlockQuote>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AntagInfo = (props: { antag_info: SummonerAntag }) => {
  const {
    antag_info: { objectives, allies, extra_info },
  } = props;
  const [tab, set_tab] = useLocalState<SummonerTab>(
    'summoner_tab',
    SummonerTab.Notes,
  );
  return (
    <>
      {!!objectives && (
        <Tabs.Tab
          icon="clipboard-list"
          selected={tab === SummonerTab.Objectives}
          onClick={() => set_tab(SummonerTab.Objectives)}
        >
          Objectives
        </Tabs.Tab>
      )}
      {!!allies && (
        <Tabs.Tab
          icon="users"
          selected={tab === SummonerTab.Allies}
          onClick={() => set_tab(SummonerTab.Allies)}
        >
          Allies
        </Tabs.Tab>
      )}
      {!!extra_info && (
        <Tabs.Tab
          icon="mask"
          selected={tab === SummonerTab.ExtraInfo}
          onClick={() => set_tab(SummonerTab.ExtraInfo)}
        >
          Extra Info
        </Tabs.Tab>
      )}
    </>
  );
};

const SummonerInfo = (_props) => {
  const {
    data: { summoner },
  } = useBackend<Info>();
  const [tab, set_tab] = useLocalState<SummonerTab>(
    'summoner_tab',
    SummonerTab.Notes,
  );
  return (
    <Section fill title="Summoner Info">
      <Tabs m={-1}>
        <Tabs.Tab
          icon="sticky-note"
          selected={tab === SummonerTab.Notes}
          onClick={() => set_tab(SummonerTab.Notes)}
        >
          Notes
        </Tabs.Tab>
        {!!summoner.antag_info && (
          <AntagInfo antag_info={summoner.antag_info} />
        )}
      </Tabs>
      {tab === SummonerTab.Notes && <Notes />}
      {!!summoner.antag_info?.objectives && tab === SummonerTab.Objectives && (
        <ObjectiveInfo />
      )}
      {!!summoner.antag_info?.extra_info && tab === SummonerTab.ExtraInfo && (
        <ExtraInfo />
      )}
    </Section>
  );
};

const StatBox = (props: {
  name: string;
  description: string;
  value: number;
}) => {
  const { data } = useBackend<Info>();
  const { name, description, value } = props;
  return (
    <Flex inline width="300px" mx={0.25} px={1}>
      <Flex.Item>
        <Box>
          <Section width="300px" title={name} className="candystripe">
            <Stack fill vertical>
              <Stack.Item>
                <Box textAlign="justify" textColor="label">
                  {description.replace(
                    '$theme',
                    data.themed_name.toLocaleLowerCase(),
                  )}
                </Box>
              </Stack.Item>
              <Stack.Item textAlign="center">
                <Box
                  inline
                  color={value >= 4 ? 'green' : value >= 2 ? 'yellow' : 'red'}
                >
                  {value}
                </Box>{' '}
                / 5
              </Stack.Item>
            </Stack>
          </Section>
        </Box>
      </Flex.Item>
    </Flex>
  );
};

const StatsSection = (_props) => {
  const { data } = useBackend<Info>();
  const { stats } = data;
  return (
    <Section>
      <Stack vertical>
        <Stack.Item>
          <StatBox
            name="Damage"
            description="Amount of damage you can deal per hit."
            value={stats.damage}
          />
          <StatBox
            name="Defense"
            description="Amount of damage you can negate, rather than transferring the entirety of it to the summoner."
            value={stats.defense}
          />
          <StatBox
            name="Speed"
            description="How fast you can move and attack targets"
            value={stats.speed}
          />
          <StatBox
            name="Potential"
            description="Does nothing on its own, but it boosts the power of your abilities in various ways, although other stats can do so as well."
            value={stats.potential}
          />
          <StatBox
            name="Range"
            description="How far you can travel from your summoner before being forcefully snapped back to the summoner's position."
            value={stats.range}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const StatsChartSection = (_props) => {
  const { data } = useBackend<Info>();
  const { accent_color, stats } = data;
  return (
    <RadarChart
      axes={['Damage', 'Defense', 'Speed', 'Potential', 'Range']}
      stages={['1', '2', '3', '4', '5']}
      values={[
        stats.damage,
        stats.defense,
        stats.speed,
        stats.potential,
        stats.range,
      ]}
      areaColor={accent_color}
      width={300}
      height={300}
    />
  );
};

const AbilityThresholds = (props: {
  title: string;
  thresholds: AbilityThreshold[];
}) => {
  const { data } = useBackend<Info>();
  return (
    <Collapsible title={props.title}>
      <Stack vertical>
        {sort_thresholds(props.thresholds || []).map(
          (threshold: AbilityThreshold, index: number) => {
            return (
              <Stack.Item key={index}>
                <Section title={threshold_title(threshold.stats)}>
                  <Box textAlign="justify" textColor="label">
                    {threshold.desc.replace(
                      '$theme',
                      data.themed_name.toLocaleLowerCase(),
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

const AbilityDisplay = (props: { ability: Ability; title?: string }) => {
  const { data } = useBackend<Info>();
  const { ability, title } = props;
  const [stat_thresholds, stat_info] = ability.thresholds.reduce(
    ([p, f], e) =>
      is_actually_a_threshold(e) ? [[...p, e], f] : [p, [...f, e]],
    [[], []],
  ); // from https://stackoverflow.com/a/47225591
  return (
    <Section
      fill
      title={
        <>
          {ability.icon && <Icon name={ability.icon} />}
          <Box mx={ability.icon && 1} inline>
            {title || ability.name}
          </Box>
        </>
      }
    >
      <Stack vertical>
        <Stack.Item>
          <Box textAlign="justify" textColor="label">
            {ability.desc.replace(
              '$theme',
              data.themed_name.toLocaleLowerCase(),
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
  );
};

const MajorAbilitySection = (_props) => {
  const { data } = useBackend<Info>();
  const { abilities } = data;
  if (!abilities.major) {
    return (
      <Section fill title="Ability">
        <Box>
          <span className="label italics">
            You do not have a major ability!
          </span>
        </Box>
      </Section>
    );
  }
  const ability = abilities.major!;
  return (
    <AbilityDisplay title={`Ability: ${ability.name}`} ability={ability} />
  );
};

const WeaponSection = (_props) => {
  const { data } = useBackend<Info>();
  const { abilities } = data;
  const weapon = abilities.weapon!;
  return <AbilityDisplay title={`Weapon: ${weapon.name}`} ability={weapon} />;
};

const LesserAbilitiesSection = (_props) => {
  const { data } = useBackend<Info>();
  if (!data.abilities.lesser?.length) {
    return (
      <Section fill title="Lesser Abilities">
        <Box>
          <span className="label italics">
            You do not have any lesser abilities!
          </span>
        </Box>
      </Section>
    );
  }
  const abilities = sort_abilities(data.abilities.lesser!);
  return (
    <Section fill scrollable title="Lesser Abilities">
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
          <Stack vertical>
            {abilities.map((ability: Ability, _index: number) => {
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
                  >
                    <Stack vertical>
                      <Stack.Item>
                        <Box textAlign="justify" textColor="label">
                          {ability.desc.replace(
                            '$theme',
                            data.themed_name.toLocaleLowerCase(),
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
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AbilitiesSection = () => {
  return (
    <Stack fill grow>
      <Stack.Item width="50%">
        <Stack vertical>
          <Stack.Item>
            <MajorAbilitySection />
          </Stack.Item>
          <Stack.Item>
            <WeaponSection />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item width="50%">
        <LesserAbilitiesSection />
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoHoloparasite = () => {
  return (
    <Window width={1000} height={850} theme="neutral">
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item height="200px">
            <Stack fill grow>
              <Stack.Item grow width="40%">
                <BasicInfo />
              </Stack.Item>
              <Stack.Item grow width="60%">
                <SummonerInfo />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item height="425px">
            <Section title="Stats">
              <Stack>
                <Stack.Item width="450px">
                  <StatsChartSection />
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item width="100%">
                  <StatsSection />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item height="300px">
            <AbilitiesSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
