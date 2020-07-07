import { createSearch, decodeHtmlEntities } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Icon, Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, Divider, Grid, ProgressBar, Collapsible } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';
import { TableRow } from '../components/Table';
import { GridColumn } from '../components/Grid';

export const ClockworkSlab = (props, context) => {
  const { data } = useBackend(context);
  const { power } = data;
  const { recollection } = data;
  const [
    selectedTab,
    setSelectedTab,
  ] = useLocalState(context, 'selectedTab', "Scriptures");
  return (
    <Window
      theme="clockwork"
      resizable>
      <Window.Content>
        <Section
          title={(
            <Box
              inline
              color={'good'}>
              <Icon name={"cog"} rotation={0} spin={1} />
              {" Clockwork Slab "}
              <Icon name={"cog"} rotation={35} spin={1} />
            </Box>
          )}>
          <ClockworkButtonSelection />
        </Section>
        <div className="ClockSlab__left">
          <Section
            height="100%"
            overflowY="scroll">
            <ClockworkSpellList selectedTab={selectedTab} />
          </Section>
        </div>
        <div className="ClockSlab__right">
          <div className="ClockSlab__stats">
            <Section
              height="100%"
              scrollable
              overflowY="scroll">
              <ClockworkOverview />
            </Section>
          </div>
          <div className="ClockSlab__current">
            <Section
              height="100%"
              scrollable
              overflowY="scroll"
              title="Servants of the Cog vol.1">
              <ClockworkHelp />
            </Section>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

export const ClockworkHelp = (props, context) => {
  return (
    <Fragment>
      <Collapsible title="Where To Start" color="average" open={1}>
        <Section>
          After a long and destructive
          war, Rat'Var has been imprisoned
          inside a dimension of suffering.
          <br />
          You are a group of his last remaining,
          most loyal servants. <br />
          You are very weak and have little power,
          with most of your scriptures unable to
          function. <br />
          <b>Use the <font color="#BD78C4">Ratvarian
          Observation Consoles</font> to warp to the
          station!</b><br />
          <b>Install <font color="#DFC69C">Integration
          Cogs</font> to unlock more scriptures and
          siphon power!</b><br />
          <b>Unlock <font color="#D8D98D">Kindle</font>,
          <font color="#F19096">Hateful Menacles</font> and
          summon a <font color="#9EA7E5">Sigil of Submission
          </font> to convert any non-believers!</b><br />
        </Section>
      </Collapsible>
      <Collapsible title="Unlocking Scriptures" color="average">
        <Section>
          Most scriptures require <b>cogs</b> to unlock.
          <br />
          Invoke <font color="#DFC69C"><b>Integration
          Cog</b></font> to summon an Integration Cog,
          which can be placed into any <b>APC</b> on the station. <br />
          Slice open the <b>APC</b> with the
          <b>Integration Cog</b>, then insert it in to
          begin siphoning power. <br />
        </Section>
      </Collapsible>
      <Collapsible title="Conversion" color="average">
        <Section>
          Invoke <b><font color="#D8D98D">Kindle</font></b>
          (After you unlock it), to <b>stun</b> and <b>mute</b>
          any target long enough for you to restrain <br />
          Using <b>zipties</b> obtained from the station, or
          by invoking <b><font color="#F19096">Hateful
          Menacles</font></b>, you can restrain targets
          to keep them from escaping the light. <br />
          Invoke <b><font color="#D5B8DC">Abscond</font></b>
          to warp back to Reebe, where the being you are
          dragging will be pulled with you. <br />
          From there, summon a <b><font color="#9EA7E5">Sigil
          of Submission</font></b> and hold them over
          it for 8 seconds. <br />
          You cannot enlighten those who have
          <b>mindshields.</b> <br />
          Make sure to take their <b>headset</b>,
          so they don't spread misinformation! <br />
        </Section>
      </Collapsible>
      <Collapsible title="Defending Reebe" color="average">
        <Section>
          <b>You have a wide range of structures and powers
          that will be vital in defending the Celestial
          Gateway.</b> <br />
          <b><font color="#B5FD9D">Replicant Fabricator: </font></b>
          A powerful tool that can rapidly construct
          Brass structures, or convert most materials
          to Brass.<br />
          <b><font color="#DED09F">Cogscarab: </font>
          </b>A small drone possessed by the spirits
           of the fallen soldiers which will protect
          Reebe while you go out and spread the
          truth!<br />
          <b><font color="#FF9D9D">Clockwork Marauder:
           </font></b> (Not implemented)<br />
        </Section>
      </Collapsible>
      <Collapsible title="Celestial Gateway" color="average">
        <Section>
          To summon Rat'Var the <b><font color="#E9E094">
          Celestial Gateway</font></b> must be opened. <br />
          This can be done by having enough servants invoke
          <b><font color="#B5FD9D">Celestial Gateway.</font></b> <br />
          After you enlighten enough of the crew,
          the <b><font color="#E9E094">Celestial
          Gateway</font></b> will be forced open. <br />
          <b>Make sure you are prepared for when the
          Gateway opens, since the entire crew
          will swarm to destroy it!</b> <br />
        </Section>
      </Collapsible>
    </Fragment>
  );
};

export const ClockworkSpellList = (props, context) => {
  const { act, data } = useBackend(context);
  const { selectedTab } = props;
  const {
    scriptures = [],
    drivers = [],
    applications = [],
  } = data;
  let tabSpells = selectedTab === "Scriptures"
    ? scriptures
    : selectedTab === "Drivers"
      ? drivers
      : applications;
  return (
    <Table>
      {tabSpells.map(script => (
        <Fragment
          key={script}>
          <TableRow>
            <Table.Cell bold>
              {script.name}
            </Table.Cell>
            <Table.Cell collapsing textAlign="right">
              <Button
                fluid
                color={script.purchased
                  ? "default"
                  : "average"}
                content={script.purchased
                  ? "Invoke " + script.cost + "W"
                  : script.cog_cost + " Cogs"}
                disabled={false}
                onClick={() => act("invoke", {
                  scriptureName: script.name,
                })} />
            </Table.Cell>
          </TableRow>
          <TableRow>
            <Table.Cell>
              {script.desc}
            </Table.Cell>
            <Table.Cell collapsing textAlign="right">
              <Button
                fluid
                content={"Quickbind"}
                disabled={!script.purchased}
                onClick={() => act("quickbind", {
                  scriptureName: script.name,
                })} />
            </Table.Cell>
          </TableRow>
          <Table.Cell>
            <Divider />
          </Table.Cell>
        </Fragment>
      ))}
    </Table>
  );
};

export const ClockworkOverview = (props, context) => {
  const { data } = useBackend(context);
  const {
    power,
    cogs,
    vitality,
  } = data;
  return (
    <Box>
      <Box
        color="good"
        bold
        fontSize="16px">
        {"Celestial Gateway Report"}
      </Box>
      <Divider />
      <ClockworkOverviewStat
        title="Cogs"
        amount={cogs}
        maxAmount={cogs + (50 / cogs)}
        iconName="cog"
        unit="" />
      <ClockworkOverviewStat
        title="Power"
        amount={power}
        maxAmount={power + (50 / power)}
        iconName="battery-half "
        unit="W" />
      <ClockworkOverviewStat
        title="Vitality"
        amount={vitality}
        maxAmount={vitality + (50 / vitality)}
        iconName="tint"
        unit="u" />
    </Box>
  );
};

export const ClockworkOverviewStat = (props, context) => {
  const {
    title,
    iconName,
    amount,
    maxAmount,
    unit,
  } = props;
  return (
    <Box height="22px" fontSize="16px">
      <Grid>
        <Grid.Column>
          <Icon name={iconName} rotation={0} spin={0} />
        </Grid.Column>
        <Grid.Column size="2">
          {title}
        </Grid.Column>
        <Grid.Column size="8">
          <ProgressBar
            value={amount}
            minValue={0}
            maxValue={maxAmount}
            ranges={{
              good: [maxAmount/2, Infinity],
              average: [maxAmount/4, maxAmount/2],
              bad: [-Infinity, maxAmount/4],
            }}>
            {amount + " " + unit}
          </ProgressBar>
        </Grid.Column>
      </Grid>
    </Box>
  );
};

export const ClockworkButtonSelection = (props, context) => {
  const [
    selectedTab,
    setSelectedTab,
  ] = useLocalState(context, 'selectedTab', {});
  const tabs = ["Scriptures", "Drivers", "Applications", "Class Selection"];
  return (
    <Table>
      <Table.Row>
        {tabs.map(tab => (
          <Table.Cell
            key={tab}
            collapsing>
            <Button
              key={tab}
              fluid
              content={tab}
              onClick={() => setSelectedTab(tab)} />
          </Table.Cell>
        ))}
      </Table.Row>
    </Table>
  );
};
