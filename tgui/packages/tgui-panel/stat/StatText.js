import { useSelector } from 'common/redux';
import { Button, Flex, Box, Section } from 'tgui/components';
import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { Divider, Table } from '../../tgui/components';
import { STAT_TEXT, STAT_BUTTON, STAT_ATOM, STAT_DIVIDER, STAT_BLANK } from './constants';
import { capitalize } from 'common/string';

export const StatText = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  let statPanelData = stat.statInfomation;
  if (!statPanelData) {
    return <Box color="red">Passed stat panel data was null contant coderman (or coderwoman).</Box>;
  }
  let verbs = {};
  if (stat.verbData !== null) {
    verbs = stat.verbData[stat.selectedTab] || {};
  }
  return (
    <div className="StatBorder">
      <Box>
        {statPanelData
          ? Object.keys(statPanelData)
            .sort((a, b) => {
              return StatTagToPriority(statPanelData[b].tag) - StatTagToPriority(statPanelData[a].tag);
            })
            .map(
              (key) =>
                !!statPanelData[key] &&
                ((statPanelData[key].type === STAT_TEXT && <StatTextText title={key} text={statPanelData[key].text} />) ||
                  (statPanelData[key].type === STAT_BUTTON && (
                    <StatTextButton
                      title={key}
                      text={statPanelData[key].text}
                      action_id={statPanelData[key].action}
                      params={statPanelData[key].params}
                      multirow={statPanelData[key].multirow}
                      buttons={statPanelData[key].buttons}
                    />
                  )) ||
                  (statPanelData[key].type === STAT_ATOM && (
                    <StatTextAtom atom_ref={key} atom_name={statPanelData[key].text} atom_tag={statPanelData[key].tag} />
                  )) ||
                  (statPanelData[key].type === STAT_DIVIDER && <StatTextDivider />) ||
                  (statPanelData[key].type === STAT_BLANK && <br />))
            )
          : 'No data'}
        {Object.keys(verbs).map((verb) => (
          <StatTextVerb key={verb} title={verb} action_id={verbs[verb].action} params={verbs[verb].params} />
        ))}
      </Box>
    </div>
  );
};

const StatTagToPriority = (text) => {
  switch (text) {
    case "You":
      return 11;
    case 'Human':
      return 10;
    case 'Mob':
      return 9;
    case 'Structure':
      return 8;
    case 'Machinery':
      return 7;
    case 'Item':
      return 6;
    case 'Turf':
      return 4;
  }
  return 5;
};

const StatTagToClassName = (text) => {
  switch (text) {
    case "You":
      return "StatAtomTag Self";
    case 'Turf':
      return 'StatAtomTag Turf';
    case 'Human':
      return 'StatAtomTag Human';
    case 'Mob':
      return 'StatAtomTag Mob';
    case 'Structure':
      return 'StatAtomTag Structure';
    case 'Machinery':
      return 'StatAtomTag Machinery';
    case 'Item':
      return 'StatAtomTag Item';
  }
  return 'StatAtomTag Other';
};

/*
 * FLEX COMPATIBLE
 */

export const StatTextText = (props, context) => {
  const { title, text } = props;
  return (
    <Flex.Item mt={1}>
      <b>{title}: </b>
      {text}
    </Flex.Item>
  );
};

export const StatTextButton = (props, context) => {
  const { title, text, action_id, params = [], multirow = false, buttons = [] } = props;
  return (
    <Flex.Item mt={1}>
      <Button
        width="100%"
        overflowX="hidden"
        onClick={() =>
          Byond.sendMessage('stat/pressed', {
            action_id: action_id,
            params: params,
          })
        }
        color="transparent">
        {!multirow ? (
          <Flex direction="row">
            <Flex.Item bold>{title}</Flex.Item>
            {buttons.map((buttonInfo) => (
              <Flex.Item shrink={1} key={buttonInfo}>
                <Button
                  color={buttonInfo['color']}
                  onClick={(e) => {
                    e.stopPropagation();
                    Byond.sendMessage('stat/pressed', {
                      action_id: buttonInfo['action_id'],
                      params: buttonInfo['params'],
                    });
                  }}>
                  {buttonInfo['title']}
                </Button>
              </Flex.Item>
            ))}
            <Flex.Item grow={1} ml={1.5} style={{
                'white-space': 'normal',
            }}>
              {text}
            </Flex.Item>
          </Flex>
        ) : (
          <>
            <Flex bold direction="row">
              <Flex.Item grow={1}>{title}</Flex.Item>
              {buttons.map((buttonInfo) => (
                <Flex.Item shrink={1} key={buttonInfo}>
                  <Button
                    color={buttonInfo['color']}
                    onClick={(e) => {
                      e.stopPropagation();
                      Byond.sendMessage('stat/pressed', {
                        action_id: buttonInfo['action_id'],
                        params: buttonInfo['params'],
                      });
                    }}>
                    {buttonInfo['title']}
                  </Button>
                </Flex.Item>
              ))}
            </Flex>
            <Box
              style={{
                'white-space': 'normal',
              }}>
              {text}
            </Box>
          </>
        )}
      </Button>
    </Flex.Item>
  );
};

let janky_storage = null; // Because IE sucks
const storeAtomRef = (value) => {
  janky_storage = value;
};
const retrieveAtomRef = () => janky_storage;

export const StatTextAtom = (props, context) => {
  const { atom_name, atom_ref, atom_tag } = props;

  storeAtomRef(null);

  return (
    <Flex.Item mt={0.5}>
      <Button
        pl={0}
        width="100%"
        overflowX="hidden"
        draggable
        onDragStart={(e) => {
          // e.dataTransfer.setData("text", atom_ref);
          /*
          Apparently can't use "text/plain" because IE, this took me way too
          long to figure out.

          Apparently, even if you do "text", IE will also put the stored data
          into your clipboard, overriding whatever was there. Fuck this.
          Leaving it here for reference, in case somebody smarter than me
          knows a way to fix it
          */
          storeAtomRef(atom_ref);
        }}
        onDragOver={(e) => {
          e.preventDefault();
        }}
        onDrop={(e) => {
          // let other_atom_ref = e.dataTransfer.getData("text");
          let other_atom_ref = retrieveAtomRef();
          if (other_atom_ref) {
            e.preventDefault();
            storeAtomRef(null);
            Byond.sendMessage('stat/pressed', {
              action_id: 'atomDrop',
              params: {
                ref: atom_ref,
                ref_other: other_atom_ref,
              },
            });
          }
        }}
        onDragEnd={(e) => {
          storeAtomRef(null);
        }}
        onClick={(e) =>
          Byond.sendMessage('stat/pressed', {
            action_id: 'atomClick',
            params: {
              ref: atom_ref,
            },
          })
        }
        color="transparent">
        <div className="StatAtomElement">
          <Flex direction="row" wrap="wrap">
            <Flex.Item basis={6} mr={2}>
              <div className={StatTagToClassName(atom_tag)}>{atom_tag}</div>
            </Flex.Item>
            <Flex.Item grow={1}>{capitalize(atom_name)}</Flex.Item>
          </Flex>
        </div>
      </Button>
    </Flex.Item>
  );
};

export const StatTextDivider = (props, context) => {
  return <Divider />;
};

export const StatTextVerb = (props, context) => {
  const { title, action_id, params = [] } = props;
  return (
    <Box shrink={1} inline width="200px">
      <Button
        content={title}
        onClick={() =>
          Byond.sendMessage('stat/pressed', {
            action_id: action_id,
            params: params,
          })
        }
        color="transparent"
        fluid
      />
    </Box>
  );
};

// =======================
// Non-Flex Support
// =======================

export const HoboStatText = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  let statPanelData = stat.statInfomation;
  if (!statPanelData) {
    return <Box color="red">Passed stat panel data was null contant coderman (or coderwoman).</Box>;
  }
  let verbs = {};
  if (stat.verbData !== null) {
    verbs = stat.verbData[stat.selectedTab] || {};
  }
  return (
    <div className="StatBorder">
      <Section>
        {statPanelData
          ? Object.keys(statPanelData).map(
            (key) =>
              !!statPanelData[key] &&
              ((statPanelData[key].type === STAT_TEXT && <HoboStatTextText title={key} text={statPanelData[key].text} />) ||
                (statPanelData[key].type === STAT_BUTTON && (
                  <HoboStatTextButton
                    title={key}
                    text={statPanelData[key].text}
                    action_id={statPanelData[key].action}
                    params={statPanelData[key].params}
                  />
                )) ||
                (statPanelData[key].type === STAT_ATOM && (
                  <HoboStatTextAtom atom_ref={key} atom_name={statPanelData[key].text} />
                )) ||
                (statPanelData[key].type === STAT_DIVIDER && <StatTextDivider />) ||
                (statPanelData[key].type === STAT_BLANK && <br />) ||
                null)
          )
          : 'No data'}
        {Object.keys(verbs).map((verb) => (
          <Box wrap="wrap" key={verb} align="left">
            <StatTextVerb title={verb} action_id={verbs[verb].action} params={verbs[verb].params} />
          </Box>
        ))}
      </Section>
    </div>
  );
};

export const HoboStatTextText = (props, context) => {
  const { title, text } = props;
  return (
    <Box>
      <b>{title}: </b>
      {text}
    </Box>
  );
};

export const HoboStatTextButton = (props, context) => {
  const { title, text, action_id, params = [] } = props;
  return (
    <Box>
      <Button
        onClick={() =>
          Byond.sendMessage('stat/pressed', {
            action_id: action_id,
            params: params,
          })
        }
        color="transparent">
        <b>{title}: </b>
        {text}
      </Button>
    </Box>
  );
};

export const HoboStatTextAtom = (props, context) => {
  const { atom_name, atom_icon, atom_ref } = props;
  return (
    <Box>
      <Button
        onClick={(e) =>
          Byond.sendMessage('stat/pressed', {
            action_id: 'atomClick',
            params: {
              ref: atom_ref,
            },
          })
        }
        color="transparent">
        <Table>
          <Table.Row>
            <Table.Cell>
              <img
                src={`data:image/jpeg;base64,${atom_icon}`}
                style={{
                  'vertical-align': 'middle',
                  'horizontal-align': 'middle',
                }}
              />
            </Table.Cell>
            <Table.Cell ml={1}>{atom_name}</Table.Cell>
          </Table.Row>
        </Table>
      </Button>
    </Box>
  );
};
