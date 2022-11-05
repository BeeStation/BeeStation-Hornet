/* eslint-disable react/prefer-stateless-function */
import { useBackend, useLocalState } from '../backend';
import { Box, ColorBox, Input, Section, Table, Tooltip, Button, Flex, ByondUi, Tabs, NumberInput } from '../components';
import { COLORS } from '../constants';
import { jobIsHead, jobToColor, healthToColor, HEALTH_COLOR_BY_LEVEL } from './CrewConsole';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';
import { ButtonCheckbox } from '../components/Button';
import { Component } from 'inferno';

/**
--------------------
     Constants
--------------------
**/

const ELLIPSIS_STYLE = { // enforces overflow ellipsis
  "max-width": "1px",
  "white-space": "nowrap",
  "text-overflow": "ellipsis",
  "overflow": "hidden",
};

const TELEMETRY_COLOR_MAP = {
  "!!!": "#e74c3c",
  "!": "#fae257",
  "???": "#e74c3c",
  "?": null,
  "...": null,
  "N/A": null,
  "DC": "#aaaaaa",
};

const KEY_REGEX = /^(\[[\d:]+\]) ([\S\s]+?)\/\(([\S\s]+?)\) \(([\s\S]+?) \((\d+, \d+, \d+)\)\) \(Event #(\d+)\)$/;

const TIMESTAMP_PARSE_REGEX = /^\[(\d+):(\d+):(\d+)\]/;

const LOG_TYPES_REVERSE = {
  "Attack": [1],
  "Say": [2, 4, 16],
  "Comms": [32, 64, 128, 256],
  "OOC": [512, 1024],
  "All": [1, 2, 4, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096],
};

const LOG_TYPES_LIST = Object.keys(LOG_TYPES_REVERSE);

const PANEL_HEIGHT = 260;


/**
--------------------
      Utilities
 (for performance)
--------------------
**/

const shallow_diff = (a, b, ignore = []) => {
  for (const key in a) {
    if (ignore.indexOf(key) === -1 && !(key in b)) {
      return true;
    }
  }
  for (const key in b) {
    if (ignore.indexOf(key) === -1 && a[key] !== b[key]) {
      return true;
    }
  }
  return false;
};

class PureComponent extends Component {
  shouldComponentUpdate(new_props, new_state) {
    return shallow_diff(this.props, new_props)
    || shallow_diff(this.state, new_state);
  }
}


/**
--------------------
  Main Window
--------------------
**/

export const PlayerPanel = (_, context) => {
  const { data, act } = useBackend(context);
  const {
    players = {},
    selected_ckey,
    use_view,
    search_text,
    update_interval,
  } = data;
  const selected_player = players[selected_ckey];
  return (
    <Window
      width={1000}
      height={615}
      theme="admin"
      buttons={
        <>
          <Input
            placeholder="Search name, job, or CKEY"
            width={20}
            value={search_text}
            onInput={(_, value) => act("set_search_text", { text: value })}
          />
          <Button
            ml={1}
            content="Check Antags"
            onClick={() => act('check_antagonists')}
          />
          <Button
            content="Silicon Laws"
            onClick={() => act('check_silicon_laws')}
          />
          <ButtonCheckbox content="Live View"
            tooltip="WARNING: Lags client"
            tooltipPosition="bottom-start"
            checked={use_view}
            onClick={() => act('set_use_view', { value: !use_view })} />
          <Tooltip
            content="Auto-Update Interval (0 to disable)"
            position="bottom-start">
            <NumberInput
              unit="s"
              width="50px"
              value={update_interval}
              onChange={(_, value) => act('set_update_interval', { value: value })}
              minValue={0}
              maxValue={120} />
          </Tooltip>
          <Button
            icon="sync-alt"
            tooltip="Reload player data"
            onClick={() => act('update')} />
        </>
      }>
      <style>{`
          .Button--fluid.button-ellipsis {
            max-width: 100%;
          }
          .button-ellipsis .Button__content {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
          }
        `}
      </style>
      <Window.Content>
        <Flex direction="column" wrap="wrap" height="100%">
          <Flex.Item grow={1}>
            <Section fill scrollable>
              <PlayerTable />
            </Section>
          </Flex.Item>
          {selected_player && (
            <Flex.Item style={{ "resize": "vertical" }} mt={1} height={`${PANEL_HEIGHT}px`}>
              <Box height="100%">
                <PlayerDetails
                  ckey={selected_player.ckey}
                  previous_names={selected_player.previous_names}
                  has_mind={selected_player.has_mind}
                  // log_mob and log_client are nested, cannot be pure
                  log_client={selected_player.log_client}
                  log_mob={selected_player.log_mob}
                  is_cyborg={selected_player.is_cyborg}
                  register_date={selected_player.register_date}
                  first_seen={selected_player.first_seen}
                  mob_type={selected_player.mob_type}
                  byond_version={selected_player.byond_version}
                  metacurrency_balance={selected_player.metacurrency_balance}
                  antag_rep={selected_player.antag_rep}
                  antag_tokens={selected_player.antag_tokens}
                  cid={selected_player.cid}
                  ip={selected_player.ip}
                  related_accounts_ip={selected_player.related_accounts_ip}
                  related_accounts_cid={selected_player.related_accounts_cid}
                  photo_path={selected_player.photo_path} />
              </Box>
            </Flex.Item>
          )}
        </Flex>
      </Window.Content>
    </Window>
  );
};

/**
--------------------
  Bottom View
--------------------
**/


const PlayerDetails = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    mapRef,
    map_range,
    use_view,
    metacurrency_name = "BeeCoin", // sorry downstreams
  } = data;

  const {
    ckey,
    previous_names = [],
    has_mind,
    log_client = {},
    log_mob = {},
    is_cyborg,
    register_date = "N/A",
    first_seen = "N/A",
    mob_type = "N/A",
    byond_version = "N/A",
    metacurrency_balance = 0,
    antag_rep = 0,
    antag_tokens = 0,
    cid = "N/A",
    ip = "N/A",
    related_accounts_ip = "N/A",
    related_accounts_cid = "N/A",
    photo_path,
  } = props;


  let action_button_data = {
    "Info": {
      "PP": "open_player_panel",
      "Notes": "open_notes",
      "Logs": "open_logs",
      "Hours": "open_hours",
      "Telem": "open_telemetry",
    },
    "Message": {
      "PM": "pm",
      "SM": "subtle_message",
      "HM": "headset_message",
      "NRT": "narrate_to",
    },
    "Action": {
      "FLW": "follow",
      "VV": "open_view_variables",
      "Lang": "open_language_panel",
      "Heal": "revive",
      "Lobby": "send_to_lobby",
    },
    "Punish": {
      "Kick": "kick",
      "Ban": "open_ban",
      "Smite": "smite",
      "Prison": "jail",
    },
  };
  if (!has_mind) {
    action_button_data["Action"]["IM"] = "init_mind";
  } else {
    action_button_data["Action"]["TP"] = "open_traitor_panel";
  }
  if (is_cyborg) {
    action_button_data["Info"]["Borg"] = "open_cyborg_panel";
  }

  const action_button_list = [];
  for (let [name, val] of Object.entries(action_button_data)) {
    action_button_list.push(
      <Flex key={name} direction="column">
        <Flex.Item mt={name === "Message" ? 4.64 : 1}>
          <strong>{name}</strong>
        </Flex.Item>
        {Object.entries(val).map(([key, action]) => (
          <Flex.Item key={key} mt={0.35} ml={0.5}>
            <Button fluid color="yellow" content={key} tooltip={action} onClick={() => act(action, { who: ckey })} />
          </Flex.Item>
        ))}
      </Flex>
    );
  }

  return (
    <Flex height="100%">
      <Flex.Item grow={1} minWidth="125px">
        <Section fill fitted scrollable
          buttons={
            <Button color="green" icon="circle" tooltip="Deselect"
              style={{ "font-weight": "normal", "font-size": "12px" }}
              onClick={() => act('select_player', { who: null })}
            />
          }
          title={
            <Box style={{
              "white-space": "nowrap",
              "text-overflow": "ellipsis",
              "overflow": "hidden",
              "color": "#ffbf00",
              "width": "calc(100% - 25px)",
              "display": "inline-block",
            }}>
              <TooltipWrap text={
                ckey.charAt(0).toUpperCase() + ckey.slice(1)
              } />
            </Box>
          }>
          <Box style={{ "white-space": "pre-wrap", "padding": "5px", "overflow-wrap": "anywhere" }}>
            <strong>Mob Type:</strong><br />
            <Box color="#d8d8d8" style={{ "display": "inline-block",
              "word-break": "break-all", "width": "100%" }}>
              {mob_type}
            </Box>
            <strong>BYOND:</strong>{" "}
            <Box inline color="#d8d8d8">
              {byond_version}
            </Box><br />
            <strong>Antag Tokens:</strong>{" "}
            <Box inline color="#d8d8d8">
              {antag_tokens}
            </Box><br />
            <strong>Antag Rep:</strong>{" "}
            <Box inline color="#d8d8d8">
              {antag_rep}
            </Box><br />
            <strong>{metacurrency_name}s:</strong>{" "}
            <Box inline color="#d8d8d8">
              {metacurrency_balance}
            </Box><br />
            <hr style={{ "border": "1px solid #ffbf00", "height": 0, "opacity": 0.8 }} />
            <Box textAlign="center" bold>
              Names
            </Box>
            <Box inline color="#d8d8d8" textAlign="center">
              {previous_names.map(name =>
                <Box inline key={name}>{name}</Box>
              )}
            </Box>
          </Box>
        </Section>
      </Flex.Item>
      <Flex.Item height={use_view ? "170px" : "150px"} ml={1}>
        <Section fill fitted title={
          <>
            View
            {use_view ? (
              <>
                <Box inline width={1.2} />
                <Button style={{ "font-weight": "normal", "font-size": "12px" }}
                  mt={0} mb={0} icon="search-minus" onClick={() => act("set_map_range", { range: map_range + 1 })} />
                <Button
                  style={{ "font-weight": "normal", "font-size": "12px" }}
                  icon="sync-alt"
                  tooltip="Refresh view window in case it breaks"
                  onClick={() => act('refresh_view')}
                />
                <Button style={{ "font-weight": "normal", "font-size": "12px" }}
                  mt={0} mb={0} icon="search-plus" onClick={() => act("set_map_range", { range: map_range - 1 })} />
              </>
            ) : (
              <>
                <Box inline width={3} />
                <Button
                  style={{ "font-weight": "normal", "font-size": "12px" }}
                  icon="sync-alt"
                  tooltip="Refresh mob icon cache"
                  onClick={() => act('reload_images')}
                />
              </>
            )}
          </>
        }>
          <Box width="100%" height="100%">
            {(
              use_view ? (
                <ByondUi
                  width="100%"
                  height="100%"
                  params={{
                    zoom: 0,
                    "view-size": 169,
                    id: mapRef,
                    type: 'map',
                  }} />
              ) : (
                <Box width="110px" height="100%" style={{ "overflow": "hidden" }}>
                  <img width="100%" src={photo_path}
                    style={{
                      "overflow": "hidden",
                      "-ms-interpolation-mode": "nearest-neighbor", // IE
                      "image-rendering": "crisp-edges",
                    }} />
                </Box>
              )
            )}
          </Box>
        </Section>
      </Flex.Item>
      <Flex.Item grow={1} ml={1} mr={0.5}>
        <Section fill scrollable
          title={(
            <>
              CKEY Data
              <Box inline width={1.1} />
              <Button style={{ "font-weight": "normal", "font-size": "12px" }} mt={0} mb={0} color="yellow"
                content="CentCom" tooltip="Search CentCom Galactic Ban DB"
                onClick={() => act("open_centcom_bans_database", { who: ckey })} />
            </>
          )}
          style={{ "white-space": "pre-wrap" }}>
          <strong>First Join:</strong><br />
          <font color="#d8d8d8">{first_seen}</font>
          <br />
          <strong>Account Registered:</strong><br />
          <font color="#d8d8d8">{register_date}</font><br />
          <strong>IP: </strong><font color="#d8d8d8">{ip}</font><br />
          <strong>CID: </strong><font color="#d8d8d8">{cid}</font><br />
          <strong>Accounts (IP):</strong><br />
          <font color="#d8d8d8">{related_accounts_ip.split(", ").join("\n")}</font><br />
          <strong>Accounts (CID):</strong><br />
          <font color="#d8d8d8">{related_accounts_cid.split(", ").join("\n")}</font>
        </Section>
      </Flex.Item>
      <Flex.Item>
        <Flex height={`${PANEL_HEIGHT + 5}px`} wrap="wrap" direction="column" textAlign="center">
          {action_button_list}
        </Flex>
      </Flex.Item>
      <Flex.Item grow={2} ml={1} minWidth="400px">
        <LogViewer log_mob={log_mob} log_client={log_client} />
      </Flex.Item>
    </Flex>
  );
};

class LogViewer extends Component {

  constructor(props) {
    super(props);
    this.state = {
      logMode: "Say",
      hideLogKey: false,
      clientLog: true,
    };
  }

  countEntries = (log1, log2) => {
    let total = 0;
    for (let log of Object.values(log1)) {
      total += Object.keys(log).length;
    }
    for (let log of Object.values(log2)) {
      total += Object.keys(log).length;
    }
    return total;
  }

  shouldComponentUpdate(new_props, new_state) {
    if (shallow_diff(this.state, new_state)) {
      return true;
    }
    return this.countEntries(this.props.log_client, this.props.log_mob)
    !== this.countEntries(new_props.log_client, new_props.log_mob);
  }

  setLogMode = (value) => {
    this.setState({ logMode: value });
  }

  setHideLogKey = (value) => {
    this.setState({ hideLogKey: value });
  }

  setClientLog = (value) => {
    this.setState({ clientLog: value });
  }

  render() {
    const {
      logMode,
      hideLogKey,
      clientLog,
    } = this.state;
    const {
      log_client,
      log_mob,
    } = this.props;
    const log_source = (clientLog ? log_client : log_mob) || {};

    let log_data = {};
    const log_type_ids = LOG_TYPES_REVERSE[logMode];
    for (let log_type_id of log_type_ids) {
      log_data = { ...log_data, ...log_source[log_type_id] };
    }
    let sorted = Object.keys(log_data).sort((a, b) => {
      let groups = TIMESTAMP_PARSE_REGEX.exec(a);
      if (!groups) {
        return 0;
      }
      let aT = groups[1] * 3600 + groups[2] * 60 + groups[3];
      let groups2 = TIMESTAMP_PARSE_REGEX.exec(b);
      if (!groups2) {
        return 0;
      }
      return (groups2[1] * 3600 + groups2[2] * 60 + groups2[3]) - aT;
    });
    const log_entries = [];
    for (let key of sorted) {
      if (!hideLogKey) {
        log_entries.push(<LogEntryKey key={key} key_data={key} />);
      }
      log_entries.push(
        <LogEntryValue key={key + log_data[key]} value_data={log_data[key]} />
      );
    }

    return (
      <Section fill scrollable title={
        <>
          <Box inline>
            Logs
          </Box>
          <ButtonCheckbox ml={1} style={{ "font-weight": "normal", "font-size": "12px" }} content="Key"
            checked={!hideLogKey}
            onClick={() => this.setHideLogKey(!hideLogKey)} />
          <Button style={{ "font-weight": "normal", "font-size": "12px" }}
            tooltip="Current Log Source"
            content={clientLog ? "Client" : "Mob"}
            onClick={() => this.setClientLog(!clientLog)} />
        </>
      } buttons={
        <Box inline>
          <Tabs>
            {LOG_TYPES_LIST.map(name => (
              <Tabs.Tab
                textAlign="center"
                key={name}
                selected={logMode === name}
                onClick={() => this.setLogMode(name)}>
                {name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Box>
      }>
        <Table>
          {log_entries}
        </Table>
      </Section>
    );
  }
}

class LogEntryKey extends PureComponent {
  render() {
    const { act } = useBackend(this.context);
    const {
      key_data,
    } = this.props;
    let results = KEY_REGEX.exec(key_data);
    if (results && results.length === 7) {
      let key_obj = {
        timestamp: results[1],
        ckey: results[2],
        character_name: results[3],
        area_name: results[4],
        coordinates: results[5],
        event_number: results[6],
      };
      return (
        <Table.Row>
          <Table.Cell collapsing>
            {key_obj.timestamp}
          </Table.Cell>
          <Table.Cell collapsing>
            #{key_obj.event_number}
          </Table.Cell>
          <Table.Cell style={ELLIPSIS_STYLE}>
            <TooltipWrap text={key_obj.character_name} />
          </Table.Cell>
          <Table.Cell collapsing textAlign="center" style={{
            "max-width": "100px",
            "white-space": "nowrap",
            "text-overflow": "ellipsis",
            "overflow": "hidden",
          }}>
            <Button
              fluid
              className="button-ellipsis"
              content={key_obj.area_name}
              tooltip={`Jump to: ${key_obj.area_name} (${key_obj.coordinates})`}
              onClick={() => act("jump_to", { coords: key_obj.coordinates.split(", ") })}
            />
          </Table.Cell>
        </Table.Row>
      );
    }
    return key_data;
  }
}

class LogEntryValue extends PureComponent {
  render() {
    const {
      value_data,
    } = this.props;
    return (
      <Table.Row style={{ "color": "#d8d8d8" }}>
        <Table.Cell colspan="4">
          {sanitizeText(value_data, [])}
        </Table.Cell>
      </Table.Row>
    );
  }
}

/**
--------------------
   Top Table
--------------------
**/

const PlayerTable = (_, context) => {
  const { data } = useBackend(context);
  const {
    selected_ckey,
  } = data;
  const [hourSort, setHourSort] = useLocalState(context, "player_panel_hour_sort", 0);
  const players = Object.values(data.players).sort((a, b) => a.ijob - b.ijob)
    .sort((a, b) => {
      let aTime = a.living_playtime === undefined ? 999999 : a.living_playtime;
      let bTime = b.living_playtime === undefined ? 999999 : b.living_playtime;
      if (hourSort === 1) {
        return aTime - bTime;
      } else if (hourSort === -1) {
        return bTime - aTime;
      }
      return 0;
    });
  return (
    <Table>
      <PlayerTableHeadings hourSort={hourSort} setHourSort={setHourSort} />
      {players.map(player => (
        <PlayerTableEntry key={player.ckey}
          selected_ckey={selected_ckey}
          name={player.name}
          real_name={player.real_name}
          job={player.job}
          ijob={player.ijob}
          ckey={player.ckey}
          has_mind={player.has_mind}
          oxydam={player.oxydam}
          toxdam={player.toxdam}
          burndam={player.burndam}
          brutedam={player.brutedam}
          health={player.health}
          health_max={player.health_max}
          position={player.position}
          living_playtime={player.living_playtime}
          is_antagonist={player.is_antagonist}
          antag_hud={player.antag_hud}
          telemetry={player.telemetry}
          connected={player.connected}
        />
      ))}
    </Table>
  );
};

class PlayerTableHeadings extends PureComponent {

  render() {
    const {
      hourSort,
      setHourSort,
    } = this.props;
    return (
      <Table.Row height={1.5}>
        <Table.Cell collapsing />
        <Table.Cell bold collapsing textAlign="center">
          Telem
        </Table.Cell>
        <Table.Cell bold collapsing textAlign="right"
          style={{
            "min-width": "14em",
          }}>
          (PP) CKEY
        </Table.Cell>
        <Table.Cell bold collapsing textAlign="center"
          style={{
            "min-width": "5em",
          }}>
          <HourSortButton
            hourSort={hourSort}
            setHourSort={setHourSort} />
        </Table.Cell>
        <Table.Cell bold collapsing textAlign="center">
          TP
        </Table.Cell>
        <Table.Cell bold collapsing textAlign="center"
          style={{
            "min-width": "9em",
          }}>
          Job/Role
        </Table.Cell>
        <Table.Cell bold>
          Name (PM)
        </Table.Cell>
        <Table.Cell bold collapsing textAlign="center"
          style={{
            "min-width": "12.5em",
          }}>
          Vitals (VV)
        </Table.Cell>
        <Table.Cell bold collapsing
          style={{
            "min-width": "12em",
          }}>
          Position (FLW)
        </Table.Cell>
      </Table.Row>
    );
  }
}

class HourSortButton extends Component {

  shouldComponentUpdate(new_props, _) {
    return new_props.hourSort !== this.props.hourSort;
  }

  render() {
    const {
      hourSort,
      setHourSort,
    } = this.props;
    return (
      <Button
        icon={hourSort === 1 ? "chevron-up" : (hourSort === -1 ? "chevron-down" : null)}
        fluid
        color="transparent"
        content="Hrs"
        onClick={() => {
          if (hourSort === 0) {
            setHourSort(1);
          } else if (hourSort === -1) {
            setHourSort(0);
          } else if (hourSort === 1) {
            setHourSort(-1);
          }
        }}
      />
    );
  }
}

const color_from_telemetry = telemetry => TELEMETRY_COLOR_MAP[telemetry];
const bold_from_telemetry = telemetry => telemetry?.includes("!");

/*
------------
  Top View
------------
*/

class PlayerTableEntry extends PureComponent {
  render() {
    const {
      selected_ckey,
      name,
      real_name,
      job,
      ijob = -1,
      ckey,
      has_mind,
      oxydam,
      toxdam,
      burndam,
      brutedam,
      health,
      health_max,
      position,
      living_playtime,
      is_antagonist,
      antag_hud,
      telemetry = "N/A",
      connected = false,
    } = this.props;
    return (
      <Table.Row height={2}>
        <Table.Cell collapsing textAlign="center">
          <PlayerSelectButton
            is_selected={selected_ckey === ckey}
            ckey={ckey} />
        </Table.Cell>
        <Table.Cell collapsing textAlign="center">
          <PlayerTelemetryButton telemetry={telemetry} ckey={ckey} />
        </Table.Cell>
        <Table.Cell collapsing textAlign="right" style={ELLIPSIS_STYLE}>
          <PlayerCKEYButton
            telemetry={telemetry}
            connected={connected}
            ckey={ckey} />
        </Table.Cell>
        <Table.Cell collapsing textAlign="center">
          <PlayerHoursButton
            living_playtime={living_playtime}
            ckey={ckey} />
        </Table.Cell>
        <Table.Cell collapsing textAlign="center">
          <PlayerTraitorPanelButton
            antag_hud={antag_hud || (is_antagonist ? "some_antag" : "none_antag")}
            has_mind={has_mind}
            ckey={ckey} />
        </Table.Cell>
        <Table.Cell collapsing textAlign="center" style={ELLIPSIS_STYLE}>
          <PlayerJobSelectButton
            job={job}
            ijob={ijob}
            ckey={ckey}
            is_selected={selected_ckey === ckey} />
        </Table.Cell>
        <Table.Cell style={ELLIPSIS_STYLE}>
          <PlayerNameButton
            name={name}
            real_name={real_name}
            ijob={ijob}
            ckey={ckey} />
        </Table.Cell>
        <Table.Cell collapsing textAlign="center">
          <PlayerVitalsButton
            ckey={ckey}
            oxydam={oxydam}
            toxdam={toxdam}
            burndam={burndam}
            brutedam={brutedam}
            health={health}
            health_max={health_max} />
        </Table.Cell>
        <Table.Cell collapsing style={ELLIPSIS_STYLE}>
          <PlayerLocationButton
            position={position}
            ckey={ckey} />
        </Table.Cell>
      </Table.Row>
    );
  }
}

/**
-----------------------------------------
    A bunch of parts of the top table
     (but split into "Pure" units)
-----------------------------------------
**/

class PlayerSelectButton extends PureComponent {
  render() {
    const { act } = useBackend(this.context);
    const {
      ckey,
      is_selected,
    } = this.props;
    return (
      <Button
        icon="circle"
        tooltip="Select Player"
        color={is_selected ? "green" : null}
        onClick={() => act('select_player', { who: is_selected ? null : ckey })} />
    );
  }
}

class PlayerTelemetryButton extends PureComponent {
  render() {
    const { act } = useBackend(this.context);
    const {
      telemetry,
      ckey,
    } = this.props;
    return (
      <Button
        fluid
        style={{
          "color": color_from_telemetry(telemetry),
        }}
        bold={bold_from_telemetry(telemetry)}
        content={telemetry !== undefined ? telemetry : "ERR"}
        tooltip="Open Telemetry"
        onClick={() => act('open_telemetry', { who: ckey })} />
    );
  }
}

class PlayerCKEYButton extends PureComponent {
  render() {
    const { act } = useBackend(this.context);
    const {
      telemetry,
      connected,
      ckey,
    } = this.props;
    return (
      <Button
        fluid
        className="button-ellipsis"
        bold={bold_from_telemetry(telemetry)}
        style={{
          "color": color_from_telemetry(telemetry),
          "font-style": !connected ? "italic" : null,
        }}
        content={ckey}
        tooltip={"Open Player Panel - " + ckey}
        onClick={() => act('open_player_panel', { who: ckey })} />
    );
  }
}

class PlayerHoursButton extends PureComponent {
  render() {
    const { act } = useBackend(this.context);
    const {
      living_playtime,
      ckey,
    } = this.props;
    const has_playtime = living_playtime !== undefined
      && living_playtime !== null;
    return (
      <Button
        textAlign={!has_playtime ? "center" : "right"}
        fluid
        content={has_playtime ? `${living_playtime}h` : "N/A"}
        disabled={!has_playtime}
        color={living_playtime >= 12 ? "default" : (living_playtime >= 1 ? "orange" : "danger")}
        onClick={() => act('open_hours', { who: ckey })} />
    );
  }
}

class PlayerTraitorPanelButton extends PureComponent {
  render() {
    const { act } = useBackend(this.context);
    const {
      antag_hud,
      has_mind,
      ckey,
    } = this.props;
    return (
      <Button
        style={{
          "padding": "0px 2px",
        }}
        content={<Box style={{ "transform": "translateY(2.5px)" }} className={`antag-hud16x16 antag-hud-${antag_hud}`} />}
        tooltip={has_mind ? "Open Traitor Panel" : "Initialize Mind"}
        onClick={() => act(has_mind ? 'open_traitor_panel' : 'init_mind', { who: ckey })}
      />
    );
  }
}

class PlayerJobSelectButton extends Component {

  render() {
    const { act } = useBackend(this.context);
    const {
      job,
      ijob,
      ckey,
      is_selected,
    } = this.props;
    return (
      <Button fluid
        className="button-ellipsis"
        color="transparent"
        content={job}
        tooltip={"Select Player - " + job}
        style={{
          "color": jobToColor(ijob),
        }}
        bold={jobIsHead(ijob)}
        onClick={() => act('select_player', { who: is_selected ? null : ckey })} />
    );
  }
}

class PlayerNameButton extends PureComponent {
  render() {
    const { act } = useBackend(this.context);
    const {
      real_name,
      name,
      ijob,
      ckey,
    } = this.props;
    return (
      <Button
        fluid
        className="button-ellipsis"
        content={`${real_name || name}${(real_name === name || !real_name ? "" : ` (as ${name})`)}`}
        tooltip={`Admin PM - ${real_name || name}${(real_name === name || !real_name ? "" : ` (as ${name})`)}`}
        style={{
          "color": jobToColor(ijob),
        }}
        bold={jobIsHead(ijob)}
        onClick={() => act('pm', { who: ckey })}
      />
    );
  }
}

class PlayerVitalsButton extends PureComponent {
  render() {
    const { act } = useBackend(this.context);
    const {
      ckey,
      oxydam,
      toxdam,
      burndam,
      brutedam,
      health,
      health_max,
    } = this.props;
    return (
      <Button
        fluid
        tooltip="View Variables"
        onClick={() => act('open_view_variables', { who: ckey })}
        content={
          <Box inline style={{ "width": "100%" }}>
            {oxydam !== undefined ? (
              <PlayerHumanVitals
                oxydam={oxydam}
                toxdam={toxdam}
                burndam={burndam}
                brutedam={brutedam} />
            ) : (
              health !== undefined ? (
                <PlayerNonHumanVitals
                  health={health}
                  health_max={health_max} />
              ) : (
                <Box inline>
                  N/A
                </Box>
              )
            )}
          </Box>
        }
      />
    );
  }
}

class PlayerHumanVitals extends PureComponent {
  render() {
    const {
      oxydam,
      toxdam,
      burndam,
      brutedam,
    } = this.props;
    return (
      <Box inline style={{ "display": "inline-flex", "align-items": "center", "width": "100%" }}>
        <ColorBox
          color={healthToColor(
            oxydam,
            toxdam,
            burndam,
            brutedam)} />
        <Box inline style={{ "flex": "1" }} />
        <Box inline style={{ "overflow": "hidden" }}>
          <HealthStatPure type="oxy" value={oxydam} />
          {'/'}
          <HealthStatPure type="toxin" value={toxdam} />
          {'/'}
          <HealthStatPure type="burn" value={burndam} />
          {'/'}
          <HealthStatPure type="brute" value={brutedam} />
        </Box>
      </Box>
    );
  }
}

class HealthStatPure extends PureComponent {
  render() {
    const {
      type,
      value,
    } = this.props;
    return (
      <Box
        inline
        width={2}
        color={COLORS.damageType[type]}
        textAlign="center">
        {value}
      </Box>
    );
  }
}

class PlayerNonHumanVitals extends PureComponent {
  render() {
    const {
      health,
      health_max,
    } = this.props;
    return (
      <Box inline style={{ "display": "inline-flex", "align-items": "center", "width": "100%" }}>
        <ColorBox color={
          HEALTH_COLOR_BY_LEVEL[Math.min(Math.max(
            Math.ceil(
              (health_max - health) / (health_max / 5)
            ), 0), 5)]
        } />
        <Box inline style={{ "flex": "1" }} />
        <Box inline style={{ "overflow": "hidden" }}>
          {`${health} of ${health_max} (${
            Math.round((health/health_max)*100)
          }%)`}
        </Box>
      </Box>
    );
  }
}

class PlayerLocationButton extends PureComponent {
  render() {
    const { act } = useBackend(this.context);
    const {
      position,
      ckey,
    } = this.props;
    return (
      <Button
        fluid
        className="button-ellipsis"
        disabled={!position}
        content={position || 'Nullspace (wtf)'}
        tooltip={"Follow player - " + position}
        onClick={() => act('follow', { who: ckey })} />
    );
  }
}

const TooltipWrap = (props) => {
  return (
    <Tooltip content={props.text}>
      <span {...props}>{props.text}</span>
    </Tooltip>
  );
};
