import { Box, Button, Section, Table, DraggableClickableControl, Dropdown, Divider, NoticeBox, ProgressBar, Flex, OrbitalMapComponent, OrbitalMapSvg } from '../components';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

export const Locator = (props, context) => {

  const { act, data } = useBackend(context);

  const {
    selected_target,
    valid_targets = [],
  } = data;

  return (
    <Window
      width={800}
      height={800}>
      <Window.Content>
        <NoticeBox
          position="absolute"
          color="green">
          <Box bold mt={1} ml={1}>
            Radar Triangulation
            <Button
              style={{
                "margin-left": "40px",
              }}
              color="red"
              icon="question"
              fontSize="14px"
              tooltip={
                <Section title="Triangulation Guide">
                  <Box color="blue">
                    1. Press <b>&#39;Activate Ping&#39;</b> to
                    trigger a radar pulse.
                  </Box>
                  <Box color="green">
                    2. Select the target you are wishing to find from the
                    dropdown list.
                  </Box>
                  <Box color="yellow">
                    3. The circles indicate possible locations of the target location.
                  </Box>
                  <Box color="purple">
                    The more pings you perform, the more accurate the pings will become.
                  </Box>
                </Section>
              } />
          </Box>
          <Box mt={1} ml={1}>
            <Button
              color="green"
              width="200px"
              content="Activate Ping"
              onClick={() => act('ping')} />
          </Box>
          <Box mt={1} ml={1}>
            <Button
              color="green"
              width="200px"
              content="Clear Pings"
              onClick={() => act('clear')} />
          </Box>
          <Box mt={1} ml={1}>
            <Dropdown
              color="green"
              width="200px"
              selected={selected_target}
              options={valid_targets}
              onSelected={(e) => act('set_target', {
                target: e,
              })} />
          </Box>
          <Box>
            {selected_target
              ? <>Scanning for {selected_target}</>
              : "Not scanning for targets."}.
          </Box>
        </NoticeBox>
        {selected_target
          ? <LocatorViewWindow />
          : <SelectWindow />}
      </Window.Content>
    </Window>
  );
};

const SelectWindow = (props, context) => {
  return (
    <svg
      viewBox="-250 -250 500 500"
      position="absolute">
      <defs>
        <pattern id="grid"
          width={250}
          height={250}
          patternUnits="userSpaceOnUse"
          x={0}
          y={0}>
          <rect width={250}
            height={250}
            fill="url(#smallgrid)" />
          <path
            fill="none" stroke="#afd9a9" stroke-width="1"
            d={"M " + (250)+ " 0 L 0 0 0 " + (250)} />
        </pattern>
        <pattern id="smallgrid"
          width={50}
          height={50}
          patternUnits="userSpaceOnUse">
          <rect
            width={50}
            height={50}
            fill="#000000" />
          <path
            fill="none"
            stroke="#738a70"
            stroke-width="0.5"
            d={"M " + (50) + " 0 L 0 0 0 "
            + (50)} />
        </pattern>
      </defs>
      <rect x="-250" y="-250" width="500" height="500"
        fill="url(#grid)" />
      <rect x="-250" y="-250" width="500" height="500"
        fill="#666666" opacity={0.5} />
      <text x="-230" y="3" fill="white" fontSize="26">
        Select a target from the dropdown.
      </text>
    </svg>
  );
};

const LocatorViewWindow = (props, context) => {

  const { data } = useBackend(context);

  const {
    x = 0,
    y = 0,
    pings = [],
  } = data;

  const [
    xOffset,
    setXOffset,
  ] = useLocalState(context, 'xOffset', x);

  const [
    yOffset,
    setYOffset,
  ] = useLocalState(context, 'yOffset', y);

  const [
    zoomScale,
    setZoomScale,
  ] = useLocalState(context, 'zoomScale', 1/64);

  const boxTargetStyle = {
    "fill-opacity": 0,
    stroke: '#DDDDDD',
    strokeWidth: '1',
  };

  let lockedZoomScale = Math.max(Math.min(zoomScale, 4), 1/32);
  return (
    <>
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
                  position="absolute">
                  <defs>
                    <pattern id="grid"
                      width={1600 * lockedZoomScale}
                      height={1600 * lockedZoomScale}
                      patternUnits="userSpaceOnUse"
                      x={-xOffset * zoomScale}
                      y={-yOffset * zoomScale}>
                      <rect width={1600 * lockedZoomScale}
                        height={1600 * lockedZoomScale}
                        fill="url(#smallgrid)" />
                      <path
                        fill="none" stroke="#afd9a9" stroke-width="1"
                        d={"M " + (1600 * lockedZoomScale)+ " 0 L 0 0 0 " + (1600 * lockedZoomScale)} />
                    </pattern>
                    <pattern id="smallgrid"
                      width={200 * lockedZoomScale}
                      height={200 * lockedZoomScale}
                      patternUnits="userSpaceOnUse">
                      <rect
                        width={200 * lockedZoomScale}
                        height={200 * lockedZoomScale}
                        fill="#000000" />
                      <path
                        fill="none"
                        stroke="#738a70"
                        stroke-width="0.5"
                        d={"M " + (200 * lockedZoomScale) + " 0 L 0 0 0 "
                        + (200 * lockedZoomScale)} />
                    </pattern>
                  </defs>
                  <rect x="-250" y="-250" width="500" height="500"
                    fill="url(#grid)" />
                  {x && y && (
                    <>
                      <rect
                        x={(x - 25 - xOffset) * zoomScale}
                        y={(y - 25 - yOffset) * zoomScale}
                        width={50 * zoomScale}
                        height={50 * zoomScale}
                        style={boxTargetStyle} />
                      <text
                        x={(x + 50 - xOffset) * zoomScale}
                        y={(y - 50 - yOffset) * zoomScale}
                        fill="white">
                        Current Location
                      </text>
                    </>
                  )}
                  {pings.map(ping => (
                    <>
                      <circle
                        cx={(ping.x - xOffset) * zoomScale}
                        cy={(ping.y - yOffset) * zoomScale}
                        r={ping.distance * zoomScale}
                        fill="none"
                        stroke={"#" + ping.colour}
                        stroke-width="0.5" />
                      <text
                        x={(ping.x + 0.707 * ping.distance - xOffset)
                          * zoomScale}
                        y={(ping.y + 0.707 * ping.distance - yOffset)
                          * zoomScale}
                        fill={"#" + ping.colour} >
                        {ping.name}
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
