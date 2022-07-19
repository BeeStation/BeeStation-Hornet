import { Box, Button, Section, Table, DraggableClickableControl, Dropdown, Divider, NoticeBox, ProgressBar, Flex, OrbitalMapComponent, OrbitalMapSvg } from '../components';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

export const Locator = (props, context) => {

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
    selectedPing,
    setSelectedPing,
  ] = useLocalState(context, 'selectedPing', null);

  const boxTargetStyle = {
    "fill-opacity": 0,
    stroke: '#DDDDDD',
    strokeWidth: '1',
  };

  let lockedZoomScale = Math.max(Math.min(zoomScale, 4), 0.125);

  const { act, data } = useBackend(context);

  const {
    x = 0,
    y = 0,
    pings = [],
  } = data;

  return (
    <Window>
      <Window.Content>
        <NoticeBox
          position="absolute"
          color="green">
          <Box bold mt={1} ml={1}>
            Radar Triangulation
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
              selected={selectedPing}
              options={pings.map(ping => ping.name)}
              onSelected={(e) => { setSelectedPing(e); }} />
          </Box>
          {xOffset}, {yOffset}
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
                    position="absolute">
                    <defs>
                      <pattern id="grid"
                        width={400 * lockedZoomScale}
                        height={400 * lockedZoomScale}
                        patternUnits="userSpaceOnUse"
                        x={-xOffset * zoomScale}
                        y={-yOffset * zoomScale}>
                        <rect width={400 * lockedZoomScale}
                          height={400 * lockedZoomScale}
                          fill="url(#smallgrid)" />
                        <path
                          fill="none" stroke="#afd9a9" stroke-width="1"
                          d={"M " + (400 * lockedZoomScale)+ " 0 L 0 0 0 " + (400 * lockedZoomScale)} />
                      </pattern>
                      <pattern id="smallgrid"
                        width={50 * lockedZoomScale}
                        height={50 * lockedZoomScale}
                        patternUnits="userSpaceOnUse">
                        <rect
                          width={50 * lockedZoomScale}
                          height={50 * lockedZoomScale}
                          fill="#000000" />
                        <path
                          fill="none"
                          stroke="#738a70"
                          stroke-width="0.5"
                          d={"M " + (50 * lockedZoomScale) + " 0 L 0 0 0 "
                          + (50 * lockedZoomScale)} />
                      </pattern>
                    </defs>
                    <rect x="-250" y="-250" width="500" height="500"
                      fill="url(#grid)" />
                    {x && y && (
                      <rect
                        x={(x - 25 - xOffset) * zoomScale}
                        y={(y - 25 - yOffset) * zoomScale}
                        width={50 * zoomScale}
                        height={50 * zoomScale}
                        style={boxTargetStyle} />
                    )}
                    {pings.map(ping => ((selectedPing === null
                    || selectedPing === ping.name) && (
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
                    )))}
                  </svg>
                </>
              )}
            </DraggableClickableControl>
          )}
        </DraggableClickableControl>
      </Window.Content>
    </Window>
  );
};
