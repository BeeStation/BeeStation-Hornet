// :fearful:

// Made by powerfulbacon

import { useState } from 'react';
import { useRef } from 'react';
import { Dropdown } from 'tgui-core/components';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  DraggableClickableControl,
  Flex,
  NoticeBox,
  OrbitalMapComponent,
  OrbitalMapSvg,
  ProgressBar,
  Section,
  Table,
} from '../components';
import { Window } from '../layouts';

export const OrbitalMap = (props) => {
  const { act, data } = useBackend();
  const {
    map_objects = [],
    linkedToShuttle = false,
    canLaunch = false,
    recall_docking_port_id = '',
    thrust_alert = false,
    damage_alert = false,
    shuttleName = '',
    interdictionTime = 0,
    designatorInserted = false,
    designatorId = null,
    shuttleId = null,
  } = data;
  const [zoomScale, setZoomScale] = useState(1);
  const [xOffset, setXOffset] = useState(0);
  const [yOffset, setYOffset] = useState(0);
  const [trackedBody, setTrackedBody] = useState(shuttleName);

  const radarRef = useRef(null);

  let dynamicXOffset = xOffset;
  let dynamicYOffset = yOffset;

  let trackedObject = null;
  let ourObject = null;
  let firstObjectName = 'null';
  if (map_objects.length > 0 && interdictionTime === 0) {
    firstObjectName = map_objects[1].name;
    // Find the right tracked body
    map_objects.forEach((element) => {
      if (element.name === shuttleName) {
        ourObject = element;
      }
      if (element.name === trackedBody && !trackedObject) {
        trackedObject = element;
        if (trackedBody !== map_objects[0].name) {
          dynamicXOffset = trackedObject.position_x + trackedObject.velocity_x;
          dynamicYOffset = trackedObject.position_y + trackedObject.velocity_y;
        }
      }
    });
  }

  return (
    <Window width={1136} height={770}>
      <Window.Content fitted>
        <Flex height="100%">
          <Flex.Item
            class="OrbitalMap__radar"
            grow
            id="radar"
            innerRef={radarRef}
          >
            {interdictionTime ? (
              <InterdictionDisplay
                xOffset={dynamicXOffset}
                yOffset={dynamicYOffset}
                zoomScale={zoomScale}
                setZoomScale={setZoomScale}
                setXOffset={setXOffset}
                setYOffset={setYOffset}
              />
            ) : (
              <OrbitalMapDisplay
                dynamicXOffset={dynamicXOffset}
                dynamicYOffset={dynamicYOffset}
                isTracking={trackedBody !== map_objects[0].name}
                zoomScale={zoomScale}
                setZoomScale={setZoomScale}
                setTrackedBody={setTrackedBody}
                ourObject={ourObject}
                radarRef={radarRef}
              />
            )}
          </Flex.Item>
          <Flex.Item class="OrbitalMap__panel">
            <Section fill scrollable>
              <Section title="Orbital Body Tracking">
                <Box bold>Tracking</Box>
                <Box mb={1}>{trackedBody}</Box>
                <Box>
                  <b>X:&nbsp;</b>
                  {trackedObject && trackedObject.position_x}
                </Box>
                <Box>
                  <b>Y:&nbsp;</b>
                  {trackedObject && trackedObject.position_y}
                </Box>
                <Box>
                  <b>Velocity:&nbsp;</b>(
                  {trackedObject && trackedObject.velocity_x},{' '}
                  {trackedObject && trackedObject.velocity_y})
                </Box>
                <Box>
                  <b>Radius:&nbsp;</b>
                  {trackedObject && trackedObject.radius} BSU
                </Box>
                <Divider />
                <Dropdown
                  selected={trackedBody}
                  width="100%"
                  color="grey"
                  options={map_objects
                    .sort((first, second) => {
                      return second.priority - first.priority;
                    })
                    .map((map_object) => map_object.name)}
                  onSelected={(value) => setTrackedBody(value)}
                />
              </Section>
              <Divider />
              <Section title="Flight Controls">
                {!thrust_alert || (
                  <NoticeBox color="red">{thrust_alert}</NoticeBox>
                )}
                {!damage_alert || (
                  <NoticeBox color="red">{damage_alert}</NoticeBox>
                )}
                {recall_docking_port_id !== '' ? (
                  <RecallControl />
                ) : linkedToShuttle ? (
                  <ShuttleControls />
                ) : canLaunch ? (
                  <>
                    <NoticeBox>
                      Currently docked, awaiting launch order.
                    </NoticeBox>
                    <Button
                      content="INITIATE LAUNCH"
                      textAlign="center"
                      fontSize="30px"
                      icon="rocket"
                      width="100%"
                      height="50px"
                      onClick={() => act('launch')}
                    />
                  </>
                ) : (
                  <NoticeBox color="red">Not linked to a shuttle.</NoticeBox>
                )}
              </Section>
              {!!designatorInserted &&
                (designatorId ? !shuttleId : shuttleId) && (
                  <>
                    <Divider />
                    <Section title="Designator Linking">
                      {designatorId ? (
                        <Button
                          content="Download shuttle link from designator"
                          onClick={() => act('updateLinkedId')}
                        />
                      ) : (
                        <Button
                          content="Upload shuttle link to designator"
                          onClick={() => act('updateDesignatorId')}
                        />
                      )}
                    </Section>
                  </>
                )}
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

export const InterdictionDisplay = (props) => {
  const boxTargetStyle = {
    fillOpacity: 0,
    stroke: '#DDDDDD',
    strokeWidth: '1',
  };

  const { xOffset, yOffset, zoomScale, setZoomScale, setXOffset, setYOffset } =
    props;

  let lockedZoomScale = Math.max(Math.min(zoomScale, 4), 0.125);

  const { data } = useBackend();

  const { interdictionTime = 0, interdictedShuttles = [] } = data;

  return (
    <>
      <NoticeBox position="absolute" color="red">
        <Box bold mt={1} ml={1}>
          ENGINES INTERDICTED
        </Box>
        <Box ml={1}>
          Flight controls disabled. Engine reboot in {interdictionTime / 10}{' '}
          seconds.
        </Box>
        <Box ml={1}>Local shuttles have been marked on the map.</Box>
      </NoticeBox>
      <Button
        position="absolute"
        icon="search-plus"
        right="20px"
        top="15px"
        fontSize="18px"
        color="grey"
        onClick={() => setZoomScale(zoomScale * 2)}
      />
      <Button
        position="absolute"
        icon="search-minus"
        right="20px"
        top="47px"
        fontSize="18px"
        color="grey"
        onClick={() => setZoomScale(zoomScale / 2)}
      />
      <DraggableClickableControl
        position="absolute"
        value={xOffset}
        dragMatrix={[-1, 0]}
        step={1}
        stepPixelSize={2 * zoomScale}
        onDrag={(e, value) => {
          setXOffset(value);
        }}
        onClick={(e, value) => {}}
        updateRate={5}
      >
        {(control) => (
          <DraggableClickableControl
            position="absolute"
            value={yOffset}
            dragMatrix={[0, -1]}
            step={1}
            stepPixelSize={2 * zoomScale}
            onDrag={(e, value) => {
              setYOffset(value);
            }}
            onClick={(e, value) => {}}
            updateRate={5}
          >
            {(control1) => (
              <>
                {control.inputElement}
                {control1.inputElement}
                <svg
                  onMouseDown={(e) => {
                    control.handleDragStart(e);
                    control1.handleDragStart(e);
                  }}
                  viewBox="-250 -250 500 500"
                  position="absolute"
                  overflowY="hidden"
                >
                  <defs>
                    <pattern
                      id="grid"
                      width={100 * lockedZoomScale}
                      height={100 * lockedZoomScale}
                      patternUnits="userSpaceOnUse"
                      x={-xOffset * zoomScale}
                      y={-yOffset * zoomScale}
                    >
                      <rect
                        width={100 * lockedZoomScale}
                        height={100 * lockedZoomScale}
                        fill="url(#smallgrid)"
                      />
                      <path
                        fill="none"
                        stroke="#CE1935"
                        stroke-width="1"
                        d={
                          'M ' +
                          100 * lockedZoomScale +
                          ' 0 L 0 0 0 ' +
                          100 * lockedZoomScale
                        }
                      />
                    </pattern>
                    <pattern
                      id="smallgrid"
                      width={50 * lockedZoomScale}
                      height={50 * lockedZoomScale}
                      patternUnits="userSpaceOnUse"
                    >
                      <rect
                        width={50 * lockedZoomScale}
                        height={50 * lockedZoomScale}
                        fill="#382424"
                      />
                      <path
                        fill="none"
                        stroke="#CE1935"
                        stroke-width="0.5"
                        d={
                          'M ' +
                          50 * lockedZoomScale +
                          ' 0 L 0 0 0 ' +
                          50 * lockedZoomScale
                        }
                      />
                    </pattern>
                  </defs>
                  <rect
                    x="-50%"
                    y="-50%"
                    width="100%"
                    height="100%"
                    fill="url(#grid)"
                  />
                  {interdictedShuttles.map((map_object) => (
                    <>
                      <rect
                        x={(map_object.x * 10 - 25 - xOffset) * zoomScale}
                        y={(-map_object.y * 10 - 25 - yOffset) * zoomScale}
                        width={50 * zoomScale}
                        height={50 * zoomScale}
                        style={boxTargetStyle}
                      />
                      <text
                        x={Math.max(
                          Math.min(
                            (map_object.x * 10 - xOffset + 30) * zoomScale,
                            200,
                          ),
                          -250,
                        )}
                        y={Math.max(
                          Math.min(
                            (-map_object.y * 10 - yOffset - 30) * zoomScale,
                            250,
                          ),
                          -240,
                        )}
                        fill="white"
                        fontSize={Math.min(40 * lockedZoomScale, 14)}
                      >
                        {map_object.shuttleName} ({map_object.x},{map_object.y})
                      </text>
                    </>
                  ))}
                </svg>
              </>
            )}
          </DraggableClickableControl>
        )}
      </DraggableClickableControl>
    </>
  );
};

export const OrbitalMapDisplay = (props) => {
  const {
    zoomScale,
    setZoomScale,
    setTrackedBody,
    ourObject,
    isTracking = false,
    dynamicXOffset,
    dynamicYOffset,
    radarRef,
  } = props;

  const [offset, setOffset] = useState([0, 0]);

  let lockedZoomScale = Math.max(Math.min(zoomScale, 4), 0.125);

  const { act, data } = useBackend();

  const {
    map_objects = [],
    shuttleName = '',
    validDockingPorts = [],
    isDocking = false,
    interdiction_range = 150,
    shuttleTargetX = 0,
    shuttleTargetY = 0,
    update_index = 0,
  } = data;

  return (
    <>
      <Button
        position="absolute"
        icon="search-plus"
        right="20px"
        top="15px"
        fontSize="18px"
        color="grey"
        onClick={() => setZoomScale(zoomScale * 2)}
      />
      <Button
        position="absolute"
        icon="search-minus"
        right="20px"
        top="47px"
        fontSize="18px"
        color="grey"
        onClick={() => setZoomScale(zoomScale / 2)}
      />
      {!isDocking || (
        <NoticeBox
          position="absolute"
          color="red"
          top="50px"
          left="calc(50% - 150px)"
          width="300px"
          textAlign="center"
          fontSize="14px"
        >
          <>
            <NoticeBox mt={1}>
              DOCKING PROTOCOL ONLINE, FLIGHT DISABLED - SELECT DESTINATION.
            </NoticeBox>
            <Dropdown
              mt={1}
              selected="Select Docking Location"
              width="100%"
              options={validDockingPorts.map((map_object) => {
                return {
                  displayText: map_object.name,
                  value: map_object.id,
                };
              })}
              displayText="Select Docking Location"
              onSelected={(value) =>
                act('gotoPort', {
                  port: value,
                })
              }
            />
          </>
        </NoticeBox>
      )}
      <OrbitalMapComponent
        position="absolute"
        step={1}
        stepPixelSize={2 * zoomScale}
        onDrag={(e, valueX, valueY) => {
          setOffset([valueX, valueY]);
          setTrackedBody(map_objects[0].name);
        }}
        valueX={isTracking ? dynamicXOffset : offset[0]}
        valueY={isTracking ? dynamicYOffset : offset[1]}
        isTracking={isTracking}
        dynamicXOffset={dynamicXOffset}
        dynamicYOffset={dynamicYOffset}
        currentUpdateIndex={update_index}
        onClick={(e, xOffset, yOffset) => {
          const radar = radarRef?.current;
          if (!radar) {
            return;
          }
          const rect = radar.getBoundingClientRect();
          let proportionalX =
            ((e.clientX - rect.left) / radar.offsetWidth) * 500;
          let proportionalY =
            ((e.clientY - rect.top) / radar.offsetHeight) * 500;
          act('setTargetCoords', {
            altKey: e.altKey,
            x:
              (proportionalX - 250) / zoomScale +
              (isTracking ? dynamicXOffset : xOffset),
            y:
              (proportionalY - 250) / zoomScale +
              (isTracking ? dynamicYOffset : yOffset),
          });
        }}
      >
        {(control) => (
          <OrbitalMapSvg
            scaledXOffset={-control.xOffset * zoomScale}
            scaledYOffset={-control.yOffset * zoomScale}
            xOffset={-control.xOffset}
            yOffset={-control.yOffset}
            ourObject={ourObject}
            lockedZoomScale={lockedZoomScale}
            map_objects={map_objects}
            interdiction_range={interdiction_range}
            shuttleTargetX={shuttleTargetX}
            shuttleTargetY={shuttleTargetY}
            dragStartEvent={(e) => control.handleDragStart(e)}
            zoomScale={zoomScale}
            shuttleName={shuttleName}
            currentUpdateIndex={update_index}
          >
            {(control) => control.svgComponent}
          </OrbitalMapSvg>
        )}
      </OrbitalMapComponent>
    </>
  );
};

export const RecallControl = (props) => {
  const { act, data } = useBackend();
  const { request_shuttle_message } = data;
  return (
    <>
      <NoticeBox>
        Manual control disabled, this location can only recall the shuttle.
      </NoticeBox>
      <Button
        content={request_shuttle_message}
        textAlign="center"
        fontSize="30px"
        icon="rocket"
        width="100%"
        height="50px"
        onClick={() => act('callShuttle')}
      />
    </>
  );
};

export const ShuttleControls = (props) => {
  const { act, data } = useBackend();
  const {
    map_objects = [],
    shuttleTarget = null,
    shuttleAngle = 0,
    shuttleThrust = 0,
    canDock = false,
    isDocking = false,
    display_fuel = false,
    fuel = 0,
    display_stats = [],
    autopilot_enabled = false,
  } = data;
  // Sort the map objects by priority
  let sortedMapObjects = map_objects.sort((first, second) => {
    return second.priority - first.priority;
  });
  return (
    <>
      <Box bold>Autopilot Target</Box>
      <Dropdown
        mt={1}
        selected={shuttleTarget}
        width="100%"
        options={sortedMapObjects.map((map_object) => map_object.name)}
        onSelected={(value) =>
          act('setTarget', {
            target: value,
          })
        }
      />
      <Box mt={1}>
        Velocity line will be adjusted to relative speed of this orbital body.
      </Box>
      <ShuttleMap />
      <NoticeBox color="purple" mt={2}>
        Click on the primary display to fly.
      </NoticeBox>
      <Box bold>Throttle</Box>
      <Box>Shuttle Thrust: {shuttleThrust}</Box>
      <Box bold mt={2}>
        Thrust Angle
      </Box>
      <Box>Angle: {shuttleAngle}</Box>
      {!display_fuel || (
        <>
          <Box bold mt={2}>
            Fuel Remaining
          </Box>
          <ProgressBar value={fuel}>{fuel} moles.</ProgressBar>
        </>
      )}
      <Table mt={2}>
        {Object.keys(display_stats).map((value) => (
          <Table.Row key={value}>
            <Table.Cell bold>{value} :</Table.Cell>
            <Table.Cell textAlign="right">{display_stats[value]}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
      <Button
        mt={2}
        content="Toggle Autopilot"
        onClick={() => act('nautopilot')}
        color={autopilot_enabled ? 'green' : 'red'}
      />
      {!(canDock && !isDocking) || (
        <Button mt={2} content="Initiate Docking" onClick={() => act('dock')} />
      )}
      <Button
        mt={2}
        content="ENGAGE INTERDICTOR"
        onClick={() => act('interdict')}
        color="purple"
      />
    </>
  );
};

export const ShuttleMap = (props) => {
  const lineStyle = {
    stroke: '#BBBBBB',
    strokeWidth: '2',
  };
  const velLineStyle = {
    stroke: '#00FF00',
    strokeWidth: '2',
  };
  const { act, data } = useBackend();
  const {
    shuttleAngle = 0,
    shuttleThrust = 0,
    shuttleVelX = 0,
    shuttleVelY = 0,
  } = data;
  let x = (shuttleThrust + 30) * Math.cos(shuttleAngle * ((2 * Math.PI) / 360));
  let y = (shuttleThrust + 30) * Math.sin(shuttleAngle * ((2 * Math.PI) / 360));
  return (
    <Box width="370px" height="160px">
      <svg position="absolute" height="100%" viewBox="-100 -100 200 200">
        <defs>
          <pattern
            id="grid"
            width={200}
            height={200}
            patternUnits="userSpaceOnUse"
          >
            <rect width={200} height={200} fill="url(#smallgrid)" />
            <path
              d={'M 200 0 L 0 0 0 200'}
              fill="none"
              stroke="#4665DE"
              stroke-width="1"
            />
          </pattern>
          <pattern
            id="smallgrid"
            width={100}
            height={100}
            patternUnits="userSpaceOnUse"
          >
            <rect width={100} height={100} fill="#2B2E3B" />
            <path
              d={'M 100 0 L 0 0 0 100'}
              fill="none"
              stroke="#4665DE"
              stroke-width="0.5"
            />
          </pattern>
        </defs>
        <rect x="-50%" y="-50%" width="100%" height="100%" fill="url(#grid)" />
        <circle
          r="30px"
          stroke="#BBBBBB"
          stroke-width="1"
          fill="rgba(0,0,0,0)"
        />
        <line x1={0} y1={0} x2={x} y2={y} style={lineStyle} />
        <line
          x1={0}
          y1={0}
          x2={shuttleVelX}
          y2={shuttleVelY}
          style={velLineStyle}
        />
      </svg>
    </Box>
  );
};
