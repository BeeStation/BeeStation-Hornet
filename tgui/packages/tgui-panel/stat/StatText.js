import { toFixed } from 'common/math';
import { useDispatch, useSelector } from 'common/redux';
import { Fragment } from 'inferno';
import { Button, Flex, Knob, Tabs, Box, Section } from 'tgui/components';
import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { sendMessage } from 'tgui/backend';
import { Divider } from '../../tgui/components';

export const StatText = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  let statPanelData = stat.statInfomation;
  return (
    <Flex.Item mt={1}>
      <Flex direction="column">
        <div className="StatBorder">
          <Section>
            {statPanelData
              ? Object.keys(statPanelData).map(key => (
                <Flex.Item mt={1}>
                  {statPanelData[key]
                    ?statPanelData[key].type === 0
                      ?<StatText_text
                      title={key}
                        text={statPanelData[key].text} />
                      :statPanelData[key].type === 1
                        ? <StatText_button
                          title={key}
                          text={statPanelData[key].text}
                          action_id={statPanelData[key].action}
                          params={statPanelData[key].params} />
                        :statPanelData[key].type === 2
                          ? <StatText_atom
                            atom_ref={key}
                            atom_name={statPanelData[key].text}
                            atom_icon={statPanelData[key].icon} />
                          : statPanelData[key].type === 3
                            ? <StatText_divider />
                            : null
                    :null
                  }
                </Flex.Item>
              ))
              : "No data"}
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
    <Fragment>
      {title}:
      <b>
        {text}
      </b>
    </Fragment>
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
    <Fragment>
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
    </Fragment>
  );
};

export const StatText_atom = (props, context) => {
  const {
    atom_name,
    atom_icon,
    atom_ref,
  } = props;
  return (
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
  );
};

export const StatText_divider = (props, context) => {
  return (
    <Divider />
  );
};
