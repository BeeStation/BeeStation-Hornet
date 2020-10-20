import { toFixed } from 'common/math';
import { useDispatch, useSelector } from 'common/redux';
import { Fragment } from 'inferno';
import { Button, Flex, Knob, Tabs, Box, Section } from 'tgui/components';
import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { sendMessage } from 'tgui/backend';
import { Divider, Grid, Table } from '../../tgui/components';
import { STAT_TEXT, STAT_BUTTON, STAT_ATOM, STAT_DIVIDER, STAT_VERB } from './constants'

export const StatText = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  let statPanelData = stat.statInfomation;
  if(!statPanelData)
  {
    return(
      <Flex.Item
        color="red">
        Passed stat panel data was null contant coderman (or coderwoman).
      </Flex.Item>
    );
  }
  let verbs = Object.keys(statPanelData)
    .filter(element => !!statPanelData[element] && statPanelData[element].type === STAT_VERB);
  return (
    <Flex.Item mt={1}>
      <Flex direction="column">
        <div className="StatBorder">
          <Section>
            {statPanelData
              ? Object.keys(statPanelData).map(key => (
                !!statPanelData[key] && (
                  statPanelData[key].type === STAT_TEXT && <StatText_text
                    title={key}
                    text={statPanelData[key].text} />
                  || statPanelData[key].type === STAT_BUTTON && <StatText_button
                    title={key}
                    text={statPanelData[key].text}
                    action_id={statPanelData[key].action}
                    params={statPanelData[key].params} />
                  || statPanelData[key].type === STAT_ATOM && <StatText_atom
                    atom_ref={key}
                    atom_name={statPanelData[key].text}
                    atom_icon={statPanelData[key].icon} />
                  || statPanelData[key].type === STAT_DIVIDER && <StatText_divider />
                  || null
                )
              ))
              : "No data"}
              {!!verbs.length && (
                <Flex.Item>
                  <Flex
                    wrap="wrap"
                    align="left">
                    {verbs.map(verb => (
                      <StatText_verb
                        title={verb}
                        action_id={statPanelData[verb].action}
                        params={statPanelData[verb].params} />
                    ))}
                  </Flex>
                </Flex.Item>
              )}
          </Section>
        </div>
      </Flex>
    </Flex.Item>
  );
};

export const StatText_text = (props, context) => {
  const {
    title,
    text,
  } = props;
  return (
    <Flex.Item mt={1}>
      {title}:
      <b>
        {text}
      </b>
    </Flex.Item>
  );
};

export const StatText_button = (props, context) => {
  const {
    title,
    text,
    action_id,
    params = [],
  } = props;
  return (
    <Flex.Item mt={1}>
      <b>
        {title}:
      </b>
      <Button
        content={text}
        onClick={() => sendMessage({
          type: 'stat/pressed',
          payload: {
            action_id: action_id,
            params: params,
          },
        })}
        color="transparent" />
    </Flex.Item>
  );
};

export const StatText_atom = (props, context) => {
  const {
    atom_name,
    atom_icon,
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
        <Flex>
          <Flex.Item>
            <img
              src={`data:image/jpeg;base64,${atom_icon}`}
              style={{
                'vertical-align': 'middle',
                'horizontal-align': 'middle',
              }} />
          </Flex.Item>
          <Flex.Item ml={1}>
            {atom_name}
          </Flex.Item>
        </Flex>
      </Button>
    </Flex.Item>
  );
};

export const StatText_divider = (props, context) => {
  return (
    <Divider />
  );
};

export const StatText_verb = (props, context) => {
  const {
    title,
    action_id,
    params = [],
  } = props;
  return (
    <Flex.Item
      shrink={1}
      basis="200px">
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
    </Flex.Item>
  );
};
