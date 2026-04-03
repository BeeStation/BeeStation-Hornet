import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

// ─── Data types ──────────────────────────────────────────────────────────────

type ThrusterData = {
  name: string;
  ref: string;
  has_fuel: boolean;
  fuel_amount: number;
  fuel_target: number;
  thrust_level: number;
  requested_thrust: number;
  fuel_fault: boolean;
};

type OrbitalData = {
  current_altitude: number;
  orbital_decay: number;
  orbital_velocity_index: number;
  normalized_resistance: number;
  thrust_level: number;
  actual_thrust: number;
  altitude_hold_enabled: boolean;
  altitude_hold_target: number;
  orbital_bands: OrbitalBand[];
  thrusters: ThrusterData[];
};

type OrbitalBand = {
  name: string;
  min_altitude: number;
  max_altitude: number;
  color: string;
  is_mining_regime?: boolean;
};

// ─── Orbital visualization constants ─────────────────────────────────────────

const PLANET_RADIUS = 720;
const MAX_ORBIT_RADIUS = 400;
const MAX_ALTITUDE = 280;
const MIN_ALTITUDE = 0;
const MINING_BAND_MIN = 95;
const MINING_BAND_MAX = 105;
const UNIVERSAL_VERTICAL_OFFSET = -650;

// ─── Orbital warning thresholds ──────────────────────────────────────────────

const CRITICAL_HIGH = 130;
const SAFE_ZONE_MAX = 120;
const SAFE_ZONE_MIN = 95;
const CRITICAL_LOW = 90;

type WarningLevel = 'none' | 'warning' | 'critical';

// ─── Root component ──────────────────────────────────────────────────────────

export const OrbitalHeightControl = () => {
  return (
    <Window width={640} height={620} title="Orbital Height Control">
      <Window.Content scrollable>
        <OrbitalHeightContent />
      </Window.Content>
    </Window>
  );
};

/** Derive warning level & message from the current orbital altitude. */
const getOrbitalWarning = (
  altitude: number,
): { level: WarningLevel; message: string } => {
  if (altitude < CRITICAL_LOW) {
    return {
      level: 'critical',
      message: 'CRITICAL: Orbital decay imminent!',
    };
  }
  if (altitude >= CRITICAL_HIGH) {
    return {
      level: 'critical',
      message: 'CRITICAL: Exceeding safe orbit!',
    };
  }
  if (altitude < SAFE_ZONE_MIN) {
    return { level: 'warning', message: 'Advisory: Low altitude' };
  }
  if (altitude > SAFE_ZONE_MAX) {
    return { level: 'warning', message: 'Warning: High altitude' };
  }
  return { level: 'none', message: '' };
};

const OrbitalHeightContent = () => {
  const { act, data } = useBackend<OrbitalData>();
  const {
    current_altitude = 98,
    orbital_decay = 17.6,
    orbital_velocity_index = 5.4,
    normalized_resistance = 4,
    thrust_level = 0,
    actual_thrust = 0,
    altitude_hold_enabled = false,
    altitude_hold_target = 98000,
    orbital_bands = [],
    thrusters = [],
  } = data;

  const hasLowFuel = thrusters.some((t) => !t.has_fuel);
  const warning = getOrbitalWarning(current_altitude);

  return (
    <Stack vertical fill>
      <Stack.Item>
        {warning.level !== 'none' && (
          <NoticeBox danger={warning.level === 'critical'} mb={1}>
            {warning.message}
          </NoticeBox>
        )}
      </Stack.Item>
      <Stack.Item>
        <Section title="Orbiting: Cinis (Auri-Geminae I)">
          <Stack>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label="Altitude">
                  {current_altitude.toFixed(1)} km
                </LabeledList.Item>
                <LabeledList.Item label="Velocity Index">
                  {orbital_velocity_index.toFixed(2)}
                </LabeledList.Item>
                <LabeledList.Item label="Orbital Decay" color="orange">
                  {orbital_decay.toFixed(2)} m/s
                </LabeledList.Item>
                <LabeledList.Item label="Atmospheric Resistance" color="red">
                  {normalized_resistance.toFixed(1)}%
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item grow>
              <ThrusterStatusPanel
                thrusters={thrusters}
                hasLowFuel={hasLowFuel}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item grow basis="0">
        <Section
          fill
          style={{
            position: 'relative',
            overflow: 'hidden',
          }}
        >
          <ThrustControlPanel
            thrust_level={thrust_level}
            actual_thrust={actual_thrust}
            altitude_hold_enabled={altitude_hold_enabled}
            act={act}
          />
          <AltitudeHoldPanel
            altitude_hold_enabled={altitude_hold_enabled}
            altitude_hold_target={altitude_hold_target}
            act={act}
          />
          <Box
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
            }}
          >
            <PlanetVisualization
              altitude={current_altitude}
              orbitalBands={orbital_bands}
            />
          </Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ThrustControlPanel = (props: {
  thrust_level: number;
  actual_thrust: number;
  altitude_hold_enabled: boolean;
  act: (action: string) => void;
}) => {
  const { thrust_level, actual_thrust, altitude_hold_enabled, act } = props;

  const thrustMismatch = Math.abs(thrust_level - actual_thrust) > 0.1;

  return (
    <Box
      style={{
        position: 'absolute',
        left: '8px',
        top: '8px',
        zIndex: 10,
        width: '110px',
        backgroundColor: 'rgba(0, 0, 0, 0.6)',
        borderRadius: '4px',
        opacity: altitude_hold_enabled ? 0.5 : 1,
        pointerEvents: altitude_hold_enabled ? 'none' : 'auto',
      }}
    >
      <Section title="Thrust">
        <Stack vertical align="center">
          <Stack.Item>
            <Button
              fluid
              icon="chevron-up"
              onClick={() => act('increase_thrust')}
            >
              Increase
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Box bold fontSize="1.8em" textAlign="center" mt={1} mb={0.5}>
              {thrust_level ?? 0}
            </Box>
            <Box color="label" textAlign="center" fontSize="0.9em">
              Set
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Button
              fluid
              icon="chevron-down"
              onClick={() => act('decrease_thrust')}
            >
              Decrease
            </Button>
          </Stack.Item>
          <Stack.Item mt={1}>
            <Tooltip
              content={
                thrustMismatch
                  ? 'Thrusters not operating at commanded level.'
                  : 'Thrusters operating at commanded level.'
              }
            >
              <Box textAlign="center">
                <Box
                  bold
                  fontSize="1.4em"
                  color={thrustMismatch ? 'orange' : 'good'}
                >
                  {actual_thrust.toFixed(1)}
                </Box>
                <Box color="label" fontSize="0.9em">
                  Actual
                </Box>
              </Box>
            </Tooltip>
          </Stack.Item>
        </Stack>
      </Section>
    </Box>
  );
};

const AltitudeHoldPanel = (props: {
  altitude_hold_enabled: boolean;
  altitude_hold_target: number;
  act: (action: string, params?: object) => void;
}) => {
  const { altitude_hold_enabled, altitude_hold_target, act } = props;

  return (
    <Box
      style={{
        position: 'absolute',
        top: '8px',
        left: '50%',
        transform: 'translateX(-50%)',
        zIndex: 10,
      }}
    >
      <Section>
        <Stack align="center">
          <Stack.Item>
            <Box color="label" mr={1}>
              Alt Hold:
            </Box>
          </Stack.Item>
          <Stack.Item>
            <NumberInput
              animated
              value={altitude_hold_target}
              unit="m"
              width="100px"
              minValue={80000}
              maxValue={140000}
              step={1000}
              stepPixelSize={10}
              onChange={(value) =>
                act('set_altitude_hold_target', {
                  target: value,
                })
              }
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon={altitude_hold_enabled ? 'toggle-on' : 'toggle-off'}
              selected={altitude_hold_enabled}
              color={altitude_hold_enabled ? 'good' : 'bad'}
              tooltip={
                altitude_hold_enabled
                  ? 'Altitude hold active - automatic thrust adjustment enabled'
                  : 'Altitude hold inactive - manual thrust control'
              }
              onClick={() => act('toggle_altitude_hold')}
            >
              {altitude_hold_enabled ? 'ON' : 'OFF'}
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </Box>
  );
};

const ThrusterStatusPanel = (props: {
  thrusters: ThrusterData[];
  hasLowFuel: boolean;
}) => {
  const { thrusters, hasLowFuel } = props;

  if (thrusters.length === 0) {
    return (
      <Section title="Thrusters">
        <Box color="label" italic>
          No thrusters detected.
        </Box>
      </Section>
    );
  }

  return (
    <Box
      style={{
        maxHeight: '120px',
        overflowY: 'auto',
      }}
    >
      {thrusters.map((thruster) => (
        <ThrusterStatusRow key={thruster.ref} thruster={thruster} />
      ))}
    </Box>
  );
};

const ThrusterStatusRow = (props: { thruster: ThrusterData }) => {
  const { thruster } = props;
  const fuelPercent = Math.min(
    (thruster.fuel_amount / thruster.fuel_target) * 100,
    100,
  );
  const isLowFuel = !thruster.has_fuel;
  const isFault = thruster.fuel_fault;
  const thrustMismatch = thruster.thrust_level !== thruster.requested_thrust;

  let fuelBarColor: string;
  if (isFault) {
    fuelBarColor = 'bad';
  } else if (isLowFuel) {
    fuelBarColor = 'bad';
  } else if (fuelPercent < 40) {
    fuelBarColor = 'average';
  } else {
    fuelBarColor = 'good';
  }

  // Determine status icon
  let iconName: string;
  let iconColor: string;
  if (isFault) {
    iconName = 'times-circle';
    iconColor = 'red';
  } else if (isLowFuel) {
    iconName = 'exclamation-triangle';
    iconColor = 'red';
  } else {
    iconName = 'check-circle';
    iconColor = 'green';
  }

  return (
    <Box mb={0.5}>
      <Stack align="center">
        <Stack.Item>
          <Icon name={iconName} color={iconColor} />
        </Stack.Item>
        <Stack.Item grow basis="0" ml={1}>
          <Box bold>
            {thruster.name}
            {isFault && (
              <Box as="span" color="red" ml={1}>
                [FAULT]
              </Box>
            )}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Tooltip
            content={`Thrust: ${thruster.thrust_level} / Requested: ${thruster.requested_thrust}`}
          >
            <Box color={thrustMismatch ? 'orange' : 'label'} bold mr={1}>
              T:{thruster.thrust_level}
            </Box>
          </Tooltip>
        </Stack.Item>
        <Stack.Item>
          <Tooltip
            content={`Fuel: ${thruster.fuel_amount.toFixed(1)} / ${thruster.fuel_target} moles`}
          >
            <ProgressBar
              value={fuelPercent / 100}
              color={fuelBarColor}
              width="120px"
            >
              {fuelPercent.toFixed(0)}%
            </ProgressBar>
          </Tooltip>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const PlanetVisualization = (props: {
  altitude: number;
  orbitalBands: OrbitalBand[];
}) => {
  const { altitude, orbitalBands } = props;

  const normalizedAltitude =
    (altitude - MIN_ALTITUDE) / (MAX_ALTITUDE - MIN_ALTITUDE);
  const orbitDistance = PLANET_RADIUS + normalizedAltitude * MAX_ORBIT_RADIUS;

  return (
    <Box
      style={{
        position: 'relative',
        width: '100%',
        height: '100%',
        display: 'flex',
        alignItems: 'flex-end',
        justifyContent: 'center',
      }}
    >
      <Box
        style={{
          position: 'relative',
          width: '100%',
          height: '100%',
          overflow: 'hidden',
          display: 'flex',
          alignItems: 'flex-end',
          justifyContent: 'center',
        }}
      >
        {orbitalBands.map((band, index) => {
          const bandMinNorm =
            (band.min_altitude - MIN_ALTITUDE) / (MAX_ALTITUDE - MIN_ALTITUDE);
          const bandMaxNorm =
            (band.max_altitude - MIN_ALTITUDE) / (MAX_ALTITUDE - MIN_ALTITUDE);
          const innerRadius = PLANET_RADIUS + bandMinNorm * MAX_ORBIT_RADIUS;
          const outerRadius = PLANET_RADIUS + bandMaxNorm * MAX_ORBIT_RADIUS;

          return (
            <Box key={index}>
              <Box
                style={{
                  position: 'absolute',
                  bottom: `${UNIVERSAL_VERTICAL_OFFSET}px`,
                  left: '50%',
                  transform: 'translate(-50%, 50%)',
                  width: `${outerRadius * 2}px`,
                  height: `${outerRadius * 2}px`,
                  borderRadius: '50%',
                  border: `${outerRadius - innerRadius}px solid ${band.color}`,
                  opacity: 0.4,
                  pointerEvents: 'none',
                  boxSizing: 'border-box',
                }}
              />
              {band.is_mining_regime && (
                <>
                  <Box
                    style={{
                      position: 'absolute',
                      bottom: `${UNIVERSAL_VERTICAL_OFFSET + outerRadius}px`,
                      left: '0',
                      right: '0',
                      height: '2px',
                      background:
                        'repeating-linear-gradient(to right, rgba(255, 255, 255, 0.3) 0px, rgba(255, 255, 255, 0.3) 10px, transparent 10px, transparent 20px)',
                      pointerEvents: 'none',
                    }}
                  />
                  <Box
                    style={{
                      position: 'absolute',
                      bottom: `${UNIVERSAL_VERTICAL_OFFSET + innerRadius}px`,
                      left: '0',
                      right: '0',
                      height: '2px',
                      background:
                        'repeating-linear-gradient(to right, rgba(255, 255, 255, 0.3) 0px, rgba(255, 255, 255, 0.3) 10px, transparent 10px, transparent 20px)',
                      pointerEvents: 'none',
                    }}
                  />
                </>
              )}
            </Box>
          );
        })}

        {/* Planet */}
        <Box
          style={{
            position: 'absolute',
            bottom: `${UNIVERSAL_VERTICAL_OFFSET}px`,
            left: '50%',
            transform: 'translate(-50%, 50%)',
            width: `${PLANET_RADIUS * 2}px`,
            height: `${PLANET_RADIUS * 2}px`,
            borderRadius: '50%',
            background:
              'radial-gradient(circle at 30% 30%, #b8b8b8, #6b6b6b 60%, #3a3a3a)',
            boxShadow:
              'inset -20px -20px 40px rgba(0, 0, 0, 0.5), 0 0 30px rgba(0, 0, 0, 0.8)',
            border: '2px solid rgba(128, 128, 128, 0.3)',
          }}
        />

        {/* Orbit ring (dashed) */}
        <Box
          style={{
            position: 'absolute',
            bottom: `${UNIVERSAL_VERTICAL_OFFSET}px`,
            left: '50%',
            transform: 'translate(-50%, 50%)',
            width: `${orbitDistance * 2}px`,
            height: `${orbitDistance * 2}px`,
            borderRadius: '50%',
            border: '2px dashed rgba(255, 255, 255, 0.5)',
            pointerEvents: 'none',
          }}
        />

        {/* Station blip */}
        <Box
          style={{
            position: 'absolute',
            bottom: `${UNIVERSAL_VERTICAL_OFFSET + orbitDistance}px`,
            left: '50%',
            transform: 'translate(-50%, 50%)',
            width: '12px',
            height: '12px',
            borderRadius: '50%',
            backgroundColor: '#ffffff',
            boxShadow: '0 0 6px rgba(255, 255, 255, 0.8)',
            border: '2px solid rgba(200, 200, 200, 0.8)',
            zIndex: 10,
          }}
        />

        {/* Altitude label */}
        <Box
          style={{
            position: 'absolute',
            bottom: `${UNIVERSAL_VERTICAL_OFFSET + orbitDistance - 18}px`,
            left: '50%',
            transform: 'translateX(20px)',
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            padding: '4px 8px',
            borderRadius: '3px',
            border: '1px solid rgba(255, 255, 255, 0.3)',
            color: '#ffffff',
            fontSize: '12px',
            fontWeight: 'bold',
            whiteSpace: 'nowrap',
            zIndex: 10,
          }}
        >
          {(altitude * 1000).toFixed(0)}m
        </Box>

        {/* Altitude line from planet to station */}
        <Box
          style={{
            position: 'absolute',
            bottom: `${UNIVERSAL_VERTICAL_OFFSET + PLANET_RADIUS}px`,
            left: '50%',
            transform: 'translateX(-50%)',
            width: '1px',
            height: `${Math.max(0, orbitDistance - PLANET_RADIUS)}px`,
            backgroundColor: 'rgba(255, 255, 255, 0.4)',
            transformOrigin: 'bottom',
            pointerEvents: 'none',
          }}
        />

        {/* Mining regime scale */}
        <Box
          style={{
            position: 'absolute',
            right: '-20px',
            top: '35px',
            height: '300px',
            width: '100px',
            pointerEvents: 'none',
          }}
        >
          <Box
            bold
            color="label"
            fontSize="10px"
            style={{
              position: 'absolute',
              top: '-24px',
              left: '0px',
              whiteSpace: 'nowrap',
            }}
          >
            Mining Regime
          </Box>
          <svg width="100" height="200" style={{ overflow: 'visible' }}>
            <rect
              x="70"
              y="0"
              width="10"
              height="200"
              fill="rgba(0, 0, 0, 0.6)"
              stroke="rgba(255, 255, 255, 0.4)"
              strokeWidth="1"
              rx="2"
            />

            {Array.from({ length: 11 }, (_, i) => {
              const altitudeValue =
                MINING_BAND_MAX -
                (i * (MINING_BAND_MAX - MINING_BAND_MIN)) / 10;
              const yPosition = (i / 10) * 200;
              return (
                <g key={i}>
                  <line
                    x1="65"
                    y1={yPosition}
                    x2="70"
                    y2={yPosition}
                    stroke="rgba(255, 255, 255, 0.5)"
                    strokeWidth="1"
                  />
                  {i % 2 === 0 && (
                    <text
                      x="60"
                      y={yPosition}
                      fill="rgba(255, 255, 255, 0.7)"
                      fontSize="10px"
                      textAnchor="end"
                      dominantBaseline="middle"
                    >
                      {altitudeValue.toFixed(0)}
                    </text>
                  )}
                </g>
              );
            })}

            {altitude >= MINING_BAND_MIN && altitude <= MINING_BAND_MAX && (
              <>
                <line
                  x1="70"
                  y1={
                    ((MINING_BAND_MAX - altitude) /
                      (MINING_BAND_MAX - MINING_BAND_MIN)) *
                    200
                  }
                  x2="100"
                  y2={
                    ((MINING_BAND_MAX - altitude) /
                      (MINING_BAND_MAX - MINING_BAND_MIN)) *
                    200
                  }
                  stroke="white"
                  strokeWidth="2"
                  strokeDasharray="6,3"
                />
                <circle
                  cx="75"
                  cy={
                    ((MINING_BAND_MAX - altitude) /
                      (MINING_BAND_MAX - MINING_BAND_MIN)) *
                    200
                  }
                  r="4"
                  fill="white"
                  stroke="rgba(255, 255, 255, 0.8)"
                  strokeWidth="1"
                />
              </>
            )}
          </svg>
        </Box>
      </Box>
    </Box>
  );
};
