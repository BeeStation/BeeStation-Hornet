import { useBackend, useLocalState } from '../backend';
import { Box, ColorBox, Input, Section, Table, Tooltip, Button, Flex, ByondUi, Icon, Stack, Dropdown, Tabs } from '../components';
import { jobIsHead, jobToColor, healthToColor, HealthStat, HEALTH_COLOR_BY_LEVEL } from './CrewConsole';
import { Window } from '../layouts';
import { sortBy } from 'common/collections';
import { sanitizeText } from '../sanitize';
import { ButtonCheckbox } from '../components/Button';

const ellipsis_style = { // enforces overflow ellipsis
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

const key_regex = /^(\[[\d:]+\]) ([\S\s]+?)\/\(([\S\s]+?)\) \(([\s\S]+?) \((\d+, \d+, \d+)\)\) \(Event #(\d+)\)$/;

const timestamp_parse = /^\[(\d+):(\d+):(\d+)\]/;

const LOG_TYPES_REVERSE = {
  "Attack": [1],
  "Say": [2, 4, 16],
  "Comms": [32, 64, 128, 256],
  "OOC": [512, 1024],
  "All": [1, 2, 4, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096],
};

const LOG_TYPES_LIST = Object.keys(LOG_TYPES_REVERSE);

export const PlayerPanel = (_, context) => {
  const [searchText, setSearchText] = useLocalState(context, "playerpanel_search_text", "");
  const { data } = useBackend(context);
  const {
    players = {},
    selected_ckey,
  } = data;
  const selected_player = players[selected_ckey];
  return (
    <Window
      width={1000}
      height={615}
      theme="admin"
      buttons={
        <Input
          placeholder="Search name, job, or CKEY"
          width={50}
          onInput={(e, value) => setSearchText(value)}
        />
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
          .player-entry {
            transition 0.25s linear background-color;
          }
          .player-entry:hover {
            background-color: #252525;
          }
        `}
      </style>
      <Window.Content>
        <Section height="400px" fill scrollable>
          <PlayerTable
            searchText={searchText} />
        </Section>
        <Box height="150px">
          {selected_player && (
            <PlayerDetails player={selected_player} />
          )}
        </Box>
      </Window.Content>
    </Window>
  );
};

const PlayerDetails = (props, context) => {
  const { data: { mapRef, map_range }, act } = useBackend(context);
  const [logMode, setLogMode] = useLocalState(context, "player_panel_log_mode", "Say");
  const [hideLogKey, setHideLogKey] = useLocalState(context, "player_panel_log_hide", false);
  const [clientLog, setClientLog] = useLocalState(context, "player_panel_log_source", true);
  const {
    ckey,
    previous_names,
    has_mind,
    log_client,
    log_mob,
    is_cyborg,
    register_date = "N/A",
    first_seen = "N/A",
    mob_type = "N/A",
    related_accounts_ip = "N/A",
    related_accounts_cid = "N/A",
  } = props.player;


  const key_parse = (key) => {
    let results = key_regex.exec(key);
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
          <Table.Cell style={ellipsis_style}>
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
              onClick={() => act("jump_to", { coords: key_obj.coordinates })}
            />
          </Table.Cell>
        </Table.Row>
      );
    }
    return key;
  };

  const log_source = clientLog ? log_client : log_mob;

  let log_data = {};
  const log_type_ids = LOG_TYPES_REVERSE[logMode];
  for (let log_type_id of log_type_ids) {
    log_data = { ...log_data, ...log_source[log_type_id] };
  }
  let sorted = Object.keys(log_data).sort((a, b) => {
    let groups = timestamp_parse.exec(a);
    if (!groups) {
      return 0;
    }
    let aT = groups[1] * 3600 + groups[2] * 60 + groups[3];
    let groups2 = timestamp_parse.exec(b);
    if (!groups2) {
      return 0;
    }
    return (groups2[1] * 3600 + groups2[2] * 60 + groups2[3]) - aT;
  });
  const log_entries = [];
  for (let key of sorted) {
    if (!hideLogKey) {
      log_entries.push(key_parse(key));
    }
    log_entries.push(
      <Table.Row style={{ "color": "#d8d8d8" }}>
        <Table.Cell colspan="4">
          {sanitizeText(log_data[key], [])}
        </Table.Cell>
      </Table.Row>
    );
  }

  let action_buttons_1 = {
    "PP": "open_player_panel",
    "VV": "open_variable_edit",
    "Notes": "open_notes",
  };
  let action_buttons_2 = {
    "SM": "subtle_message",
    "HM": "headset_message",
    "NRT": "narrate_to",
    "FLW": "follow",
    "PM": "pm",
    "Kick": "kick",
    "Ban": "open_ban",
    "Logs": "open_logs",
    "Hours": "open_hours",
    "Telem": "open_telemetry",
    "Smite": "smite",
    "Lang": "open_language_panel",
    "Heal": "revive",
    "Prison": "jail",
    "Lobby": "send_to_lobby",
  };
  if (!has_mind) {
    action_buttons_1["IM"] = "init_mind";
  } else {
    action_buttons_1["TP"] = "open_traitor_panel";
  }
  if (is_cyborg) {
    action_buttons_2["Borg"] = "open_cyborg_panel";
  }
  const action_buttons = { ...action_buttons_1, ...action_buttons_2 };

  const action_button_list = [];
  for (let [name, action] of Object.entries(action_buttons)) {
    action_button_list.push(
      <Flex.Item mt={0.35} ml={0.5}>
        <Button fluid color="yellow" content={name} tooltip={action} onClick={() => act(action, { who: ckey })} />
      </Flex.Item>
    );
  }

  return (
    <Flex>
      <Flex.Item width="120px">
        <Section fill fitted scrollable
          title={
            <Box mt={0.25} mb={0.25} style={{
              "white-space": "nowrap",
              "text-overflow": "ellipsis",
              "overflow": "hidden",
            }}>
              <TooltipWrap text={ckey} />
            </Box>
          }>
          <Box style={{ "white-space": "pre-wrap", "padding": "5px", "overflow-wrap": "anywhere" }}>
            <strong>Mob Type:</strong><br />
            <Box color="#d8d8d8" style={{ "display": "inline-block",
              "word-break": "break-all", "width": "100%" }}>
              {mob_type}
            </Box>
            <Box textAlign="center" bold>
              Names
            </Box>
            <Box inline color="#d8d8d8" textAlign="center">{previous_names.join("\n")}</Box>
          </Box>
        </Section>
      </Flex.Item>
      <Flex.Item ml={1}>
        <Section fill fitted title={
          <>
            View
            <Box inline width={1.2} />
            <Button style={{ "font-weight": "normal", "font-size": "12px" }}
              mt={0} mb={0} icon="search-minus" onClick={() => act("set_map_range", { range: map_range + 1 })} />
            <Button style={{ "font-weight": "normal", "font-size": "12px" }}
              mt={0} mb={0} icon="search-plus" onClick={() => act("set_map_range", { range: map_range - 1 })} />
          </>
        }>
          <Box width="100%" height="120px">
            <ByondUi
              width="100%"
              height="100%"
              params={{
                zoom: 0,
                id: mapRef,
                type: 'map',
              }} />
          </Box>
        </Section>
      </Flex.Item>
      <Flex.Item width="200px" ml={1}>
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
          <strong>Accounts (IP):</strong><br />
          <font color="#d8d8d8">{related_accounts_ip.split(", ").join("\n")}</font><br />
          <strong>Accounts (CID):</strong><br />
          <font color="#d8d8d8">{related_accounts_cid.split(", ").join("\n")}</font>
        </Section>
      </Flex.Item>
      <Flex.Item>
        <Flex height="155px" wrap="wrap" direction="column" textAlign="center">
          {action_button_list}
        </Flex>
      </Flex.Item>
      <Flex.Item ml={1}>
        <Section fill scrollable title={
          <>
            <Box inline>
              Logs
            </Box>
            <ButtonCheckbox ml={1} style={{ "font-weight": "normal", "font-size": "12px" }} content="Key"
              checked={!hideLogKey}
              onClick={() => setHideLogKey(!hideLogKey)} />
            <Button ml={1} style={{ "font-weight": "normal", "font-size": "12px" }}
              tooltip="Current Log Source"
              content={clientLog ? "Client" : "Mob"}
              onClick={() => setClientLog(!clientLog)} />
          </>
        } width="420px" buttons={
          <Box inline>
            <Tabs>
              {LOG_TYPES_LIST.map(name => (
                <Tabs.Tab
                  textAlign="center"
                  key={name}
                  selected={logMode === name}
                  onClick={() => setLogMode(name)}>
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
      </Flex.Item>
    </Flex>
  );
};

const PlayerTable = (props, context) => {
  const { data } = useBackend(context);
  const {
    searchText,
  } = props;
  const players = sortBy(
    s => s.job
  )(Object.values(data.players) ?? []);
  return (
    <Table>
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
        <Table.Cell bold collapsing textAlign="center">
          Hours
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
        <Table.Cell bold collapsing textAlign="center">
          Vitals (VV)
        </Table.Cell>
        <Table.Cell bold collapsing
          style={{
            "min-width": "12em",
          }}>
          Position (FLW)
        </Table.Cell>
      </Table.Row>
      {players.filter(player => searchText === undefined || searchText === ""
      || `${player.name} ${player.real_name} ${player.ckey} \
      ${player.job} ${player.previous_names}`
        .toLowerCase().includes(searchText.toLowerCase()))
        .map(player => (
          <PlayerTableEntry player={player} key={player.ckey} />
        ))}
    </Table>
  );
};

const PlayerTableEntry = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    selected_ckey,
  } = data;
  const { player } = props;
  const {
    name,
    real_name,
    job,
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
    telemetry = "N/A",
    connected = false,
  } = player;
  let antag_hud = player.antag_hud;
  if (!antag_hud) {
    antag_hud = is_antagonist ? "some_antag" : "none_antag";
  }
  const telemetry_color = TELEMETRY_COLOR_MAP[telemetry];
  const telemetry_bold = telemetry?.includes("!");
  const has_playtime = living_playtime !== undefined
  && living_playtime !== null;
  return (
    <Table.Row className="player-entry" height={2} onClick={() => act('select_player', { who: ckey })}>
      <Table.Cell collapsing textAlign="center">
        <Button icon="circle" color={ckey === selected_ckey ? "green" : null} onClick={() => act('select_player', { who: ckey === selected_ckey ? null : ckey })} />
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Button
          fluid
          style={{
            "color": telemetry_color,
          }}
          bold={telemetry_bold}
          content={telemetry !== undefined ? telemetry : "ERR"}
          onClick={() => act('open_telemetry', { who: ckey })} />
      </Table.Cell>
      <Table.Cell collapsing textAlign="right" bold={telemetry_bold}
        style={{ // enforces overflow ellipsis
          "max-width": "1px",
          "white-space": "nowrap",
          "text-overflow": "ellipsis",
          "overflow": "hidden",
        }}>
        <Button
          fluid
          className="button-ellipsis"
          style={{
            "color": telemetry_color,
            "font-style": !connected ? "italic" : null,
          }}
          content={ckey}
          tooltip={ckey}
          onClick={() => act('open_player_panel', { who: ckey })} />
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Button
          textAlign={!has_playtime ? "center" : "right"}
          fluid
          content={
            has_playtime ? `${living_playtime}h` : "N/A"
          }
          disabled={!has_playtime}
          color={living_playtime >= 12 ? "default" : (living_playtime >= 1 ? "orange" : "danger")}
          onClick={() => act('open_hours', { who: ckey })} />
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Button
          style={{
            "padding": "0px 2px",
          }}
          content={<Box style={{ "transform": "translateY(2.5px)" }} className={`antag-hud16x16 antag-hud-${antag_hud}`} />}
          tooltip={has_mind ? "Open Traitor Panel" : "Initialize Mind"}
          onClick={() => act(has_mind ? 'open_traitor_panel' : 'init_mind', { who: ckey })}
        />
      </Table.Cell>
      <Table.Cell collapsing textAlign="center"
        bold={jobIsHead(job)}
        color={jobToColor(job)}
        style={ellipsis_style}>
        <TooltipWrap text={job} />
      </Table.Cell>
      <Table.Cell
        bold={jobIsHead(job)}
        style={ellipsis_style}>
        <Button
          fluid
          className="button-ellipsis"
          content={`${real_name}${(real_name === name ? "" : ` (as ${name})`)}`}
          tooltip={`${real_name}${(real_name === name ? "" : ` (as ${name})`)}`}
          style={{
            "color": jobToColor(job),
          }}
          onClick={() => act('pm', { who: ckey })}
        />
      </Table.Cell>
      <Table.Cell collapsing textAlign="center" style={{
        "min-width": "12.5em", // prevent layout shift
      }}>
        <Button
          fluid
          tooltip="VV"
          onClick={() => act('open_view_variables', { who: ckey })}
          content={
            <Box inline style={{ "width": "100%" }}>
              {oxydam !== undefined ? (
                <Box inline style={{ "display": "inline-flex", "align-items": "center", "width": "100%" }}>
                  <ColorBox
                    color={healthToColor(
                      oxydam,
                      toxdam,
                      burndam,
                      brutedam)} />
                  <Box inline style={{ "flex": "1" }} />
                  <Box inline style={{ "overflow": "hidden" }}>
                    <HealthStat type="oxy" value={oxydam} />
                    {'/'}
                    <HealthStat type="toxin" value={toxdam} />
                    {'/'}
                    <HealthStat type="burn" value={burndam} />
                    {'/'}
                    <HealthStat type="brute" value={brutedam} />
                  </Box>
                </Box>
              ) : (
                health !== undefined ? (
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
                ) : (
                  <Box inline>
                    N/A
                  </Box>
                )
              )}
            </Box>
          }
        />
      </Table.Cell>
      <Table.Cell collapsing style={ellipsis_style}>
        <Button
          fluid
          className="button-ellipsis"
          disabled={!position}
          content={position || 'Nullspace (wtf)'}
          tooltip={"Follow player - " + position}
          onClick={() => act('follow', { who: ckey })} />
      </Table.Cell>
    </Table.Row>
  );
};

const TooltipWrap = (props) => {
  return (
    <Tooltip content={props.text}>
      <span {...props}>{props.text}</span>
    </Tooltip>
  );
};
