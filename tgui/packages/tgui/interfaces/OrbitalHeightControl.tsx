import { useBackend } from '../backend';
import { Box, NumberInput, Section, Stack, Tooltip } from '../components';
import {
  BigNumericDisplay,
  CompactNumericDisplay,
  ExpandablePanel,
  labelStyle,
  ReadoutBox,
  ScanLineOverlay,
  SciFi,
  SciFiActionButton,
  SciFiWindow,
  StatusBar,
  StatusIcon,
  ToggleButton,
  WarningBanner,
  type WarningLevel,
} from './common/SciFiTheme';

// ─── Data types (specific to the orbital console) ────────────────────────────

type ThrusterData = {
  name: string;
  ref: string;
  has_fuel: boolean;
  fuel_amount: number;
  fuel_target: number;
  thrust_level: number;
  requested_thrust: number;
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

// ─── Root component ──────────────────────────────────────────────────────────

export const OrbitalHeightControl = () => {
  return (
    <SciFiWindow width={640} height={620}>
      <OrbitalHeightContent />
    </SciFiWindow>
  );
};

/** Derive warning level & message from the current orbital altitude. */
const getOrbitalWarning = (
  altitude: number,
): { level: WarningLevel; message: string } => {
  if (altitude < CRITICAL_LOW) {
    return { level: 'critical', message: '⚠ CRITICAL: ORBITAL DECAY IMMINENT ⚠' };
  }
  if (altitude >= CRITICAL_HIGH) {
    return { level: 'critical', message: '⚠ CRITICAL: EXCEEDING SAFE ORBIT ⚠' };
  }
  if (altitude < SAFE_ZONE_MIN) {
    return { level: 'warning', message: '⚠ ADVISORY: LOW ALTITUDE ⚠' };
  }
  if (altitude > SAFE_ZONE_MAX) {
    return { level: 'warning', message: '⚠ WARNING: HIGH ALTITUDE ⚠' };
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
    <>
      <ScanLineOverlay />
      <Stack vertical fill>
        <Stack.Item>
          <Section
            title=">>> ORBITING: CINIS (AURI-GEMINAE I) <<<"
            style={{
              fontFamily: SciFi.font,
              borderColor: SciFi.accent,
              borderWidth: '2px',
              backgroundColor: SciFi.bgPanel,
              boxShadow: `0 0 15px ${SciFi.accentDim}, inset 0 0 20px ${SciFi.accentFaint}`,
            }}
          >
            <Stack vertical>
              <Stack.Item>
                <Stack>
                  <Stack.Item grow>
                    <ReadoutBox
                      label="ALT"
                      value={`${current_altitude.toFixed(1)} km`}
                      color="turquoise"
                      tooltip="The station's current distance from the planet's surface"
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <ReadoutBox
                      label="VEL_IDX"
                      value={orbital_velocity_index.toFixed(2)}
                      color="turquoise"
                      tooltip="Indicates vertical orbital velocity on a -10 to +10 scale relative to optimal parameters"
                      textAlign="right"
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack>
                  <Stack.Item grow>
                    <ReadoutBox
                      label="DECAY"
                      value={`${orbital_decay.toFixed(2)} m/s`}
                      color="orange"
                      tooltip="The rate at which the station's orbit is decaying due to atmospheric drag"
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <ReadoutBox
                      label="ATM_RES"
                      value={`${normalized_resistance.toFixed(1)}%`}
                      color="red"
                      tooltip="Atmospheric density affecting orbital stability - higher values increase drag"
                      textAlign="right"
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>

        <Stack.Item grow basis="0">
          <Section
            fill
            style={{
              backgroundColor: SciFi.bgSurface,
              border: `2px solid ${SciFi.accentDim}`,
              boxShadow: 'inset 0 0 20px rgba(0, 0, 0, 0.8)',
              position: 'relative',
              padding: '8px',
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
            <WarningBanner level={warning.level} message={warning.message} />
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
        <Stack.Item>
          <ThrusterStatusPanel
            thrusters={thrusters}
            hasLowFuel={hasLowFuel}
          />
        </Stack.Item>
      </Stack>
    </>
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

  // Colors for the SET display depend on sign of thrust
  const setColor = thrust_level >= 0 ? SciFi.green : SciFi.redBright;
  const setGlow = thrust_level >= 0 ? SciFi.greenGlow : SciFi.redBrightGlow;

  // Colors for the ACTUAL display depend on mismatch + sign
  const actualColor = thrustMismatch
    ? SciFi.amber
    : actual_thrust >= 0
      ? SciFi.accent
      : SciFi.redBright;
  const actualGlow = thrustMismatch
    ? SciFi.amberGlow
    : actual_thrust >= 0
      ? SciFi.accentGlow
      : SciFi.redBrightGlow;
  const actualBorder = thrustMismatch
    ? `rgba(255, 165, 0, 0.6)`
    : `rgba(64, 224, 208, 0.4)`;

  return (
    <Box
      style={{
        position: 'absolute',
        left: '10px',
        top: '10px',
        zIndex: 10,
        width: '100px',
        backgroundColor: SciFi.bgOverlay,
        border: altitude_hold_enabled
          ? `2px solid ${SciFi.accentDim}`
          : `2px solid ${SciFi.accent}`,
        borderRadius: '4px',
        boxShadow: altitude_hold_enabled
          ? `0 0 5px ${SciFi.accentSubtle}`
          : `0 0 10px ${SciFi.accentDim}`,
        padding: '8px',
        opacity: altitude_hold_enabled ? 0.5 : 1,
        filter: altitude_hold_enabled ? 'grayscale(0.6)' : 'none',
        transition: 'all 0.3s ease',
        pointerEvents: altitude_hold_enabled ? 'none' : 'auto',
      }}
    >
      <Box
        style={{
          ...labelStyle(SciFi.accent),
          textAlign: 'center',
          marginBottom: '8px',
          borderBottom: `1px solid ${SciFi.accentDim}`,
          paddingBottom: '4px',
        }}
      >
        THRUST
      </Box>

      <SciFiActionButton
        onClick={() => act('increase_thrust')}
        style={{ marginBottom: '8px' }}
      >
        ▲
      </SciFiActionButton>

      <Box style={{ marginBottom: '8px' }}>
        <BigNumericDisplay
          value={thrust_level ?? 0}
          label="SET"
          color={setColor}
          glowColor={setGlow}
          borderColor="rgba(0, 255, 0, 0.6)"
        />
      </Box>

      <SciFiActionButton onClick={() => act('decrease_thrust')}>
        ▼
      </SciFiActionButton>

      {/* Actual thrust output indicator */}
      <Box style={{ marginTop: '8px' }}>
        <CompactNumericDisplay
          value={actual_thrust.toFixed(1)}
          label="ACTUAL"
          color={actualColor}
          glowColor={actualGlow}
          borderColor={actualBorder}
          tooltip={
            thrustMismatch
              ? 'Thrusters not operating at commanded level. Please check system status.'
              : 'Thrusters operating at commanded level'
          }
        />
      </Box>
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
        top: '10px',
        left: '50%',
        transform: 'translateX(-50%)',
        zIndex: 10,
        backgroundColor: SciFi.bgOverlay,
        border: `2px solid ${SciFi.accent}`,
        borderRadius: '4px',
        boxShadow: `0 0 10px ${SciFi.accentDim}`,
        padding: '6px 10px',
      }}
    >
      <Stack align="center" fill>
        <Stack.Item>
          <Box
            style={{
              ...labelStyle(SciFi.accent, '10px'),
              letterSpacing: '1.5px',
              marginRight: '8px',
              whiteSpace: 'nowrap',
            }}
          >
            ALT_HOLD:
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
          <ToggleButton
            enabled={altitude_hold_enabled}
            tooltip={
              altitude_hold_enabled
                ? 'Altitude hold active - automatic thrust adjustment enabled'
                : 'Altitude hold inactive - manual thrust control'
            }
            onClick={() => act('toggle_altitude_hold')}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const ThrusterStatusPanel = (props: {
  thrusters: ThrusterData[];
  hasLowFuel: boolean;
}) => {
  const { thrusters, hasLowFuel } = props;

  if (thrusters.length === 0) {
    return null;
  }

  return (
    <ExpandablePanel
      title="THRUSTER STATUS"
      count={thrusters.length}
      alert={hasLowFuel}
      alertText="⚠ LOW FUEL"
      defaultExpanded={hasLowFuel}
    >
      <Stack vertical>
        {thrusters.map((thruster) => (
          <Stack.Item key={thruster.ref}>
            <ThrusterStatusRow thruster={thruster} />
          </Stack.Item>
        ))}
      </Stack>
    </ExpandablePanel>
  );
};

const ThrusterStatusRow = (props: { thruster: ThrusterData }) => {
  const { thruster } = props;
  const fuelPercent = Math.min(
    (thruster.fuel_amount / thruster.fuel_target) * 100,
    100,
  );
  const isLowFuel = !thruster.has_fuel;

  // Determine fuel bar color
  let fuelColor: string;
  let fuelGlow: string;
  if (isLowFuel) {
    fuelColor = SciFi.redBright;
    fuelGlow = 'rgba(255, 68, 68, 0.6)';
  } else if (fuelPercent < 40) {
    fuelColor = SciFi.amber;
    fuelGlow = 'rgba(255, 165, 0, 0.6)';
  } else {
    fuelColor = SciFi.green;
    fuelGlow = SciFi.greenDim;
  }

  const thrustMismatch = thruster.thrust_level !== thruster.requested_thrust;
  const thrustColor = thrustMismatch ? SciFi.amber : SciFi.accent;
  const thrustGlow = thrustMismatch ? SciFi.amberGlow : 'rgba(64, 224, 208, 0.6)';

  return (
    <Box
      style={{
        backgroundColor: SciFi.bgSurface,
        border: isLowFuel
          ? `1px solid rgba(255, 68, 68, 0.4)`
          : `1px solid ${SciFi.accentSubtle}`,
        borderRadius: '2px',
        padding: '4px 8px',
      }}
    >
      <Stack align="center">
        <Stack.Item grow basis="0">
          <Stack align="center">
            <Stack.Item>
              <StatusIcon
                ok={!isLowFuel}
                okTooltip="Thruster fuel nominal"
                alertTooltip="Thruster has insufficient fuel!"
              />
            </Stack.Item>
            <Stack.Item grow>
              <Box
                style={{
                  ...labelStyle(SciFi.accent, '10px'),
                  letterSpacing: '1px',
                  whiteSpace: 'nowrap',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                }}
              >
                {thruster.name}
              </Box>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Tooltip
            content={`Thrust: ${thruster.thrust_level} / Requested: ${thruster.requested_thrust}`}
          >
            <Box
              style={{
                fontFamily: SciFi.font,
                color: thrustColor,
                fontSize: '10px',
                fontWeight: 'bold',
                textShadow: `0 0 5px ${thrustGlow}`,
                marginRight: '10px',
                whiteSpace: 'nowrap',
              }}
            >
              T:{thruster.thrust_level}
            </Box>
          </Tooltip>
        </Stack.Item>
        <Stack.Item>
          <StatusBar
            percent={fuelPercent}
            color={fuelColor}
            glowColor={fuelGlow}
            borderColor={
              isLowFuel ? SciFi.redBrightDim : SciFi.accentDim
            }
            tooltip={`Fuel: ${thruster.fuel_amount.toFixed(1)} / ${thruster.fuel_target} moles`}
          />
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

  // Calculate position of the orbital blip
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
            border: `2px dashed rgba(64, 224, 208, 0.6)`,
            pointerEvents: 'none',
            boxShadow: `0 0 5px ${SciFi.accentDim}`,
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
            backgroundColor: SciFi.accent,
            boxShadow: `0 0 10px ${SciFi.accent}, 0 0 20px ${SciFi.accent}, 0 0 30px rgba(64, 224, 208, 0.5)`,
            border: `2px solid ${SciFi.accentGlow}`,
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
            backgroundColor: 'rgba(0, 0, 0, 0.95)',
            padding: '8px 12px',
            borderRadius: '3px',
            border: `2px solid ${SciFi.accent}`,
            color: SciFi.accent,
            fontSize: '14px',
            fontWeight: 'bold',
            fontFamily: SciFi.font,
            whiteSpace: 'nowrap',
            zIndex: 10,
            boxShadow: `0 0 15px rgba(64, 224, 208, 0.6), inset 0 0 8px ${SciFi.accentSubtle}`,
            textShadow: `0 0 5px ${SciFi.accent}`,
            letterSpacing: '1px',
          }}
        >
          [{(altitude * 1000).toFixed(0)}m]
        </Box>

        {/* Altitude line from planet to station */}
        <Box
          style={{
            position: 'absolute',
            bottom: `${UNIVERSAL_VERTICAL_OFFSET + PLANET_RADIUS}px`,
            left: '50%',
            transform: 'translateX(-50%)',
            width: '2px',
            height: `${Math.max(0, orbitDistance - PLANET_RADIUS)}px`,
            background: `linear-gradient(to top, ${SciFi.accentGlow}, ${SciFi.accentDim})`,
            transformOrigin: 'bottom',
            pointerEvents: 'none',
          }}
        />

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
          {/* Mining Regime label above the scale */}
          <Box
            style={{
              position: 'absolute',
              top: '-28px',
              left: '-35px',
              ...labelStyle(SciFi.accent),
              textAlign: 'left',
              width: '115%',
              whiteSpace: 'nowrap',
              backgroundColor: SciFi.bgInset,
              padding: '2px 6px',
              border: `1px solid rgba(64, 224, 208, 0.5)`,
              borderRadius: '2px',
            }}
          >
            MINING_REGIME
          </Box>
          <svg width="100" height="200" style={{ overflow: 'visible' }}>
            <rect
              x="70"
              y="0"
              width="10"
              height="200"
              fill={SciFi.bgDarkest}
              stroke={SciFi.accent}
              strokeWidth="2"
              rx="2"
            />

            <rect
              x="71"
              y="1"
              width="8"
              height="198"
              fill="url(#scaleGradient)"
              rx="1"
            />
            <defs>
              <linearGradient
                id="scaleGradient"
                x1="0%"
                y1="0%"
                x2="0%"
                y2="100%"
              >
                <stop
                  offset="0%"
                  style={{
                    stopColor: SciFi.accentSubtle,
                    stopOpacity: 1,
                  }}
                />
                <stop
                  offset="50%"
                  style={{
                    stopColor: SciFi.accentFaint,
                    stopOpacity: 1,
                  }}
                />
                <stop
                  offset="100%"
                  style={{
                    stopColor: SciFi.accentSubtle,
                    stopOpacity: 1,
                  }}
                />
              </linearGradient>
            </defs>

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
                    stroke={SciFi.accent}
                    strokeWidth="2"
                  />
                  {i % 2 === 0 && (
                    <text
                      x="60"
                      y={yPosition}
                      fill={SciFi.accent}
                      fontSize="11px"
                      fontFamily={SciFi.font}
                      textAnchor="end"
                      dominantBaseline="middle"
                      fontWeight="bold"
                      style={{
                        textShadow: `0 0 5px ${SciFi.accentGlow}`,
                        filter: `drop-shadow(0 0 3px rgba(64, 224, 208, 0.6))`,
                      }}
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
                  stroke={SciFi.green}
                  strokeWidth="3"
                  strokeDasharray="6,3"
                  style={{
                    filter: `drop-shadow(0 0 3px ${SciFi.greenGlow})`,
                  }}
                />
                <circle
                  cx="75"
                  cy={
                    ((MINING_BAND_MAX - altitude) /
                      (MINING_BAND_MAX - MINING_BAND_MIN)) *
                    200
                  }
                  r="4"
                  fill={SciFi.green}
                  stroke={SciFi.white}
                  strokeWidth="1"
                  style={{ filter: `drop-shadow(0 0 5px ${SciFi.green})` }}
                />
              </>
            )}
          </svg>
        </Box>
      </Box>
    </Box>
  );
};
