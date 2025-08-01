import { capitalizeAll, multiline } from 'common/string';
import { useBackend } from 'tgui/backend';
import {
  Button,
  Flex,
  Icon,
  LabeledControls,
  NoticeBox,
  Section,
  Slider,
  Stack,
  Tooltip,
} from 'tgui/components';
import { getGasLabel } from 'tgui/constants';
import { Window } from 'tgui/layouts';

type SimpleBotContext = {
  can_hack: number;
  locked: number;
  emagged: number;
  pai: Pai;
  settings: Settings;
  custom_controls: Controls;
};

type Pai = {
  allow_pai: number;
  card_inserted: number;
};

type Settings = {
  power: number;
  booting: boolean;
  airplane_mode: number;
  maintenance_lock: number;
  patrol_station: number;
};

type Controls = {
  [Control: string]: [Value: number];
};

export const SimpleBot = (_) => {
  const { data } = useBackend<SimpleBotContext>();
  const { can_hack, locked } = data;
  const access = !locked || can_hack;

  return (
    <Window width={450} height={320}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Settings" buttons={<TabDisplay />}>
              {!access ? <NoticeBox>Locked!</NoticeBox> : <SettingsDisplay />}
            </Section>
          </Stack.Item>
          {access && (
            <Stack.Item grow>
              <Section fill scrollable title="Controls">
                <ControlsDisplay />
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Creates a lock button at the top of the controls */
const TabDisplay = (_) => {
  const { act, data } = useBackend<SimpleBotContext>();
  const { can_hack, locked, pai } = data;
  const { allow_pai } = pai;

  return (
    <>
      {!!can_hack && <HackButton />}
      {!!allow_pai && <PaiButton />}
      <Button
        color="transparent"
        icon={locked ? 'lock' : 'lock-open'}
        onClick={() => act('lock')}
        selected={locked}
        tooltip={`${locked ? 'Unlock' : 'Lock'} the control panel.`}
      >
        Controls Lock
      </Button>
    </>
  );
};

/** If user is a bad silicon, they can press this button to hack the bot */
const HackButton = (_) => {
  const { act, data } = useBackend<SimpleBotContext>();
  const { can_hack, emagged } = data;

  return (
    <Button
      color="danger"
      disabled={!can_hack}
      icon={emagged ? 'bug' : 'lock'}
      onClick={() => act('hack')}
      selected={!emagged}
      tooltip={
        !emagged
          ? 'Unlocks the safety protocols.'
          : 'Resets the bot operating system.'
      }
    >
      {emagged ? 'Malfunctional' : 'Safety Lock'}
    </Button>
  );
};

/** Creates a button indicating PAI status and offers the eject action */
const PaiButton = (_) => {
  const { act, data } = useBackend<SimpleBotContext>();
  const { card_inserted } = data.pai;

  if (!card_inserted) {
    return (
      <Button
        color="transparent"
        icon="robot"
        tooltip={multiline`Insert an active PAI card to control this device.`}
      >
        No PAI Inserted
      </Button>
    );
  } else {
    return (
      <Button
        disabled={!card_inserted}
        icon="eject"
        onClick={() => act('eject_pai')}
        tooltip={multiline`Ejects the current PAI.`}
      >
        Eject PAI
      </Button>
    );
  }
};

/** Displays the bot's standard settings: Power, patrol, etc. */
const SettingsDisplay = (_) => {
  const { act, data } = useBackend<SimpleBotContext>();
  const { settings } = data;
  const { airplane_mode, patrol_station, power, booting, maintenance_lock } =
    settings;

  const color = power ? 'good' : booting ? 'bad' : 'gray';

  return (
    <LabeledControls>
      <LabeledControls.Item label="Power">
        <Tooltip content={`Powers ${power ? 'off' : 'on'} the bot.`}>
          <Icon
            size={2}
            name="power-off"
            color={color}
            onClick={() => act('power')}
          />
        </Tooltip>
      </LabeledControls.Item>
      <LabeledControls.Item label="Remote Control">
        <Tooltip
          content={`${airplane_mode ? 'Disables' : 'Enables'} remote access via PDA app.`}
        >
          <Icon
            size={2}
            name="wifi"
            color={airplane_mode ? 'yellow' : 'gray'}
            onClick={() => act('airplane')}
          />
        </Tooltip>
      </LabeledControls.Item>
      <LabeledControls.Item label="Patrol Station">
        <Tooltip
          content={`${patrol_station ? 'Disables' : 'Enables'} automatic station patrol.`}
        >
          <Icon
            size={2}
            name="map-signs"
            color={patrol_station ? 'good' : 'gray'}
            onClick={() => act('patrol')}
          />
        </Tooltip>
      </LabeledControls.Item>
      <LabeledControls.Item label="Maintenance Lock">
        <Tooltip
          content={
            maintenance_lock
              ? 'Opens the maintenance hatch for repairs.'
              : 'Closes the maintenance hatch.'
          }
        >
          <Icon
            size={2}
            name="toolbox"
            color={maintenance_lock ? 'yellow' : 'gray'}
            onClick={() => act('maintenance')}
          />
        </Tooltip>
      </LabeledControls.Item>
    </LabeledControls>
  );
};

/** Iterates over custom controls.
 * Calls the helper to identify which button to use.
 */
const ControlsDisplay = (_) => {
  const { data } = useBackend<SimpleBotContext>();
  const { custom_controls } = data;

  return (
    <LabeledControls wrap>
      {Object.entries(custom_controls).map((control) => {
        if (control[0] === 'scrub_gasses') {
          return <ControlHelper key={control[0]} control={control} />;
        }
        return (
          <LabeledControls.Item
            pb={2}
            key={control[0]}
            label={capitalizeAll(control[0].replace('_', ' '))}
          >
            <ControlHelper control={control} />
          </LabeledControls.Item>
        );
      })}
    </LabeledControls>
  );
};

/** Helper function which identifies which button to create.
 * Might need some fine tuning if you are using more advanced controls.
 */
const ControlHelper = (props) => {
  const { act } = useBackend<SimpleBotContext>();
  const { control } = props;
  if (control[0] === 'sync_tech') {
    /** Control is for sync - this is medbot specific */
    return <MedbotSync control={control} />;
  } else if (control[0] === 'heal_threshold') {
    /** Control is a threshold - this is medbot specific */
    return <MedbotThreshold control={control} />;
  } else if (control[0] === 'injection_amount') {
    /** Control is a threshold - this is medbot specific */
    return <MedbotInjectionThreshold control={control} />;
  } else if (control[0] === 'container') {
    return <MedbotBeaker control={control} />;
  } else if (control[0] === 'tile_stack') {
    return <FloorbotTiles control={control} />;
  } else if (control[0] === 'line_mode') {
    return <FloorbotLine control={control} />;
  } else if (control[0] === 'breach_pressure') {
    return <AtmosbotBreachPressure control={control} />;
  } else if (control[0] === 'ideal_temperature') {
    return <AtmosbotTargetTemperature control={control} />;
  } else if (control[0] === 'scrub_gasses') {
    return <AtmosbotScrubbedGasses control={control} />;
  } else {
    /** Control is a boolean of some type */
    return (
      <Icon
        color={control[1] ? 'good' : 'gray'}
        name={control[1] ? 'toggle-on' : 'toggle-off'}
        size={2}
        onClick={() => act(control[0])}
      />
    );
  }
};

/** Small button to sync medbots with research. */
const MedbotSync = (props) => {
  const { act } = useBackend<SimpleBotContext>();
  const { control } = props;
  const efficiency = Math.round(control[1] * 100);

  return (
    <Tooltip
      content={
        multiline`Synchronize surgical data with research network.
       Currently at: ` +
        efficiency +
        `% efficiency.`
      }
    >
      <Icon
        color="purple"
        name="cloud-download-alt"
        size={2}
        onClick={() => act('sync_tech')}
      />
    </Tooltip>
  );
};

/** Slider button for medbot healing thresholds */
const MedbotThreshold = (props) => {
  const { act } = useBackend<SimpleBotContext>();
  const { control } = props;

  return (
    <Tooltip content="Adjusts the sensitivity for damage treatment.">
      <Slider
        minValue={5}
        maxValue={95}
        ranges={{
          good: [-Infinity, 15],
          average: [15, 55],
          bad: [55, Infinity],
        }}
        step={5}
        unit="%"
        value={control[1]}
        onChange={(_, value) => act(control[0], { threshold: value })}
      />
    </Tooltip>
  );
};

/** Slider button for medbot healing thresholds */
const MedbotInjectionThreshold = (props) => {
  const { act } = useBackend<SimpleBotContext>();
  const { control } = props;

  return (
    <Tooltip content="Adjusts the dose of chemicals administered.">
      <Slider
        minValue={5}
        maxValue={30}
        ranges={{
          good: [-Infinity, 15],
          average: [15, 25],
          bad: [25, Infinity],
        }}
        step={5}
        unit="u"
        value={control[1]}
        onChange={(_, value) => act(control[0], { inject: value })}
      />
    </Tooltip>
  );
};

const MedbotBeaker = (props) => {
  const { act } = useBackend<SimpleBotContext>();
  const { control } = props;
  const [reagent_glass, total_volume, maximum_volume] = [
    control[1]['reagent_glass'],
    control[1]['total_volume'],
    control[1]['maximum_volume'],
  ];

  return (
    <Button
      disabled={!reagent_glass}
      icon={reagent_glass ? 'eject' : ''}
      onClick={() => act('eject')}
      tooltip="Container contained in the bot."
    >
      {reagent_glass
        ? `${reagent_glass} [${total_volume}/${maximum_volume}]`
        : 'Empty'}
    </Button>
  );
};

/** Tile stacks for floorbots - shows number and eject button */
const FloorbotTiles = (props) => {
  const { act } = useBackend<SimpleBotContext>();
  const { control } = props;
  const [tilestack, amount, max_amount] = [
    control[1]['tilestack'],
    control[1]['amount'],
    control[1]['max_amount'],
  ];

  return (
    <Button
      disabled={!tilestack}
      icon={tilestack ? 'eject' : ''}
      onClick={() => act('eject_tiles')}
      tooltip="Floor tiles contained in the bot."
    >
      {tilestack ? `${tilestack} [${amount}/${max_amount}]` : 'Empty'}
    </Button>
  );
};

/** Direction indicator for floorbot when line mode is chosen. */
const FloorbotLine = (props) => {
  const { act } = useBackend<SimpleBotContext>();
  const { control } = props;

  return (
    <Tooltip content="Enables straight line tiling mode.">
      <Icon
        color={control[1] ? 'good' : 'gray'}
        name={control[1] ? 'compass' : 'toggle-off'}
        onClick={() => act('line_mode')}
        size={!control[1] ? 2 : 1.5}
      >
        {' '}
        {control[1] ? control[1].toString().charAt(0).toUpperCase() : ''}
      </Icon>
    </Tooltip>
  );
};

/** Slider button for atmosbot breach pressure detection thresholds */
const AtmosbotBreachPressure = (props) => {
  const { act } = useBackend<SimpleBotContext>();
  const { control } = props;

  return (
    <Tooltip content="Adjusts the pressure to scan for breaches at.">
      <Slider
        minValue={0}
        maxValue={100}
        step={5}
        unit="kPa"
        value={control[1]}
        onChange={(_, value) => act(control[0], { pressure: value })}
      />
    </Tooltip>
  );
};

/** Slider button for atmosbot target temperature */
const AtmosbotTargetTemperature = (props) => {
  const { act } = useBackend<SimpleBotContext>();
  const { control } = props;
  const [T0C, T20C] = [273.15, 293.15];

  return (
    <Tooltip content="Adjusts the target temperature.">
      <Slider
        minValue={T0C}
        maxValue={T20C + 20}
        step={1}
        unit="K"
        value={control[1]}
        onChange={(_, value) => act(control[0], { temperature: value })}
      />
    </Tooltip>
  );
};

const AtmosbotScrubbedGasses = (props) => {
  const { act } = useBackend<SimpleBotContext>();
  const { control } = props;
  const gasses = Object.entries(control[1]);

  return (
    <Flex wrap>
      <Section title="Scrubbed gasses">
        {gasses.map((gas) => {
          const gas_id = gas[0];
          const enabled = gas[1];
          return (
            <Button
              key={gas_id}
              icon={enabled ? 'check-square-o' : 'square-o'}
              content={getGasLabel(gas_id)}
              selected={enabled}
              onClick={() => act(control[0], { id: gas_id })}
            />
          );
        })}
      </Section>
    </Flex>
  );
};
