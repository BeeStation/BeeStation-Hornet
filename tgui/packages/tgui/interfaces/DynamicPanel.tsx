import { exhaustiveCheck } from 'common/exhaustive';
import { BooleanLike } from 'common/react';
import { Dropdown } from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Chart,
  Divider,
  Flex,
  LabeledList,
  NumberInput,
  Section,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type Data = {
  forced_extended: BooleanLike;
  possible_storytellers: string[];
  current_storyteller: string;
};

type GamemodeData = {
  has_round_started: BooleanLike;
  gamemode_whitelist_forced: BooleanLike;
  gamemode_blacklist_forced: BooleanLike;
  forced_gamemode_rulesets: Ruleset[];
  valid_gamemode_rulesets: Ruleset[];
  executed_gamemode_rulesets: Ruleset[];
};

type SupplementaryData = {
  supplementary_points: number;
  supplementary_divergence: number;
  supplementary_divergence_upper: number;
  supplementary_divergence_lower: number;
  supplementary_points_per_ready: number;
  supplementary_points_per_unready: number;
  supplementary_points_per_observer: number;
  roundstart_ready_amount: number;
  has_round_started: BooleanLike;
  roundstart_points_override: BooleanLike;
  supplementary_whitelist_forced: BooleanLike;
  supplementary_blacklist_forced: BooleanLike;
  forced_supplementary_rulesets: CostRuleset[];
  valid_supplementary_rulesets: CostRuleset[];
  executed_supplementary_rulesets: CostRuleset[];
  supplementary_next: CostRuleset;
};

type Ruleset = {
  name: string;
  path: string;
};

type CostRuleset = Ruleset & {
  cost: number;
};

type MidroundData = {
  current_midround_points: number;
  midround_grace_period: number;
  midround_failure_stallout: number;
  living_delta: number;
  dead_delta: number;
  dead_security_delta: number;
  observer_delta: number;
  linear_delta: number;
  linear_delta_forced: number;
  logged_points: number[][];
  logged_points_living: number[][];
  logged_points_dead: number[][];
  logged_points_dead_security: number[][];
  logged_points_observer: number[][];
  logged_points_antag: number[][];
  logged_points_linear: number[][];
  logged_points_linear_forced: number[][];
  logged_light_chance: number[][];
  logged_medium_chance: number[][];
  logged_heavy_chance: number[][];
  current_midround_ruleset: Ruleset;
  valid_midround_rulesets: Ruleset[];
  executed_midround_rulesets: CostRuleset[];
};

enum Tab {
  Gamemode,
  Supplementary,
  Midround,
}

export const DynamicPanel = () => {
  const { data, act } = useBackend<Data>();
  const { forced_extended, current_storyteller, possible_storytellers } = data;

  const [currentTab, setCurrentTab] = useLocalState(
    'dynamic_tab',
    Tab.Gamemode,
  );
  let currentPage;

  switch (currentTab) {
    case Tab.Gamemode:
      currentPage = <GamemodePage />;
      break;
    case Tab.Supplementary:
      currentPage = <SupplementaryPage />;
      break;
    case Tab.Midround:
      currentPage = <MidroundPage />;
      break;
    default:
      exhaustiveCheck(currentTab);
  }

  return (
    <Window title="Dynamic Panel" theme="admin" height={500} width={700}>
      <Window.Content scrollable>
        <Section>
          <Box style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <Button
              tooltip="Opens the Dynamic VV panel."
              onClick={() => act('vv')}
            >
              VV
            </Button>
            <Button
              tooltip="Reloads the the dynamic storyteller files. Only intended for hot reloads"
              onClick={() => act('reload_storytellers')}
            >
              Reload Storytellers
            </Button>
            <Button
              tooltip="Blocks rulesets from running"
              color={forced_extended ? 'green' : 'red'}
              icon={forced_extended ? 'check' : 'times'}
              onClick={() => act('toggle_forced_extended')}
            >
              Forced Extended
            </Button>
            <Box
              style={{
                marginLeft: 'auto',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
              }}
            >
              Current Storyteller:
              <Dropdown
                options={[...possible_storytellers, 'None']}
                selected={current_storyteller ?? 'None'}
                onSelected={(value) => {
                  act('set_storyteller', { new_storyteller: value });
                }}
              />
            </Box>
          </Box>
        </Section>
        <Divider />
        <Tabs>
          <Tabs.Tab
            selected={currentTab === Tab.Gamemode}
            onClick={() => setCurrentTab(Tab.Gamemode)}
          >
            Gamemodes
          </Tabs.Tab>
          <Tabs.Tab
            selected={currentTab === Tab.Supplementary}
            onClick={() => setCurrentTab(Tab.Supplementary)}
          >
            Supplementary
          </Tabs.Tab>
          <Tabs.Tab
            selected={currentTab === Tab.Midround}
            onClick={() => setCurrentTab(Tab.Midround)}
          >
            Midround
          </Tabs.Tab>
        </Tabs>
        {currentPage}
      </Window.Content>
    </Window>
  );
};

const GamemodePage = () => {
  const { act, data } = useBackend<GamemodeData>();
  const {
    valid_gamemode_rulesets,
    executed_gamemode_rulesets,
    has_round_started,
    gamemode_blacklist_forced,
    gamemode_whitelist_forced,
    forced_gamemode_rulesets,
  } = data;

  const [forced_roundstart_points, set_forced_points] = useLocalState(
    'forced_roundstart_points',
    0,
  );

  const roundstart_rulesets_by_name = Object.fromEntries(
    valid_gamemode_rulesets.map((ruleset) => {
      return [ruleset.name, ruleset.path];
    }),
  );

  const roundstart_ruleset_names = Object.keys(roundstart_rulesets_by_name);
  roundstart_ruleset_names.sort();

  return (
    <Flex direction="column">
      {/* Forced roundstarts */}
      <Section
        fill
        title="Forced Roundstart Rulesets"
        buttons={
          <>
            <Button
              disabled={has_round_started}
              color={gamemode_whitelist_forced ? 'green' : 'red'}
              icon={gamemode_whitelist_forced ? 'check' : 'times'}
              tooltip="Prevent rulesets other than the ones below from being drafted"
              onClick={() => act('toggle_gamemode_whitelist_forced')}
            >
              Force Selected
            </Button>
            <Button
              disabled={has_round_started}
              color={gamemode_blacklist_forced ? 'green' : 'red'}
              icon={gamemode_blacklist_forced ? 'check' : 'times'}
              tooltip="Prevent the rulesets below from being drafted"
              onClick={() => act('toggle_gamemode_blacklist_forced')}
            >
              Blacklist Selected
            </Button>
          </>
        }
      >
        {roundstart_ruleset_names.length === 0 ? (
          <Box italic>There are no valid roundstart rulesets (uh oh)</Box>
        ) : (
          roundstart_ruleset_names.map((ruleset, idx) => (
            <Button.Checkbox
              disabled={has_round_started}
              checked={forced_gamemode_rulesets.find(
                (forced_ruleset) => forced_ruleset.name === ruleset,
              )}
              key={ruleset + idx}
              onClick={() => {
                const selectedRuleset = valid_gamemode_rulesets.find(
                  (valid_ruleset) => valid_ruleset.name === ruleset,
                );
                act('force_gamemode_ruleset', {
                  forced_roundstart_ruleset: selectedRuleset
                    ? selectedRuleset.path
                    : ruleset,
                });
              }}
              verticalAlign="middle"
            >
              {ruleset}
            </Button.Checkbox>
          ))
        )}
      </Section>
      {/* Executed roundstarts */}
      <Section fill title="Executed Gamemodes Rulesets">
        {executed_gamemode_rulesets.length === 0 ? (
          <Box italic>No executed gamemode rulesets.</Box>
        ) : (
          executed_gamemode_rulesets.map((executed_ruleset, idx) => (
            <LabeledList.Item
              key={executed_ruleset.path + idx}
              label={executed_ruleset.name}
              verticalAlign="middle"
            >
              <Box>Executed Roundstart</Box>
            </LabeledList.Item>
          ))
        )}
      </Section>
    </Flex>
  );
};

const SupplementaryPage = () => {
  const { act, data } = useBackend<SupplementaryData>();
  const {
    supplementary_points,
    supplementary_divergence,
    supplementary_divergence_upper,
    supplementary_divergence_lower,
    roundstart_ready_amount,
    supplementary_points_per_ready,
    supplementary_points_per_unready,
    supplementary_points_per_observer,
    has_round_started,
    roundstart_points_override,
    supplementary_whitelist_forced,
    supplementary_blacklist_forced,
    forced_supplementary_rulesets,
    valid_supplementary_rulesets,
    executed_supplementary_rulesets,
    supplementary_next,
  } = data;

  const [forced_roundstart_points, set_forced_points] = useLocalState(
    'forced_roundstart_points',
    0,
  );

  const supplementary_rulesets_by_name = Object.fromEntries(
    valid_supplementary_rulesets.map((ruleset) => {
      return [ruleset.name, ruleset.path];
    }),
  );

  const supplementary_ruleset_names = Object.keys(
    supplementary_rulesets_by_name,
  );
  supplementary_ruleset_names.sort();

  return (
    <Flex direction="column">
      {/* Variables */}
      <Flex.Item>
        <Flex direction="row">
          <Flex.Item grow>
            <Section fill title="Variables">
              <LabeledList.Item
                label="Upper Divergence Range"
                verticalAlign="middle"
              >
                <NumberInput
                  value={supplementary_divergence_upper ?? 0}
                  disabled={has_round_started}
                  animated
                  minValue={0}
                  maxValue={10}
                  step={0.2}
                  onChange={(value) =>
                    act('set_roundstart_divergence_upper', {
                      new_divergence_upper: value,
                    })
                  }
                  width="50%"
                />
              </LabeledList.Item>
              <LabeledList.Item
                label="Lower Divergence Range"
                verticalAlign="middle"
              >
                <NumberInput
                  value={supplementary_divergence_lower ?? 0}
                  disabled={has_round_started}
                  animated
                  minValue={0}
                  maxValue={10}
                  step={0.2}
                  onChange={(value) =>
                    act('set_roundstart_divergence_lower', {
                      new_divergence_lower: value,
                    })
                  }
                  width="50%"
                />
              </LabeledList.Item>
              <LabeledList.Item label="Points per Ready" verticalAlign="middle">
                <NumberInput
                  value={supplementary_points_per_ready ?? 0}
                  disabled={has_round_started}
                  animated
                  minValue={0}
                  maxValue={100}
                  step={1}
                  onChange={(value) =>
                    act('set_supplementary_points_per_ready', {
                      new_points_per_ready: value,
                    })
                  }
                  width="50%"
                />
              </LabeledList.Item>
              <LabeledList.Item
                label="Points per Unready"
                verticalAlign="middle"
              >
                <NumberInput
                  value={supplementary_points_per_unready ?? 0}
                  disabled={has_round_started}
                  animated
                  minValue={0}
                  maxValue={100}
                  step={1}
                  onChange={(value) =>
                    act('set_supplementary_points_per_unready', {
                      new_points_per_unready: value,
                    })
                  }
                  width="50%"
                />
              </LabeledList.Item>
              <LabeledList.Item
                label="Points per Observer"
                verticalAlign="middle"
              >
                <NumberInput
                  value={supplementary_points_per_observer ?? 0}
                  disabled={has_round_started}
                  animated
                  minValue={0}
                  maxValue={100}
                  step={1}
                  onChange={(value) =>
                    act('set_supplementary_points_per_observer', {
                      new_points_per_observer: value,
                    })
                  }
                  width="50%"
                />
              </LabeledList.Item>
            </Section>
          </Flex.Item>
          <Divider vertical />
          <Flex.Item grow>
            <Section
              fill
              title="Overrides"
              buttons={
                <Button
                  disabled={has_round_started}
                  color={roundstart_points_override ? 'green' : 'red'}
                  icon={roundstart_points_override ? 'check' : 'times'}
                  tooltip="Use the values below on roundstart regardless"
                  onClick={() =>
                    act('toggle_roundstart_points_override', {
                      forced_roundstart_points: forced_roundstart_points,
                    })
                  }
                >
                  Override Points
                </Button>
              }
            >
              <LabeledList.Item
                label="Supplementary Points"
                verticalAlign="middle"
              >
                <NumberInput
                  value={
                    !has_round_started
                      ? (forced_roundstart_points ?? 0)
                      : supplementary_points
                  }
                  disabled={!has_round_started && !roundstart_points_override}
                  animated
                  minValue={0}
                  maxValue={100}
                  step={1}
                  onChange={(value) => {
                    if (!has_round_started) {
                      set_forced_points(value);
                    } else {
                      act('set_supplementary_points', {
                        new_supplementary_points: value,
                      });
                    }
                  }}
                  width="25%"
                />
              </LabeledList.Item>
              <LabeledList.Item label="Next Latejoin" verticalAlign="middle">
                <Dropdown
                  options={supplementary_ruleset_names}
                  selected={supplementary_next?.name ?? 'None'}
                  width="100%"
                  onSelected={(value) => {
                    const selectedRuleset = valid_supplementary_rulesets.find(
                      (ruleset) => ruleset.name === value,
                    );
                    act('set_latejoin_ruleset', {
                      new_latejoin_ruleset: selectedRuleset
                        ? selectedRuleset.path
                        : value,
                    });
                  }}
                />
              </LabeledList.Item>
            </Section>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Divider />

      {/* Forced roundstarts */}
      <Section
        fill
        title="Forced Roundstart Rulesets"
        buttons={
          <>
            <Button
              disabled={has_round_started}
              color={supplementary_whitelist_forced ? 'green' : 'red'}
              icon={supplementary_whitelist_forced ? 'check' : 'times'}
              tooltip="Prevent rulesets other than the ones below from being drafted"
              onClick={() => act('toggle_supplementary_whitelist_forced')}
            >
              Force Selected
            </Button>
            <Button
              disabled={has_round_started}
              color={supplementary_blacklist_forced ? 'green' : 'red'}
              icon={supplementary_blacklist_forced ? 'check' : 'times'}
              tooltip="Prevent the rulesets below from being drafted"
              onClick={() => act('toggle_supplementary_blacklist_forced')}
            >
              Blacklist Selected
            </Button>
          </>
        }
      >
        {supplementary_ruleset_names.length === 0 ? (
          <Box italic>There are no valid roundstart rulesets (uh oh)</Box>
        ) : (
          supplementary_ruleset_names.map((ruleset, idx) => (
            <Button.Checkbox
              disabled={has_round_started}
              checked={forced_supplementary_rulesets.find(
                (forced_ruleset) => forced_ruleset.name === ruleset,
              )}
              key={ruleset + idx}
              onClick={() => {
                const selectedRuleset = valid_supplementary_rulesets.find(
                  (valid_ruleset) => valid_ruleset.name === ruleset,
                );
                act('force_roundstart_ruleset', {
                  forced_roundstart_ruleset: selectedRuleset
                    ? selectedRuleset.path
                    : ruleset,
                });
              }}
              verticalAlign="middle"
            >
              {ruleset}
            </Button.Checkbox>
          ))
        )}
      </Section>
      <Divider />

      {/* Roundstart Stats */}
      <Section fill title="Supplementary Stats" tooltip="test">
        {has_round_started ? (
          <>
            <LabeledList.Item label="Ready Count" verticalAlign="middle">
              {roundstart_ready_amount ?? 0}
            </LabeledList.Item>
            <LabeledList.Item
              label="Supplementary Points"
              verticalAlign="middle"
            >
              {supplementary_points ?? 0}
            </LabeledList.Item>
            <LabeledList.Item
              label="Roundstart Divergence"
              verticalAlign="middle"
            >
              {supplementary_divergence
                ? `${Math.round((supplementary_divergence - 1) * 100)}%`
                : '0%'}
            </LabeledList.Item>
          </>
        ) : (
          <Box italic>The round has not started</Box>
        )}
      </Section>
      <Divider />

      {/* Executed roundstarts */}
      <Section fill title="Executed Supplementary Rulesets">
        {executed_supplementary_rulesets.length === 0 ? (
          <Box italic>No executed roundstart rulesets.</Box>
        ) : (
          executed_supplementary_rulesets.map((executed_ruleset, idx) => (
            <LabeledList.Item
              key={executed_ruleset.path + idx}
              label={executed_ruleset.name}
              verticalAlign="middle"
            >
              <Box>
                {forced_supplementary_rulesets.find(
                  (forced_ruleset) =>
                    forced_ruleset.name === executed_ruleset.name,
                )
                  ? 'Forced'
                  : `Cost: ${executed_ruleset.cost}`}
              </Box>
            </LabeledList.Item>
          ))
        )}
      </Section>
    </Flex>
  );
};

const MidroundPage = () => {
  const { act, data } = useBackend<MidroundData>();
  const {
    logged_light_chance,
    logged_medium_chance,
    logged_heavy_chance,
    logged_points,
    logged_points_living,
    logged_points_dead,
    logged_points_dead_security,
    logged_points_observer,
    logged_points_antag,
    logged_points_linear,
    logged_points_linear_forced,
    valid_midround_rulesets,
    executed_midround_rulesets,
    current_midround_ruleset,
    current_midround_points,
    midround_grace_period,
    midround_failure_stallout,
    living_delta,
    dead_delta,
    dead_security_delta,
    observer_delta,
    linear_delta,
    linear_delta_forced,
  } = data;

  // Convert our logged data into a useable format
  const light_data = logged_light_chance.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);
  const medium_data = logged_medium_chance.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);
  const heavy_data = logged_heavy_chance.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);

  const points_data = logged_points.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);
  const living_data = logged_points_living.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);
  const dead_data = logged_points_dead.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);
  const dead_security_data = logged_points_dead_security.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);
  const observer_data = logged_points_observer.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);
  const antag_data = logged_points_antag.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);
  const linear_data = logged_points_linear.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);
  const linear_forced_data = logged_points_linear_forced.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);

  const midround_rulesets_by_name = Object.fromEntries(
    valid_midround_rulesets.map((ruleset) => {
      return [ruleset.name, ruleset.path];
    }),
  );

  const midround_ruleset_names = Object.keys(midround_rulesets_by_name);
  midround_ruleset_names.sort();

  const [show_light, toggle_light_graph] = useLocalState('show_light', true);
  const [show_medium, toggle_medium_graph] = useLocalState('show_medium', true);
  const [show_heavy, toggle_heavy_graph] = useLocalState('show_heavy', true);

  const [show_living_delta, toggle_living_graph] = useLocalState(
    'show_living_delta',
    true,
  );
  const [show_dead_delta, toggle_dead_graph] = useLocalState(
    'show_dead_delta',
    true,
  );
  const [show_dead_security_delta, toggle_dead_security_graph] = useLocalState(
    'show_dead_security_delta',
    true,
  );
  const [show_observer_delta, toggle_observer_graph] = useLocalState(
    'show_observer_delta',
    true,
  );
  const [show_antag_delta, toggle_antag_graph] = useLocalState(
    'show_antag_delta',
    true,
  );
  const [show_linear_delta, toggle_linear_graph] = useLocalState(
    'show_linear_delta',
    true,
  );
  const [show_linear_delta_forced, toggle_linear_graph_forced] = useLocalState(
    'show_linear_delta_forced',
    true,
  );

  return (
    <Flex direction="column">
      {/* Variables */}
      <Flex.Item>
        <Flex direction="row">
          <Flex.Item grow>
            <Section
              fill
              title="Misc"
              buttons={
                <Button
                  disabled={!current_midround_ruleset}
                  tooltip="Does not affect midround points"
                  onClick={() => act('execute_midround_ruleset')}
                >
                  Execute Chosen Ruleset
                </Button>
              }
            >
              <LabeledList.Item label="Midround Ruleset" verticalAlign="middle">
                <Dropdown
                  options={midround_ruleset_names}
                  selected={current_midround_ruleset?.name ?? 'None'}
                  width="100%"
                  onSelected={(value) => {
                    const selectedRuleset = valid_midround_rulesets.find(
                      (ruleset) => ruleset.name === value,
                    );
                    act('set_midround_ruleset', {
                      new_midround_ruleset: selectedRuleset
                        ? selectedRuleset.path
                        : value,
                    });
                  }}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Midround Points" verticalAlign="middle">
                <NumberInput
                  value={current_midround_points ?? 0}
                  animated
                  minValue={0}
                  maxValue={1000}
                  step={1}
                  onChange={(value) =>
                    act('set_midround_points', { new_points: value })
                  }
                  width="50%"
                />
              </LabeledList.Item>
              <LabeledList.Item label="Grace Period" verticalAlign="middle">
                <NumberInput
                  value={midround_grace_period ?? 0}
                  animated
                  minValue={0}
                  maxValue={120}
                  step={5}
                  onChange={(value) =>
                    act('set_midround_grace_period', {
                      new_grace_period: value,
                    })
                  }
                  width="50%"
                />
              </LabeledList.Item>
              <LabeledList.Item
                label="Midround Failure Stallout"
                verticalAlign="middle"
              >
                <NumberInput
                  value={midround_failure_stallout ?? 0}
                  animated
                  minValue={0}
                  maxValue={60}
                  step={1}
                  onChange={(value) =>
                    act('set_midround_failure_stallout', {
                      new_midround_stallout: value,
                    })
                  }
                  width="50%"
                />
              </LabeledList.Item>
            </Section>
          </Flex.Item>
          <Divider vertical />
          <Flex.Item grow>
            <Section fill title="Midround Deltas">
              <LabeledList.Item label="Living Delta" verticalAlign="middle">
                <NumberInput
                  value={living_delta ?? 0}
                  animated
                  minValue={-10}
                  maxValue={10}
                  step={0.5}
                  onChange={(value) =>
                    act('set_midround_living_delta', {
                      new_living_delta: value,
                    })
                  }
                  width="25%"
                />
              </LabeledList.Item>
              <LabeledList.Item label="Dead Delta" verticalAlign="middle">
                <NumberInput
                  value={dead_delta ?? 0}
                  animated
                  minValue={-10}
                  maxValue={10}
                  step={0.5}
                  onChange={(value) =>
                    act('set_midround_dead_delta', { new_dead_delta: value })
                  }
                  width="25%"
                />
              </LabeledList.Item>
              <LabeledList.Item label="Dead Sec Delta" verticalAlign="middle">
                <NumberInput
                  value={dead_security_delta ?? 0}
                  animated
                  minValue={-10}
                  maxValue={10}
                  step={0.5}
                  onChange={(value) =>
                    act('set_midround_dead_security_delta', {
                      new_dead_security_delta: value,
                    })
                  }
                  width="25%"
                />
              </LabeledList.Item>
              <LabeledList.Item label="Observer Delta" verticalAlign="middle">
                <NumberInput
                  value={observer_delta ?? 0}
                  animated
                  minValue={-10}
                  maxValue={10}
                  step={0.5}
                  onChange={(value) =>
                    act('set_midround_observer_delta', {
                      new_observer_delta: value,
                    })
                  }
                  width="25%"
                />
              </LabeledList.Item>
              <LabeledList.Item label="Linear Delta" verticalAlign="middle">
                <NumberInput
                  value={linear_delta ?? 0}
                  animated
                  minValue={-10}
                  maxValue={10}
                  step={0.5}
                  onChange={(value) =>
                    act('set_midround_linear_delta', {
                      new_linear_delta: value,
                    })
                  }
                  width="25%"
                />
              </LabeledList.Item>
              <LabeledList.Item
                label="Forced Linear Delta"
                verticalAlign="middle"
              >
                <NumberInput
                  value={linear_delta_forced ?? 0}
                  animated
                  minValue={-10}
                  maxValue={10}
                  step={0.5}
                  onChange={(value) =>
                    act('set_midround_linear_delta_forced', {
                      new_linear_delta_forced: value,
                    })
                  }
                  width="25%"
                />
              </LabeledList.Item>
            </Section>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Divider />

      {/* Executed midround rulesets */}
      <Section fill title="Executed Midround Rulesets">
        {executed_midround_rulesets.length === 0 ? (
          <Box italic>No executed midround rulesets.</Box>
        ) : (
          executed_midround_rulesets.map((ruleset, idx) => (
            <LabeledList.Item
              key={ruleset.path + idx}
              label={ruleset.name}
              verticalAlign="middle"
            >
              <Box>Cost: {ruleset.cost}</Box>
            </LabeledList.Item>
          ))
        )}
      </Section>
      <Divider />

      {/* Ruleset Chances */}
      <Flex direction="row">
        <Flex.Item>
          <Section
            fill
            title="—"
            style={{ height: '245px', width: '40px', position: 'relative' }}
          >
            <Box
              position="absolute"
              top={0}
              left="50%"
              style={{ transform: 'translate(-50%, 0)' }}
            >
              100%
            </Box>
            <Box
              position="absolute"
              top="25%"
              left="50%"
              style={{ transform: 'translate(-50%, -50%)' }}
            >
              75%
            </Box>
            <Box
              position="absolute"
              top="50%"
              left="50%"
              style={{ transform: 'translate(-50%, -50%)' }}
            >
              50%
            </Box>
            <Box
              position="absolute"
              top="75%"
              left="50%"
              style={{ transform: 'translate(-50%, -50%)' }}
            >
              25%
            </Box>
            <Box
              position="absolute"
              bottom={0}
              left="50%"
              style={{ transform: 'translate(-50%, 0)' }}
            >
              0%
            </Box>
          </Section>
        </Flex.Item>
        <Flex.Item grow>
          <Section
            fill
            title="Ruleset Chances:"
            height="245px"
            width="633px"
            style={{ position: 'relative' }}
          >
            <Box
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                width: '100%',
                height: '100%',
                pointerEvents: 'none',
                zIndex: 1,
              }}
            >
              {[0, 0.25, 0.5, 0.75, 1].map((v, i) => (
                <Box
                  key={`hgrid-${i}`}
                  style={{
                    position: 'absolute',
                    left: 0,
                    right: 0,
                    top: `${v * 100}%`,
                    height: '1px',
                    background: 'rgba(128,128,128,0.2)',
                    transform: 'translateY(-0.5px)',
                  }}
                />
              ))}
            </Box>
            {show_light && (
              <Chart.Line
                fillPositionedParent
                data={light_data}
                rangeX={[0, light_data.length - 1]}
                rangeY={[0, 10]}
                strokeColor="rgb(38, 191, 74)"
              />
            )}
            {show_medium && (
              <Chart.Line
                fillPositionedParent
                data={medium_data}
                rangeX={[0, medium_data.length - 1]}
                rangeY={[0, 10]}
                strokeColor="rgb(46, 147, 222)"
              />
            )}
            {show_heavy && (
              <Chart.Line
                fillPositionedParent
                data={heavy_data}
                rangeX={[0, heavy_data.length - 1]}
                rangeY={[0, 10]}
                strokeColor="rgb(223, 62, 62)"
              />
            )}
          </Section>
        </Flex.Item>
      </Flex>
      <Flex.Item align="center" p={0.5}>
        <Button
          icon={show_light ? 'check-square-o' : 'square-o'}
          onClick={() => toggle_light_graph(!show_light)}
        >
          <Box inline textColor="green">
            Light
          </Box>
        </Button>
        <Button
          icon={show_medium ? 'check-square-o' : 'square-o'}
          onClick={() => toggle_medium_graph(!show_medium)}
        >
          <Box inline textColor="blue">
            Medium
          </Box>
        </Button>
        <Button
          icon={show_heavy ? 'check-square-o' : 'square-o'}
          onClick={() => toggle_heavy_graph(!show_heavy)}
        >
          <Box inline textColor="red">
            Heavy
          </Box>
        </Button>
      </Flex.Item>
      <Divider />

      {/* Point Deltas */}
      <Flex direction="row">
        <Flex.Item>
          <Section
            fill
            title="—"
            style={{ height: '245px', width: '40px', position: 'relative' }}
          >
            <Box
              position="absolute"
              top={0}
              left="50%"
              style={{ transform: 'translate(-50%, 0)' }}
            >
              5
            </Box>
            <Box
              position="absolute"
              top="25%"
              left="50%"
              style={{ transform: 'translate(-50%, -50%)' }}
            >
              2.5
            </Box>
            <Box
              position="absolute"
              top="50%"
              left="50%"
              style={{ transform: 'translate(-50%, -50%)' }}
            >
              0
            </Box>
            <Box
              position="absolute"
              top="75%"
              left="50%"
              style={{ transform: 'translate(-50%, -50%)' }}
            >
              -2.5
            </Box>
            <Box
              position="absolute"
              bottom={0}
              left="50%"
              style={{ transform: 'translate(-50%, 0)' }}
            >
              -5
            </Box>
          </Section>
        </Flex.Item>
        <Flex.Item grow>
          <Section
            fill
            title="Point Deltas:"
            height="245px"
            width="633px"
            style={{ position: 'relative' }}
          >
            {/* Grid overlay */}
            <Box
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                width: '100%',
                height: '100%',
                pointerEvents: 'none',
                zIndex: 1,
              }}
            >
              {/* Horizontal grid lines */}
              {[0, 0.25, 0.5, 0.75, 1].map((v, i) => (
                <Box
                  key={`hgrid-${i}`}
                  style={{
                    position: 'absolute',
                    left: 0,
                    right: 0,
                    top: `${v * 100}%`,
                    height: '1px',
                    background: 'rgba(128,128,128,0.2)',
                    transform: 'translateY(-0.5px)',
                  }}
                />
              ))}
            </Box>

            {/* Chart lines */}
            {show_living_delta && (
              <Chart.Line
                fillPositionedParent
                data={living_data}
                rangeX={[0, living_data.length - 1]}
                rangeY={[-5, 5]}
                strokeColor="rgb(38, 191, 74)"
              />
            )}
            {show_dead_delta && (
              <Chart.Line
                fillPositionedParent
                data={dead_data}
                rangeX={[0, dead_data.length - 1]}
                rangeY={[-5, 5]}
                strokeColor="rgb(46, 147, 222)"
              />
            )}
            {show_dead_security_delta && (
              <Chart.Line
                fillPositionedParent
                data={dead_security_data}
                rangeX={[0, dead_security_data.length - 1]}
                rangeY={[-5, 5]}
                strokeColor="rgba(255, 0, 93, 1)"
              />
            )}
            {show_observer_delta && (
              <Chart.Line
                fillPositionedParent
                data={observer_data}
                rangeX={[0, observer_data.length - 1]}
                rangeY={[-5, 5]}
                strokeColor="rgb(127, 127, 127)"
              />
            )}
            {show_antag_delta && (
              <Chart.Line
                fillPositionedParent
                data={antag_data}
                rangeX={[0, antag_data.length - 1]}
                rangeY={[-5, 5]}
                strokeColor="rgb(223, 62, 62)"
              />
            )}
            {show_linear_delta && (
              <Chart.Line
                fillPositionedParent
                data={linear_data}
                rangeX={[0, linear_data.length - 1]}
                rangeY={[-5, 5]}
                strokeColor="rgb(255, 255, 255)"
              />
            )}
            {show_linear_delta_forced && (
              <Chart.Line
                fillPositionedParent
                data={linear_forced_data}
                rangeX={[0, linear_forced_data.length - 1]}
                rangeY={[-5, 5]}
                strokeColor="rgb(255, 255, 0)"
              />
            )}
          </Section>
        </Flex.Item>
      </Flex>
      <Flex.Item align="center" p={0.5}>
        <Button
          icon={show_living_delta ? 'check-square-o' : 'square-o'}
          onClick={() => toggle_living_graph(!show_living_delta)}
        >
          <Box inline textColor="green">
            Living
          </Box>
        </Button>
        <Button
          icon={show_dead_delta ? 'check-square-o' : 'square-o'}
          onClick={() => toggle_dead_graph(!show_dead_delta)}
        >
          <Box inline textColor="blue">
            Dead
          </Box>
        </Button>
        <Button
          icon={show_dead_security_delta ? 'check-square-o' : 'square-o'}
          onClick={() => toggle_dead_security_graph(!show_dead_security_delta)}
        >
          <Box inline textColor="deeppink">
            Dead Security
          </Box>
        </Button>
        <Button
          icon={show_observer_delta ? 'check-square-o' : 'square-o'}
          onClick={() => toggle_observer_graph(!show_observer_delta)}
        >
          <Box inline textColor="grey">
            Observer
          </Box>
        </Button>
        <Button
          icon={show_antag_delta ? 'check-square-o' : 'square-o'}
          onClick={() => toggle_antag_graph(!show_antag_delta)}
        >
          <Box inline textColor="red">
            Antag
          </Box>
        </Button>
        <Button
          icon={show_linear_delta ? 'check-square-o' : 'square-o'}
          onClick={() => toggle_linear_graph(!show_linear_delta)}
        >
          <Box inline textColor="white">
            Linear
          </Box>
        </Button>
        <Button
          icon={show_linear_delta_forced ? 'check-square-o' : 'square-o'}
          onClick={() => toggle_linear_graph_forced(!show_linear_delta_forced)}
        >
          <Box inline textColor="yellow">
            Forced Linear
          </Box>
        </Button>
      </Flex.Item>
      <Divider />

      {/* Point Graph */}
      <Flex direction="row">
        <Flex.Item>
          <Section
            fill
            title="—"
            style={{ height: '245px', width: '40px', position: 'relative' }}
          >
            <Box
              position="absolute"
              top={0}
              left="50%"
              style={{ transform: 'translate(-50%, 0)' }}
            >
              100
            </Box>
            <Box
              position="absolute"
              top="25%"
              left="50%"
              style={{ transform: 'translate(-50%, -50%)' }}
            >
              75
            </Box>
            <Box
              position="absolute"
              top="50%"
              left="50%"
              style={{ transform: 'translate(-50%, -50%)' }}
            >
              50
            </Box>
            <Box
              position="absolute"
              top="75%"
              left="50%"
              style={{ transform: 'translate(-50%, -50%)' }}
            >
              25
            </Box>
            <Box
              position="absolute"
              bottom={0}
              left="50%"
              style={{ transform: 'translate(-50%, 0)' }}
            >
              0
            </Box>
          </Section>
        </Flex.Item>
        <Flex.Item grow>
          <Section
            fill
            title="Points:"
            height="245px"
            width="633px"
            style={{ position: 'relative' }}
          >
            <Box
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                width: '100%',
                height: '100%',
                pointerEvents: 'none',
                zIndex: 1,
              }}
            >
              {[0, 0.25, 0.5, 0.75, 1].map((v, i) => (
                <Box
                  key={`hgrid-${i}`}
                  style={{
                    position: 'absolute',
                    left: 0,
                    right: 0,
                    top: `${v * 100}%`,
                    height: '1px',
                    background: 'rgba(128,128,128,0.2)',
                    transform: 'translateY(-0.5px)',
                  }}
                />
              ))}
            </Box>
            <Chart.Line
              fillPositionedParent
              data={points_data}
              rangeX={[0, points_data.length - 1]}
              rangeY={[0, 100]}
              strokeColor="rgb(255, 255, 255)"
            />
          </Section>
        </Flex.Item>
      </Flex>
    </Flex>
  );
};
