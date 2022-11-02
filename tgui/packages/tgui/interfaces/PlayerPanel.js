import { useBackend, useLocalState } from '../backend';
import { Box, ColorBox, Input, Section, Table } from '../components';
import { jobIsHead, jobToColor, healthToColor, HealthStat } from './CrewConsole';
import { Window } from '../layouts';
import { sortBy } from 'common/collections';

export const PlayerPanel = (_, context) => {
  const [searchText, setSearchText] = useLocalState(context, "playerpanel_search_text", "");
  return (
    <Window
      width={1000}
      height={600}
      theme="admin"
      buttons={
        <Input
          placeholder="Search:"
          width={220}
          onChange={(e, value) => setSearchText(value)}
        />
      }>
      <Window.Content scrollable>
        <Section minHeight="540px">
          <PlayerTable />
        </Section>
      </Window.Content>
    </Window>
  );
};

const PlayerTable = (_, context) => {
  const { data } = useBackend(context);
  const players = sortBy(
    s => s.job
  )(data.players ?? []);
  return (
    <Table>
      <Table.Row>
        <Table.Cell bold textAlign="center">
          Telem
        </Table.Cell>
        <Table.Cell bold collapsing textAlign="right">
          CKEY
        </Table.Cell>
        <Table.Cell bold textAlign="center">
          Hours
        </Table.Cell>
        <Table.Cell bold textAlign="center">
          TP
        </Table.Cell>
        <Table.Cell bold>
          Name
        </Table.Cell>
        <Table.Cell bold collapsing />
        <Table.Cell bold collapsing textAlign="center">
          Vitals
        </Table.Cell>
        <Table.Cell bold>
          Position
        </Table.Cell>
      </Table.Row>
      {players.map(player => (
        <PlayerTableEntry player={player} key={player.ckey} />
      ))}
    </Table>
  );
};

const PlayerTableEntry = (props) => {
  const { player } = props;
  const {
    name,
    real_name,
    job,
    ckey,
    life_status,
    oxydam,
    toxdam,
    burndam,
    brutedam,
    health,
    health_max,
    position,
    living_playtime,
    is_antagonist,
    telemetry,
  } = player;
  const telemetry_color = telemetry === "!!!" ? "#e74c3c" : (telemetry === "!" ? "#c38312" : (telemetry !== undefined ? null : "#e74c3c"));
  const telemetry_bold = telemetry?.includes("!");
  return (
    <Table.Row>
      <Table.Cell textAlign="center" color={telemetry_color} bold={telemetry_bold}>
        {telemetry !== undefined ? telemetry : "ERR"}
      </Table.Cell>
      <Table.Cell collapsing textAlign="right" color={telemetry_color} bold={telemetry_bold}>
        {ckey}
      </Table.Cell>
      <Table.Cell textAlign="center">
        {living_playtime ? `${living_playtime}hrs` : "N/A"}
      </Table.Cell>
      <Table.Cell textAlign="center">
        {is_antagonist ? "A" : "-"}
      </Table.Cell>
      <Table.Cell
        bold={jobIsHead(job)}
        color={jobToColor(job)}>
        {name}{job !== undefined ? ` (${job})` : ""}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {life_status && oxydam !== undefined ? (
          <ColorBox
            color={healthToColor(
              oxydam,
              toxdam,
              burndam,
              brutedam)} />
        ) : (
          <ColorBox color={'#ed2814'} />
        )}
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        {oxydam !== undefined ? (
          <Box inline>
            <HealthStat type="oxy" value={oxydam} />
            {'/'}
            <HealthStat type="toxin" value={toxdam} />
            {'/'}
            <HealthStat type="burn" value={burndam} />
            {'/'}
            <HealthStat type="brute" value={brutedam} />
          </Box>
        ) : (
          health !== undefined ? (
            <Box inline>
              {`${health}/${health_max} \
            (${Math.round((health/health_max)*100)}%)`}
            </Box>
          ) : (
            <Box inline>
              N/A
            </Box>
          )
        )}
      </Table.Cell>
      <Table.Cell>
        {position !== undefined ? position : 'Nullspace (wtf)'}
      </Table.Cell>
    </Table.Row>
  );
};
