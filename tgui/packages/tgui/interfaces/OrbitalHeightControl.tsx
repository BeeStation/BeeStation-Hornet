import { useBackend } from '../backend';
import {
  Box,
  Button,
  NumberInput,
  Section,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

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
};

type OrbitalBand = {
  name: string;
  min_altitude: number;
  max_altitude: number;
  color: string;
  is_mining_regime?: boolean;
};

// Constants for visualization
const PLANET_RADIUS = 720;
const MAX_ORBIT_RADIUS = 400;
const MAX_ALTITUDE = 280;
const MIN_ALTITUDE = 0;
const MINING_BAND_MIN = 95;
const MINING_BAND_MAX = 105;
const UNIVERSAL_VERTICAL_OFFSET = -650;

export const OrbitalHeightControl = () => {
  return (
    <Window width={640} height={580}>
      <Window.Content
        style={{
          fontFamily: 'Consolas, "Courier New", monospace',
          background: 'linear-gradient(180deg, #0a0a0a 0%, #1a1a1a 100%)',
        }}
      >
        <OrbitalHeightContent />
      </Window.Content>
    </Window>
  );
};

const OrbitalWarning = (props: { current_altitude: number }) => {
  const { current_altitude } = props;

  // Define danger thresholds based on the orbital bands
  const CRITICAL_HIGH = 130; // km
  const SAFE_ZONE_MAX = 120; // km
  const SAFE_ZONE_MIN = 95; // km
  const CRITICAL_LOW = 90; // km

  let warningLevel: 'none' | 'warning' | 'critical' = 'none';
  let warningMessage = '';

  if (current_altitude < CRITICAL_LOW) {
    warningLevel = 'critical';
    warningMessage = '⚠ CRITICAL: ORBITAL DECAY IMMINENT ⚠';
  } else if (current_altitude >= CRITICAL_HIGH) {
    warningLevel = 'critical';
    warningMessage = '⚠ CRITICAL: EXCEEDING SAFE ORBIT ⚠';
  } else if (current_altitude < SAFE_ZONE_MIN) {
    warningLevel = 'warning';
    warningMessage = '⚠ ADVISORY: LOW ALTITUDE ⚠';
  } else if (current_altitude > SAFE_ZONE_MAX) {
    warningLevel = 'warning';
    warningMessage = '⚠ WARNING: HIGH ALTITUDE ⚠';
  }

  if (warningLevel === 'none') {
    return null;
  }

  const isCritical = warningLevel === 'critical';

  return (
    <Box
      style={{
        position: 'absolute',
        top: '90px',
        left: '50%',
        transform: 'translateX(-50%)',
        zIndex: 10,
        backgroundColor: isCritical
          ? 'rgba(139, 0, 0, 0.9)'
          : 'rgba(255, 140, 0, 0.85)',
        border: isCritical
          ? '2px solid rgba(255, 0, 0, 0.8)'
          : '2px solid rgba(255, 200, 0, 0.9)',
        borderRadius: '4px',
        boxShadow: isCritical
          ? '0 0 20px rgba(255, 0, 0, 0.6), inset 0 0 15px rgba(255, 0, 0, 0.2)'
          : '0 0 15px rgba(255, 200, 0, 0.6), inset 0 0 10px rgba(255, 140, 0, 0.2)',
        padding: '6px 16px',
      }}
    >
      <Box
        style={{
          fontFamily: 'Consolas, "Courier New", monospace',
          color: isCritical ? '#ff0000' : '#ffff00',
          fontSize: '12px',
          fontWeight: 'bold',
          textTransform: 'uppercase',
          letterSpacing: '2px',
          textShadow: isCritical
            ? '0 0 10px rgba(255, 0, 0, 1), 0 0 20px rgba(255, 0, 0, 0.5)'
            : '0 0 10px rgba(255, 255, 0, 1), 0 0 5px rgba(0, 0, 0, 1)',
          whiteSpace: 'nowrap',
          textAlign: 'center',
        }}
      >
        {warningMessage}
      </Box>
    </Box>
  );
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
  } = data;

  return (
    <>
      {/* Scan line effect overlay */}
      <Box
        style={{
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background:
            'repeating-linear-gradient(0deg, rgba(0, 0, 0, 0.15), rgba(0, 0, 0, 0.15) 1px, transparent 1px, transparent 2px)',
          pointerEvents: 'none',
          zIndex: 9999,
        }}
      />
      <Stack vertical fill>
        <Stack.Item>
          <Section
            title=">>> ORBITING: CINIS (AURI-GEMINAE I) <<<"
            style={{
              fontFamily: 'Consolas, "Courier New", monospace',
              borderColor: '#40e0d0',
              borderWidth: '2px',
              backgroundColor: 'rgba(0, 20, 20, 0.6)',
              boxShadow:
                '0 0 15px rgba(64, 224, 208, 0.3), inset 0 0 20px rgba(64, 224, 208, 0.05)',
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
              backgroundColor: 'rgba(0, 0, 0, 0.4)',
              border: '2px solid rgba(64, 224, 208, 0.3)',
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
            <OrbitalWarning current_altitude={current_altitude} />
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
    </>
  );
};

const ReadoutBox = (props: {
  label: string;
  value: string;
  color: 'turquoise' | 'orange' | 'red';
  tooltip: string;
  textAlign?: string;
}) => {
  const { label, value, color, tooltip, textAlign = 'left' } = props;

  const colorMap = {
    turquoise: {
      color: '#40e0d0',
      shadow: 'rgba(64, 224, 208, 0.8)',
      bg: 'rgba(64, 224, 208, 0.05)',
      border: 'rgba(64, 224, 208, 0.3)',
    },
    orange: {
      color: '#ff9933',
      shadow: 'rgba(255, 153, 51, 0.8)',
      bg: 'rgba(255, 153, 51, 0.08)',
      border: 'rgba(255, 153, 51, 0.3)',
    },
    red: {
      color: '#ff6666',
      shadow: 'rgba(255, 102, 102, 0.8)',
      bg: 'rgba(255, 102, 102, 0.08)',
      border: 'rgba(255, 102, 102, 0.3)',
    },
  };

  const colors = colorMap[color];

  return (
    <Tooltip content={tooltip}>
      <Box
        fontSize="1.1em"
        bold
        textAlign={textAlign}
        style={{
          fontFamily: 'Consolas, "Courier New", monospace',
          color: colors.color,
          textShadow: `0 0 5px ${colors.shadow}`,
          backgroundColor: colors.bg,
          padding: '4px 8px',
          borderRadius: '2px',
          border: `1px solid ${colors.border}`,
        }}
      >
        [{label}: {value}]
      </Box>
    </Tooltip>
  );
};

const ThrustControlPanel = (props: {
  thrust_level: number;
  actual_thrust: number;
  altitude_hold_enabled: boolean;
  act: (action: string) => void;
}) => {
  const { thrust_level, actual_thrust, altitude_hold_enabled, act } = props;

  const buttonStyle = {
    fontFamily: 'Consolas, "Courier New", monospace',
    fontWeight: 'bold',
    fontSize: '1.5em',
    padding: '10px 20',
    textAlign: 'center' as const,
    backgroundColor: 'rgba(64, 224, 208, 0.15)',
    border: '2px solid #40e0d0',
    boxShadow:
      '0 0 10px rgba(64, 224, 208, 0.4), inset 0 0 10px rgba(64, 224, 208, 0.1)',
  };

  // Determine if actual thrust differs from set thrust
  const thrustMismatch = Math.abs(thrust_level - actual_thrust) > 0.1;

  return (
    <Box
      style={{
        position: 'absolute',
        left: '10px',
        top: '10px',
        zIndex: 10,
        width: '100px',
        backgroundColor: 'rgba(0, 0, 0, 0.85)',
        border: altitude_hold_enabled
          ? '2px solid rgba(64, 224, 208, 0.3)'
          : '2px solid #40e0d0',
        borderRadius: '4px',
        boxShadow: altitude_hold_enabled
          ? '0 0 5px rgba(64, 224, 208, 0.15)'
          : '0 0 10px rgba(64, 224, 208, 0.3)',
        padding: '8px',
        opacity: altitude_hold_enabled ? 0.5 : 1,
        filter: altitude_hold_enabled ? 'grayscale(0.6)' : 'none',
        transition: 'all 0.3s ease',
        pointerEvents: altitude_hold_enabled ? 'none' : 'auto',
      }}
    >
      <Box
        style={{
          fontFamily: 'Consolas, "Courier New", monospace',
          color: '#40e0d0',
          fontSize: '11px',
          fontWeight: 'bold',
          textAlign: 'center',
          marginBottom: '8px',
          textTransform: 'uppercase',
          letterSpacing: '2px',
          textShadow: '0 0 8px rgba(64, 224, 208, 0.8)',
          borderBottom: '1px solid rgba(64, 224, 208, 0.3)',
          paddingBottom: '4px',
        }}
      >
        THRUST
      </Box>

      <Button
        fluid
        onClick={() => act('increase_thrust')}
        style={{ ...buttonStyle, marginBottom: '8px' }}
      >
        ▲
      </Button>

      <Box
        style={{
          backgroundColor: 'rgba(0, 0, 0, 0.8)',
          border: '2px solid rgba(0, 255, 0, 0.6)',
          borderRadius: '4px',
          padding: '20px 10px',
          marginBottom: '8px',
          textAlign: 'center',
          boxShadow:
            '0 0 15px rgba(0, 255, 0, 0.3), inset 0 0 10px rgba(0, 255, 0, 0.1)',
        }}
      >
        <Box
          style={{
            fontFamily: 'Consolas, "Courier New", monospace',
            color: thrust_level >= 0 ? '#00ff00' : '#ff4444',
            fontSize: '3em',
            fontWeight: 'bold',
            textShadow:
              thrust_level >= 0
                ? '0 0 10px rgba(0, 255, 0, 0.8), 0 0 20px rgba(0, 255, 0, 0.4)'
                : '0 0 10px rgba(255, 68, 68, 0.8), 0 0 20px rgba(255, 68, 68, 0.4)',
            lineHeight: '1',
          }}
        >
          {thrust_level ?? 0}
        </Box>
        <Box
          style={{
            fontFamily: 'Consolas, "Courier New", monospace',
            color: '#00ff00',
            fontSize: '0.7em',
            marginTop: '8px',
            textTransform: 'uppercase',
            letterSpacing: '2px',
            textShadow: '0 0 5px rgba(0, 255, 0, 0.8)',
          }}
        >
          SET
        </Box>
      </Box>

      <Button fluid onClick={() => act('decrease_thrust')} style={buttonStyle}>
        ▼
      </Button>

      {/* Actual thrust output indicator */}
      <Tooltip
        content={
          thrustMismatch
            ? 'Thrusters not operating at commanded level. Please check system status.'
            : 'Thrusters operating at commanded level'
        }
      >
        <Box
          style={{
            backgroundColor: 'rgba(0, 0, 0, 0.9)',
            border: thrustMismatch
              ? '2px solid rgba(255, 165, 0, 0.6)'
              : '2px solid rgba(64, 224, 208, 0.4)',
            borderRadius: '4px',
            padding: '8px 6px',
            marginTop: '8px',
            textAlign: 'center',
            boxShadow: thrustMismatch
              ? '0 0 10px rgba(255, 165, 0, 0.3), inset 0 0 8px rgba(255, 165, 0, 0.1)'
              : '0 0 8px rgba(64, 224, 208, 0.2), inset 0 0 5px rgba(64, 224, 208, 0.05)',
          }}
        >
          <Box
            style={{
              fontFamily: 'Consolas, "Courier New", monospace',
              color: thrustMismatch
                ? '#ffa500'
                : actual_thrust >= 0
                  ? '#40e0d0'
                  : '#ff4444',
              fontSize: '1.8em',
              fontWeight: 'bold',
              textShadow: thrustMismatch
                ? '0 0 8px rgba(255, 165, 0, 0.8)'
                : actual_thrust >= 0
                  ? '0 0 8px rgba(64, 224, 208, 0.8)'
                  : '0 0 8px rgba(255, 68, 68, 0.8)',
              lineHeight: '1',
            }}
          >
            {actual_thrust.toFixed(1)}
          </Box>
          <Box
            style={{
              fontFamily: 'Consolas, "Courier New", monospace',
              color: thrustMismatch ? '#ffa500' : '#40e0d0',
              fontSize: '0.6em',
              marginTop: '4px',
              textTransform: 'uppercase',
              letterSpacing: '1.5px',
              textShadow: thrustMismatch
                ? '0 0 5px rgba(255, 165, 0, 0.8)'
                : '0 0 5px rgba(64, 224, 208, 0.8)',
            }}
          >
            ACTUAL
          </Box>
        </Box>
      </Tooltip>
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
        backgroundColor: 'rgba(0, 0, 0, 0.85)',
        border: '2px solid #40e0d0',
        borderRadius: '4px',
        boxShadow: '0 0 10px rgba(64, 224, 208, 0.3)',
        padding: '6px 10px',
      }}
    >
      <Stack align="center" fill>
        <Stack.Item>
          <Box
            style={{
              fontFamily: 'Consolas, "Courier New", monospace',
              color: '#40e0d0',
              fontSize: '10px',
              fontWeight: 'bold',
              textTransform: 'uppercase',
              letterSpacing: '1.5px',
              textShadow: '0 0 8px rgba(64, 224, 208, 0.8)',
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
          <Tooltip
            content={
              altitude_hold_enabled
                ? 'Altitude hold active - automatic thrust adjustment enabled'
                : 'Altitude hold inactive - manual thrust control'
            }
          >
            <Button
              onClick={() => act('toggle_altitude_hold')}
              style={{
                fontFamily: 'Consolas, "Courier New", monospace',
                fontWeight: 'bold',
                fontSize: '0.85em',
                padding: '4px 12px',
                backgroundColor: altitude_hold_enabled
                  ? 'rgba(0, 255, 0, 0.2)'
                  : 'rgba(255, 0, 0, 0.15)',
                border: altitude_hold_enabled
                  ? '2px solid rgba(0, 255, 0, 0.6)'
                  : '2px solid rgba(255, 0, 0, 0.4)',
                color: altitude_hold_enabled ? '#00ff00' : '#ff6666',
                boxShadow: altitude_hold_enabled
                  ? '0 0 8px rgba(0, 255, 0, 0.4), inset 0 0 8px rgba(0, 255, 0, 0.1)'
                  : '0 0 8px rgba(255, 0, 0, 0.3), inset 0 0 8px rgba(255, 0, 0, 0.1)',
                textShadow: altitude_hold_enabled
                  ? '0 0 6px rgba(0, 255, 0, 0.8)'
                  : '0 0 6px rgba(255, 0, 0, 0.8)',
                textTransform: 'uppercase',
                letterSpacing: '1px',
                whiteSpace: 'nowrap',
              }}
            >
              {altitude_hold_enabled ? '● ON' : '○ OFF'}
            </Button>
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

        <Box
          style={{
            position: 'absolute',
            bottom: `${UNIVERSAL_VERTICAL_OFFSET}px`,
            left: '50%',
            transform: 'translate(-50%, 50%)',
            width: `${orbitDistance * 2}px`,
            height: `${orbitDistance * 2}px`,
            borderRadius: '50%',
            border: '2px dashed rgba(64, 224, 208, 0.6)',
            pointerEvents: 'none',
            boxShadow: '0 0 5px rgba(64, 224, 208, 0.3)',
          }}
        />

        <Box
          style={{
            position: 'absolute',
            bottom: `${UNIVERSAL_VERTICAL_OFFSET + orbitDistance}px`,
            left: '50%',
            transform: 'translate(-50%, 50%)',
            width: '12px',
            height: '12px',
            borderRadius: '50%',
            backgroundColor: '#40e0d0',
            boxShadow:
              '0 0 10px #40e0d0, 0 0 20px #40e0d0, 0 0 30px rgba(64, 224, 208, 0.5)',
            border: '2px solid rgba(64, 224, 208, 0.8)',
            zIndex: 10,
          }}
        />

        <Box
          style={{
            position: 'absolute',
            bottom: `${UNIVERSAL_VERTICAL_OFFSET + orbitDistance - 18}px`,
            left: '50%',
            transform: 'translateX(20px)',
            backgroundColor: 'rgba(0, 0, 0, 0.95)',
            padding: '8px 12px',
            borderRadius: '3px',
            border: '2px solid #40e0d0',
            color: '#40e0d0',
            fontSize: '14px',
            fontWeight: 'bold',
            fontFamily: 'Consolas, "Courier New", monospace',
            whiteSpace: 'nowrap',
            zIndex: 10,
            boxShadow:
              '0 0 15px rgba(64, 224, 208, 0.6), inset 0 0 8px rgba(64, 224, 208, 0.15)',
            textShadow: '0 0 5px rgba(64, 224, 208, 1)',
            letterSpacing: '1px',
          }}
        >
          [{(altitude * 1000).toFixed(0)}m]
        </Box>

        <Box
          style={{
            position: 'absolute',
            bottom: `${UNIVERSAL_VERTICAL_OFFSET + PLANET_RADIUS}px`,
            left: '50%',
            transform: 'translateX(-50%)',
            width: '2px',
            height: `${Math.max(0, orbitDistance - PLANET_RADIUS)}px`,
            background:
              'linear-gradient(to top, rgba(64, 224, 208, 0.8), rgba(64, 224, 208, 0.3))',
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
              color: '#40e0d0',
              fontWeight: 'bold',
              fontSize: '11px',
              textShadow: '0 0 8px rgba(64, 224, 208, 1)',
              textAlign: 'left',
              width: '115%',
              whiteSpace: 'nowrap',
              fontFamily: 'Consolas, "Courier New", monospace',
              textTransform: 'uppercase',
              letterSpacing: '2px',
              backgroundColor: 'rgba(0, 0, 0, 0.8)',
              padding: '2px 6px',
              border: '1px solid rgba(64, 224, 208, 0.5)',
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
              fill="rgba(0, 0, 0, 0.9)"
              stroke="rgba(64, 224, 208, 1)"
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
                    stopColor: 'rgba(64, 224, 208, 0.2)',
                    stopOpacity: 1,
                  }}
                />
                <stop
                  offset="50%"
                  style={{
                    stopColor: 'rgba(64, 224, 208, 0.05)',
                    stopOpacity: 1,
                  }}
                />
                <stop
                  offset="100%"
                  style={{
                    stopColor: 'rgba(64, 224, 208, 0.2)',
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
                    stroke="rgba(64, 224, 208, 1)"
                    strokeWidth="2"
                  />
                  {i % 2 === 0 && (
                    <text
                      x="60"
                      y={yPosition}
                      fill="#40e0d0"
                      fontSize="11px"
                      fontFamily="Consolas, 'Courier New', monospace"
                      textAnchor="end"
                      dominantBaseline="middle"
                      fontWeight="bold"
                      style={{
                        textShadow: '0 0 5px rgba(64, 224, 208, 0.8)',
                        filter: 'drop-shadow(0 0 3px rgba(64, 224, 208, 0.6))',
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
                  stroke="#00ff00"
                  strokeWidth="3"
                  strokeDasharray="6,3"
                  style={{
                    filter: 'drop-shadow(0 0 3px rgba(0, 255, 0, 0.8))',
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
                  fill="#00ff00"
                  stroke="#ffffff"
                  strokeWidth="1"
                  style={{ filter: 'drop-shadow(0 0 5px rgba(0, 255, 0, 1))' }}
                />
              </>
            )}
          </svg>
        </Box>
      </Box>
    </Box>
  );
};
