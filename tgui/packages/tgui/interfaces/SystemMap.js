import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, ByondUi, Input, Section, Box, Divider, ProgressBar, NoticeBox, Flex, Table, Icon, Grid, Tabs } from '../components';
import { refocusLayout, Window } from '../layouts';
import { GridColumn } from '../components/Grid';

export const SystemMap = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    ship_status,
    active_lanes,
    queue_length,
    departure_time,
    ship_name,
    ship_faction,
    stars = [],
    extra_data = [],
    custom_shuttle,
  } = data;
  const [
    system,
    setSystem,
  ] = useLocalState(context, 'system', {});
  return (
    <Window
      width={540}
      height={708}
      resizable>
      <Section
        textAlign="center">
        <b>
          {ship_name}
        </b>
        <Box
          textAlign="center">
          Faction: {ship_faction}
        </Box>
        <Box
          textAlign="center"
          bold>
          Status: {ship_status}
        </Box>
      </Section>
      <Divider />
      <Section>
        <b>
          System Diagnostics
        </b>
        <Divider />
        <Table>
          <Table.Row>
            <Table.Cell>
              Bluespace Traffic Control:
            </Table.Cell>
            <Table.Cell
              bold
              color="green">
              Connection Stable
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              Active Bluespace Hyperlanes
            </Table.Cell>
            <Table.Cell
              bold
              color="average">
              {active_lanes}
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              Hyperdrive Queue Length
            </Table.Cell>
            <Table.Cell
              bold
              color="green">
              {queue_length}
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              Estimated Departure Time
            </Table.Cell>
            <Table.Cell
              bold
              color="green">
              {departure_time} seconds
            </Table.Cell>
          </Table.Row>
          {extra_data.map(extra_data_peice => (
            <Table.Row
              key={extra_data_peice}>
              <Table.Cell>
                {extra_data_peice[0]}
              </Table.Cell>
              <Table.Cell
                bold
                color="green">
                {extra_data_peice[1]}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
        {custom_shuttle
          ?(
            <Box
              textAlign="center">
              <Divider />
              <Button
                content="Calculate Stats"
                onClick={() => act('calculate_custom_shuttle')} />
            </Box>
          )
          : ""}
      </Section>
      <Divider />
      <Section>
        <Table>
          <Table.Row>
            <Table.Cell bold>
              Selected System:
            </Table.Cell>
            <Table.Cell bold>
              {system ? system.name : "N/A"}
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              System Alignment
            </Table.Cell>
            <Table.Cell bold>
              {system ? system.alignment : "N/A"}
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              Threat Level
            </Table.Cell>
            <Table.Cell bold>
              {system ? system.threat : "N/A"}
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              Research Value (Ruin Density)
            </Table.Cell>
            <Table.Cell bold>
              {system ? system.research_value : "N/A"}
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              Distance From Station
            </Table.Cell>
            <Table.Cell bold>
              {system ? system.distance + " BSU" : "N/A"}
            </Table.Cell>
          </Table.Row>
        </Table>
        <Divider />
        <Box
          textAlign="center">
          <Button
            content="Request Jump"
            onClick={() => act('jump', {
              'system_name': system
                ? system.id
                  ? system.id
                  : system.name
                : "",
            })} />
        </Box>
      </Section>
      <Divider />
      <Section>
        <Table>
          {stars.map(star => (
            <Table.Row
              key={star}>
              <Table.Cell>
                <Box
                  bold>
                  {star.name}
                </Box>
              </Table.Cell>
              <Table.Cell>
                <Box>
                  Alignment: {star.alignment}
                </Box>
              </Table.Cell>
              <Table.Cell>
                <Box>
                  Threat: {star.threat}
                </Box>
              </Table.Cell>
              <Table.Cell>
                <Button
                  content="Select System"
                  onClick={() => setSystem(star)} />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Window>
  );
};
