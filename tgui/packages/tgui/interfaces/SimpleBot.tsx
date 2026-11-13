import { capitalizeAll } from 'common/string';
import type { CSSProperties } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Icon, NoticeBox, Slider, Tooltip } from 'tgui/components';
import { getGasLabel } from 'tgui/constants';
import { Window } from 'tgui/layouts';

type SimpleBotContext = {
  can_hack: number;
  locked: number;
  emagged: number;
  model: string;
  ui_colour: string;
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

type Controls = Record<string, any>;

const MODEL_ICONS: Record<string, string> = {
  Medibot: 'vial',
  Floorbot: 'square',
  Atmosbot: 'smog',
  Securitron: 'shield-halved',
  Cleanbot: 'broom',
  Firebot: 'fire-extinguisher',
  'ED-209': 'shield',
  Honkbot: 'bullhorn',
};

/** Fontawesome Icons Used For Bot Buttons */
const TOGGLE_META: Record<string, { icon: string; label?: string }> = {
  speaker: { icon: 'volume' },
  crit_alerts: { icon: 'heart-pulse', label: 'Critical Alerts' },
  stationary_mode: { icon: 'anchor' },
  synth_epi: { icon: 'syringe', label: 'Synthesize Epinephrine' },
  check_id: { icon: 'id-badge', label: 'Check ID' },
  check_weapons: { icon: 'magnifying-glass' },
  check_warrants: { icon: 'file-alt' },
  handcuff_targets: { icon: 'handcuffs' },
  arrest_alert: { icon: 'tower-broadcast' },
  clean_blood: { icon: 'droplet' },
  clean_trash: { icon: 'trash-can' },
  clean_graffiti: { icon: 'spray-can' },
  pest_control: { icon: 'bugs' },
  extinguish_fires: { icon: 'fire-extinguisher' },
  extinguish_people: { icon: 'fire' },
  tile_hull: { icon: 'gear' },
  place_tiles: { icon: 'hammer' },
  place_custom: { icon: 'screwdriver' },
  repair_damage: { icon: 'wrench' },
  traction_magnets: { icon: 'magnet' },
  radio_alerts: { icon: 'tower-cell' },
};

const THRESHOLD_STYLE = {
  heal_threshold_brute: { label: 'Brute', color: 'red' },
  heal_threshold_burn: { label: 'Burn', color: 'orange' },
  heal_threshold_toxin: { label: 'Toxin', color: 'green' },
  heal_threshold_oxy: { label: 'Suffocation', color: 'blue' },
  heal_threshold: { label: 'Total', color: 'white' },
};

/** Special Keys which need independant handling */
const SPECIAL_CONTROL_KEYS = new Set([
  'heal_types',
  'heal_threshold',
  'heal_threshold_brute',
  'heal_threshold_burn',
  'heal_threshold_toxin',
  'heal_threshold_oxy',
  'container',
  'tile_stack',
  'line_mode',
  'ideal_temperature',
  'temperature_control',
  'breach_pressure',
  'scrub_gasses',
  'sync_tech',
  'injection_amount',
]);

export const SimpleBot = (_) => {
  const { data } = useBackend<SimpleBotContext>();
  const { can_hack, locked, ui_colour } = data;
  const access = !locked || can_hack;

  return (
    <Window width={550} height={460}>
      <Window.Content>
        <div
          className="simplebot"
          style={{ '--ui-tint': ui_colour || undefined } as CSSProperties}
        >
          <BotHeader />
          {!access ? (
            <NoticeBox>Locked!</NoticeBox>
          ) : (
            <div className="simplebot_body">
              <CoreSettings />
              <ControlsGrid />
            </div>
          )}
        </div>
      </Window.Content>
    </Window>
  );
};

/** Bot Header + Alaways Accessible Controls */
const BotHeader = (_) => {
  const { act, data } = useBackend<SimpleBotContext>();
  const { can_hack, locked, emagged, pai, model } = data;
  const { allow_pai, card_inserted } = pai;

  return (
    <div className="simplebot_header">
      <div className="simplebot_header_title">
        <Icon name={MODEL_ICONS[model] || 'robot'} size={1.6} />
        <Box fontSize="1.1em" bold>
          {model || 'Automated Unit'}
        </Box>
      </div>
      <div className="simplebot_header_actions">
        {!!allow_pai && (
          <Tooltip
            content={
              card_inserted
                ? 'Eject the inserted pAI card.'
                : 'No active pAI card inserted.'
            }
          >
            <Icon
              className="simplebot_chip"
              name="robot"
              color={card_inserted ? 'good' : 'label'}
              onClick={card_inserted ? () => act('eject_pai') : undefined}
            />
          </Tooltip>
        )}
        {!!can_hack && (
          <Tooltip
            content={
              emagged
                ? 'Resets the bot operating system.'
                : 'Unlocks the safety protocols.'
            }
          >
            <Icon
              className="simplebot_chip"
              name={emagged ? 'bug' : 'lock'}
              color={emagged ? 'bad' : 'label'}
              onClick={() => act('hack')}
            />
          </Tooltip>
        )}
        <Tooltip content={`${locked ? 'Unlock' : 'Lock'} the control panel.`}>
          <Icon
            className="simplebot_chip"
            name={locked ? 'lock' : 'lock-open'}
            color={locked ? 'bad' : 'good'}
            onClick={() => act('lock')}
          />
        </Tooltip>
      </div>
    </div>
  );
};

/** Generic Bot Settings Shared Between All Simplebots. */
const CoreSettings = (_) => {
  const { act, data } = useBackend<SimpleBotContext>();
  const { settings } = data;
  const { airplane_mode, patrol_station, power, booting, maintenance_lock } =
    settings;

  return (
    <div className="simplebot_grid">
      <SettingCard
        icon="power-off"
        label="Power"
        sublabel={power ? 'Online' : booting ? 'Booting\u2026' : 'Offline'}
        state={power ? 'on' : booting ? 'warn' : 'off'}
        tooltip={`Powers ${power ? 'off' : 'on'} the bot.`}
        onClick={() => act('power')}
      />
      <SettingCard
        icon="wifi"
        label="Remote Control"
        sublabel={airplane_mode ? 'Enabled' : 'Disabled'}
        state={airplane_mode ? 'warn' : 'off'}
        tooltip={`${airplane_mode ? 'Disables' : 'Enables'} remote access via PDA app.`}
        onClick={() => act('airplane')}
      />
      <SettingCard
        icon="location-arrow"
        label="Patrol Station"
        sublabel={patrol_station ? 'Patrolling' : 'Stationary'}
        state={patrol_station ? 'on' : 'off'}
        tooltip={`${patrol_station ? 'Disables' : 'Enables'} automatic station patrol.`}
        onClick={() => act('patrol')}
      />
      <SettingCard
        icon="toolbox"
        label="Maintenance"
        sublabel={maintenance_lock ? 'Secured' : 'Open'}
        state={maintenance_lock ? 'warn' : 'off'}
        tooltip={
          maintenance_lock
            ? 'Opens the maintenance hatch for repairs.'
            : 'Closes the maintenance hatch.'
        }
        onClick={() => act('maintenance')}
      />
    </div>
  );
};

const SettingCard = (props: {
  icon: string;
  label: string;
  sublabel: string;
  state: 'on' | 'warn' | 'off';
  tooltip: string;
  onClick: () => void;
}) => {
  const { icon, label, sublabel, state, tooltip, onClick } = props;
  return (
    <Tooltip content={tooltip}>
      <div className={`simplebot_card state-${state}`} onClick={onClick}>
        <Icon name={icon} size={1.6} />
        <Box className="simplebot_card_label">{label}</Box>
        <Box className="simplebot_card_sub">{sublabel}</Box>
      </div>
    </Tooltip>
  );
};

/* Special Keys Handling */
const ControlsGrid = (_) => {
  const { data } = useBackend<SimpleBotContext>();
  const { custom_controls } = data;
  const keys = Object.keys(custom_controls);

  if (!keys.length) {
    return null;
  }

  const hasThresholds = keys.some(
    (key) => key === 'heal_threshold' || key.startsWith('heal_threshold_'),
  );
  const toggles = Object.entries(custom_controls).filter(
    ([key]) => !SPECIAL_CONTROL_KEYS.has(key),
  );

  return (
    <div className="simplebot_grid">
      {hasThresholds && <ThresholdsCard custom_controls={custom_controls} />}
      {custom_controls.container && 'injection_amount' in custom_controls ? (
        <div className="simplebot_medbot_row">
          <SupplyCard custom_controls={custom_controls} />
          <DoseCard value={custom_controls.injection_amount} />
        </div>
      ) : (
        <>
          {(custom_controls.container || custom_controls.tile_stack) && (
            <SupplyCard custom_controls={custom_controls} />
          )}
          {'injection_amount' in custom_controls && (
            <DoseCard value={custom_controls.injection_amount} />
          )}
        </>
      )}
      {'ideal_temperature' in custom_controls && (
        <TemperatureCard custom_controls={custom_controls} />
      )}
      {'breach_pressure' in custom_controls && (
        <PressureCard value={custom_controls.breach_pressure} />
      )}
      {'sync_tech' in custom_controls && (
        <SyncCard value={custom_controls.sync_tech} />
      )}
      {'line_mode' in custom_controls && (
        <DirectionCard value={custom_controls.line_mode} />
      )}
      {'scrub_gasses' in custom_controls && (
        <GasCard value={custom_controls.scrub_gasses} />
      )}
      {toggles.map(([key, value]) => (
        <ToggleCard key={key} ctrlKey={key} value={!!value} />
      ))}
    </div>
  );
};

/** Toggle for Generic Bot Controls. */
const ToggleCard = (props: { ctrlKey: string; value: boolean }) => {
  const { act } = useBackend<SimpleBotContext>();
  const { ctrlKey, value } = props;
  const meta = TOGGLE_META[ctrlKey];
  const label = meta?.label || capitalizeAll(ctrlKey.replace(/_/g, ' '));

  return (
    <Tooltip content={`Toggle ${label.toLowerCase()}.`}>
      <div
        className={`simplebot_card state-${value ? 'on' : 'off'}`}
        onClick={() => act(ctrlKey)}
      >
        <Icon name={meta?.icon || 'cog'} size={1.6} />
        <Box className="simplebot_card_label">{label}</Box>
      </div>
    </Tooltip>
  );
};

/** Controller For Medbots Healing Theshold  */
const ThresholdsCard = (props: { custom_controls: Controls }) => {
  const { act } = useBackend<SimpleBotContext>();
  const { custom_controls } = props;
  const types = (custom_controls.heal_types || {}) as Record<string, boolean>;
  const entries = Object.entries(custom_controls).filter(
    ([key]) => key === 'heal_threshold' || key.startsWith('heal_threshold_'),
  );

  return (
    <div className="simplebot_card wide static">
      <Box className="simplebot_card_label">
        <Icon name="heartbeat" mr={1} />
        Treatment Thresholds
      </Box>
      <Box className="simplebot_card_caption">
        Patients are treated when any enabled threshold is met.
      </Box>
      {entries.map(([key, value]) => {
        const damageType =
          key === 'heal_threshold'
            ? 'total'
            : key.replace('heal_threshold_', '');
        const style = THRESHOLD_STYLE[key];
        const enabled = !!types?.[damageType];
        return (
          <div className="simplebot_threshold_row" key={key}>
            <Button
              compact
              className="simplebot_threshold_label"
              color={enabled ? 'good' : 'bad'}
              tooltip="Toggle checking this damage type."
              onClick={() => act('heal_type', { damage_type: damageType })}
            >
              {style.label}
            </Button>
            <Tooltip
              content={`Treat patients with at least this much ${damageType} damage.`}
            >
              <Slider
                className="simplebot_threshold_slider"
                minValue={10}
                maxValue={100}
                step={5}
                stepPixelSize={20}
                unit="%"
                color={style.color}
                value={value}
                onChange={(_, v) =>
                  act('heal_threshold_type', {
                    damage_type: damageType,
                    threshold: v,
                  })
                }
              />
            </Tooltip>
          </div>
        );
      })}
    </div>
  );
};

/* Medbot Reagent Container and some Tile Stack Handling. */
const SupplyCard = (props: { custom_controls: Controls }) => {
  const { act } = useBackend<SimpleBotContext>();
  const { custom_controls } = props;

  if (custom_controls.container) {
    const { reagent_glass, total_volume, maximum_volume } =
      custom_controls.container;
    return (
      <div className="simplebot_card static simplebot_supply_card">
        <Box className="simplebot_card_label">
          <Icon name="flask" mr={1} color={reagent_glass ? 'good' : 'label'} />
          Reagent Supply
        </Box>
        <div className="simplebot_supply_row">
          <Box>
            {reagent_glass
              ? `${reagent_glass} [${total_volume}/${maximum_volume}]`
              : 'Empty'}
          </Box>
          <Button
            compact
            disabled={!reagent_glass}
            icon="eject"
            onClick={() => act('eject')}
          >
            Eject
          </Button>
        </div>
      </div>
    );
  }

  const { tilestack, amount, max_amount } = custom_controls.tile_stack;
  return (
    <div className="simplebot_card static">
      <Box className="simplebot_card_label">
        <Icon name="th-large" mr={1} color={tilestack ? 'good' : 'label'} />
        Tile Supply
      </Box>
      <div className="simplebot_supply_row">
        <Box>
          {tilestack ? `${tilestack} [${amount}/${max_amount}]` : 'Empty'}
        </Box>
        <Button
          compact
          disabled={!tilestack}
          icon="eject"
          onClick={() => act('eject_tiles')}
        >
          Eject
        </Button>
      </div>
    </div>
  );
};

/* Floorbot Tiling Mode Controller  */
const DirectionCard = (props: { value: any }) => {
  const { act } = useBackend<SimpleBotContext>();
  const { value } = props;
  const active = !!value;

  return (
    <Tooltip content="Enables straight line tiling mode.">
      <div
        className={`simplebot_card state-${active ? 'on' : 'off'}`}
        onClick={() => act('line_mode')}
      >
        <Icon name="compass" size={1.6} />
        <Box className="simplebot_card_label">Line Mode</Box>
        <Box className="simplebot_card_sub">
          {active ? value.toString() : 'Disabled'}
        </Box>
      </div>
    </Tooltip>
  );
};

/* Temperature Control Special Key Handling! */
const TemperatureCard = (props: { custom_controls: Controls }) => {
  const { act } = useBackend<SimpleBotContext>();
  const { custom_controls } = props;
  const [T0C, T20C] = [273.15, 293.15];
  const hasToggle = 'temperature_control' in custom_controls;
  const enabled = hasToggle ? !!custom_controls.temperature_control : true;

  return (
    <div className="simplebot_card wide static">
      <Box className="simplebot_card_label">
        <Icon name="thermometer-half" mr={1} />
        Target Temperature
        {hasToggle && (
          <Button
            compact
            ml={1}
            color={enabled ? 'good' : 'bad'}
            onClick={() => act('temperature_control')}
          >
            {enabled ? 'Active' : 'Disabled'}
          </Button>
        )}
      </Box>
      <Tooltip content="Adjusts the target temperature.">
        <Slider
          minValue={T0C}
          maxValue={T20C + 20}
          step={1}
          stepPixelSize={20}
          unit="K"
          value={custom_controls.ideal_temperature}
          onChange={(_, v) => act('ideal_temperature', { temperature: v })}
        />
      </Tooltip>
    </div>
  );
};

/** Atmosbot Pressure Scan Controller */
const PressureCard = (props: { value: number }) => {
  const { act } = useBackend<SimpleBotContext>();

  return (
    <div className="simplebot_card wide static">
      <Box className="simplebot_card_label">
        <Icon name="wind" mr={1} />
        Breach Detection
      </Box>
      <Tooltip content="Adjusts the pressure to scan for breaches at.">
        <Slider
          minValue={0}
          maxValue={100}
          step={5}
          stepPixelSize={20}
          unit="kPa"
          value={props.value}
          onChange={(_, v) => act('breach_pressure', { pressure: v })}
        />
      </Tooltip>
    </div>
  );
};

/** Medbot Injection Dose Controller */
const DoseCard = (props: { value: number }) => {
  const { act } = useBackend<SimpleBotContext>();

  return (
    <div className="simplebot_card static">
      <Box className="simplebot_card_label">
        <Icon name="syringe" mr={1} />
        Injection Dose
      </Box>
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
          stepPixelSize={50}
          unit="u"
          value={props.value}
          onChange={(_, v) => act('injection_amount', { inject: v })}
        />
      </Tooltip>
    </div>
  );
};

/** Medbot Efficency Synch */
const SyncCard = (props: { value: number }) => {
  const { act } = useBackend<SimpleBotContext>();
  const efficiency = Math.round((props.value || 0) * 100);

  return (
    <Tooltip
      content={`Synchronize surgical data with research network. Currently at: ${efficiency}% efficiency.`}
    >
      <div className="simplebot_card" onClick={() => act('sync_tech')}>
        <Icon name="cloud-download-alt" size={1.6} color="purple" />
        <Box className="simplebot_card_label">Tech Sync</Box>
        <Box className="simplebot_card_sub">{efficiency}%</Box>
      </div>
    </Tooltip>
  );
};

/** Atmosbot's Gas Scrubbing Controls */
const GasCard = (props: { value: Record<string, boolean> }) => {
  const { act } = useBackend<SimpleBotContext>();
  const gasses = Object.entries(props.value || {});

  return (
    <div className="simplebot_card xwide static">
      <Box className="simplebot_card_label">
        <Icon name="wind" mr={1} />
        Gas Scrubbing
      </Box>
      <div className="simplebot_chip_grid">
        {gasses.map(([gasId, enabled]) => (
          <Button
            key={gasId}
            compact
            icon={enabled ? 'check-square-o' : 'square-o'}
            selected={!!enabled}
            onClick={() => act('scrub_gasses', { id: gasId })}
          >
            {getGasLabel(gasId)}
          </Button>
        ))}
      </div>
    </div>
  );
};
