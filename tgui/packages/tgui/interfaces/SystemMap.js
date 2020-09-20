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
  const { data } = useBackend(context);
  const {
    jump_state,
  } = data;
  return (
    <Window
      resizable>
      <Section
        textAlign="center">
        <b>
          N.T.T. Pathfinder
        </b>
        <Box
          textAlign="center">
          Faction: Nanotrasen
        </Box>
        <Box
          textAlign="center"
          bold>
          Status: ENGINES IDLE - AWAITING INPUT
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
              3/4
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              Hyperdrive Queue Length
            </Table.Cell>
            <Table.Cell
              bold
              color="green">
              2
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              Estimated Departure Time
            </Table.Cell>
            <Table.Cell
              bold
              color="green">
              300 seconds
            </Table.Cell>
          </Table.Row>
        </Table>
      </Section>
      <Divider />
      <Section>
        <Table>
          <Table.Row>
            <Table.Cell bold>
              Selected System:
            </Table.Cell>
            <Table.Cell bold>
              None
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              System Alignment
            </Table.Cell>
            <Table.Cell bold>
              Neutral
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              Threat Level
            </Table.Cell>
            <Table.Cell bold>
              Low
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              Research Value
            </Table.Cell>
            <Table.Cell bold>
              High
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              Distance From Station
            </Table.Cell>
            <Table.Cell bold>
              4 BSU
            </Table.Cell>
          </Table.Row>
        </Table>
        <Divider />
        <Box bold
          textAlign="center">
          Detected Signals
        </Box>
        <Box
          textAlign="center">
          Hostile Signal
        </Box>
        <Divider />
        <Box
          textAlign="center">
          <Button
            content="Request Jump" />
        </Box>
      </Section>
      <Divider />
      <Section>
        <Table>
          <Table.Row>
            <Table.Cell>
              <Box
                bold>
                System Name
              </Box>
            </Table.Cell>
            <Table.Cell>
              <Box>
                Alignment: Neutral
              </Box>
            </Table.Cell>
            <Table.Cell>
              <Box>
                Threat: Low
              </Box>
            </Table.Cell>
            <Table.Cell>
              <Button
                content="Select System" />
            </Table.Cell>
          </Table.Row>
        </Table>
      </Section>
    </Window>
  );
};
