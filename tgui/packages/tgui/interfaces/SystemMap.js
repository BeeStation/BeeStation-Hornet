import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, ByondUi, Input, Section, Box, Divider, ProgressBar, NoticeBox, Flex, Table, Icon, Grid } from '../components';
import { refocusLayout, Window } from '../layouts';
import { GridColumn } from '../components/Grid';

export const SystemMap = (props, context) => {
  return (
    <Window
      resizable>
      <div className="SystemMap__left">
        <Window.Content scrollable>
          <StarMapStarList />
        </Window.Content>
      </div>
      <div className="SystemMap__right">
        <div className="SystemMap__map">
          <Box
            height="660px"
            width="660px">
            <StarMapSvg />
          </Box>
        </div>
      </div>
    </Window>
  );
};

export const StarMapStarList = (props, context) => {
  return (
    <Section>
      <Box
        className={classes([
          'Button',
          'Button--fluid',
          'Button--color--transparent',
          'Button--ellipsis',
          'Button--selected',
        ])}>
        <b>
          Star Name
        </b>
        <Divider />
        Distance: 0ly
      </Box>
    </Section>
  );
};

/*
 * The star map is an SVG element with a bunch of circles and lines representing the stars
 * It is a way way way overcomplicated thing to just draw a bunch of planets, but as far as I know, it works
*/
export const StarMapSvg = (props, context) => {
  const { data } = useBackend(context);
  const {
    stars = [],
    links = [],
    icon_cache = [],
  } = data;
  return (
    <Fragment>
      <svg
        height="1000"
        width="1000"
        style="background-color:black">
        <StarMapBackground />
        {links.map(link => (
          <line x1={link.x1} y1={link.y1} x2={link.x2} y2={link.y2} stroke="#CEF0FF" />
        ))}
        {stars.map(star => (
          <Star
            key={star.name}
            starName={star.name}
            map_x={star.x}
            map_y={star.y}
            color="red" />
        ))}
      </svg>
      {stars.map(star => (
        <Fragment
          key={star.id}>
          <Box
            position="absolute"
            className={icon_cache[2].class_name}
            style={{
              'transform': 'scale(2, 2);',
            }}
            top={(star.y-16)+"px"}
            left={(star.x-16)+"px"} />
          {star.orbitting
            ? (
              <Box
                position="absolute"
                className={icon_cache[0].class_name}
                style={{
                  'transform': 'scale(1.5, 1.5);',
                }}
                top={(star.y-16)+"px"}
                left={(star.x-16)+"px"} />
            )
            : ""}
        </Fragment>
      ))}
    </Fragment>
  );
};

export const StarMapBackground = (props, context) => {
  const gridRows = [100, 200, 300, 400, 500, 600, 700, 800, 900];
  return (
    <Fragment>
      {gridRows.map(row => (
        <Fragment
          key={row}>
          <line x1={row} x2={row} y1={0} y2={1000} stroke="#333333" />
          <line y1={row} y2={row} x1={0} x2={1000} stroke="#333333" />
        </Fragment>
      ))}
    </Fragment>
  );
};

export const Star = (props, context) => {
  const { data } = useBackend(context);
  const {
    icon_cache = [],
  } = data;
  const {
    starName,
    map_x,
    map_y,
    color,
  } = props;
  return (
    <Fragment>
      <text
        x={map_x}
        y={map_y+30}
        fill="white"
        text-anchor="middle">
        {starName}
      </text>
    </Fragment>
  );
};
