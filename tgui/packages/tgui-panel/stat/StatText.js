import { useSelector } from 'common/redux';
import { Button, Flex, Box, Section } from 'tgui/components';
import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { Divider, Table } from '../../tgui/components';
import { STAT_TEXT, STAT_BUTTON, STAT_ATOM, STAT_DIVIDER, STAT_BLANK } from './constants';

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
          ? Object.keys(statPanelData).map(
            (key) =>
              !!statPanelData[key] &&
              ((statPanelData[key].type === STAT_TEXT && <StatTextText title={key} text={statPanelData[key].text} />) ||
                (statPanelData[key].type === STAT_BUTTON && (
                  <StatTextButton
                    title={key}
                    text={statPanelData[key].text}
                    action_id={statPanelData[key].action}
                    params={statPanelData[key].params}
                  />
                )) ||
                (statPanelData[key].type === STAT_ATOM && (
                  <StatTextAtom atom_ref={key} atom_name={statPanelData[key].text} />
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
  const { title, text, action_id, params = [] } = props;
  return (
    <Flex.Item mt={1}>
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
    </Flex.Item>
  );
};

let janky_storage = null; // Because IE sucks
const storeAtomRef = (value) => {
  janky_storage = value;
};
const retrieveAtomRef = () => janky_storage;

export const StatTextAtom = (props, context) => {
  const { atom_name, atom_ref } = props;

  storeAtomRef(null);

  return (
    <Flex.Item mt={1}>
      <Button
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
        {atom_name}
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
