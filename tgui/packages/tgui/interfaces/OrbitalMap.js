import { toTitleCase } from 'common/string';
import { Box, Button, Section, Table } from '../components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

export const OrbitalMap = (props, context) => {
  const { act, data } = useBackend(context);
  const { map_objects } = data;
  const increments = [-200, -150, -100, -50, 0, 50, 100, 150, 200];
  const lineStyle = {
    stroke: 'rgb(255,0,0)',
    strokeWidth: '2',
  };
  return (
    <Window
      resizable
      width={800}
      height={800}>
      <Window.Content scrollable>
        <svg viewBox="-250 -250 500 500" position="absolute">
          <defs>
            <pattern id="grid" width="100" height="100" patternUnits="userSpaceOnUse">
              <rect width="100" height="100" fill="url(#smallgrid)" />
              <path d="M 100 0 L 0 0 0 100" fill="none" stroke="#4665DE" stroke-width="1" />
            </pattern>
            <pattern id="smallgrid" width="50" height="50" patternUnits="userSpaceOnUse">
              <rect width="50" height="50" fill="#6AC0FF" />
              <path d="M 50 0 L 0 0 0 50" fill="none" stroke="#4665DE" stroke-width="0.5" />
            </pattern>
          </defs>
          <rect x="-50%" y="-50%" width="100%" height="100%" fill="url(#grid)" />
          {map_objects.map(map_object => (
            <>
              <circle
                cx={Math.max(Math.min(map_object.position_x, 250), -250)}
                cy={Math.max(Math.min(map_object.position_y, 250), -250)}
                r="5" />
              <line
                x1={Math.max(Math.min(map_object.position_x, 250), -250)}
                y1={Math.max(Math.min(map_object.position_y, 250), -250)}
                x2={Math.max(Math.min(map_object.position_x, 250), -250)
                  + map_object.velocity_x * 10}
                y2={Math.max(Math.min(map_object.position_y, 250), -250)
                  + map_object.velocity_y * 10}
                style={lineStyle} />
              <text
                x={Math.max(Math.min(map_object.position_x, 250), -250)}
                y={Math.max(Math.min(map_object.position_y, 250), -250)}
                fill="white">
                {map_object.name} - (
                {map_object.position_x}, {map_object.position_y})
              </text>
            </>
          ))};
        </svg>
      </Window.Content>
    </Window>
  );
};
