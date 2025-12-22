import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Tooltip } from '../components';
import { Window } from '../layouts';

type OrbitalData = {
  current_altitude: number;
  orbital_decay: number;
  orbital_velocity_index: number;
  normalized_resistance: number;
  thrust_level: number;
  orbital_bands: OrbitalBand[];
};

type OrbitalBand = {
  name: string;
  min_altitude: number;
  max_altitude: number;
  color: string;
  is_mining_regime?: boolean;
};

export const OrbitalHeightControl = (props) => {
  const { act, data } = useBackend<OrbitalData>();
  const {
    current_altitude = 98,
    orbital_decay = 17.6,
    orbital_velocity_index = 5.4,
    normalized_resistance = 4,
    thrust_level = 0,
    orbital_bands = [],
  } = data;

  return (
    <Window width={640} height={580}>
      <Window.Content>
        <Stack vertical fill>
          {/* Top readouts section */}
          <Stack.Item>
            <Section
              title=">>> ORBITING: CINIS (AURI-GEMINAE I)"
              style={{
                fontFamily: 'Consolas, "Courier New", monospace',
                borderColor: '#40e0d0',
                borderWidth: '2px',
              }}
            >
              <Stack vertical>
                <Stack.Item>
                  <Stack>
                    <Stack.Item grow>
                      <Tooltip content="The station's current distance from the planet's surface">
                        <Box
                          fontSize="1.1em"
                          bold
                          style={{
                            fontFamily: 'Consolas, "Courier New", monospace',
                            color: '#40e0d0',
                            textShadow: '0 0 5px rgba(64, 224, 208, 0.5)',
                          }}
                        >
                          ALT: {current_altitude.toFixed(1)} km
                        </Box>
                      </Tooltip>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Tooltip content="Indicates vertical orbital velocity on a -10 to +10 scale relative to optimal parameters">
                        <Box
                          fontSize="1.1em"
                          bold
                          textAlign="right"
                          style={{
                            fontFamily: 'Consolas, "Courier New", monospace',
                            color: '#40e0d0',
                            textShadow: '0 0 5px rgba(64, 224, 208, 0.5)',
                          }}
                        >
                          VEL_IDX: {orbital_velocity_index.toFixed(2)}
                        </Box>
                      </Tooltip>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item grow>
                      <Tooltip content="The rate at which the station's orbit is decaying due to atmospheric drag">
                        <Box
                          fontSize="1.1em"
                          bold
                          style={{
                            fontFamily: 'Consolas, "Courier New", monospace',
                            color: '#ff9933',
                            textShadow: '0 0 5px rgba(255, 153, 51, 0.5)',
                          }}
                        >
                          DECAY: {orbital_decay.toFixed(2)} m/s
                        </Box>
                      </Tooltip>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Tooltip content="Atmospheric density affecting orbital stability - higher values increase drag">
                        <Box
                          fontSize="1.1em"
                          bold
                          textAlign="right"
                          style={{
                            fontFamily: 'Consolas, "Courier New", monospace',
                            color: '#ff6666',
                            textShadow: '0 0 5px rgba(255, 102, 102, 0.5)',
                          }}
                        >
                          ATM_RES: {normalized_resistance.toFixed(1)}%
                        </Box>
                      </Tooltip>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          {/* Visualization section with thrust panel overlaid */}
          <Stack.Item grow>
            <Section fill>
              <Box
                style={{ position: 'relative', width: '100%', height: '100%' }}
              >
                {/* Thrust control panel - positioned absolutely on top left */}
                <Box
                  style={{
                    position: 'absolute',
                    left: '10px',
                    top: '10px',
                    zIndex: 10,
                    width: '90px',
                    backgroundColor: 'rgba(0, 0, 0, 0.85)',
                    border: '2px solid #40e0d0',
                    borderRadius: '4px',
                    boxShadow: '0 0 10px rgba(64, 224, 208, 0.3)',
                    padding: '8px',
                  }}
                >
                  {/* Title */}
                  <Box
                    style={{
                      fontFamily: 'Consolas, "Courier New", monospace',
                      color: '#40e0d0',
                      fontSize: '11px',
                      fontWeight: 'bold',
                      textAlign: 'center',
                      marginBottom: '8px',
                      textTransform: 'uppercase',
                      letterSpacing: '1px',
                    }}
                  >
                    [ THRUST ]
                  </Box>

                  {/* Up button */}
                  <Button
                    fluid
                    onClick={() => act('increase_thrust')}
                    style={{
                      fontFamily: 'Consolas, "Courier New", monospace',
                      fontWeight: 'bold',
                      fontSize: '1.5em',
                      padding: '10px 0',
                      marginBottom: '8px',
                      textAlign: 'center',
                    }}
                  >
                    ▲
                  </Button>

                  {/* Thrust level display */}
                  <Box
                    style={{
                      backgroundColor: 'rgba(0, 0, 0, 0.5)',
                      border: '1px solid rgba(64, 224, 208, 0.3)',
                      borderRadius: '4px',
                      padding: '20px 10px',
                      marginBottom: '8px',
                      textAlign: 'center',
                    }}
                  >
                    <Box
                      style={{
                        fontFamily: 'Consolas, "Courier New", monospace',
                        color: '#00ff00',
                        fontSize: '3em',
                        fontWeight: 'bold',
                        textShadow:
                          '0 0 10px rgba(0, 255, 0, 0.8), 0 0 20px rgba(0, 255, 0, 0.4)',
                        lineHeight: '1',
                      }}
                    >
                      {thrust_level ?? 0}
                    </Box>
                    <Box
                      style={{
                        fontFamily: 'Consolas, "Courier New", monospace',
                        color: '#40e0d0',
                        fontSize: '0.7em',
                        marginTop: '8px',
                        textTransform: 'uppercase',
                        letterSpacing: '1px',
                      }}
                    >
                      LEVEL
                    </Box>
                  </Box>

                  {/* Down button */}
                  <Button
                    fluid
                    onClick={() => act('decrease_thrust')}
                    style={{
                      fontFamily: 'Consolas, "Courier New", monospace',
                      fontWeight: 'bold',
                      fontSize: '1.5em',
                      padding: '10px 0',
                      textAlign: 'center',
                    }}
                  >
                    ▼
                  </Button>
                </Box>

                {/* Planet visualization */}
                <PlanetVisualization
                  altitude={current_altitude}
                  orbitalBands={orbital_bands}
                />
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PlanetVisualization = (props: {
  altitude: number;
  orbitalBands: OrbitalBand[];
}) => {
  const { altitude, orbitalBands } = props;

  // Mining band altitude range (linear scale)
  const miningBandMin = 95; // km
  const miningBandMax = 105; // km

  // Calculate position of the orbital blip
  // maxAltitude is double the actual, 280km, for visualization scaling
  const maxAltitude = 280;
  const minAltitude = 0;
  const normalizedAltitude =
    (altitude - minAltitude) / (maxAltitude - minAltitude);

  // The blip orbits around the planet
  // We'll position it at the top for simplicity, with distance from center based on altitude
  const planetRadius = 720; // Scaled planet radius (doubled)
  const maxOrbitRadius = 400; // Scaled orbital range (doubled)
  const orbitDistance = planetRadius + normalizedAltitude * maxOrbitRadius;

  // Universal vertical offset - adjust this single value to move the entire visualization up/down
  const universalVerticalOffset = -650; // pixels from bottom (planet center position)

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
      {/* Container for the orbital system - zoomed in to show only top portion */}
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
        {/* Orbital bands */}
        {orbitalBands.map((band, index) => {
          const bandMinNorm =
            (band.min_altitude - minAltitude) / (maxAltitude - minAltitude);
          const bandMaxNorm =
            (band.max_altitude - minAltitude) / (maxAltitude - minAltitude);
          const innerRadius = planetRadius + bandMinNorm * maxOrbitRadius;
          const outerRadius = planetRadius + bandMaxNorm * maxOrbitRadius;

          return (
            <Box key={index}>
              <Box
                style={{
                  position: 'absolute',
                  bottom: `${universalVerticalOffset}px`,
                  left: '50%',
                  transform: 'translate(-50%, 50%)',
                  width: `${outerRadius * 2}px`,
                  height: `${outerRadius * 2}px`,
                  borderRadius: '50%',
                  border: `${outerRadius - innerRadius}px solid ${band.color}`,
                  opacity: 0.4, // Increased opacity for better visibility
                  pointerEvents: 'none',
                  boxSizing: 'border-box',
                }}
              />
              {/* Mining regime indicator lines */}
              {band.is_mining_regime && (
                <>
                  {/* Top boundary line - horizontal dashed line */}
                  <Box
                    style={{
                      position: 'absolute',
                      bottom: `${universalVerticalOffset + outerRadius}px`,
                      left: '0',
                      right: '0',
                      height: '2px',
                      background:
                        'repeating-linear-gradient(to right, rgba(255, 255, 255, 0.3) 0px, rgba(255, 255, 255, 0.3) 10px, transparent 10px, transparent 20px)',
                      pointerEvents: 'none',
                    }}
                  />
                  {/* Bottom boundary line - horizontal dashed line */}
                  <Box
                    style={{
                      position: 'absolute',
                      bottom: `${universalVerticalOffset + innerRadius}px`,
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

        {/* The planet */}
        <Box
          style={{
            position: 'absolute',
            bottom: `${universalVerticalOffset}px`,
            left: '50%',
            transform: 'translate(-50%, 50%)',
            width: `${planetRadius * 2}px`,
            height: `${planetRadius * 2}px`,
            borderRadius: '50%',
            background:
              'radial-gradient(circle at 30% 30%, #b8b8b8, #6b6b6b 60%, #3a3a3a)',
            boxShadow:
              'inset -20px -20px 40px rgba(0, 0, 0, 0.5), 0 0 30px rgba(0, 0, 0, 0.8)',
            border: '2px solid rgba(128, 128, 128, 0.3)',
          }}
        />

        {/* Orbital path indicator */}
        <Box
          style={{
            position: 'absolute',
            bottom: `${universalVerticalOffset}px`,
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

        {/* Orbital blip (spacecraft) */}
        <Box
          style={{
            position: 'absolute',
            bottom: `${universalVerticalOffset + orbitDistance}px`,
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

        {/* Altitude readout next to the blip */}
        <Box
          style={{
            position: 'absolute',
            bottom: `${universalVerticalOffset + orbitDistance - 18}px`,
            left: '50%',
            transform: 'translateX(20px)',
            backgroundColor: 'rgba(0, 0, 0, 0.85)',
            padding: '6px 10px',
            borderRadius: '3px',
            border: '1px solid #40e0d0',
            color: '#40e0d0',
            fontSize: '13px',
            fontWeight: 'bold',
            fontFamily: 'Consolas, "Courier New", monospace',
            whiteSpace: 'nowrap',
            zIndex: 10,
            boxShadow:
              '0 0 10px rgba(64, 224, 208, 0.4), inset 0 0 5px rgba(64, 224, 208, 0.1)',
            textShadow: '0 0 3px rgba(64, 224, 208, 0.8)',
          }}
        >
          {(altitude * 1000).toFixed(0)}m
        </Box>

        {/* Altitude indicator line - connects planet surface to spacecraft */}
        <Box
          style={{
            position: 'absolute',
            bottom: `${universalVerticalOffset + planetRadius}px`,
            left: '50%',
            transform: 'translateX(-50%)',
            width: '2px',
            height: `${Math.max(0, orbitDistance - planetRadius)}px`,
            background:
              'linear-gradient(to top, rgba(64, 224, 208, 0.8), rgba(64, 224, 208, 0.3))',
            transformOrigin: 'bottom',
            pointerEvents: 'none',
          }}
        />

        {/* Linear altitude scale (mining band) */}
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
              fontSize: '12px',
              textShadow: '0 0 5px rgba(64, 224, 208, 0.8)',
              textAlign: 'left',
              width: '100%',
              whiteSpace: 'nowrap',
              fontFamily: 'Consolas, "Courier New", monospace',
              textTransform: 'uppercase',
              letterSpacing: '1px',
            }}
          >
            [MINING_REGIME]
          </Box>
          <svg width="100" height="200" style={{ overflow: 'visible' }}>
            {/* Background bar */}
            <rect
              x="70"
              y="0"
              width="10"
              height="200"
              fill="rgba(0, 0, 0, 0.7)"
              stroke="rgba(64, 224, 208, 0.8)"
              strokeWidth="2"
              rx="2"
            />

            {/* Tick marks and labels */}
            {Array.from({ length: 11 }, (_, i) => {
              const altitudeValue =
                miningBandMax - (i * (miningBandMax - miningBandMin)) / 10;
              const yPosition = (i / 10) * 200;
              return (
                <g key={i}>
                  {/* Tick mark */}
                  <line
                    x1="65"
                    y1={yPosition}
                    x2="70"
                    y2={yPosition}
                    stroke="rgba(64, 224, 208, 0.8)"
                    strokeWidth="2"
                  />
                  {/* Label - show every other tick to avoid crowding */}
                  {i % 2 === 0 && (
                    <text
                      x="60"
                      y={yPosition}
                      fill="#40e0d0"
                      fontSize="10px"
                      fontFamily="Consolas, 'Courier New', monospace"
                      textAnchor="end"
                      dominantBaseline="middle"
                      style={{ textShadow: '0 0 3px rgba(64, 224, 208, 0.5)' }}
                    >
                      {altitudeValue.toFixed(0)}
                    </text>
                  )}
                </g>
              );
            })}

            {/* Current altitude indicator on the linear scale */}
            {altitude >= miningBandMin && altitude <= miningBandMax && (
              <>
                {/* Indicator line */}
                <line
                  x1="70"
                  y1={
                    ((miningBandMax - altitude) /
                      (miningBandMax - miningBandMin)) *
                    200
                  }
                  x2="100"
                  y2={
                    ((miningBandMax - altitude) /
                      (miningBandMax - miningBandMin)) *
                    200
                  }
                  stroke="#00ff00"
                  strokeWidth="3"
                  strokeDasharray="6,3"
                  style={{
                    filter: 'drop-shadow(0 0 3px rgba(0, 255, 0, 0.8))',
                  }}
                />
                {/* Indicator dot */}
                <circle
                  cx="75"
                  cy={
                    ((miningBandMax - altitude) /
                      (miningBandMax - miningBandMin)) *
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
