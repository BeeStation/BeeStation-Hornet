import { toFixed } from 'common/math';
import { useDispatch, useSelector } from 'common/redux';
import { Fragment } from 'inferno';
import { Button, Flex, Knob, Tabs, Box, Section } from 'tgui/components';
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
      <Flex.Item
        color="red">
        Passed stat panel data was null contant coderman (or coderwoman).
      </Flex.Item>
    );
  }
  let verbs = Object.keys(statPanelData)
    .filter(element => !!statPanelData[element]
      && statPanelData[element].type === STAT_VERB);
  return (
    <Flex.Item mt={1}>
      <Flex direction="column">
        <div className="StatBorder">
          <Section>
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
                    atom_name={statPanelData[key].text}
                    atom_icon={statPanelData[key].icon} />
                  || statPanelData[key].type === STAT_DIVIDER
                  && <StatTextDivider />
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
                    <StatTextVerb
                      key={verb}
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

export const StatTextText = (props, context) => {
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
        color="transparent"
        textColor={settings.statButtonColour}>
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
  const settings = useSettings(context);
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
        textColor={settings.statButtonColour}
        fluid />
    </Flex.Item>
  );
};
