// :fearful:

// Made by powerfulbacon

import { Box, Button, Section, Table, DraggableClickableControl, Dropdown, Divider, NoticeBox, Slider, ProgressBar, Fragment, ScrollableBox, OrbitalMapComponent } from '../components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

export const OrbitalMap = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    map_objects = [],
    linkedToShuttle = false,
    canLaunch = false,
    recall_docking_port_id = "",
    thrust_alert = false,
    damage_alert = false,
    shuttleName = "",
    update_index = -1,
    interdictionTime = 0,
  } = data;
  const [
    zoomScale,
    setZoomScale,
  ] = useLocalState(context, 'zoomScale', 1);
  const [
    xOffset,
    setXOffset,
  ] = useLocalState(context, 'xOffset', 0);
  const [
    yOffset,
    setYOffset,
  ] = useLocalState(context, 'yOffset', 0);
  const [
    trackedBody,
    setTrackedBody,
  ] = useLocalState(context, 'trackedBody', shuttleName);

  let dynamicXOffset = xOffset;
  let dynamicYOffset = yOffset;

  let trackedObject = null;
  let ourObject = null;
  if (map_objects.length > 0 && interdictionTime === 0)
  {
    // Find the right tracked body
    map_objects.forEach(element => {
      if (element.name === shuttleName)
      {
        ourObject = element;
      }
      if (element.name === trackedBody && !trackedObject)
      {
        trackedObject = element;
        if (trackedBody !== map_objects[0].name)
        {
          dynamicXOffset = trackedObject.position_x
           + trackedObject.velocity_x;
          dynamicYOffset = trackedObject.position_y
           + trackedObject.velocity_y;
        }
      }
    });
  }

  return (
    <Window
      width={1136}
      height={770}
      resizable
      overflowY="hidden">
      <Window.Content overflowY="hidden">
        <div class="OrbitalMap__radar" id="radar">
          {interdictionTime ? (
            <InterdictionDisplay
              xOffset={dynamicXOffset}
              yOffset={dynamicYOffset}
              zoomScale={zoomScale}
              setZoomScale={setZoomScale}
              setXOffset={setXOffset}
              setYOffset={setYOffset} />
          ) : (
            <OrbitalMapDisplay
              dynamicXOffset={dynamicXOffset}
              dynamicYOffset={dynamicYOffset}
              isTracking={trackedBody !== map_objects[0].name}
              zoomScale={zoomScale}
              setZoomScale={setZoomScale}
              setTrackedBody={setTrackedBody}
              ourObject={ourObject} />
          )}
        </div>
        <div class="OrbitalMap__panel">
          <ScrollableBox overflowY="scroll" height="100%">
            <Section title="Orbital Body Tracking">
              <Box bold>
                Tracking
              </Box>
              <Box mb={1}>
                {trackedBody}
              </Box>
              <Box>
                <b>
                  X:&nbsp;
                </b>
                {trackedObject && trackedObject.position_x}
              </Box>
              <Box>
                <b>
                  Y:&nbsp;
                </b>
                {trackedObject && trackedObject.position_y}
              </Box>
              <Box>
                <b>
                  Velocity:&nbsp;
                </b>
                ({trackedObject && trackedObject.velocity_x}
                , {trackedObject && trackedObject.velocity_y})
              </Box>
              <Box>
                <b>
                  Radius:&nbsp;
                </b>
                {trackedObject && trackedObject.radius} BSU
              </Box>
              <Divider />
              <Dropdown
                selected={trackedBody}
                width="100%"
                color="grey"
                options={map_objects.map(map_object => (map_object.name))}
                onSelected={value => setTrackedBody(value)} />
            </Section>
            <Divider />
            <Section title="Flight Controls">
              {(!thrust_alert) || (
                <NoticeBox color="red">
                  {thrust_alert}
                </NoticeBox>
              )}
              {(!damage_alert) || (
                <NoticeBox color="red">
                  {damage_alert}
                </NoticeBox>
              )}
              {recall_docking_port_id !== ""
                ? <RecallControl />
                : linkedToShuttle
                  ? <ShuttleControls />
                  : (canLaunch ? (
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
                        onClick={() => act('launch')} />
                    </>
                  ) : (
                    <NoticeBox
                      color="red">
                      Not linked to a shuttle.
                    </NoticeBox>
                  ))}
            </Section>
          </ScrollableBox>
        </div>
      </Window.Content>
    </Window>
  );
};

export const InterdictionDisplay = (props, context) => {

  // SVG Background Style
  const lineStyle = {
    stroke: '#BBBBBB',
    strokeWidth: '2',
  };
  const blueLineStyle = {
    stroke: '#8888FF',
    strokeWidth: '2',
  };
  const boxTargetStyle = {
    "fill-opacity": 0,
    stroke: '#DDDDDD',
    strokeWidth: '1',
  };
  const lineTargetStyle = {
    opacity: 0.4,
    stroke: '#DDDDDD',
    strokeWidth: '1',
  };

  const {
    xOffset,
    yOffset,
    zoomScale,
    setZoomScale,
    setXOffset,
    setYOffset,
  } = props;

  let lockedZoomScale = Math.max(Math.min(zoomScale, 4), 0.125);

  const { act, data } = useBackend(context);

  const {
    map_objects = [],
    interdictionTime = 0,
    interdictedShuttles = [],
  } = data;

  return (
    <Fragment>
      <NoticeBox
        position="absolute"
        color="red">
        <Box bold mt={1} ml={1}>
          ENGINES INTERDICTED
        </Box>
        <Box ml={1}>
          Flight controls disabled.
          Engine reboot in {interdictionTime / 10} seconds.
        </Box>
        <Box ml={1}>
          Local shuttles have been marked on the map.
        </Box>
      </NoticeBox>
      <Button
        position="absolute"
        icon="search-plus"
        right="20px"
        top="15px"
        fontSize="18px"
        color="grey"
        onClick={() => setZoomScale(zoomScale * 2)} />
      <Button
        position="absolute"
        icon="search-minus"
        right="20px"
        top="47px"
        fontSize="18px"
        color="grey"
        onClick={() => setZoomScale(zoomScale / 2)} />
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
        updateRate={5}>
        {control => (
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
            updateRate={5}>
            {control1 => (
              <>
                {control.inputElement}
                {control1.inputElement}
                <svg
                  onMouseDown={e => {
                    control.handleDragStart(e);
                    control1.handleDragStart(e);
                  }}
                  viewBox="-250 -250 500 500"
                  position="absolute"
                  overflowY="hidden">
                  <defs>
                    <pattern id="grid" width={100 * lockedZoomScale}
                      height={100 * lockedZoomScale}
                      patternUnits="userSpaceOnUse"
                      x={-xOffset * zoomScale}
                      y={-yOffset * zoomScale}>
                      <rect width={100 * lockedZoomScale}
                        height={100 * lockedZoomScale}
                        fill="url(#smallgrid)" />
                      <path
                        fill="none" stroke="#CE1935" stroke-width="1"
                        d={"M " + (100 * lockedZoomScale)+ " 0 L 0 0 0 " + (100 * lockedZoomScale)} />
                    </pattern>
                    <pattern id="smallgrid"
                      width={50 * lockedZoomScale}
                      height={50 * lockedZoomScale}
                      patternUnits="userSpaceOnUse">
                      <rect
                        width={50 * lockedZoomScale}
                        height={50 * lockedZoomScale}
                        fill="#382424" />
                      <path
                        fill="none"
                        stroke="#CE1935"
                        stroke-width="0.5"
                        d={"M " + (50 * lockedZoomScale) + " 0 L 0 0 0 "
                        + (50 * lockedZoomScale)} />
                    </pattern>
                  </defs>
                  <rect x="-50%" y="-50%" width="100%" height="100%"
                    fill="url(#grid)" />
                  {interdictedShuttles.map(map_object => (
                    <>
                      <rect
                        x={(map_object.x * 10 - 25 - xOffset) * zoomScale}
                        y={(-map_object.y * 10 - 25 - yOffset) * zoomScale}
                        width={50 * zoomScale}
                        height={50 * zoomScale}
                        style={boxTargetStyle} />
                      <text
                        x={Math.max(Math.min((map_object.x * 10
                          - xOffset
                          + 30)
                          * zoomScale, 200), -250)}
                        y={Math.max(Math.min((-map_object.y * 10
                          - yOffset
                          - 30)
                          * zoomScale, 250), -240)}
                        fill="white"
                        fontSize={Math.min(40 * lockedZoomScale, 14)}>
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
    </Fragment>
  );

};

export const OrbitalMapDisplay = (props, context) => {

  // SVG Background Style
  const lineStyle = {
    stroke: '#BBBBBB',
    strokeWidth: '2',
  };
  const blueLineStyle = {
    stroke: '#8888FF',
    strokeWidth: '2',
  };
  const boxTargetStyle = {
    "fill-opacity": 0,
    stroke: '#DDDDDD',
    strokeWidth: '1',
  };
  const lineTargetStyle = {
    opacity: 0.4,
    stroke: '#DDDDDD',
    strokeWidth: '1',
  };

  const {
    zoomScale,
    setZoomScale,
    setTrackedBody,
    ourObject,
    isTracking = false,
    dynamicXOffset,
    dynamicYOffset,
  } = props;

  const [
    offset,
    setOffset,
  ] = useLocalState(context, 'offset', [0, 0]);

  let lockedZoomScale = Math.max(Math.min(zoomScale, 4), 0.125);

  const { act, data } = useBackend(context);

  const {
    map_objects = [],
    shuttleName = "",
    desired_vel_x = 0,
    desired_vel_y = 0,
    validDockingPorts = [],
    isDocking = false,
    interdiction_range = 150,
    shuttleTargetX = 0,
    shuttleTargetY = 0,
    update_index = 0,
    interdictionTime = 0,
  } = data;

  return (
    <Fragment>
      <Button
        position="absolute"
        icon="search-plus"
        right="20px"
        top="15px"
        fontSize="18px"
        color="grey"
        onClick={() => setZoomScale(zoomScale * 2)} />
      <Button
        position="absolute"
        icon="search-minus"
        right="20px"
        top="47px"
        fontSize="18px"
        color="grey"
        onClick={() => setZoomScale(zoomScale / 2)} />
      {!isDocking || (
        <NoticeBox
          position="absolute"
          color="red"
          top="50px"
          left="calc(50% - 150px)"
          width="300px"
          textAlign="center"
          fontSize="14px">
          <>
            <NoticeBox mt={1}>
              DOCKING PROTOCOL ONLINE,
              FLIGHT DISABLED -
              SELECT DESTINATION.
            </NoticeBox>
            <Dropdown
              mt={1}
              selected="Select Docking Location"
              width="100%"
              options={validDockingPorts.map(
                map_object => (
                  <option key={map_object.id}>
                    {map_object.name}
                  </option>
                ))}
              onSelected={value => act("gotoPort", {
                port: value.key,
              })} />
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
          let clickedOnDiv = document.getElementById("radar"); // This is kind
          // of funky but A) I don't know react / javascript and B) Nobody in
          // the history of the universe knows react / javascript so nobody
          // will probably ever read this so I'm good.
          let proportionalX = e.offsetX / clickedOnDiv.offsetWidth * 500;
          let proportionalY = (e.offsetY - 30) / clickedOnDiv.offsetHeight
           * 500;
          act("setTargetCoords", {
            x: (proportionalX - 250) / zoomScale + (isTracking
              ? dynamicXOffset : xOffset),
            y: (proportionalY - 250) / zoomScale + (isTracking
              ? dynamicYOffset : yOffset),
          });
        }} >
        {control => (
          <svg
            onMouseDown={e => {
              control.handleDragStart(e);
            }}
            viewBox="-250 -250 500 500"
            position="absolute"
            overflowY="hidden" >
            <defs>
              <pattern id="grid" width={100 * lockedZoomScale}
                height={100 * lockedZoomScale}
                patternUnits="userSpaceOnUse"
                x={-control.xOffset * zoomScale}
                y={-control.yOffset * zoomScale}>
                <rect width={100 * lockedZoomScale}
                  height={100 * lockedZoomScale}
                  fill="url(#smallgrid)" />
                <path
                  fill="none" stroke="#4665DE" stroke-width="1"
                  d={"M " + (100 * lockedZoomScale)+ " 0 L 0 0 0 " + (100 * lockedZoomScale)} />
              </pattern>
              <pattern id="smallgrid"
                width={50 * lockedZoomScale}
                height={50 * lockedZoomScale}
                patternUnits="userSpaceOnUse">
                <rect
                  width={50 * lockedZoomScale}
                  height={50 * lockedZoomScale}
                  fill="#2B2E3B" />
                <path
                  fill="none"
                  stroke="#4665DE"
                  stroke-width="0.5"
                  d={"M " + (50 * lockedZoomScale) + " 0 L 0 0 0 "
                  + (50 * lockedZoomScale)} />
              </pattern>
            </defs>
            <rect x="-50%" y="-50%" width="100%" height="100%"
              fill="url(#grid)" />
            {map_objects.map(map_object => (
              <>
                <circle
                  cx={Math.max(Math.min((map_object.position_x
                    - control.xOffset
                    + map_object.velocity_x * control.elapsed)
                    * zoomScale, 250), -250)}
                  cy={Math.max(Math.min((map_object.position_y
                    - control.yOffset
                    + map_object.velocity_y * control.elapsed)
                    * zoomScale, 250), -250)}
                  r={((map_object.position_y - control.yOffset)
                    * zoomScale > 250
                    || (map_object.position_y - control.yOffset)
                    * zoomScale < -250
                    || (map_object.position_x - control.xOffset)
                    * zoomScale > 250
                    || (map_object.position_x - control.xOffset)
                    * zoomScale < -250)
                    ? 5 * zoomScale
                    : Math.max(5 * zoomScale, map_object.radius
                      * zoomScale)}
                  stroke="#BBBBBB"
                  stroke-width="1"
                  fill="rgba(0,0,0,0)" />
                <line
                  style={lineStyle}
                  x1={Math.max(Math.min((map_object.position_x
                    - control.xOffset
                    + map_object.velocity_x * control.elapsed)
                    * zoomScale, 250), -250)}
                  y1={Math.max(Math.min((map_object.position_y
                    - control.yOffset
                    + map_object.velocity_y * control.elapsed)
                    * zoomScale, 250), -250)}
                  x2={Math.max(Math.min((map_object.position_x
                    - control.xOffset
                    + map_object.velocity_x * 10)
                    * zoomScale, 250), -250)}
                  y2={Math.max(Math.min((map_object.position_y
                    - control.yOffset
                    + map_object.velocity_y * 10)
                    * zoomScale, 250), -250)} />
                <text
                  x={Math.max(Math.min((map_object.position_x
                    - control.xOffset
                    + map_object.velocity_x * control.elapsed)
                    * zoomScale, 200), -250)}
                  y={Math.max(Math.min((map_object.position_y
                    - control.yOffset
                    + map_object.velocity_y * control.elapsed)
                    * zoomScale, 250), -240)}
                  fill="white"
                  fontSize={Math.min(40 * lockedZoomScale, 14)}>
                  {map_object.name}
                </text>
                {shuttleName !== map_object.name || (
                  <line
                    style={blueLineStyle}
                    x1={Math.max(Math.min((map_object.position_x
                      - control.xOffset
                      + map_object.velocity_x * control.elapsed)
                      * zoomScale, 250), -250)}
                    y1={Math.max(Math.min((map_object.position_y
                      - control.yOffset
                      + map_object.velocity_y * control.elapsed)
                      * zoomScale, 250), -250)}
                    x2={Math.max(Math.min((map_object.position_x
                      - control.xOffset
                      + map_object.velocity_x * control.elapsed
                      + desired_vel_x * 10)
                      * zoomScale, 250), -250)}
                    y2={Math.max(Math.min((map_object.position_y
                      - control.yOffset
                      + map_object.velocity_y * control.elapsed
                      + desired_vel_y * 10)
                      * zoomScale, 250), -250)} />
                )}
              </>
            ))};
            {/*
              Shuttle Target Locator
            */}
            {((shuttleTargetX || shuttleTargetY) && ourObject) && (
              <>
                <rect
                  x={Math.max(Math.min((shuttleTargetX
                    - control.xOffset - 25)
                    * zoomScale, 250), -250)}
                  y={Math.max(Math.min((shuttleTargetY
                    - control.yOffset - 25)
                    * zoomScale, 250), -250)}
                  width={50 * zoomScale}
                  height={50 * zoomScale}
                  style={boxTargetStyle} />
                <line
                  x1={Math.max(Math.min((shuttleTargetX
                    - control.xOffset - 25)
                    * zoomScale, 250), -250) + 25 * zoomScale}
                  y1={Math.max(Math.min((shuttleTargetY
                    - control.yOffset - 25)
                    * zoomScale, 250), -250) - 25 * zoomScale}
                  x2={Math.max(Math.min((shuttleTargetX
                    - control.xOffset - 25)
                    * zoomScale, 250), -250) + 25 * zoomScale}
                  y2={Math.max(Math.min((shuttleTargetY
                    - control.yOffset - 25)
                    * zoomScale, 250), -250) + 75 * zoomScale}
                  style={boxTargetStyle} />
                <line
                  x1={Math.max(Math.min((shuttleTargetX
                    - control.xOffset - 25)
                    * zoomScale, 250), -250) - 25 * zoomScale}
                  y1={Math.max(Math.min((shuttleTargetY
                    - control.yOffset - 25)
                    * zoomScale, 250), -250) + 25 * zoomScale}
                  x2={Math.max(Math.min((shuttleTargetX
                    - control.xOffset - 25)
                    * zoomScale, 250), -250) + 75 * zoomScale}
                  y2={Math.max(Math.min((shuttleTargetY
                    - control.yOffset - 25)
                    * zoomScale, 250), -250) + 25 * zoomScale}
                  style={boxTargetStyle} />
                <line
                  x1={Math.max(Math.min((ourObject.position_x
                    - control.xOffset
                    + ourObject.velocity_x * control.elapsed)
                    * zoomScale, 250), -250)}
                  y1={Math.max(Math.min((ourObject.position_y
                    - control.yOffset
                    + ourObject.velocity_y * control.elapsed)
                    * zoomScale, 250), -250)}
                  x2={Math.max(Math.min((shuttleTargetX
                    - control.xOffset)
                    * zoomScale, 250), -250)}
                  y2={Math.max(Math.min((shuttleTargetY
                    - control.yOffset)
                    * zoomScale, 250), -250)}
                  style={lineTargetStyle} />
              </>
            )}
            {ourObject && (
              <circle
                cx={Math.max(Math.min((ourObject.position_x
                  - control.xOffset
                  + ourObject.velocity_x * control.elapsed)
                  * zoomScale, 250), -250)}
                cy={Math.max(Math.min((ourObject.position_y
                  - control.yOffset
                  + ourObject.velocity_y * control.elapsed)
                  * zoomScale, 250), -250)}
                r={((ourObject.position_y - control.yOffset)
                  * zoomScale > 250
                  || (ourObject.position_y - control.yOffset)
                  * zoomScale < -250
                  || (ourObject.position_x - control.xOffset)
                  * zoomScale > 250
                  || (ourObject.position_x - control.xOffset)
                  * zoomScale < -250)
                  ? 5 * zoomScale
                  : Math.max(5 * zoomScale, interdiction_range
                    * zoomScale)}
                stroke="#00FF00"
                stroke-width="1"
                fill="rgba(0,0,0,0)" />
            )}
          </svg>
        )}
      </OrbitalMapComponent>
    </Fragment>
  );

};

export const RecallControl = (props, context) => {
  const { act, data } = useBackend(context);
  const { request_shuttle_message } = data;
  return (
    <>
      <NoticeBox>
        Manual control disabled, this location
        can only recall the shuttle.
      </NoticeBox>
      <Button
        content={request_shuttle_message}
        textAlign="center"
        fontSize="30px"
        icon="rocket"
        width="100%"
        height="50px"
        onClick={() => act('callShuttle')} />
    </>
  );
};

export const ShuttleControls = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    map_objects = [],
    shuttleTarget = null,
    shuttleAngle = 0,
    shuttleThrust = 0,
    canDock = false,
    isDocking = false,
    validDockingPorts = [],
    display_fuel = false,
    fuel = 0,
    display_stats = [],
    autopilot_enabled = false,
  } = data;
  return (
    <>
      <Box bold>
        Autopilot Target
      </Box>
      <Dropdown
        mt={1}
        selected={shuttleTarget}
        width="100%"
        options={map_objects.map(map_object => (map_object.name))}
        onSelected={value => act("setTarget", {
          target: value,
        })} />
      <Box mt={1}>
        Velocity line will be adjusted to relative
        speed of this orbital body.
      </Box>
      <ShuttleMap />
      <NoticeBox color="purple" mt={2}>
        Click on the primary display to fly.
      </NoticeBox>
      <Box bold>
        Throttle
      </Box>
      <Box>
        Shuttle Thrust: {shuttleThrust}
      </Box>
      <Box bold mt={2}>
        Thrust Angle
      </Box>
      <Box>
        Angle: {shuttleAngle}
      </Box>
      {(!display_fuel) || (
        <>
          <Box bold mt={2}>
            Fuel Remaining
          </Box>
          <ProgressBar
            value={fuel}>
            {fuel} moles.
          </ProgressBar>
        </>
      )}
      <Table mt={2}>
        {Object.keys(display_stats).map(value => (
          <Table.Row key={value}>
            <Table.Cell bold>
              {value} :
            </Table.Cell>
            <Table.Cell textAlign="right">
              {display_stats[value]}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
      <Button
        mt={2}
        content="Toggle Autopilot"
        onClick={() => act('nautopilot')}
        color={autopilot_enabled ? "green" : "red"} />
      {!(canDock && !isDocking) || (
        <Button
          mt={2}
          content="Initiate Docking"
          onClick={() => act('dock')} />
      )}
      <Button
        mt={2}
        content="ENGAGE INTERDICTOR"
        onClick={() => act('interdict')}
        color="purple" />
    </>
  );
};

export const ShuttleMap = (props, context) => {
  const lineStyle = {
    stroke: '#BBBBBB',
    strokeWidth: '2',
  };
  const velLineStyle = {
    stroke: '#00FF00',
    strokeWidth: '2',
  };
  const { act, data } = useBackend(context);
  const {
    shuttleAngle = 0,
    shuttleThrust = 0,
    shuttleVelX = 0,
    shuttleVelY = 0,
  } = data;
  let x = (shuttleThrust + 30) * Math.cos(shuttleAngle * (2 * Math.PI / 360));
  let y = (shuttleThrust + 30) * Math.sin(shuttleAngle * (2 * Math.PI / 360));
  return (
    <Box
      width="370px"
      height="160px">
      <svg
        position="absolute"
        height="100%"
        viewBox="-100 -100 200 200">
        <defs>
          <pattern id="grid" width={200} height={200} patternUnits="userSpaceOnUse">
            <rect width={200} height={200} fill="url(#smallgrid)" />
            <path d={"M 200 0 L 0 0 0 200"} fill="none" stroke="#4665DE" stroke-width="1" />
          </pattern>
          <pattern id="smallgrid" width={100} height={100} patternUnits="userSpaceOnUse">
            <rect width={100} height={100} fill="#2B2E3B" />
            <path d={"M 100 0 L 0 0 0 100"} fill="none" stroke="#4665DE" stroke-width="0.5" />
          </pattern>
        </defs>
        <rect x="-50%" y="-50%" width="100%" height="100%" fill="url(#grid)" />
        <circle
          r="30px"
          stroke="#BBBBBB"
          stroke-width="1"
          fill="rgba(0,0,0,0)" />
        <line
          x1={0}
          y1={0}
          x2={x}
          y2={y}
          style={lineStyle} />
        <line
          x1={0}
          y1={0}
          x2={shuttleVelX}
          y2={shuttleVelY}
          style={velLineStyle} />
      </svg>
    </Box>
  );
};
