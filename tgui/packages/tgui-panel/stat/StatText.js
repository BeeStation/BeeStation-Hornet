import { useSelector } from 'common/redux';
import { Button, Flex, Knob, Tabs, Box, Section, Fragment } from 'tgui/components';
import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { sendMessage } from 'tgui/backend';
import { Divider, Grid, Table } from '../../tgui/components';
import { STAT_TEXT, STAT_BUTTON, STAT_ATOM, STAT_DIVIDER, STAT_VERB } from './constants';

export const StatText = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  let statPanelData = stat.statInfomation;
  if (!statPanelData)
  {
    return (
      <Box color="red">
        Passed stat panel data was null contant coderman (or coderwoman).
      </Box>
    );
  }
  let verbs = Object.keys(statPanelData)
    .filter(element => !!statPanelData[element]
      && statPanelData[element].type === STAT_VERB);
  return (
    <div className="StatBorder">
      <Box>
        {statPanelData
          ? Object.keys(statPanelData).map(key => (
            !!statPanelData[key] && (
              statPanelData[key].type === STAT_TEXT && <StatTextText
                title={key}
                text={statPanelData[key].text} />
              || statPanelData[key].type === STAT_BUTTON && <StatTextButton
                title={key}
                text={statPanelData[key].text}
                action_id={statPanelData[key].action}
                params={statPanelData[key].params} />
              || statPanelData[key].type === STAT_ATOM && <StatTextAtom
                atom_ref={key}
                atom_name={statPanelData[key].text} />
              || statPanelData[key].type === STAT_DIVIDER
              && <StatTextDivider />
              || null
            )
          ))
          : "No data"}
        {!!verbs.length && (
          verbs.map(verb => (
            <StatTextVerb
              key={verb}
              title={verb}
              action_id={statPanelData[verb].action}
              params={statPanelData[verb].params} />
          ))
        )}
      </Box>
    </div>
  );
};

/*
 * FLEX COMPATIBLE
*/

export const StatTextText = (props, context) => {
  const {
    title,
    text,
  } = props;
  return (
    <Flex.Item mt={1}>
      <b>
        {title}:{" "}
      </b>
      {text}
    </Flex.Item>
  );
};

export const StatTextButton = (props, context) => {
  const {
    title,
    text,
    action_id,
    params = [],
  } = props;
  const settings = useSettings(context);
  return (
    <Flex.Item mt={1}>
      <Button
        onClick={() => sendMessage({
          type: 'stat/pressed',
          payload: {
            action_id: action_id,
            params: params,
          },
        })}
        color="transparent">
        <b>
          {title}:{" "}
        </b>
        {text}
      </Button>
    </Flex.Item>
  );
};

export const StatTextAtom = (props, context) => {
  const {
    atom_name,
    atom_ref,
  } = props;
  return (
    <Flex.Item mt={1}>
      <Button
        onClick={e => sendMessage({
          type: 'stat/pressed',
          payload: {
            action_id: 'atomClick',
            params: {
              ref: atom_ref,
            },
          },
        })}
        color="transparent">
        {atom_name}
      </Button>
    </Flex.Item>
  );
};

export const StatTextDivider = (props, context) => {
  return (
    <Divider />
  );
};

export const StatTextVerb = (props, context) => {
  const {
    title,
    action_id,
    params = [],
  } = props;
  return (
    <Box
      shrink={1}
      inline
      width="200px">
      <Button
        content={title}
        onClick={() => sendMessage({
          type: 'stat/pressed',
          payload: {
            action_id: action_id,
            params: params,
          },
        })}
        color="transparent"
        fluid />
    </Box>
  );
};

// =======================
// Non-Flex Support
// =======================

export const HoboStatText = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  let statPanelData = stat.statInfomation;
  if (!statPanelData)
  {
    return (
      <Box color="red">
        Passed stat panel data was null contant coderman (or coderwoman).
      </Box>
    );
  }
  let verbs = Object.keys(statPanelData)
    .filter(element => !!statPanelData[element]
      && statPanelData[element].type === STAT_VERB);
  return (
    <div className="StatBorder">
      <Section>
        {statPanelData
          ? Object.keys(statPanelData).map(key => (
            !!statPanelData[key] && (
              statPanelData[key].type === STAT_TEXT && <HoboStatTextText
                title={key}
                text={statPanelData[key].text} />
              || statPanelData[key].type === STAT_BUTTON && <HoboStatTextButton
                title={key}
                text={statPanelData[key].text}
                action_id={statPanelData[key].action}
                params={statPanelData[key].params} />
              || statPanelData[key].type === STAT_ATOM && <HoboStatTextAtom
                atom_ref={key}
                atom_name={statPanelData[key].text} />
              || statPanelData[key].type === STAT_DIVIDER
              && <StatTextDivider />
              || null
            )
          ))
          : "No data"}
        {!!verbs.length && (
          <Box
            wrap="wrap"
            align="left">
            {verbs.map(verb => (
              <StatTextVerb
                key={verb}
                title={verb}
                action_id={statPanelData[verb].action}
                params={statPanelData[verb].params} />
            ))}
          </Box>
        )}
      </Section>
    </div>
  );
};

export const HoboStatTextText = (props, context) => {
  const {
    title,
    text,
  } = props;
  return (
    <Box>
      <b>
        {title}:{" "}
      </b>
      {text}
    </Box>
  );
};

export const HoboStatTextButton = (props, context) => {
  const {
    title,
    text,
    action_id,
    params = [],
  } = props;
  const settings = useSettings(context);
  return (
    <Box>
      <Button
        onClick={() => sendMessage({
          type: 'stat/pressed',
          payload: {
            action_id: action_id,
            params: params,
          },
        })}
        color="transparent">
        <b>
          {title}:{" "}
        </b>
        {text}
      </Button>
    </Box>
  );
};

export const HoboStatTextAtom = (props, context) => {
  const {
    atom_name,
    atom_icon,
    atom_ref,
  } = props;
  return (
    <Box>
      <Button
        onClick={e => sendMessage({
          type: 'stat/pressed',
          payload: {
            action_id: 'atomClick',
            params: {
              ref: atom_ref,
            },
          },
        })}
        color="transparent">
        <Table>
          <Table.Row>
            <Table.Cell>
              <img
                src={`data:image/jpeg;base64,${atom_icon}`}
                style={{
                  'vertical-align': 'middle',
                  'horizontal-align': 'middle',
                }} />
            </Table.Cell>
            <Table.Cell ml={1}>
              {atom_name}
            </Table.Cell>
          </Table.Row>
        </Table>
      </Button>
    </Box>
  );
};
